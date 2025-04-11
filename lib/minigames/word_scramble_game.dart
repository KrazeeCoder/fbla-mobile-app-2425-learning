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
import '../widgets/gamesucesswidget.dart';

class WordScrambleGame extends StatefulWidget {
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

  const WordScrambleGame({
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
  _WordScrambleGameState createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  bool showSuccess = false;
  Map<String, dynamic>? subtopicNav;
  bool puzzleCompleted = false;
  List<Map<String, dynamic>> quizQuestions = [];
  Map<String, dynamic>? currentQuestion;
  String? selectedOption;
  bool showQuestion = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Word scramble specific variables
  String scrambledWord = '';
  String correctWord = '';
  List<String> letters = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  final int requiredCorrectAnswers = 5;

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
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/content.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    List<Map<String, dynamic>> allQuestions =
        List<Map<String, dynamic>>.from(data['questions']);
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

    setState(() {
      quizQuestions = selectedQuestions;
      _showNextQuestion();
    });
  }

  void _showNextQuestion() {
    if (currentQuestionIndex >= quizQuestions.length) {
      currentQuestionIndex = 0;
    }

    setState(() {
      currentQuestion = quizQuestions[currentQuestionIndex];
      correctWord = currentQuestion!['correct_answer'];
      scrambledWord = _scrambleWord(correctWord);
      letters = scrambledWord.split('');
      showQuestion = true;
      selectedOption = null;
    });
  }

  String _scrambleWord(String word) {
    List<String> chars = word.split('');
    chars.shuffle();
    return chars.join();
  }

  void _checkAnswer(String answer) {
    if (answer == correctWord) {
      setState(() {
        correctAnswers++;
        showQuestion = false;
      });

      if (correctAnswers >= requiredCorrectAnswers && !showSuccess) {
        _handleGameCompletion(); // call completion first
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          currentQuestionIndex++;
          _showNextQuestion();
        });
      }
    } else {
      setState(() {
        selectedOption = answer;
      });
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
          lastSubtopicofUnit: subtopicNav?['isLastOfUnit'],
          lastSubtopicofGrade: subtopicNav?['isLastOfGrade'],
          lastSubtopicofSubject: subtopicNav?['isLastOfSubject'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Word Scramble",
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
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Title and Instructions
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.scatter_plot,
                        size: 40,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Unscramble the word to answer the question!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap letters to build your answer",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Question Card
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: Colors.blue.shade200, width: 1),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade50,
                                    Colors.blue.shade100
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.help_outline,
                                    color: Colors.blue,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    currentQuestion?['question'] ??
                                        'Loading...',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Scrambled Letters
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shuffle,
                                        color: Colors.purple.shade400,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Scrambled Letters",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      alignment: WrapAlignment.center,
                                      children: letters
                                          .map((letter) =>
                                              _buildLetterTile(letter))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Answer Input
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: selectedOption != null &&
                                        selectedOption != correctWord
                                    ? Colors.red
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.question_answer,
                                        color: Colors.green.shade600,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Your Answer",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selectedOption != null &&
                                                selectedOption != correctWord
                                            ? Colors.red
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedOption ??
                                                'Tap letters above to build word',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: selectedOption != null &&
                                                      selectedOption !=
                                                          correctWord
                                                  ? Colors.red
                                                  : selectedOption != null
                                                      ? Colors.green.shade700
                                                      : Colors.grey.shade600,
                                              fontStyle: selectedOption == null
                                                  ? FontStyle.italic
                                                  : FontStyle.normal,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        if (selectedOption != null &&
                                            selectedOption!.isNotEmpty)
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedOption = selectedOption!
                                                    .substring(
                                                        0,
                                                        selectedOption!.length -
                                                            1);
                                                if (selectedOption!.isEmpty) {
                                                  selectedOption = null;
                                                }
                                              });
                                            },
                                            icon: Icon(Icons.backspace,
                                                color: Colors.grey.shade700),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            selectedOption = null;
                                          });
                                        },
                                        icon: const Icon(Icons.clear),
                                        label: const Text('Clear'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade100,
                                          foregroundColor: Colors.red.shade800,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _checkAnswer(selectedOption ?? ''),
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Submit'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (showSuccess)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GameSuccessMessage(onNext: _goToNextLesson),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLetterTile(String letter) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (selectedOption == null) {
              selectedOption = letter;
            } else {
              selectedOption = selectedOption! + letter;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.shade200,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade100, Colors.blue.shade200],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
