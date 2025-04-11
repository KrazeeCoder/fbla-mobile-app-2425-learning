import 'package:flutter/material.dart';
import '../services/streak_manager.dart';
import '../utils/app_logger.dart';
import 'dart:math' as math;

class StreakHomepage extends StatefulWidget {
  final String userId;

  const StreakHomepage({
    super.key,
    required this.userId,
  });

  @override
  State<StreakHomepage> createState() => _StreakHomepageState();
}

class _StreakHomepageState extends State<StreakHomepage>
    with SingleTickerProviderStateMixin {
  int _currentStreak = 0;
  bool _isLoading = true;
  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _loadStreak();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _flameAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flameController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  Future<void> _loadStreak() async {
    try {
      final streak = await StreakManager.getCurrentStreak(widget.userId);
      if (mounted) {
        setState(() {
          _currentStreak = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.e('Error loading streak', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _currentStreak > 0
              ? [
                  const Color(0xFFFF6B00).withOpacity(0.1),
                  const Color(0xFFFF8A00).withOpacity(0.1),
                ]
              : [
                  Colors.grey.shade100,
                  Colors.grey.shade200,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _currentStreak > 0
                ? const Color(0xFFFF6B00).withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _currentStreak > 0
              ? const Color(0xFFFF6B00).withOpacity(0.2)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
              ),
            )
          : Row(
              children: [
                // Animated Flame Icon
                AnimatedBuilder(
                  animation: _flameAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: _currentStreak > 0
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFFF6B00).withOpacity(0.12),
                                  const Color(0xFFFF8A00).withOpacity(0.08),
                                ],
                              )
                            : null,
                        color:
                            _currentStreak == 0 ? Colors.grey.shade200 : null,
                        shape: BoxShape.circle,
                        boxShadow: _currentStreak > 0
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF6B00).withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, -2 * _flameAnimation.value),
                          child: Transform.scale(
                            scale: 1.0 + (_flameAnimation.value * 0.05),
                            child: Icon(
                              Icons.local_fire_department,
                              color: _currentStreak > 0
                                  ? const Color.fromARGB(255, 255, 94, 0)
                                  : Colors.grey,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                // Streak Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentStreak == 0 ? "Start Your Streak" : "🔥 Streak",
                        style: TextStyle(
                          fontSize: 14,
                          color: _currentStreak > 0
                              ? const Color(0xFFFF6B00)
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _currentStreak == 0
                                ? "Complete a lesson today"
                                : "$_currentStreak ${_currentStreak == 1 ? 'day' : 'days'}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = _currentStreak > 0
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B00),
                                          Color(0xFFFF8A00)
                                        ],
                                      ).createShader(
                                        const Rect.fromLTWH(
                                            0.0, 0.0, 200.0, 70.0),
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.grey.shade600,
                                          Colors.grey.shade400,
                                        ],
                                      ).createShader(
                                        const Rect.fromLTWH(
                                            0.0, 0.0, 200.0, 70.0),
                                      ),
                            ),
                          ),
                          if (_currentStreak > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              "• ${_currentStreak ~/ 7} ${_currentStreak ~/ 7 == 1 ? 'week' : 'weeks'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Streak Progress
                if (_currentStreak > 0)
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF6B00).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            value: (_currentStreak % 7) / 7,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF6B00)),
                            strokeWidth: 4,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${_currentStreak % 7}/7",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B00),
                              ),
                            ),
                            Text(
                              "days",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
