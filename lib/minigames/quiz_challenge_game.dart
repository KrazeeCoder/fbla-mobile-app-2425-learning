import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../xp_manager.dart';
import '../utils/app_logger.dart';
import '../widgets/earth_unlock_animation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/updateprogress.dart';
import '../widgets/subtopic_widget.dart';
import '../utils/subTopicNavigation.dart';
import 'dart:async';

class QuizChallengeGame extends StatefulWidget {
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

  final bool lastSubtopicofUnit;
  final bool lastSubtopicofGrade;
  final bool lastSubtopicofSubject;

  const QuizChallengeGame({
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
    this.lastSubtopicofUnit = false,
    this.lastSubtopicofGrade = false,
    this.lastSubtopicofSubject = false,
  });

  @override
  _QuizChallengeGameState createState() => _QuizChallengeGameState();
}

class _QuizChallengeGameState extends State<QuizChallengeGame>
    with TickerProviderStateMixin {
  Map<String, dynamic>? subtopicNav;
  bool gameCompleted = false;
  List<Map<String, dynamic>> quizQuestions = [];
  Map<String, dynamic>? currentQuestion;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  int streak = 0;
  int maxStreak = 0;
  int timeLeft = 15;
  int requiredCorrectAnswers = 7;
  Timer? _timer;
  bool showFeedback = false;
  String? selectedAnswer;
  bool isAnswerCorrect = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _animation;

  // New game variables
  int coins = 0;
  int powerUps = 0;
  bool isPowerUpActive = false;
  Timer? powerUpTimer;
  int comboMultiplier = 1;
  int timeBonus = 0;
  List<String> availablePowerUps = [
    'Time Freeze',
    'Double Points',
    'Skip Question'
  ];
  String? activePowerUp;

  // Animation controllers for game effects
  late AnimationController _powerUpController;
  late Animation<double> _powerUpAnimation;
  late AnimationController _comboController;
  late Animation<double> _comboAnimation;

  List<Color> backgroundColors = [
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.purple.shade50,
    Colors.orange.shade50,
    Colors.teal.shade50,
  ];
  int currentColorIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    getSubtopicNavigationInfo(
      subject: widget.subject,
      grade: widget.grade,
      subtopicId: widget.subtopicId,
    ).then((value) {
      setState(() {
        subtopicNav = value;
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Initialize power-up animation
    _powerUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _powerUpAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _powerUpController,
        curve: Curves.elasticOut,
      ),
    );

    // Initialize combo animation
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _comboAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _comboController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    powerUpTimer?.cancel();
    _audioPlayer.dispose();
    _animationController.dispose();
    _powerUpController.dispose();
    _comboController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/content.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      List<Map<String, dynamic>> allQuestions =
          List<Map<String, dynamic>>.from(data['questions']);
      List<int> quizPool = [];

      // Find the quiz pool for this subtopic
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

      // Get questions from the pool
      List<Map<String, dynamic>> selectedQuestions =
          allQuestions.where((q) => quizPool.contains(q['id'] as int)).toList();
      selectedQuestions.shuffle();

      setState(() {
        quizQuestions = selectedQuestions;
        if (quizQuestions.isNotEmpty) {
          currentQuestion = quizQuestions[0];
          startTimer();
        }
      });
    } catch (e) {
      AppLogger.e('Error loading questions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void startTimer() {
    _timer?.cancel();
    setState(() {
      timeLeft = 15;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _timer?.cancel();
          if (!showFeedback) {
            handleTimeout();
          }
        }
      });
    });
  }

  void handleTimeout() {
    setState(() {
      streak = 0;
      incorrectAnswers++;
      showFeedback = true;
      isAnswerCorrect = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      moveToNextQuestion();
    });
  }

  void checkAnswer(String answer) {
    _timer?.cancel();

    bool correct = answer == currentQuestion!['correct_answer'];

    setState(() {
      selectedAnswer = answer;
      showFeedback = true;
      isAnswerCorrect = correct;

      if (correct) {
        // Calculate score with bonuses
        int baseScore = 100;
        int streakBonus = streak * 10;
        int timeBonus = timeLeft * 2;
        int comboBonus = comboMultiplier * 50;

        int totalScore =
            (baseScore + streakBonus + timeBonus) * comboMultiplier;
        coins += totalScore;

        correctAnswers++;
        streak++;
        if (streak > maxStreak) {
          maxStreak = streak;
        }
        _animationController
            .forward()
            .then((_) => _animationController.reverse());
        _comboController.forward().then((_) => _comboController.reverse());
      } else {
        streak = 0;
        comboMultiplier = 1;
        incorrectAnswers++;
      }
    });

    // Wait 1.5 seconds before moving to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      moveToNextQuestion();
    });
  }

  void moveToNextQuestion() {
    // Change background color
    setState(() {
      currentColorIndex = (currentColorIndex + 1) % backgroundColors.length;
      showFeedback = false;
      selectedAnswer = null;
    });

    if (correctAnswers >= requiredCorrectAnswers) {
      _goToNextLesson();
    } else {
      // Move to next question
      setState(() {
        currentQuestionIndex =
            (currentQuestionIndex + 1) % quizQuestions.length;
        currentQuestion = quizQuestions[currentQuestionIndex];
      });
      startTimer();
    }
  }

  void _goToNextLesson() async {
    await handleGameCompletion(
      context: context,
      audioPlayer: _audioPlayer,
      showSuccess: true,
      markSuccessState: () => setState(() => gameCompleted = true),
      subtopicId: widget.subtopicId,
      userId: widget.userId,
      subject: widget.subject,
      grade: widget.grade,
      unitId: widget.unitId,
      unitTitle: widget.unitTitle,
      subtopicTitle: widget.subtopicTitle,
      lastSubtopicofUnit: widget.lastSubtopicofUnit,
      lastSubtopicofGrade: widget.lastSubtopicofGrade,
      lastSubtopicofSubject: widget.lastSubtopicofSubject,
    );

    if (subtopicNav == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Unable to load next lesson. Please try again.")),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SubtopicPage(
          subtopic: subtopicNav?['nextSubtopic'],
          subtopicId: subtopicNav?['nextSubtopicId'],
          readingTitle: subtopicNav?['readingTitle'],
          readingContent: subtopicNav?['readingContent'],
          isCompleted: false,
          subject: widget.subject,
          grade: subtopicNav?['nextGrade'],
          unitId: subtopicNav?['unitId'],
          unitTitle: subtopicNav?['unitTitle'],
          userId: widget.userId,
          lastSubtopicofUnit: widget.lastSubtopicofUnit,
          lastSubtopicofGrade: widget.lastSubtopicofGrade,
          lastSubtopicofSubject: widget.lastSubtopicofSubject,
        ),
      ),
    );
  }

  void activatePowerUp(String powerUp) {
    if (powerUps <= 0) return;

    setState(() {
      powerUps--;
      activePowerUp = powerUp;
      isPowerUpActive = true;
    });

    switch (powerUp) {
      case 'Time Freeze':
        _timer?.cancel();
        powerUpTimer = Timer(const Duration(seconds: 5), () {
          setState(() {
            isPowerUpActive = false;
            activePowerUp = null;
          });
          startTimer();
        });
        break;
      case 'Double Points':
        comboMultiplier = 2;
        powerUpTimer = Timer(const Duration(seconds: 10), () {
          setState(() {
            comboMultiplier = 1;
            isPowerUpActive = false;
            activePowerUp = null;
          });
        });
        break;
      case 'Skip Question':
        moveToNextQuestion();
        setState(() {
          isPowerUpActive = false;
          activePowerUp = null;
        });
        break;
    }

    _powerUpController.forward().then((_) => _powerUpController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quiz Challenge",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            letterSpacing: 1.2,
            color: Colors.indigo.shade800,
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
                  Icons.check_circle,
                  color: Colors.green.shade800,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "$correctAnswers/$requiredCorrectAnswers",
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, backgroundColors[currentColorIndex]],
          ),
        ),
        child: SafeArea(
          child: currentQuestion == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildStatusBar(),
                    _buildPowerUpBar(),
                    _buildQuestionCard(),
                    _buildAnswerOptions(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: timeLeft <= 5 ? Colors.red.shade100 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: timeLeft <= 5 ? Colors.red : Colors.blue.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: timeLeft <= 5 ? Colors.red : Colors.blue.shade800,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "$timeLeft",
                  style: TextStyle(
                    color: timeLeft <= 5 ? Colors.red : Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Streak
          ScaleTransition(
            scale: _animation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.orange.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade800,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Streak: $streak",
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.purple.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.score,
                  color: Colors.purple.shade800,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "${correctAnswers - incorrectAnswers}",
                  style: TextStyle(
                    color: Colors.purple.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.amber.shade800,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "$coins",
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              if (isPowerUpActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.purple.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPowerUpIcon(activePowerUp!),
                        color: Colors.purple.shade800,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activePowerUp!,
                        style: TextStyle(
                          color: Colors.purple.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availablePowerUps
                  .map((powerUp) => _buildPowerUpButton(powerUp))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo.shade50, Colors.indigo.shade100],
            ),
          ),
          child: Column(
            children: [
              Text(
                "Question ${currentQuestionIndex + 1}",
                style: TextStyle(
                  color: Colors.indigo.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  currentQuestion?['question'] ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              if (showFeedback)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAnswerCorrect
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAnswerCorrect ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAnswerCorrect ? Icons.check_circle : Icons.cancel,
                        color: isAnswerCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAnswerCorrect ? "Correct!" : "Incorrect!",
                        style: TextStyle(
                          color: isAnswerCorrect
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions() {
    // Get options from current question
    List<String> options = List<String>.from(currentQuestion!['answers']);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < options.length; i++)
              _buildOptionButton(options[i], ['A', 'B', 'C', 'D'][i]),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option, String letter) {
    bool isSelected = selectedAnswer == option;
    bool isCorrect = currentQuestion!['correct_answer'] == option;

    // Determine button color based on feedback state
    Color buttonColor;
    Color textColor;

    if (showFeedback) {
      if (isCorrect) {
        buttonColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
      } else if (isSelected) {
        buttonColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
      } else {
        buttonColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
      }
    } else {
      buttonColor = Colors.white;
      textColor = Colors.indigo.shade800;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        elevation: isSelected ? 4 : 2,
        borderRadius: BorderRadius.circular(15),
        color: buttonColor,
        child: InkWell(
          onTap: showFeedback ? null : () => checkAnswer(option),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: showFeedback
                    ? isCorrect
                        ? Colors.green.shade500
                        : isSelected
                            ? Colors.red.shade500
                            : Colors.grey.shade300
                    : Colors.indigo.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: showFeedback
                        ? isCorrect
                            ? Colors.green.shade200
                            : isSelected
                                ? Colors.red.shade200
                                : Colors.grey.shade200
                        : Colors.indigo.shade100,
                    border: Border.all(
                      color: showFeedback
                          ? isCorrect
                              ? Colors.green.shade500
                              : isSelected
                                  ? Colors.red.shade500
                                  : Colors.grey.shade400
                          : Colors.indigo.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (showFeedback && isCorrect)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                  )
                else if (showFeedback && isSelected && !isCorrect)
                  Icon(
                    Icons.cancel,
                    color: Colors.red.shade600,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPowerUpButton(String powerUp) {
    return ScaleTransition(
      scale: _powerUpAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: () => activatePowerUp(powerUp),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.purple.shade300, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPowerUpIcon(powerUp),
                color: Colors.purple.shade800,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                powerUp,
                style: TextStyle(
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPowerUpIcon(String powerUp) {
    switch (powerUp) {
      case 'Time Freeze':
        return Icons.timer_off;
      case 'Double Points':
        return Icons.star;
      case 'Skip Question':
        return Icons.skip_next;
      default:
        return Icons.help;
    }
  }
}
