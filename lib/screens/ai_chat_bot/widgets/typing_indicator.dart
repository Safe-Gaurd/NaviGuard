import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';

// Widget for typing indicator
class GeminiStyleTypingIndicator extends StatefulWidget {
  const GeminiStyleTypingIndicator({Key? key}) : super(key: key);

  @override
  State<GeminiStyleTypingIndicator> createState() => _GeminiStyleTypingIndicatorState();
}

class _GeminiStyleTypingIndicatorState extends State<GeminiStyleTypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(isUser: false),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildDot(0.0),
                  const SizedBox(width: 4),
                  _buildDot(0.2),
                  const SizedBox(width: 4),
                  _buildDot(0.4),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDot(double delay) {
    final delayedValue = (_controller.value - delay) % 1.0;
    final opacity = delayedValue < 0.0 ? 0.0 : (delayedValue < 0.5 ? delayedValue * 2 : (1.0 - delayedValue) * 2);

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: blueColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        backgroundColor: isUser
            ? const Color(0xFF4285F4).withOpacity(0.8)
            : Colors.grey.shade200,
        radius: 16,
        child: Icon(
          isUser ? Icons.person : Icons.smart_toy_outlined,
          color: isUser ? Colors.white : const Color(0xFF4285F4),
          size: 18,
        ),
      ),
    );
  }
}
