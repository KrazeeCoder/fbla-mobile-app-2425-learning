import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../widgets/subtopic_widget.dart';
import '../widgets/earth_unlock_animation.dart';
import '../services/updateprogress.dart';
import '../xp_manager.dart';

class MazeGame extends StatefulWidget {
  final String subtopicId;
  final String subject;
  final int grade;
  final int unitId;
  final String unitTitle;
  final String subtopicTitle;
  final String userId;
  final String nextSubtopicId;
  final String nextSubtopicTitle;
  final String nextReadingContent;

  const MazeGame({
    super.key,
    required this.subtopicId,
    required this.subject,
    required this.grade,
    required this.unitId,
    required this.unitTitle,
    required this.subtopicTitle,
    required this.userId,
    required this.nextSubtopicId,
    required this.nextSubtopicTitle,
    required this.nextReadingContent,
  });

  @override
  State<MazeGame> createState() => _MazeGameState();
}

class _MazeGameState extends State<MazeGame> {
  static const int mazeSize = 11;
  late List<List<int>> maze;
  late List<List<bool>> checkpoints;
  int playerX = 0, playerY = 5;
  final int goalX = 10, goalY = 5;
  List<Map<String, dynamic>> quizQuestions = [];
  Set<String> answeredCheckpoints = {};
  Map<String, dynamic>? currentQuestion;
  String? selectedOption;
  bool showQuestion = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _generateSolvableMaze();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final jsonString = await rootBundle.loadString('assets/content.json');
    final data = json.decode(jsonString);
    final allQuestions = List<Map<String, dynamic>>.from(data['questions']);

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

    final questions =
        allQuestions.where((q) => quizPool.contains(q['id'])).toList();
    questions.shuffle();

    setState(() {
      quizQuestions = questions;
    });
  }

  void _generateSolvableMaze() {
    maze = List.generate(mazeSize, (_) => List.filled(mazeSize, 1));
    checkpoints = List.generate(mazeSize, (_) => List.filled(mazeSize, false));

    void carve(int x, int y) {
      maze[x][y] = 0;
      var dirs = [
        [0, 2],
        [0, -2],
        [2, 0],
        [-2, 0]
      ]..shuffle();
      for (var dir in dirs) {
        int nx = x + dir[0], ny = y + dir[1];
        if (nx > 0 &&
            nx < mazeSize - 1 &&
            ny > 0 &&
            ny < mazeSize - 1 &&
            maze[nx][ny] == 1) {
          maze[x + dir[0] ~/ 2][y + dir[1] ~/ 2] = 0;
          carve(nx, ny);
        }
      }
    }

    carve(1, 1);
    maze[0][5] = maze[1][5] = maze[9][5] = maze[10][5] = 0;

    final random = Random();
    for (int i = 1; i < mazeSize - 1; i++) {
      for (int j = 1; j < mazeSize - 1; j++) {
        if (maze[i][j] == 0 && random.nextDouble() < 0.2) {
          checkpoints[i][j] = true;
        }
      }
    }
  }

  void _movePlayer(int dx, int dy) {
    if (showQuestion) return;
    int newX = playerX + dx, newY = playerY + dy;

    if ((newX == goalX && newY == goalY) ||
        (newX >= 0 &&
            newX < mazeSize &&
            newY >= 0 &&
            newY < mazeSize &&
            maze[newX][newY] == 0)) {
      setState(() {
        playerX = newX;
        playerY = newY;
      });

      if (playerX == goalX && playerY == goalY) {
        _goToNextLesson();
        return;
      }

      String checkpointKey = "$newX-$newY";
      if (checkpoints[newX][newY] &&
          !answeredCheckpoints.contains(checkpointKey)) {
        _showQuestion(newX, newY);
      }
    }
  }

  void _showQuestion(int x, int y) {
    final question = quizQuestions[Random().nextInt(quizQuestions.length)];
    setState(() {
      currentQuestion = question;
      selectedOption = null;
      showQuestion = true;
    });
  }

  void _answerQuestion(String selected, int x, int y) {
    if (selected == currentQuestion!["correct_answer"]) {
      setState(() {
        answeredCheckpoints.add("$x-$y");
        checkpoints[x][y] = false;
        showQuestion = false;
      });
    } else {
      setState(() {
        selectedOption = selected;
      });
    }
  }

  Future<void> _goToNextLesson() async {
    await _audioPlayer.play(AssetSource('congrats.mp3'));
    await markQuizAsCompleted(subtopicId: widget.subtopicId, marksEarned: 10);

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

    Provider.of<XPManager>(context, listen: false).addXP(10,
        onLevelUp: (level) {
      EarthUnlockAnimation.show(context, level);
    });

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

  Widget _buildQuestionBox() {
    if (!showQuestion || currentQuestion == null) return SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Question",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => showQuestion = false)),
            ],
          ),
          Text(currentQuestion!["question"], textAlign: TextAlign.center),
          ...currentQuestion!["answers"].asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isCorrect = option == currentQuestion!["correct_answer"];
            final isSelected = option == selectedOption;
            final bgColor = isSelected
                ? (isCorrect ? Colors.green : Colors.red)
                : Colors.white;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ElevatedButton(
                onPressed: () => _answerQuestion(option, playerX, playerY),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: Colors.black),
                ),
                child: Row(
                  children: [
                    _optionLabel(index),
                    const SizedBox(width: 10),
                    Expanded(child: Text(option)),
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _optionLabel(int index) {
    const labels = ["A", "B", "C", "D"];
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black),
        color: Colors.white,
      ),
      child: Text(labels[index],
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Maze Quiz Game")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "🔹 Start outside and enter the maze!\n"
              "🔹 Reach the red goal outside.\n"
              "🔹 Answer questions at blue checkpoints 🌍.\n"
              "🔹 Use the arrows to move!",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: mazeSize),
              itemCount: mazeSize * mazeSize,
              itemBuilder: (context, index) {
                int x = index ~/ mazeSize, y = index % mazeSize;
                Color tileColor;
                if (x == playerX && y == playerY)
                  tileColor = Colors.blue;
                else if (x == goalX && y == goalY)
                  tileColor = Colors.red;
                else if (maze[x][y] == 1)
                  tileColor = Colors.grey[800]!;
                else if (answeredCheckpoints.contains("$x-$y"))
                  tileColor = Colors.green.withOpacity(0.5);
                else if (checkpoints[x][y])
                  tileColor = Colors.blue.withOpacity(0.7);
                else
                  tileColor = Colors.white;

                return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: tileColor, borderRadius: BorderRadius.circular(6)),
                  child: (checkpoints[x][y] &&
                          !answeredCheckpoints.contains("$x-$y"))
                      ? const Center(
                          child: Icon(Icons.public, color: Colors.white))
                      : null,
                );
              },
            ),
          ),
          if (showQuestion)
            _buildQuestionBox()
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  _arrowButton(
                      Icons.keyboard_arrow_up, () => _movePlayer(-1, 0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _arrowButton(
                          Icons.keyboard_arrow_left, () => _movePlayer(0, -1)),
                      _arrowButton(
                          Icons.keyboard_arrow_down, () => _movePlayer(1, 0)),
                      _arrowButton(
                          Icons.keyboard_arrow_right, () => _movePlayer(0, 1)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        child: Icon(icon),
      ),
    );
  }
}
