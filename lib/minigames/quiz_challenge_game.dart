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
import '../widgets/gamesucesswidget.dart';
import '../utils/game_launcher.dart';

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
  });

  @override
  _QuizChallengeGameState createState() => _QuizChallengeGameState();
}

class _QuizChallengeGameState extends State<QuizChallengeGame>
    with TickerProviderStateMixin {
  Map<String, dynamic>? subtopicNav;
  bool gameCompleted = false;
  bool showSuccess = false;

  List<Map<String, dynamic>> quizQuestions = [];
  Map<String, dynamic>? currentQuestion;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  int streak = 0;
  int maxStreak = 0;
  int timeLeft = 20; // Increased from 15 to make it more player-friendly
  int requiredCorrectAnswers = 7;
  Timer? _timer;
  bool showFeedback = false;
  String? selectedAnswer;
  bool isAnswerCorrect = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Game score tracking
  int score = 0;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  // Animation controllers for game effects
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;

  List<Color> backgroundColors = [
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.purple.shade50,
    Colors.orange.shade50,
    Colors.teal.shade50,
  ];
  int currentColorIndex = 0;
  int consecutiveCorrect = 0;

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

    // Initialize score animation
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _scoreController,
        curve: Curves.elasticOut,
      ),
    );

    // Initialize feedback animation
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _feedbackAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _animationController.dispose();
    _scoreController.dispose();
    _feedbackController.dispose();
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
      timeLeft = 20; // Increased time
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
      consecutiveCorrect = 0;
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
        int basePoints = 100;
        int streakBonus = streak * 20;
        int timeBonus = timeLeft * 5;

        int pointsEarned = basePoints + streakBonus + timeBonus;
        score += pointsEarned;

        correctAnswers++;
        streak++;
        consecutiveCorrect++;

        if (streak > maxStreak) {
          maxStreak = streak;
        }

        _animationController
            .forward()
            .then((_) => _animationController.reverse());
        _scoreController.forward().then((_) => _scoreController.reverse());
        _feedbackController
            .forward()
            .then((_) => _feedbackController.reverse());
      } else {
        streak = 0;
        consecutiveCorrect = 0;
        incorrectAnswers++;
        _feedbackController
            .forward()
            .then((_) => _feedbackController.reverse());
      }
    });

    // Wait before moving to next question (longer for incorrect answers)
    Future.delayed(Duration(milliseconds: correct ? 1200 : 1800), () {
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
      _handleGameCompletion();
      return;
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

  Future<void> _handleGameCompletion() async {
    if (showSuccess) return;

    await handleGameCompletion(
      context: context,
      audioPlayer: _audioPlayer,
      subtopicId: widget.subtopicId,
      userId: widget.userId,
      subject: widget.subject,
      grade: widget.grade,
      unitId: widget.unitId,
      unitTitle: widget.unitTitle,
      subtopicTitle: widget.subtopicTitle,
      lastSubtopicofUnit: subtopicNav?['isLastOfUnit'],
      lastSubtopicofGrade: subtopicNav?['isLastOfGrade'],
      lastSubtopicofSubject: subtopicNav?['isLastOfSubject'],
    );

    setState(() {
      showSuccess = true;
    });
  }

  void _goToNextLesson() async {
    try {
      // Check if widget is still mounted before using context
      if (!mounted) {
        AppLogger.w("Widget not mounted during navigation attempt");
        return;
      }

      // Check if navigation data is available
      if (widget.nextSubtopicId.isEmpty || widget.nextReadingContent.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Unable to load next lesson. Please try again.")),
          );
        }
        return;
      }

      // Direct navigation to next lesson
      navigateToNextLesson(
        context: context,
        subject: widget.subject,
        grade: widget.grade,
        unitId: widget.unitId,
        unitTitle: widget.unitTitle,
        nextSubtopicId: widget.nextSubtopicId,
        nextSubtopicTitle: widget.nextSubtopicTitle,
        nextReadingContent: widget.nextReadingContent,
        userId: widget.userId,
      );
    } catch (e) {
      AppLogger.e("Error navigating to next lesson from QuizChallengeGame: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false, // We’ll manually add the back button
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // 👈 Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  const SizedBox(width: 8),

                  // Title + Spacer + Progress
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quiz Challenge",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            letterSpacing: 1.2,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                        Container(
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
                  ),
                ],
              ),
            ),
          ),
        ),
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
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        "Loading Quiz Challenge...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: Colors.indigo.shade200),
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.indigo.shade700, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Grade ${widget.grade} | ${widget.unitTitle} | ${widget.subtopicTitle}",
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.indigo.shade700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),


                              _buildStatusBar(),
                              _buildScoreDisplay(),
                              _buildQuestionCard(),
                              Expanded(child: _buildAnswerOptions()),
                              if (showSuccess)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: GameSuccessMessage(
                                    onNext: _goToNextLesson,
                                    nextSubtopicId: widget.nextSubtopicId,
                                    nextSubtopicTitle: widget.nextSubtopicTitle,
                                    nextReadingContent:
                                        widget.nextReadingContent,
                                    subject: widget.subject,
                                    grade: widget.grade,
                                    unitId: widget.unitId,
                                    unitTitle: widget.unitTitle,
                                    userId: widget.userId,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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

          // Progress indicator
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
                  Icons.quiz,
                  color: Colors.purple.shade800,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "${currentQuestionIndex + 1}/${quizQuestions.length}",
                  style: TextStyle(
                    color: Colors.purple.shade800,
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
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: ScaleTransition(
        scale: _scoreAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.stars,
                color: Colors.amber.shade800,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Score: $score",
                style: TextStyle(
                  color: Colors.amber.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              if (consecutiveCorrect >= 3)
                Row(
                  children: [
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.whatshot,
                              color: Colors.red.shade700, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "HOT STREAK!",
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
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
              // Timer hint text
              if (!showFeedback)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: timeLeft <= 5
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: timeLeft <= 5
                          ? Colors.red.shade300
                          : Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: timeLeft <= 5
                            ? Colors.red.shade700
                            : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Answer before time runs out!",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: timeLeft <= 5
                              ? Colors.red.shade700
                              : Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              if (showFeedback)
                ScaleTransition(
                  scale: _feedbackAnimation,
                  child: Container(
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
                          isAnswerCorrect
                              ? "Correct! +${streak * 20 + timeLeft * 5 + 100} points"
                              : "Incorrect!",
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
}
