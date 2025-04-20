// 🎯 Cleaned & Merged Final Version of CypherUI
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../widgets/cypher_question.dart';
import '../widgets/subtopic_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/updateprogress.dart';
import '../utils/subTopicNavigation.dart';
import '../widgets/gamesucesswidget.dart';
import 'package:provider/provider.dart';
import '../xp_manager.dart';
import '../widgets/earth_unlock_animation.dart';
import '../utils/audio/audio_integration.dart';
import '../utils/app_logger.dart';
import '../utils/game_launcher.dart';

class CypherUI extends StatefulWidget {
  final String subtopicId;
  final String subject;
  final int grade;
  final int unitId;
  final String unitTitle;
  final String subtopicTitle;
  final String nextSubtopicId;
  final String nextSubtopicTitle;
  final String nextReadingContent;
  final String userId;

  const CypherUI(
      {super.key,
      required this.subtopicId,
      required this.subject,
      required this.grade,
      required this.unitId,
      required this.unitTitle,
      required this.subtopicTitle,
      required this.nextSubtopicId,
      required this.nextSubtopicTitle,
      required this.nextReadingContent,
      required this.userId});

  @override
  State<CypherUI> createState() => _CypherUIState();
}

class _CypherUIState extends State<CypherUI> with TickerProviderStateMixin {
  bool showSuccess = false;
  final random = Random();
  List<Map<String, dynamic>> quizQuestions = [];
  List<Map<String, dynamic>> gameState = [];
  String currentPhrase = "";
  int currentQuestionIndex = 0;
  Map<int, String> answeredQuestions = {};
  Set<int> correctAnswers = {};
  late AnimationController _revealController;
  late AnimationController _bounceController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, dynamic>? subtopicNav;

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

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _revealController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/content.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    List<Map<String, dynamic>> allQuestions =
        List<Map<String, dynamic>>.from(data['questions']);
    List<dynamic> subjects = data['subjects'];
    List<int> quizPool = [];

    for (var subject in subjects) {
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

    if (quizPool.isEmpty) {
      debugPrint("⚠️ No quiz pool found for subtopic ID: ${widget.subtopicId}");
      return;
    }

    List<Map<String, dynamic>> questions =
        allQuestions.where((q) => quizPool.contains(q['id'] as int)).toList();

    final wordList = [
      "SMART",
      "BRAVE",
      "LIGHT",
      "STORM",
      "CLOUD",
      "RAPID",
      "FLARE"
    ];
    currentPhrase = wordList[random.nextInt(wordList.length)];

    questions.shuffle();
    questions = questions.take(5).toList();

    List<int> scrambledNumbers = List.generate(questions.length, (i) => i)
      ..shuffle();

    setState(() {
      quizQuestions = questions;
      gameState = List.generate(questions.length, (index) {
        return {
          "letter": currentPhrase[index],
          "revealed": false,
          "questionIndex": scrambledNumbers[index],
        };
      });
    });
  }

  void onAnswerSelected(int questionIndex, String selectedAnswer) {
    setState(() {
      answeredQuestions[questionIndex] = selectedAnswer;

      if (selectedAnswer == quizQuestions[questionIndex]["correct_answer"]) {
        correctAnswers.add(questionIndex);
        _revealController.forward(from: 0);

        for (var item in gameState) {
          if (item["questionIndex"] == questionIndex) {
            item["revealed"] = true;
            break;
          }
        }
      }
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < quizQuestions.length - 1) {
      setState(() => currentQuestionIndex++);
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() => currentQuestionIndex--);
    }
  }

  Future<void> _handleGameCompletion() async {
    if (showSuccess ||
        quizQuestions.isEmpty ||
        correctAnswers.length < quizQuestions.length) {
      return;
    }

    // Use new AudioIntegration instead of direct audio player
    await AudioIntegration.handleGameComplete();

    // Update progress
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

    setState(() {
      showSuccess = true;
    });
  }

  void _goNextChapter() {
    try {
      // Check if widget is still mounted before using context
      if (!mounted) {
        AppLogger.w("Widget not mounted during navigation");
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
      // Log the error but allow the app to continue
      AppLogger.e("Error navigating to next chapter: $e");
    }
  }

  bool get isGameCompleted => correctAnswers.length == quizQuestions.length;

  @override
  Widget build(BuildContext context) {
    if (quizQuestions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
              const SizedBox(height: 20),
              Text(
                "Loading Cipher Game...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = quizQuestions[currentQuestionIndex];
    if (isGameCompleted && !showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleGameCompletion();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cipher Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.indigo,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Game context information
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 10.0),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.indigo.shade700, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Grade ${widget.grade} | ${widget.unitTitle} | ${widget.subtopicTitle}",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Game instructions
                if (!isGameCompleted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Answer all questions correctly to reveal the secret word!",
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Cipher Display
                // Cipher Display (Responsive & Overflow-Proof)
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, _) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        double spacing = 12;
                        int itemCount = gameState.length;
                        double availableWidth =
                            constraints.maxWidth - (spacing * (itemCount - 1));
                        double cardWidth = availableWidth / itemCount;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: spacing,
                            runSpacing: 12,
                            children: gameState.map((item) {
                              double elevationValue = item["revealed"]
                                  ? 4.0
                                  : 2.0 + (_bounceController.value * 2.0);

                              return Material(
                                elevation: elevationValue,
                                borderRadius: BorderRadius.circular(12),
                                color: item["revealed"]
                                    ? Colors.green.shade500
                                    : Colors.indigo.shade600,
                                child: Container(
                                  width: cardWidth.clamp(45.0, 70.0),
                                  height: 80,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item["revealed"] ? item["letter"] : "?",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 2,
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              offset: const Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "#${(item["questionIndex"] + 1)}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: item["revealed"]
                                                ? Colors.green.shade700
                                                : Colors.indigo.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  },
                ),

                // Question Area with Navigation
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Previous button
                          IconButton(
                            onPressed: previousQuestion,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: currentQuestionIndex > 0
                                    ? Colors.indigo.shade100
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 24,
                                color: currentQuestionIndex > 0
                                    ? Colors.indigo
                                    : Colors.grey,
                              ),
                            ),
                          ),

                          // Question content
                          Expanded(
                            child: SingleChildScrollView(
                              child: MultipleChoiceQuestion(
                                key: ValueKey(currentQuestionIndex),
                                question: currentQuestion["question"],
                                options: List<String>.from(
                                    currentQuestion["answers"]),
                                correctAnswer:
                                    currentQuestion["correct_answer"],
                                selectedAnswer:
                                    answeredQuestions[currentQuestionIndex],
                                previouslyAnswered: answeredQuestions
                                    .containsKey(currentQuestionIndex),
                                isCorrectlyAnswered: correctAnswers
                                    .contains(currentQuestionIndex),
                                onAnswerSelected: (answer) {
                                  if (!correctAnswers
                                      .contains(currentQuestionIndex)) {
                                    onAnswerSelected(
                                        currentQuestionIndex, answer);
                                  }
                                },
                                questionTextStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Next button
                          IconButton(
                            onPressed: nextQuestion,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: currentQuestionIndex <
                                        quizQuestions.length - 1
                                    ? Colors.indigo.shade100
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 24,
                                color: currentQuestionIndex <
                                        quizQuestions.length - 1
                                    ? Colors.indigo
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Success Message
                if (showSuccess)
                  AnimatedOpacity(
                    opacity: showSuccess ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: GameSuccessMessage(
                      onNext: _goNextChapter,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
