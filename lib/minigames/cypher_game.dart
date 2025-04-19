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
  }

  @override
  void dispose() {
    _revealController.dispose();
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
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = quizQuestions[currentQuestionIndex];
    if (isGameCompleted && !showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleGameCompletion();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cipher Game'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                "Question ${currentQuestionIndex + 1} / ${quizQuestions.length}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: previousQuestion,
                  icon: const Icon(Icons.arrow_left),
                  iconSize: 36,
                  color: Colors.blueAccent,
                ),
                Expanded(
                  child: MultipleChoiceQuestion(
                    key: ValueKey(currentQuestionIndex),
                    question: currentQuestion["question"],
                    options: List<String>.from(currentQuestion["answers"]),
                    correctAnswer: currentQuestion["correct_answer"],
                    selectedAnswer: answeredQuestions[currentQuestionIndex],
                    previouslyAnswered:
                        answeredQuestions.containsKey(currentQuestionIndex),
                    isCorrectlyAnswered:
                        correctAnswers.contains(currentQuestionIndex),
                    onAnswerSelected: (answer) {
                      if (!correctAnswers.contains(currentQuestionIndex)) {
                        onAnswerSelected(currentQuestionIndex, answer);
                      }
                    },
                    questionTextStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: nextQuestion,
                  icon: const Icon(Icons.arrow_right),
                  iconSize: 36,
                  color: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 30),
            AnimatedBuilder(
              animation: _revealController,
              builder: (context, _) {
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: gameState.map((item) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: item["revealed"] ? 1.0 : 0.3,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item["revealed"]
                              ? Colors.green[400]
                              : Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(blurRadius: 8, offset: Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              item["revealed"] ? item["letter"] : "_",
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (item["questionIndex"] + 1).toString(),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 30),
            if (showSuccess)
              GameSuccessMessage(
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
          ],
        ),
      ),
    );
  }
}
