import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../widgets/cypher_question.dart';

class CypherUI extends StatefulWidget {
  final int subtopicId; // ✅ Add this

  const CypherUI({super.key, required this.subtopicId}); // ✅ Update constructor

  @override
  State<CypherUI> createState() => _CypherUIState();
}


class _CypherUIState extends State<CypherUI> {
  final random = Random();
  List<Map<String, dynamic>> quizQuestions = [];
  List<Map<String, dynamic>> gameState = [];
  String currentPhrase = "";
  int currentQuestionIndex = 0;
  Map<int, String> answeredQuestions = {};
  Set<int> correctAnswers = {}; // Store correct answers to disable further clicks

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/content.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    List<Map<String, dynamic>> allQuestions = List<Map<String, dynamic>>.from(data['questions']);

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
      print("No quiz pool found for subtopic ID: ${widget.subtopicId}");
      return;
    }

    // ✅ Filter only the relevant questions
    List<Map<String, dynamic>> questions = allQuestions
        .where((q) => quizPool.contains(q['id'] as int))
        .toList();

    if (questions.isEmpty) return;

    // ✅ Ensure phrase length is always 5 (even if more questions exist)
    final wordList = ["SMART", "BRAVE", "LIGHT", "STORM", "CLOUD", "RAPID", "FLARE"];
    currentPhrase = (wordList.toList()..shuffle()).first; // Pick a random meaningful word

    // ✅ Randomly select 5 questions from the available pool
    questions.shuffle();
    questions = questions.take(5).toList();

    List<int> scrambledNumbers = List.generate(questions.length, (i) => i);
    scrambledNumbers.shuffle();

    setState(() {
      quizQuestions = questions;
      gameState = List.generate(questions.length, (index) {
        return {
          "letter": currentPhrase[index],  // ✅ Phrase is always meaningful!
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
        correctAnswers.add(questionIndex); // Mark question as correctly answered

        // Reveal the letter only when the answer is correct
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
      appBar: AppBar(title: const Text('Cipher Game')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  icon: const Icon(Icons.arrow_left, color: Colors.black, size: 28),
                ),
                Expanded(
                  child: MultipleChoiceQuestion(
                    key: ValueKey(currentQuestionIndex),
                    question: currentQuestion["question"].toString(),
                    options: List<String>.from(currentQuestion["answers"].map((e) => e.toString())),
                    correctAnswer: currentQuestion["correct_answer"].toString(),
                    selectedAnswer: answeredQuestions[currentQuestionIndex],
                    previouslyAnswered: answeredQuestions.containsKey(currentQuestionIndex),
                    isCorrectlyAnswered: correctAnswers.contains(currentQuestionIndex),
                    onAnswerSelected: (answer) {
                      if (!correctAnswers.contains(currentQuestionIndex)) {
                        onAnswerSelected(currentQuestionIndex, answer);
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: nextQuestion,
                  icon: const Icon(Icons.arrow_right, color: Colors.black, size: 28),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: gameState.map((item) {
                return Column(
                  children: [
                    Text(
                      item["revealed"] ? item["letter"] : "_",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (item["questionIndex"] + 1).toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            if (isGameCompleted)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "🎉 You're Done! Move on to the next lesson! 🎉",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Next Lesson"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
