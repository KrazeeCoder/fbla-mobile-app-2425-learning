import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MazeGame extends StatefulWidget {
  final String subtopicId; // ✅ Add this
  const MazeGame({super.key, required this.subtopicId}); // ✅ Update constructor

  @override
  _MazeGameState createState() => _MazeGameState();
}



class _MazeGameState extends State<MazeGame> {
  static const int mazeSize = 11;
  late List<List<int>> maze;
  int playerX = 0, playerY = 5;
  final int goalX = 10, goalY = 5;
  List<Map<String, dynamic>> quizQuestions = [];
  Set<String> answeredCheckpoints = {};
  late List<List<bool>> checkpoints;
  Map<String, dynamic>? currentQuestion;
  String? selectedOption;
  bool showQuestion = false;

  @override
  void initState() {
    super.initState();
    _generateSolvableMaze();
    _loadQuestions();
  }

  /// Loads quiz questions from JSON
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
      debugPrint("⚠️ No quiz pool found for subtopic ID: ${widget.subtopicId}");
      return;
    }

    // ✅ Filter only the relevant questions
    List<Map<String, dynamic>> questions = allQuestions
        .where((q) => quizPool.contains(q['id'] as int))
        .toList();

    if (questions.isEmpty) {
      debugPrint("⚠️ No questions found in quiz pool for subtopic ID: ${widget.subtopicId}");
      return;
    }

    // ✅ Randomly shuffle the questions
    questions.shuffle();

    setState(() {
      quizQuestions = questions;
    });
  }


  /// Generates a **solvable maze** with a random DFS carve
  void _generateSolvableMaze() {
    // 1 = wall, 0 = open
    maze = List.generate(mazeSize, (_) => List.filled(mazeSize, 1));
    checkpoints = List.generate(mazeSize, (_) => List.filled(mazeSize, false));

    void carve(int x, int y) {
      maze[x][y] = 0;
      var directions = [
        [0, 2], [0, -2], [2, 0], [-2, 0]
      ]..shuffle(Random());

      for (var dir in directions) {
        int nx = x + dir[0], ny = y + dir[1];
        if (nx > 0 && nx < mazeSize - 1 && ny > 0 && ny < mazeSize - 1 && maze[nx][ny] == 1) {
          // carve the wall between (x, y) and (nx, ny)
          maze[x + dir[0] ~/ 2][y + dir[1] ~/ 2] = 0;
          carve(nx, ny);
        }
      }
    }

    // Start carving from (1,1)
    carve(1, 1);

    // Force the entry and exit columns to be open:
    // top row (0,5) and row (1,5) near the entrance
    maze[0][5] = 0;       // Make the "outside" cell white
    maze[1][5] = 0;       // Maze entrance
    // bottom row (10,5) and row (9,5) near the exit
    maze[mazeSize - 1][5] = 0;
    maze[mazeSize - 2][5] = 0;

    // Randomly place checkpoints in open cells
    var random = Random();
    for (int i = 1; i < mazeSize - 1; i++) {
      for (int j = 1; j < mazeSize - 1; j++) {
        if (maze[i][j] == 0 && random.nextDouble() < 0.2) {
          checkpoints[i][j] = true;
        }
      }
    }
  }

  /// Move the player, then see if we should show a question
  void _movePlayer(int dx, int dy) {
    // If a question is open, ignore movement until it's answered
    if (showQuestion) return;

    int newX = playerX + dx;
    int newY = playerY + dy;

    // Check boundaries and walls
    bool isValidMove = (newX >= 0 && newX < mazeSize &&
        newY >= 0 && newY < mazeSize &&
        maze[newX][newY] == 0);

    bool isGoalMove = (newX == goalX && newY == goalY);

    if (isValidMove || isGoalMove) {
      // 1) Move the player first
      setState(() {
        playerX = newX;
        playerY = newY;
      });

      // 2) Check if we've reached the goal
      if (playerX == goalX && playerY == goalY) {
        _goToNextLesson();
        return;
      }

      // 3) If this is an unanswered checkpoint, show the quiz
      String checkpointKey = "$newX-$newY";
      if (checkpoints[newX][newY] && !answeredCheckpoints.contains(checkpointKey)) {
        _showQuestion(newX, newY);
      }
    }
  }

 /// Shows a formatted question matching the screenshot design
void _showQuestion(int checkpointX, int checkpointY) {
  final random = Random();
  Map<String, dynamic> question = quizQuestions[random.nextInt(quizQuestions.length)];

  setState(() {
    showQuestion = true;
    currentQuestion = question;
    selectedOption = null;
  });
}

/// Handles answer selection (with UI update)
void _answerQuestion(String selected, int checkpointX, int checkpointY) {
  if (selected == currentQuestion!["correct_answer"]) {
    // Correct: Mark as answered, hide question
    setState(() {
      answeredCheckpoints.add("$checkpointX-$checkpointY");
      checkpoints[checkpointX][checkpointY] = false;
      showQuestion = false;
    });
  } else {
    // Incorrect: mark the chosen option as selected (turns red)
    setState(() {
      selectedOption = selected;
    });
  }
}


