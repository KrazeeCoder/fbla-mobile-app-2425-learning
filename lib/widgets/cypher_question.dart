import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? selectedAnswer;
  final bool previouslyAnswered;
  final bool isCorrectlyAnswered;
  final Function(String) onAnswerSelected;

  const MultipleChoiceQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.onAnswerSelected,
    required this.previouslyAnswered,
    required this.isCorrectlyAnswered,
    this.selectedAnswer,
    Key? key,
  }) : super(key: key);

  @override
  _MultipleChoiceQuestionState createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...widget.options.map((option) {
            bool isSelected = widget.selectedAnswer == option;
            bool isCorrectChoice = option == widget.correctAnswer;
            Color backgroundColor = widget.isCorrectlyAnswered
                ? (isCorrectChoice ? Colors.green : const Color(0xFFDFFFD6)) // Correct answer locks in green
                : (isSelected ? (isCorrectChoice ? Colors.green : Colors.red) : const Color(0xFFDFFFD6));

            return GestureDetector(
              onTap: widget.isCorrectlyAnswered ? null : () => widget.onAnswerSelected(option),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                child: Text(option, style: const TextStyle(fontSize: 18)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
