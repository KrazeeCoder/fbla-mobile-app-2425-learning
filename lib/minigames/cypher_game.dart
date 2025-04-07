import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../widgets/cypher_question.dart';
import '../widgets/subtopic_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/updateprogress.dart';
import '../widgets/subtopic_widget.dart';

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

  const CypherUI({
    super.key,
    required this.subtopicId,
    required this.subject,
    required this.grade,
    required this.unitId,
    required this.unitTitle,
    required this.subtopicTitle,
    required this.nextSubtopicId,
    required this.nextSubtopicTitle,
    required this.nextReadingContent,
    required this.userId,
  });

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
  final AudioPlayer _audioPlayer = AudioPlayer();

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

      if (selectedAnswer == quizQuestions[questionIndex]["correct_answer"]) {
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

  Future<void> _saveProgressAndGoNext() async {
    await _audioPlayer.play(AssetSource('audio/congrats.mp3'));

    await markQuizAsCompleted(
      subtopicId: widget.subtopicId,
      marksEarned: getDummyMarks(),
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SubtopicPage(
          subtopic: widget.nextSubtopicTitle,
          subtopicId: widget.nextSubtopicId,
          readingTitle: widget.nextSubtopicTitle,
          readingContent: widget.nextReadingContent,
          isCompleted: false,
          subject: widget.subject,
          grade: widget.grade,
          unitId: widget.unitId,
          unitTitle: widget.unitTitle,
          userId: widget.userId,
        ),
      ),
    );
  }

  getDummyMarks() {
    // Dummy function to simulate marks calculation
    return 10; // Replace with actual logic if needed
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
                    correctAnswer: currentQuestion["correct_answer"].toString(),
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
                    onPressed: () => _saveProgressAndGoNext(),
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
}
