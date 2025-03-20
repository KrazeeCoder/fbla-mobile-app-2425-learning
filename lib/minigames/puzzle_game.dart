import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PuzzleScreen extends StatefulWidget {
  final String subtopicId;
  const PuzzleScreen({super.key, required this.subtopicId});

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> quizQuestions = [];
  String selectedImage = '';
  List<bool> answered = [];
  List<bool> placed = [];
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _randomizeImage();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  void _randomizeImage() {
    List<String> images = ['assets/cherry.png', 'assets/mushroom.png'];
    selectedImage = images[Random().nextInt(images.length)];
  }

  Future<void> _loadQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/content.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    List<Map<String, dynamic>> allQuestions = List<Map<String, dynamic>>.from(data['questions']);

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
      placed = List.filled(4, false);
    });
  }

  void _showQuestionDialog(int index) {
    final question = quizQuestions[index]['question'];
    final List<String> answers = List<String>.from(quizQuestions[index]['answers']);
    final String correctAnswer = quizQuestions[index]['correct_answer'];

    String? selectedAnswer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: answers
                  .map((answer) => RadioListTile<String>(
                title: Text(answer),
                value: answer,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  setState(() => selectedAnswer = value);
                },
              ))
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedAnswer == correctAnswer) {
                    setState(() => answered[index] = true);
                    Navigator.pop(context);
                    this.setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect answer, try again!')),
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
          const Text('Complete the Puzzle!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Puzzle Board (Fixed Position)
          SizedBox(
            width: pieceSize * 2,
            height: pieceSize * 2,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => DragTarget<int>(
                onAccept: (data) => setState(() => placed[data] = true),
                onWillAccept: (data) => data == index,
                builder: (context, _, __) => ClipRect(  /// 🔥 FIX: Clip the placed puzzle pieces
                  child: placed[index]
                      ? PuzzlePiece(
                    imagePath: selectedImage,
                    index: index,
                    isPlaced: true,
                    size: pieceSize,
                  )
                      : Container(
                    width: pieceSize,
                    height: pieceSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Puzzle Pieces
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: List.generate(4, (index) {
              if (placed[index]) return const SizedBox.shrink();
              return answered[index]
                  ? Draggable<int>(
                data: index,
                feedback: PuzzlePiece(imagePath: selectedImage, index: index, size: pieceSize),
                childWhenDragging: PuzzlePiece(imagePath: selectedImage, index: index, opacity: 0.5, size: pieceSize),
                child: GlowingPuzzlePiece(
                  imagePath: selectedImage,
                  index: index,
                  controller: _glowController,
                  size: pieceSize,
                ),
              )
                  : GestureDetector(
                onTap: () => _showQuestionDialog(index),
                child: PuzzlePiece(imagePath: selectedImage, index: index, opacity: 0.5, size: pieceSize),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }
}

class PuzzlePiece extends StatelessWidget {
  final String imagePath;
  final int index;
  final bool isPlaced;
  final double opacity;
  final double size;

  const PuzzlePiece({
    super.key,
    required this.imagePath,
    required this.index,
    this.isPlaced = false,
    this.opacity = 1.0,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ClipRect(
        child: Align(
          alignment: _getAlignment(index),
          widthFactor: 0.5,
          heightFactor: 0.5,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: size * 2,
            height: size * 2,
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(int index) {
    switch (index) {
      case 0: return Alignment.topLeft;
      case 1: return Alignment.topRight;
      case 2: return Alignment.bottomLeft;
      case 3: return Alignment.bottomRight;
      default: return Alignment.center;
    }
  }
}

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
