import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? selectedAnswer;
  final bool previouslyAnswered;
  final bool isCorrectlyAnswered;
  final Function(String) onAnswerSelected;
  final TextStyle questionTextStyle;

  const MultipleChoiceQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.onAnswerSelected,
    required this.previouslyAnswered,
    required this.isCorrectlyAnswered,
    this.selectedAnswer,
    this.questionTextStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    Key? key,
  }) : super(key: key);

  @override
  _MultipleChoiceQuestionState createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),  // Slightly reduce padding around the whole container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Question Text
          Text(
            widget.question,
            style: widget.questionTextStyle,
          ),
          const SizedBox(height: 16),  // Slightly smaller spacing

          // ✅ Answer Options with Smaller Box Height
          ...widget.options.map((option) {
            bool isSelected = widget.selectedAnswer == option;
            bool isCorrectChoice = option == widget.correctAnswer;

            Color backgroundColor = widget.isCorrectlyAnswered
                ? (isCorrectChoice ? Colors.green : const Color(0xFFDFFFD6)) // Correct answers remain green
                : (isSelected ? (isCorrectChoice ? Colors.green : Colors.red) : const Color(0xFFDFFFD6));

            return GestureDetector(
              onTap: widget.isCorrectlyAnswered ? null : () => widget.onAnswerSelected(option),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),  // Reduce margin between boxes
                height: 45,  // ✅ Smaller box height
                width: double.infinity,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),  // ✅ Internal padding
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,  // ✅ Left-align text with padding
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 16),  // ✅ Slightly smaller text size
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
