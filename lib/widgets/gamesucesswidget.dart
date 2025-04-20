import 'package:flutter/material.dart';
import '../utils/app_logger.dart';
import 'package:showcaseview/showcaseview.dart';
import '../pages/subtopic_page.dart';

class GameSuccessMessage extends StatefulWidget {
  final VoidCallback onNext;
  // Optional direct navigation properties
  final String? nextSubtopicId;
  final String? nextSubtopicTitle;
  final String? nextReadingContent;
  final String? subject;
  final int? grade;
  final int? unitId;
  final String? unitTitle;
  final String? userId;

  const GameSuccessMessage({
    super.key,
    required this.onNext,
    this.nextSubtopicId,
    this.nextSubtopicTitle,
    this.nextReadingContent,
    this.subject,
    this.grade,
    this.unitId,
    this.unitTitle,
    this.userId,
  });

  @override
  State<GameSuccessMessage> createState() => _GameSuccessMessageState();
}

class _GameSuccessMessageState extends State<GameSuccessMessage> {
  bool _isNavigating = false;
  bool _navigateDirectly = false;

  @override
  void initState() {
    super.initState();
    // Check if we have all the data needed for direct navigation
    _navigateDirectly = widget.nextSubtopicId != null &&
        widget.nextSubtopicTitle != null &&
        widget.nextReadingContent != null &&
        widget.subject != null &&
        widget.grade != null &&
        widget.unitId != null &&
        widget.unitTitle != null &&
        widget.userId != null;
  }

  void _safeNavigate() {
    // Only allow navigation once
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      // Call the onNext callback safely
      widget.onNext();

      // Set a timeout to reset the navigation state if it gets stuck
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isNavigating && _navigateDirectly) {
          _performDirectNavigation();
        }
      });
    } catch (e) {
      AppLogger.e("Error during navigation: $e");

      // Only show error if still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Navigation error: Please try again"),
            backgroundColor: Colors.red,
          ),
        );

        // Reset navigation state so user can try again
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  void _performDirectNavigation() {
    if (!_navigateDirectly) return;

    AppLogger.i("Attempting direct navigation");

    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
            builder: (context) => SubtopicPage(
              subtopic: widget.nextSubtopicTitle!,
              subtopicId: widget.nextSubtopicId!,
              readingTitle: widget.nextSubtopicTitle!,
              readingContent: widget.nextReadingContent!,
              isCompleted: false,
              subject: widget.subject!,
              grade: widget.grade!,
              unitId: widget.unitId!,
              unitTitle: widget.unitTitle!,
              userId: widget.userId!,
              lastSubtopicofUnit: false,
              lastSubtopicofGrade: false,
              lastSubtopicofSubject: false,
            ),
          ),
          settings: const RouteSettings(name: 'DirectNextLesson'),
        ),
      );
    } catch (e) {
      AppLogger.e("Direct navigation failed: $e");
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Navigation failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "🎉 Well Done! You've completed this challenge! 🎉",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isNavigating ? null : _safeNavigate,
          icon: _isNavigating
              ? Container(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ))
              : const Icon(Icons.arrow_forward, size: 20),
          label: Text(
            _isNavigating
                ? "Loading next lesson..."
                : "Continue to Next Lesson",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }
}