Widget _buildQuestionBox() {
  if (!showQuestion || currentQuestion == null) return Container();

  return Container(
    width: MediaQuery.of(context).size.width * 0.85, // ✅ Slightly reduced width
    margin: const EdgeInsets.all(8), // ✅ Less margin for compact look
    padding: const EdgeInsets.all(12), // ✅ Reduced padding
    decoration: BoxDecoration(
      color: Colors.green[50], // Light green background
      borderRadius: BorderRadius.circular(12), // ✅ Softer, rounded edges
      border: Border.all(color: Colors.black, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title and Close Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Question",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => setState(() => showQuestion = false),
            ),
          ],
        ),

        // Question Text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            currentQuestion!["question"],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),

        // Answer Choices with better spacing
        ...currentQuestion!["answers"].asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          bool isSelected = (option == selectedOption);
          bool isCorrect = (option == currentQuestion!["correct_answer"]);
          Color bgColor = isSelected
              ? (isCorrect ? Colors.green : Colors.red)
              : Colors.white;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _answerQuestion(option, playerX, playerY),
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10), // ✅ Reduced padding
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8), // ✅ Added left padding
                  _optionLabel(index), // ✅ Properly centered option label
                  const SizedBox(width: 12), // ✅ Spaced from text
                  Expanded(
                    child: Text(option, style: const TextStyle(fontSize: 14)), // ✅ Smaller font for elegance
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    ),
  );
}



/// Generates option labels (A, B, C, D)
Widget _optionLabel(int index) {
  List<String> labels = ["A", "B", "C", "D"];
  return Container(
    width: 30, // ✅ Slightly smaller for balance
    height: 30,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black, width: 1.5),
      color: Colors.white,
    ),
    child: Text(
      labels[index],
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );
}




  /// Navigates to the next lesson (Placeholder)
  void _goToNextLesson() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NextLessonScreen()),
    );
  }

@override
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Maze Quiz Game")),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "🔹 Start from outside and enter the maze!\n"
                "🔹 Reach the red goal outside the maze.\n"
                "🔹 Answer questions at blue checkpoints 🌍.\n"
                "🔹 Use the arrows to move!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // ✅ Game Grid (Maze)
       Expanded(
  child: GridView.builder(
    padding: const EdgeInsets.all(10),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: mazeSize,
    ),
    itemCount: mazeSize * mazeSize,
    itemBuilder: (context, index) {
      int x = index ~/ mazeSize;
      int y = index % mazeSize;

      // Decide the color for each cell
      Color tileColor;
      if (x == playerX && y == playerY) {
        // Player tile
        tileColor = Colors.blue;
      } else if (x == goalX && y == goalY) {
        // Goal tile
        tileColor = Colors.red;
      } else if (maze[x][y] == 1) {
        // ✅ IMPASSABLE WALL (Now Grey)
        tileColor = Colors.grey[800]!;
      } else if (answeredCheckpoints.contains("$x-$y")) {
        // Already answered checkpoint
        tileColor = Colors.green.withOpacity(0.5);
      } else if (checkpoints[x][y]) {
        // Unanswered checkpoint
        tileColor = Colors.blue.withOpacity(0.7);
      } else {
        // Normal open path
        tileColor = Colors.white;
      }

      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: (checkpoints[x][y] && !answeredCheckpoints.contains("$x-$y"))
            ? const Center(child: Icon(Icons.public, color: Colors.white))
            : null,
      );
    },
  ),
),


        // ✅ Show Question Box instead of Arrows when active
        if (showQuestion)
          _buildQuestionBox()
        else
          // ✅ Show Arrow Controls when no question is active
          Padding(
  padding: const EdgeInsets.only(bottom: 16), // Adjusted padding for better alignment
  child: Container(
    width: MediaQuery.of(context).size.width * 0.7, // Smaller outer box
    padding: const EdgeInsets.all(8), // Reduced padding for compact size
    decoration: BoxDecoration(
      color: Colors.green[100], // Light green background
      borderRadius: BorderRadius.circular(15), // More elegant corners
      border: Border.all(color: Colors.black, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Use arrows to move", // Simplified instruction
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 5),

        // 🔼 Up Arrow (Centered)
        _arrowButton(Icons.keyboard_arrow_up, () => _movePlayer(-1, 0)),

        // ⬅ Left Arrow + ⬇ Down Arrow + ➡ Right Arrow (Aligned)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _arrowButton(Icons.keyboard_arrow_left, () => _movePlayer(0, -1)),
            const SizedBox(width: 5), // Space between arrows
            _arrowButton(Icons.keyboard_arrow_down, () => _movePlayer(1, 0)),
            const SizedBox(width: 5),
            _arrowButton(Icons.keyboard_arrow_right, () => _movePlayer(0, 1)),
          ],
        ),
      ],
    ),
  ),
),

      ],
    ),
  );
}



}
/// Custom Arrow Button with Consistent Design
Widget _arrowButton(IconData icon, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Uniform spacing
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(), // Circle shape for consistency
        padding: const EdgeInsets.all(12), // Smaller size for compact look
        backgroundColor: Colors.white, // White button
        foregroundColor: Colors.black, // Black icon for contrast
        shadowColor: Colors.grey.withOpacity(0.3), // Soft shadow
        elevation: 5, // Balanced depth effect
      ),
      child: Icon(icon, size: 28), // Consistent arrow size
    ),
  );
}




class NextLessonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Next Lesson")),
      body: const Center(child: Text("Next Lesson Placeholder")),
    );
  }
}
