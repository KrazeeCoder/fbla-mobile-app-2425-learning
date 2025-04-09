import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../xp_manager.dart';
import '../utils/app_logger.dart';
import '../widgets/earth_unlock_animation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/updateprogress.dart';
import '../widgets/subtopic_widget.dart';

class RacingGame extends StatefulWidget {
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

  const RacingGame({
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
  _RacingGameState createState() => _RacingGameState();
}

class _RacingGameState extends State<RacingGame> {
  List<Map<String, dynamic>> quizQuestions = [];
  Map<String, dynamic>? currentQuestion;
  String? selectedOption;
  bool showQuestion = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Racing game specific variables
  late Timer _gameTimer;
  int _elapsedSeconds = 0;
  int _playerPosition = 5; // Start slightly above the bottom
  List<double> _aiPositions = [
    5.0,
    5.0,
    5.0
  ]; // All AI cars start at the same position
  final Random _random = Random();
  bool _gameOver = false;
  bool _playerWon = false;

  // Speed variables - GRADUAL BUT VERY SLOW
  final int _baseSpeed = 0; // No automatic movement
  final int _correctAnswerBoost = 10; // Even larger boost for correct answers
  final int _wrongAnswerPenalty = 5; // Penalty for wrong answers
  final double _aiBaseSpeed = 0.07; // Small increment on each timer tick

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startGameTimer();
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startGameTimer() {
    // Shorter interval for smoother animation (150ms)
    _gameTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_gameOver) {
        timer.cancel();
        return;
      }

      setState(() {
        // Move AI cars very gradually on every tick
        for (int i = 0; i < _aiPositions.length; i++) {
          // Calculate a slightly different speed for each AI car
          double speedFactor =
              1.0 + (i * 0.1); // First car: 1.0, second: 1.1, third: 1.2
          double aiSpeed = _aiBaseSpeed * speedFactor;

          // Apply small random variance to speed (±20%)
          double variance = 0.8 + (_random.nextDouble() * 0.4); // 0.8 to 1.2

          _aiPositions[i] = min(_aiPositions[i] + (aiSpeed * variance), 100.0);
        }

        // Check if any car reached finish line
        if (_playerPosition >= 100) {
          _gameOver = true;
          _playerWon = true;
          _goToNextLesson();
        } else if (_aiPositions.any((pos) => pos >= 100)) {
          _gameOver = true;
          _playerWon = false;
          _showLoseDialog();
        }

        _elapsedSeconds = (timer.tick / 6.67).floor(); // ~150ms × 6.67 ≈ 1s
      });
    });
  }

  /// Loads quiz questions from JSON
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

    // Filter only the relevant questions
    List<Map<String, dynamic>> questions =
        allQuestions.where((q) => quizPool.contains(q['id'] as int)).toList();

    if (questions.isEmpty) {
      debugPrint(
          "⚠️ No questions found in quiz pool for subtopic ID: ${widget.subtopicId}");
      return;
    }

    // Randomly shuffle the questions
    questions.shuffle();

    setState(() {
      quizQuestions = questions;
      _showNextQuestion();
    });
  }

  /// Shows a formatted question matching the screenshot design
  void _showNextQuestion() {
    if (quizQuestions.isEmpty) return;

    final random = Random();
    final question = quizQuestions[random.nextInt(quizQuestions.length)];

    setState(() {
      showQuestion = true;
      currentQuestion = question;
      selectedOption = null;
    });
  }

  /// Handles answer selection
  void _answerQuestion(String selected) {
    if (selected == currentQuestion!["correct_answer"]) {
      // Correct: Move player forward
      setState(() {
        _playerPosition = min(_playerPosition + _correctAnswerBoost, 100);
        showQuestion = false;
      });

      if (!_gameOver) {
        _showNextQuestion();
      }
    } else {
      // Incorrect: Move player backward and mark the chosen option as selected (turns red)
      setState(() {
        _playerPosition = max(_playerPosition - _wrongAnswerPenalty, 0);
        selectedOption = selected;
      });
    }
  }

  void _showLoseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Race Lost!'),
        content:
            const Text('Try again! Answer questions faster to win the race.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _playerPosition = 5; // Reset to initial visible position
      _aiPositions = [5.0, 5.0, 5.0]; // Reset to initial visible positions
      _elapsedSeconds = 0;
      _gameOver = false;
      _playerWon = false;
      showQuestion = true;
    });
    _startGameTimer();
    _showNextQuestion();
  }

  /// Award XP for completing the game
  void _awardXPForCompletion(BuildContext context) {
    try {
      // Access the XP manager
      final xpManager = Provider.of<XPManager>(context, listen: false);

      // Award XP for game completion
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
      AppLogger.e('Error awarding XP in Racing Game', error: e);
    }
  }

  /// Show custom level up animation with earth unlocked
  void _showEarthUnlockedAnimation(BuildContext context, int newLevel) {
    EarthUnlockAnimation.show(context, newLevel);
  }

  /// Navigates to the next lesson with proper transitions
  Future<void> _goToNextLesson() async {
    // Award XP for completing the game
    _awardXPForCompletion(context);

    await _audioPlayer.play(AssetSource('congrats.mp3'));

    final marks = 10;

    await markQuizAsCompleted(
      subtopicId: widget.subtopicId,
      marksEarned: marks,
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

    debugPrint('[RacingGame] Progress saved for ${widget.subtopicId}');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Racing Game",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            letterSpacing: 1.2,
            color: Colors.green.shade800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: Colors.green.shade800,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "${_elapsedSeconds}s",
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Answer questions correctly to make your car move!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Race Track (takes about 40% of screen)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildRaceTrack(),
            ),
          ),

          // Question Area (takes about 60% of screen)
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildQuestionArea(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceTrack() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          // Finish line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Checkered pattern
                  ...List.generate(40, (index) {
                    bool isWhite = (index ~/ 5 + index % 5) % 2 == 0;
                    return Positioned(
                      left: (index *
                          (MediaQuery.of(context).size.width - 32) /
                          40),
                      top: 0,
                      child: Column(
                        children: [
                          Container(
                            width:
                                (MediaQuery.of(context).size.width - 32) / 40,
                            height: 15,
                            color: isWhite ? Colors.white : Colors.black,
                          ),
                          Container(
                            width:
                                (MediaQuery.of(context).size.width - 32) / 40,
                            height: 15,
                            color: !isWhite ? Colors.white : Colors.black,
                          ),
                        ],
                      ),
                    );
                  }),
                  // Finish text
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        margin:
                            const EdgeInsets.only(top: 2, left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          "FINISH LINE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 3,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lane dividers
          ...List.generate(3, (index) {
            double leftPosition =
                (index + 1) * (MediaQuery.of(context).size.width - 32) / 4;
            return Positioned(
              top: 30, // Start below finish line
              bottom: 0,
              left: leftPosition,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }),

          // Lane numbers
          ...List.generate(4, (index) {
            double leftPosition =
                index * (MediaQuery.of(context).size.width - 32) / 4 + 15;
            return Positioned(
              bottom: 5,
              left: leftPosition,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),

          // AI Cars
          ..._aiPositions.asMap().entries.map((entry) {
            int index = entry.key;
            double position = entry.value;
            // Calculate lane position: Each lane is 1/4 of the track width
            // Lane 1: 3/8 width, Lane 2: 5/8 width, Lane 3: 7/8 width
            double trackWidth = MediaQuery.of(context).size.width - 32;
            double laneWidth = trackWidth / 4;
            double leftPosition = (index + 1.5) * laneWidth - 15;
            return Positioned(
              bottom: position *
                  ((MediaQuery.of(context).size.height * 0.4) - 20) /
                  100,
              left: leftPosition,
              child: _buildCar(
                  index == 0
                      ? Colors.red.shade800
                      : index == 1
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                  "AI ${index + 1}"),
            );
          }).toList(),

          // Player Car (in first lane)
          Positioned(
            bottom: _playerPosition *
                ((MediaQuery.of(context).size.height * 0.4) - 20) /
                100,
            // Player car in lane 0 (1/8 width)
            left: (MediaQuery.of(context).size.width - 32) / 8 - 15,
            child: _buildCar(Colors.blue, "YOU"),
          ),
        ],
      ),
    );
  }

  Widget _buildCar(Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Car body
        Container(
          width: 30,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Headlights
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              // Windshield
              Container(
                margin: const EdgeInsets.only(top: 15, left: 5, right: 5),
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        // Car label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionArea() {
    if (currentQuestion == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade800, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                currentQuestion!["question"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Answer choices
            ...currentQuestion!["answers"].asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              bool isSelected = (option == selectedOption);
              bool isCorrect = (option == currentQuestion!["correct_answer"]);
              Color bgColor = Colors.white;

              if (isSelected) {
                bgColor =
                    isCorrect ? Colors.green.shade100 : Colors.red.shade100;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    side: BorderSide(
                      color: isSelected
                          ? (isCorrect ? Colors.green : Colors.red)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1),
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ['A', 'B', 'C', 'D'][index],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // Game status or helper text
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.shade700),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lightbulb_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Answer correctly to speed up your car! Beat the other cars to win!",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
