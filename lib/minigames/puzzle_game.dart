import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/subtopic_widget.dart';
import '../services/updateprogress.dart';
import '../utils/subTopicNavigation.dart';
import '../widgets/gamesucesswidget.dart';

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
    _shuffledIndices = [0, 1, 2, 3]..shuffle();
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
    selectedQuestions = selectedQuestions.take(4).toList();

    setState(() {
      quizQuestions = selectedQuestions;
      answered = List.filled(4, false);
    });
  }

  int getDummyMarks() {
    return 10; // return a dummy score
  }

  void _showQuestionDialog(int index) {
    final question = quizQuestions[index]['question'];
    final List<String> answers =
        List<String>.from(quizQuestions[index]['answers']);
    final String correctAnswer = quizQuestions[index]['correct_answer'];
    String? selectedAnswer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(question,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: answers.map((answer) {
                return RadioListTile<String>(
                  title: Text(answer),
                  value: answer,
                  groupValue: selectedAnswer,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedAnswer = value;
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedAnswer == correctAnswer) {
                    Navigator.pop(context);
                    setState(() {
                      answered[index] = true;
                    });
                    _checkPuzzleCompletion();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incorrect answer, try again!'),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _checkPuzzleCompletion() {
    if (answered.every((a) => a) && placedMap.length == 4) {
      _onPuzzleCompleted();
    }
  }

  Future<void> _goToNextLesson() async {
    if (subtopicNav == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Unable to load next lesson. Please try again.")),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SubtopicPage(
          subtopic: subtopicNav?['nextSubtopicTitle'],
          subtopicId: subtopicNav?['nextSubtopicId'],
          readingTitle: subtopicNav?['nextReadingTitle'],
          readingContent: subtopicNav?['nextReadingContent'],
          isCompleted: false,
          subject: widget.subject,
          grade: subtopicNav?['nextGrade'],
          unitId: subtopicNav?['nextUnitId'],
          unitTitle: subtopicNav?['nextUnitTitle'],
          userId: widget.userId,
          lastSubtopicofGrade: subtopicNav?['isLastOfGrade'],
          lastSubtopicofUnit: subtopicNav?['isLastOfUnit'],
          lastSubtopicofSubject: subtopicNav?['isLastOfSubject'],
        ),
      ),
    );
  }

  Future<void> _saveProgress() async {
    await handleGameCompletion(
      context: context,
      audioPlayer: _audioPlayer,
      subtopicId: widget.subtopicId,
      userId: widget.userId,
      subject: widget.subject,
      grade: widget.grade,
      unitId: widget.unitId,
      unitTitle: widget.unitTitle,
      subtopicTitle: widget.subtopicTitle,
      lastSubtopicofUnit: subtopicNav?['isLastOfUnit'],
      lastSubtopicofGrade: subtopicNav?['isLastOfGrade'],
      lastSubtopicofSubject: subtopicNav?['isLastOfSubject'],
    );

    debugPrint('[Puzzle] : Saved quiz progress for ${widget.subtopicId}');
  }

  Future<void> _onPuzzleCompleted() async {
    if (_completionHandled) return;

    setState(() {
      puzzleCompleted = true;
      _completionHandled = true;
    });

    await handleGameCompletion(
      context: context,
      audioPlayer: _audioPlayer,
      subtopicId: widget.subtopicId,
      userId: widget.userId,
      subject: widget.subject,
      grade: widget.grade,
      unitId: widget.unitId,
      unitTitle: widget.unitTitle,
      subtopicTitle: widget.subtopicTitle,
      lastSubtopicofUnit: subtopicNav?['isLastOfUnit'] ?? false,
      lastSubtopicofGrade: subtopicNav?['isLastOfGrade'] ?? false,
      lastSubtopicofSubject: subtopicNav?['isLastOfSubject'] ?? false,
    );

    debugPrint('[Puzzle] : Quiz progress saved for ${widget.subtopicId}');
  }

  @override
  Widget build(BuildContext context) {
    double pieceSize = 150;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: quizQuestions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  puzzleCompleted
                      ? '🎉 Puzzle Completed!'
                      : 'Complete the Puzzle!',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Puzzle Grid
                SizedBox(
                  width: pieceSize * 2,
                  height: pieceSize * 2,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final placedIndex = placedMap[index];
                      return DragTarget<int>(
                        onAccept: (pieceIndex) {
                          setState(() {
                            placedMap[index] = pieceIndex;
                          });
                          _checkPuzzleCompletion();
                        },
                        onWillAccept: (pieceIndex) => pieceIndex == index,
                        builder: (context, _, __) {
                          return SizedBox(
                            width: pieceSize,
                            height: pieceSize,
                            child: placedIndex != null
                                ? PuzzlePiece(
                                    imagePath: selectedImage,
                                    index: placedIndex,
                                    size: pieceSize)
                                : Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300))),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                if (puzzleCompleted)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GameSuccessMessage(onNext: _goToNextLesson),
                  ),

                if (!puzzleCompleted)
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
                                child: PuzzlePiece(
                                    imagePath: selectedImage,
                                    index: index,
                                    size: pieceSize),
                              ),
                              childWhenDragging: PuzzlePiece(
                                imagePath: selectedImage,
                                index: index,
                                opacity: 0.5,
                                size: pieceSize,
                              ),
                              child: GlowingPuzzlePiece(
                                imagePath: selectedImage,
                                index: index,
                                controller: _glowController,
                                size: pieceSize,
                              ),
                            )
                          : GestureDetector(
                              onTap: () => _showQuestionDialog(index),
                              child: PuzzlePiece(
                                imagePath: selectedImage,
                                index: index,
                                opacity: 0.5,
                                size: pieceSize,
                              ),
                            );
                    }).toList(),
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
            maxWidth: size * 2,
            maxHeight: size * 2,
            child: Align(
              alignment: _getAlignment(index),
              widthFactor: 0.5,
              heightFactor: 0.5,
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(int index) {
    switch (index) {
      case 0:
        return Alignment.topLeft;
      case 1:
        return Alignment.topRight;
      case 2:
        return Alignment.bottomLeft;
      case 3:
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(controller.value),
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
