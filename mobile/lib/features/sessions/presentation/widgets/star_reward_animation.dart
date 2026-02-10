import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

/// Animated star reward widget shown when a drill is completed
class StarRewardAnimation extends StatefulWidget {
  final int starsEarned;
  final VoidCallback? onComplete;

  const StarRewardAnimation({
    super.key,
    required this.starsEarned,
    this.onComplete,
  });

  @override
  State<StarRewardAnimation> createState() => _StarRewardAnimationState();
}

class _StarRewardAnimationState extends State<StarRewardAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _starController;
  late final AnimationController _burstController;
  late final Animation<double> _starScale;
  late final Animation<double> _starRotation;
  late final Animation<double> _burstScale;
  late final Animation<double> _burstOpacity;

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _starScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _starController,
        curve: Curves.elasticOut,
      ),
    );

    _starRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _starController,
        curve: Curves.easeOut,
      ),
    );

    _burstController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _burstScale = Tween<double>(begin: 0.5, end: 2.0).animate(
      CurvedAnimation(
        parent: _burstController,
        curve: Curves.easeOut,
      ),
    );

    _burstOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _burstController,
        curve: Curves.easeIn,
      ),
    );

    _playAnimation();
  }

  Future<void> _playAnimation() async {
    // Burst effect first
    _burstController.forward();

    // Stars pop in slightly after
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    await _starController.forward();

    // Wait for user to see the result
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Burst particles
          AnimatedBuilder(
            animation: _burstController,
            builder: (context, child) {
              return Opacity(
                opacity: _burstOpacity.value,
                child: Transform.scale(
                  scale: _burstScale.value,
                  child: _BurstParticles(color: AppColors.accent),
                ),
              );
            },
          ),

          // Stars
          AnimatedBuilder(
            animation: _starController,
            builder: (context, child) {
              return Transform.scale(
                scale: _starScale.value,
                child: Transform.rotate(
                  angle: _starRotation.value,
                  child: child,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.starsEarned, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star_rounded,
                    size: 48,
                    color: AppColors.accent,
                    shadows: [
                      Shadow(
                        color: AppColors.accent.withAlpha(100),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Stars earned text
          Positioned(
            bottom: 0,
            child: AnimatedBuilder(
              animation: _starController,
              builder: (context, child) {
                return Opacity(
                  opacity: _starScale.value.clamp(0.0, 1.0),
                  child: child,
                );
              },
              child: Text(
                '+${widget.starsEarned} Stars!',
                style: AppTypography.title.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple burst particle effect
class _BurstParticles extends StatelessWidget {
  final Color color;

  const _BurstParticles({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: _BurstPainter(color: color),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final Color color;

  _BurstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withAlpha(150)
      ..style = PaintingStyle.fill;

    // Draw small circles radiating outward
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi;
      final radius = size.width / 2 * 0.6;
      final offset = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawCircle(offset, 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
