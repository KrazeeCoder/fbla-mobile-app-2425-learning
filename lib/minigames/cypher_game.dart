import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../widgets/cypher_question.dart';
import 'package:provider/provider.dart';
import '../xp_manager.dart';
import '../utils/app_logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/earth_unlock_animation.dart';

class CypherUI extends StatefulWidget {
  final String subtopicId;
  const CypherUI({super.key, required this.subtopicId});

  @override
  State<CypherUI> createState() => _CypherUIState();
}

class _CypherUIState extends State<CypherUI> with TickerProviderStateMixin {
  final random = Random();
  List<Map<String, dynamic>> quizQuestions = [];
  List<Map<String, dynamic>> gameState = [];
  String currentPhrase = "";
  int currentQuestionIndex = 0;
  Map<int, String> answeredQuestions = {};
  Set<int> correctAnswers = {};
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _loadQuestions();

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

    // ✅ Select quiz pool based on the subtopic ID
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
      print("No quiz pool found for subtopic ID: ${widget.subtopicId}");
      return;
    }

    List<Map<String, dynamic>> questions =
        allQuestions.where((q) => quizPool.contains(q['id'] as int)).toList();

    if (questions.isEmpty) return;

    // ✅ Improved randomization
    final wordList = [
      "SMART",
      "BRAVE",
      "LIGHT",
      "STORM",
      "CLOUD",
      "RAPID",
      "FLARE"
    ];
    currentPhrase =
        wordList[random.nextInt(wordList.length)]; // Randomly pick a word

    questions.shuffle();
    questions = questions.take(5).toList(); // Ensure 5 questions only

    List<int> scrambledNumbers = List.generate(questions.length, (i) => i);
    scrambledNumbers.shuffle();

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

      if (selectedAnswer == quizQuestions[questionIndex]["correctAnswer"]) {
        correctAnswers.add(questionIndex);
        _revealController.forward(from: 0); // Trigger animation

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
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  bool get isGameCompleted => correctAnswers.length == quizQuestions.length;

  @override
  Widget build(BuildContext context) {
    if (quizQuestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = quizQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cipher Game'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🎯 Question Progress
            Text(
              "Question ${currentQuestionIndex + 1} / ${quizQuestions.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: previousQuestion,
                  icon: const Icon(Icons.arrow_left),
                  color: Colors.blueAccent,
                  iconSize: 36,
                ),
                Expanded(
                  child: MultipleChoiceQuestion(
                    key: ValueKey(currentQuestionIndex),
                    question: currentQuestion["question"].toString(),
                    options: List<String>.from(
                        currentQuestion["answers"].map((e) => e.toString())),
                    correctAnswer: currentQuestion["correctAnswer"].toString(),
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
                    questionTextStyle: const TextStyle(
                        fontSize: 16), // ✅ Smaller Question Text
                  ),
                ),
                IconButton(
                  onPressed: nextQuestion,
                  icon: const Icon(Icons.arrow_right),
                  color: Colors.blueAccent,
                  iconSize: 36,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 🎯 Phrase Reveal with Animation
            AnimatedBuilder(
              animation: _revealController,
              builder: (context, child) {
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
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              item["revealed"] ? item["letter"] : "_",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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

            // 🎯 Instructions or Completion Message
            if (isGameCompleted)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "🎉 Well Done! You've solved the cipher! 🎉",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Award XP for completing the game
                      _awardXPForCompletion(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Next Lesson"),
                  ),
                ],
              )
            else
              const Text(
                "🔑 Instructions: Answer the questions correctly to reveal the letters and solve the cipher.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  // Add XP for completing the game
  void _awardXPForCompletion(BuildContext context) {
    try {
      // Access the XP manager
      final xpManager = Provider.of<XPManager>(context, listen: false);

      // Award XP for game completion (using a base value plus difficulty)
      final int xpAmount = 10; // Base XP for game completion

      // Add XP and handle level up
      xpManager.addXP(xpAmount, onLevelUp: (newLevel) {
        // Show custom level up animation
        _showEarthUnlockedAnimation(context, newLevel);
      });

      // Show a brief XP notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+ $xpAmount XP earned!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      AppLogger.e('Error awarding XP in Cypher Game', error: e);
    }
  }

  // Show custom level up animation with earth unlocked
  void _showEarthUnlockedAnimation(BuildContext context, int newLevel) {
    EarthUnlockAnimation.show(context, newLevel);
  }
}
