import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:showcaseview/showcaseview.dart';
import '../coach_marks/showcase_keys.dart';
import '../coach_marks/showcase_provider.dart';
import '../utils/app_logger.dart';
import '../widgets/subtopic_widget.dart';
import '../services/updateprogress.dart';
import '../utils/subTopicNavigation.dart';
import '../widgets/gamesucesswidget.dart';
import 'package:provider/provider.dart';
import '../utils/audio/audio_integration.dart';
import '../utils/game_launcher.dart';
import '../xp_manager.dart';
import '../widgets/earth_unlock_animation.dart';

class PuzzleScreen extends StatefulWidget {
  final String subtopicId;
  final String nextSubtopicId;
  final String nextSubtopicTitle;
  final String nextReadingContent;
  final String subject;
  final int grade;
  final int unitId;
  final String unitTitle;
  final String subtopicTitle;
  final String userId;

  const PuzzleScreen({
    super.key,
    required this.subtopicId,
    required this.nextSubtopicId,
    required this.nextSubtopicTitle,
    required this.nextReadingContent,
    required this.subject,
    required this.grade,
    required this.unitId,
    required this.unitTitle,
    required this.subtopicTitle,
    required this.userId,
  });

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> quizQuestions = [];
  Map<String, dynamic>? subtopicNav;

  String selectedImage = '';
  List<bool> answered = [];
  Map<int, int> placedMap = {};
  List<int> _shuffledIndices = [];
  late AnimationController _glowController;
  bool puzzleCompleted = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _completionHandled = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    getSubtopicNavigationInfo(
      subject: widget.subject,
      grade: widget.grade,
      subtopicId: widget.subtopicId,
    ).then((value) {
      setState(() {
        subtopicNav = value;
      });
    });
    _randomizeImage();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _shuffledIndices = List.generate(9, (index) => index)..shuffle();

    // Initialize showcase after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final showcaseService =
          Provider.of<ShowcaseService>(context, listen: false);
      if (!showcaseService.hasCompletedInitialShowcase) {
        showcaseService.startGameScreenShowcase(context);
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _randomizeImage() {
    List<String> images = ['assets/cherry.png', 'assets/mushroom.png'];
    selectedImage = images[Random().nextInt(images.length)];
  }

  Future<void> _loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/content.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    List<Map<String, dynamic>> allQuestions =
        List<Map<String, dynamic>>.from(data['questions']);
    List<int> quizPool = [];

    for (var subject in data['subjects']) {
      for (var grade in subject['grades']) {
        for (var unit in grade['units']) {
          for (var subtopic in unit['subtopics']) {
            if (subtopic['subtopic_id'] == widget.subtopicId) {
              quizPool = List<int>.from(subtopic['quizPool']);
              break;
            }
          }
        }
      }
    }

    List<Map<String, dynamic>> selectedQuestions =
        allQuestions.where((q) => quizPool.contains(q['id'] as int)).toList();
    selectedQuestions.shuffle();

    // Make sure we have enough questions or repeat questions to fill the puzzle
    if (selectedQuestions.isEmpty) {
      // If no questions found, create dummy questions to avoid errors
      AppLogger.w(
          "No questions found for subtopic ${widget.subtopicId}. Creating dummy questions.");
      selectedQuestions = List.generate(
          9,
          (index) => {
                'id': index,
                'question': 'Dummy question $index',
                'answers': ['Option A', 'Option B', 'Option C', 'Option D'],
                'correct_answer': 'Option A'
              });
    } else if (selectedQuestions.length < 9) {
      // If we have some questions but less than 9, repeat them to fill the grid
      AppLogger.w(
          "Only ${selectedQuestions.length} questions found for subtopic ${widget.subtopicId}. Repeating questions.");
      final originalQuestions =
          List<Map<String, dynamic>>.from(selectedQuestions);
      while (selectedQuestions.length < 9) {
        selectedQuestions.addAll(originalQuestions
            .take(min(9 - selectedQuestions.length, originalQuestions.length)));
      }
    }

    // Take exactly 9 questions for the puzzle
    selectedQuestions = selectedQuestions.take(9).toList();

    setState(() {
      quizQuestions = selectedQuestions;
      answered = List.filled(9, false);
    });
  }

  int getDummyMarks() {
    return 10; // return a dummy score
  }

