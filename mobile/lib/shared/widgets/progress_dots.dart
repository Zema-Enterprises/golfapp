import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Horizontal progress dots indicator.
/// Shows completed (green), current (orange + pulse), and pending (gray) dots.
class ProgressDots extends StatefulWidget {
  final int total;
  final int current;

  const ProgressDots({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  State<ProgressDots> createState() => _ProgressDotsState();
}

class _ProgressDotsState extends State<ProgressDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.total, (index) {
        final isCompleted = index < widget.current;
        final isCurrent = index == widget.current;

        Widget dot = Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.greenMain
                : isCurrent
                    ? AppColors.orange
                    : AppColors.gray300,
          ),
        );

        if (isCurrent) {
          dot = AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              );
            },
            child: dot,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: dot,
        );
      }),
    );
  }
}
