import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final Function(String) onAnswerSelected;

  MultipleChoiceQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.onAnswerSelected,
    Key? key,
  }) : super(key: key);

  @override
  _MultipleChoiceQuestionState createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  String? selectedAnswer;
  bool isCorrect = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 10.0), // Adds margin around the widget
      decoration: BoxDecoration(
        color: Color(0xFFDBDFFF), // Soft background color
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4), // Subtle shadow
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          ...widget.options.map((option) {
            return RadioListTile<String>(
              value: option,
              groupValue: selectedAnswer,
              onChanged: (String? value) {
                setState(() {
                  selectedAnswer = value;
                  isCorrect = selectedAnswer == widget.correctAnswer;
                });

                // Call the parent onAnswerSelected callback
                widget.onAnswerSelected(selectedAnswer!);

                // If correct, display feedback and mark letter as solved
                if (isCorrect) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Correct!", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Incorrect, try again!", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              title: Text(option, style: TextStyle(fontSize: 16)),
            );
          }).toList(),
          SizedBox(height: 20),
          if (selectedAnswer != null)
            Text(
              isCorrect ? 'Correct!' : 'Incorrect, try again!',
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
        ],
      ),
    );
  }
}
