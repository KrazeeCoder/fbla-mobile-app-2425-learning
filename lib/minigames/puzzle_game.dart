import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MathPuzzleGame());
}

class MathPuzzleGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuzzleScreen(),
    );
  }
}

class PuzzleScreen extends StatefulWidget {
  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  List<Map<String, dynamic>> quizQuestions = [];
  String selectedImage = "";
  Map<String, String> questionAnswerPairs = {};
  Map<String, bool> matchedPairs = {};
  Map<int, bool> placedFragments = {};
  Map<int, int?> fragmentPositions = {};
  bool isGameComplete = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _randomizeImage();
  }

  void _randomizeImage() {
    List<String> images = ['assets/cherry.png', 'assets/mushroom.png'];
    selectedImage = images[Random().nextInt(images.length)];
  }

  Future<void> _loadQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/content.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    List<Map<String, dynamic>> allQuestions = List<Map<String, dynamic>>.from(data["questions"]);

    List<Map<String, dynamic>> selectedQuestions = (allQuestions..shuffle()).take(4).toList();

    setState(() {
      for (int i = 0; i < selectedQuestions.length; i++) {
        var question = selectedQuestions[i];
        questionAnswerPairs[question["question"]] = question["correct_answer"];
        matchedPairs[question["question"]] = false;
        placedFragments[i] = false;
        fragmentPositions[i] = null;
      }
    });
  }

  void _onMatch(String question) {
    setState(() {
      matchedPairs[question] = true;
      int index = questionAnswerPairs.keys.toList().indexOf(question);
      fragmentPositions[index] = index;
    });
  }

  void _onPlaceFragment(int index) {
    setState(() {
      placedFragments[index] = true;
      fragmentPositions[index] = null;
      if (placedFragments.values.every((placed) => placed)) {
        isGameComplete = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Math Puzzle Game"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Match the equations to reveal puzzle pieces!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: 4,
              itemBuilder: (context, index) {
                return DragTarget<int>(
                  onAccept: (data) {
                    _onPlaceFragment(data);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return placedFragments[index]!
                        ? ImageFragment(imagePath: selectedImage, index: index)
                        : Container(color: Colors.grey[300]);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: questionAnswerPairs.keys.map((question) {
                      int index = questionAnswerPairs.keys.toList().indexOf(question);
                      return matchedPairs[question]!
                          ? fragmentPositions[index] != null
                          ? Draggable<int>(
                        data: index,
                        feedback: Material(
                          color: Colors.transparent,
                          child: ImageFragment(imagePath: selectedImage, index: index),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: ImageFragment(imagePath: selectedImage, index: index),
                        ),
                        child: ImageFragment(imagePath: selectedImage, index: index),
                      )
                          : SizedBox()
                          : Draggable<String>(
                        data: question,
                        feedback: Material(
                          color: Colors.transparent,
                          child: AnswerSlot(text: question),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: AnswerSlot(text: question),
                        ),
                        child: AnswerSlot(text: question),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: questionAnswerPairs.keys.map((question) {
                      return DragTarget<String>(
                        onAccept: (data) {
                          if (data == question) {
                            _onMatch(question);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return matchedPairs[question]!
                              ? SizedBox()
                              : AnswerSlot(text: questionAnswerPairs[question]!);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImageFragment extends StatelessWidget {
  final String imagePath;
  final int index;

  ImageFragment({required this.imagePath, required this.index});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment(-1 + (index % 2) * 2, -1 + (index ~/ 2) * 2),
        widthFactor: 0.5,
        heightFactor: 0.5,
        child: Image.asset(imagePath, fit: BoxFit.cover, width: 100, height: 100),
      ),
    );
  }
}

class AnswerSlot extends StatelessWidget {
  final String text;
  AnswerSlot({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 14, color: Colors.white)),
    );
  }
}