  void _showQuestionDialog(int index) {
    // Validate index to prevent range errors
    if (index < 0 || index >= quizQuestions.length) {
      AppLogger.e(
          "Attempted to access question at invalid index: $index (available: ${quizQuestions.length})");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Can't load this question. Try another piece."),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final question = quizQuestions[index]['question'];
    final List<String> answers =
        List<String>.from(quizQuestions[index]['answers']);
    final String correctAnswer = quizQuestions[index]['correct_answer'];
    String? selectedAnswer;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Question ${index + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...answers.map((answer) {
                    final bool isSelected = selectedAnswer == answer;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: isSubmitting
                            ? null
                            : () {
                                setDialogState(() {
                                  selectedAnswer = answer;
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  answer,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            isSubmitting ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isSubmitting || selectedAnswer == null
                            ? null
                            : () async {
                                setDialogState(() {
                                  isSubmitting = true;
                                });

                                await Future.delayed(
                                    const Duration(milliseconds: 500));

                                if (selectedAnswer == correctAnswer) {
                                  Navigator.pop(context);
                                  setState(() {
                                    answered[index] = true;
                                  });
                                  _checkPuzzleCompletion();
                                } else {
                                  setDialogState(() {
                                    isSubmitting = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Incorrect answer, try again!'),
                                      backgroundColor: Colors.red.shade400,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _checkPuzzleCompletion() {
    if (answered.every((a) => a) && placedMap.length == 9) {
      _onPuzzleCompleted();
    }
  }

  Future<void> _goToNextLesson() async {
    try {
      // Check if the widget is mounted before using context
      if (!mounted) {
        AppLogger.w("Widget not mounted during navigation");
        return;
      }

      // Check if navigation data is available
      if (widget.nextSubtopicId.isEmpty || widget.nextReadingContent.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Unable to load next lesson. Please try again.")),
          );
        }
        AppLogger.e(
            "Navigation data unavailable: nextSubtopicId=${widget.nextSubtopicId.isNotEmpty}, nextReadingContent=${widget.nextReadingContent.isNotEmpty}");
        return;
      }

      // Direct navigation to next lesson
      navigateToNextLesson(
        context: context,
        subject: widget.subject,
        grade: widget.grade,
        unitId: widget.unitId,
        unitTitle: widget.unitTitle,
        nextSubtopicId: widget.nextSubtopicId,
        nextSubtopicTitle: widget.nextSubtopicTitle,
        nextReadingContent: widget.nextReadingContent,
        userId: widget.userId,
      );
    } catch (e) {
      AppLogger.e("Error in _goToNextLesson: $e");
      // Only show error if context is still valid
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    }
  }

  Future<void> _onPuzzleCompleted() async {
    if (_completionHandled) return;

    setState(() {
      puzzleCompleted = true;
      _completionHandled = true;
    });

    // Use the new AudioIntegration instead of direct AudioPlayer
    await AudioIntegration.handleGameComplete();

    // Handle game completion to update progress and award XP
    try {
      // Update progress in Firebase
      await markQuizAsCompleted(
        subtopicId: widget.subtopicId,
        marksEarned: 10,
      );

      await updateResumePoint(
        userId: widget.userId,
        subject: widget.subject,
        grade: 'Grade ${widget.grade}',
        unitId: widget.unitId,
        unitName: widget.unitTitle,
        subtopicId: widget.subtopicId,
        subtopicName: widget.subtopicTitle,
        actionType: 'game',
        actionState: 'completed',
      );

      // Award XP
      final xpManager = Provider.of<XPManager>(context, listen: false);
      xpManager.addXP(10, onLevelUp: (newLevel) {
        EarthUnlockAnimation.show(
          context,
          newLevel,
          widget.subject,
          widget.subtopicTitle,
          xpManager.currentXP,
        );
      });

      // Note: No need to show a dialog here as the GameSuccessMessage component
      // already handles displaying completion UI at the bottom of the screen
    } catch (e) {
      AppLogger.e('Error during puzzle completion: $e');
    }

    debugPrint('[Puzzle] : Quiz progress saved for ${widget.subtopicId}');
  }

  @override
  Widget build(BuildContext context) {
    double pieceSize = 100;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Puzzle Challenge',
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: theme.primaryColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: quizQuestions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          puzzleCompleted
                              ? '🎉 Puzzle Completed!'
                              : 'Complete the Puzzle!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Collapsible Instructions Container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            title: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'How to Play',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInstructionStep(
                                      '1. Click on a puzzle piece to answer a question',
                                      Icons.touch_app,
                                      theme,
                                    ),
                                    _buildInstructionStep(
                                      '2. Answer correctly to unlock the piece',
                                      Icons.check_circle,
                                      theme,
                                    ),
                                    _buildInstructionStep(
                                      '3. Drag and drop pieces to complete the puzzle',
                                      Icons.drag_indicator,
                                      theme,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Puzzle Grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Puzzle Board',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: pieceSize * 3,
                              height: pieceSize * 3,
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemCount: 9,
                                itemBuilder: (context, index) {
                                  final placedIndex = placedMap[index];
                                  return DragTarget<int>(
                                    onAccept: (pieceIndex) {
                                      setState(() {
                                        placedMap[index] = pieceIndex;
                                      });
                                      _checkPuzzleCompletion();
                                    },
                                    onWillAccept: (pieceIndex) =>
                                        pieceIndex == index,
                                    builder: (context, _, __) {
                                      return Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: placedIndex != null
                                                ? theme.primaryColor
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Stack(
                                          children: [
                                            SizedBox(
                                              width: pieceSize,
                                              height: pieceSize,
                                              child: placedIndex != null
                                                  ? PuzzlePiece(
                                                      imagePath: selectedImage,
                                                      index: placedIndex,
                                                      size: pieceSize)
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                    ),
                                            ),
                                            if (placedIndex == null)
                                              Center(
                                                child: Icon(
                                                  Icons.add_circle_outline,
                                                  color: theme.primaryColor
                                                      .withOpacity(0.3),
                                                  size: 30,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      if (puzzleCompleted)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: GameSuccessMessage(
                            onNext: _goToNextLesson,
                            nextSubtopicId: widget.nextSubtopicId,
                            nextSubtopicTitle: widget.nextSubtopicTitle,
                            nextReadingContent: widget.nextReadingContent,
                            subject: widget.subject,
                            grade: widget.grade,
                            unitId: widget.unitId,
                            unitTitle: widget.unitTitle,
                            userId: widget.userId,
                          ),
                        ),

                      if (!puzzleCompleted)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Available Pieces',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                children: _shuffledIndices.map((index) {
                                  if (placedMap.containsValue(index))
                                    return const SizedBox.shrink();

                                  return answered[index]
                                      ? Draggable<int>(
                                          data: index,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: theme.primaryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: PuzzlePiece(
                                                  imagePath: selectedImage,
                                                  index: index,
                                                  size: pieceSize),
                                            ),
                                          ),
                                          childWhenDragging: PuzzlePiece(
                                            imagePath: selectedImage,
                                            index: index,
                                            opacity: 0.5,
                                            size: pieceSize,
                                          ),
                                          child: Stack(
                                            children: [
                                              GlowingPuzzlePiece(
                                                imagePath: selectedImage,
                                                index: index,
                                                controller: _glowController,
                                                size: pieceSize,
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Icon(
                                                  Icons.drag_indicator,
                                                  color: theme.primaryColor,
                                                  size: 24,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () =>
                                              _showQuestionDialog(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: theme.primaryColor
                                                    .withOpacity(0.3),
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Stack(
                                              children: [
                                                PuzzlePiece(
                                                  imagePath: selectedImage,
                                                  index: index,
                                                  opacity: 0.5,
                                                  size: pieceSize,
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Icon(
                                                    Icons.question_mark,
                                                    color: theme.primaryColor,
                                                    size: 24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInstructionStep(String text, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Puzzle Piece Widget
class PuzzlePiece extends StatelessWidget {
  final String imagePath;
  final int index;
  final double opacity;
  final double size;

  const PuzzlePiece({
    super.key,
    required this.imagePath,
    required this.index,
    this.opacity = 1.0,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRect(
          child: OverflowBox(
            maxWidth: size * 3,
            maxHeight: size * 3,
            child: Align(
              alignment: _getAlignment(index),
              widthFactor: 1 / 3,
              heightFactor: 1 / 3,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: size * 3,
                height: size * 3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(int index) {
    final row = index ~/ 3;
    final col = index % 3;

    double x = -1.0 + (col * 1.0);
    double y = -1.0 + (row * 1.0);

    return Alignment(x, y);
  }
}

// Glowing Puzzle Piece
class GlowingPuzzlePiece extends StatelessWidget {
  final String imagePath;
  final int index;
  final AnimationController controller;
  final double size;

  const GlowingPuzzlePiece({
    super.key,
    required this.imagePath,
    required this.index,
    required this.controller,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(controller.value * 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: PuzzlePiece(
        imagePath: imagePath,
        index: index,
        size: size,
      ),
    );
  }
}
