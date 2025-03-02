import 'package:flutter/material.dart';

class TypewriterAnimationDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration delay;

  const TypewriterAnimationDot({
    super.key,
    required this.color,
    this.size = 8.0,
    required this.delay,
  });

  @override
  _TypewriterAnimationDotState createState() => _TypewriterAnimationDotState();
}

class _TypewriterAnimationDotState extends State<TypewriterAnimationDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.3 + (0.7 * _animation.value)),
            borderRadius: BorderRadius.circular(widget.size / 2),
          ),
        );
      },
    );
  }
}

class GeminiStyleTypingIndicator extends StatelessWidget {
  final Color primaryColor;

  const GeminiStyleTypingIndicator({
    super.key,
    this.primaryColor = const Color(0xFF4285F4), // Google Blue
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(right: 64, left: 12, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.smart_toy_outlined,
              size: 16,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              TypewriterAnimationDot(
                color: primaryColor,
                delay: Duration.zero,
              ),
              const SizedBox(width: 5),
              TypewriterAnimationDot(
                color: primaryColor,
                delay: const Duration(milliseconds: 200),
              ),
              const SizedBox(width: 5),
              TypewriterAnimationDot(
                color: primaryColor,
                delay: const Duration(milliseconds: 400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}