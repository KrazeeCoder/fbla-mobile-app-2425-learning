import 'package:flutter/material.dart';
import 'dart:math';

import '../widgets/cypher_question.dart';

final phrases = [
  "Green leaves grow", "Blue skies above", "Life finds a way", "Rocks hold secrets",
  "Water flows freely", "The sun warms all", "Stars light paths", "Winds carry whispers",
  "Soil gives life", "Rain feeds roots", "Earth turns quietly", "The ocean calls",
  "Mountains stand tall", "Trees reach upward", "Nature is balance"
];


class CypherUI extends StatefulWidget {
  CypherUI({super.key});

  @override
  State<CypherUI> createState() => _CypherUIState();
}

class _CypherUIState extends State<CypherUI> {
  final random = Random();
  List<Map<String, dynamic>> gameState = [];
  List<int> allSums = [];
  String currentPhrase = "";
  List<Map<String, int>> unsolvedQuestions = [];
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    currentPhrase = phrases[random.nextInt(phrases.length)];

    List<String> words = currentPhrase.split(' '); // Split phrase into words

    for (int wordIndex = 0; wordIndex < words.length; wordIndex++) {
      List<Map<String, dynamic>> wordGameState = [];
      for (int letterIndex = 0; letterIndex < words[wordIndex].length; letterIndex++) {
        while (true) {
          List<int>? temp = generateQuestion();
          if (temp != null) {
            wordGameState.add({
              "letter": words[wordIndex][letterIndex],
              "problem": temp,
              "solved": false,
            });
            unsolvedQuestions.add({"wordIndex": wordIndex, "letterIndex": letterIndex});
            break;
          }
        }
      }
      gameState.add({"word": words[wordIndex], "letters": wordGameState});
    }

    unsolvedQuestions.shuffle(random);
  }

  List<int>? generateQuestion() {
    List<int> tempList = [random.nextInt(30), random.nextInt(30)];
    int addSum = tempList.fold(0, (sum, num) => sum + num);

    if (!allSums.contains(addSum)) {
      allSums.add(addSum);
      return tempList;
    }
    return null;
  }

  int listSum(List<int> addendList) => addendList.fold(0, (sum, num) => sum + num);

  void markLetterAsSolved(int wordIndex, int letterIndex) {
    setState(() {
      gameState[wordIndex]["letters"][letterIndex]["solved"] = true;
      unsolvedQuestions.removeWhere((q) => q["wordIndex"] == wordIndex && q["letterIndex"] == letterIndex);
      if (unsolvedQuestions.isNotEmpty) {
        currentQuestionIndex = currentQuestionIndex % unsolvedQuestions.length;
      }
    });
  }

  void navigateToNextQuestion() {
    setState(() {
      if (unsolvedQuestions.isNotEmpty) {
        currentQuestionIndex = (currentQuestionIndex + 1) % unsolvedQuestions.length;
      }
    });
  }

  void navigateToPreviousQuestion() {
    setState(() {
      if (unsolvedQuestions.isNotEmpty) {
        currentQuestionIndex = (currentQuestionIndex - 1 + unsolvedQuestions.length) % unsolvedQuestions.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (unsolvedQuestions.isEmpty) {
      return Center(
        child: Text(
          "All questions solved! 🎉",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }

    int wordIndex = unsolvedQuestions[currentQuestionIndex]["wordIndex"]!;
    int letterIndex = unsolvedQuestions[currentQuestionIndex]["letterIndex"]!;
    Map<String, dynamic> currentLetter = gameState[wordIndex]["letters"][letterIndex];

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MultipleChoiceQuestion(
              question: "${currentLetter["problem"][0]} + ${currentLetter["problem"][1]} = ?",
              options: generateAnswerOptions(listSum(currentLetter["problem"])),
              correctAnswer: listSum(currentLetter["problem"]).toString(),
              onAnswerSelected: (answer) {
                if (answer == listSum(currentLetter["problem"]).toString()) {
                  markLetterAsSolved(wordIndex, letterIndex);
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: navigateToPreviousQuestion,
                child: Text("Previous"),
              ),
              ElevatedButton(
                onPressed: navigateToNextQuestion,
                child: Text("Next"),
              ),
            ],
          ),
          ...gameState.map((wordItem) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: wordItem["letters"].map<Widget>((item) {
                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Column(
                      children: [
                        Visibility(
                          visible: item["solved"],
                          replacement: const Text(" ", style: TextStyle(fontSize: 24)),
                          child: Text(item["letter"], style: const TextStyle(fontSize: 24)),
                        ),
                        Container(width: 35, height: 4, color: Colors.black),
                        Text(listSum(item["problem"]).toString()),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<String> generateAnswerOptions(int correctAnswer) {
    List<String> options = ["0", "0", "0", "0"];
    Random r = Random();
    int correctIndex = r.nextInt(4);

    options[correctIndex] = correctAnswer.toString();
    options[(correctIndex + 1) % 4] = (correctAnswer + 1).toString();
    options[(correctIndex + 2) % 4] = (correctAnswer - 5).toString();

    return options;
  }
}
