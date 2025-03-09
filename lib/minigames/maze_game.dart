import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MazeGame extends StatefulWidget {
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
    setState(() {
      quizQuestions = List<Map<String, dynamic>>.from(data["questions"]);
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

  /// Shows a random question from the JSON
  void _showQuestion(int checkpointX, int checkpointY) {
    final random = Random();
    Map<String, dynamic> question = quizQuestions[random.nextInt(quizQuestions.length)];

    setState(() {
      showQuestion = true;
      currentQuestion = question;
      selectedOption = null;
    });
  }

  /// Handles answer selection
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

  /// Navigates to the next lesson (Placeholder)
  void _goToNextLesson() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NextLessonScreen()),
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
              "🔹 Start from outside and enter the maze!\n"
                  "🔹 Reach the red goal outside the maze.\n"
                  "🔹 Answer questions at blue checkpoints 🌍.\n"
                  "🔹 Use the arrows to move!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
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
                  // Wall
                  tileColor = Colors.grey;
                } else if (answeredCheckpoints.contains("$x-$y")) {
                  // Already answered checkpoint
                  tileColor = Colors.green;
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

          // If a question is active, show it at the bottom
          if (showQuestion && currentQuestion != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    currentQuestion!["question"],
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  // Render answer choices
                  ...currentQuestion!["answers"].map<Widget>((option) {
                    bool isSelected = (option == selectedOption);
                    bool isCorrect = (option == currentQuestion!["correct_answer"]);
                    Color bgColor;

                    if (isSelected) {
                      bgColor = isCorrect ? Colors.green : Colors.red;
                    } else {
                      bgColor = Colors.white;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(option, playerX, playerY),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgColor,
                          // Make text black so it's visible on white/green/red
                          foregroundColor: Colors.black,
                        ),
                        child: Text(option),
                      ),
                    );
                  }).toList(),
                ],
              ),
            )
          else
          // Otherwise, show the arrow controls
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () => _movePlayer(0, -1),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: () => _movePlayer(-1, 0),
                      ),
                      const SizedBox(height: 10),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: () => _movePlayer(1, 0),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () => _movePlayer(0, 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
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
