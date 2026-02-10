import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/constants.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../providers/sessions_provider.dart';

/// Celebration screen shown when all drills are completed
class SessionCompleteScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionCompleteScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionCompleteScreen> createState() =>
      _SessionCompleteScreenState();
}

class _SessionCompleteScreenState
    extends ConsumerState<SessionCompleteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _trophyController;
  late final Animation<double> _trophyScale;
  late final AnimationController _starsController;
  late final Animation<double> _starsOpacity;
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _trophyScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _trophyController, curve: Curves.elasticOut),
    );

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _starsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starsController, curve: Curves.easeIn),
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _playAnimation();
  }

  Future<void> _playAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _trophyController.forward();
    _confettiController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _starsController.forward();
  }

  @override
  void dispose() {
    _trophyController.dispose();
    _starsController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleViewSummary() {
    context.go('/session/${widget.sessionId}/summary');
  }

  void _handleGoHome() {
    ref.read(activeSessionProvider.notifier).clearSession();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(activeSessionProvider);
    final session = sessionState.session;
    final totalDrills = session?.drills.length ?? 0;
    final totalStars = totalDrills * AppConstants.starsPerDrill;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.greenHeader,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti background effect
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _ConfettiPainter(
                      progress: _confettiController.value,
                    ),
                  );
                },
              ),

              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Trophy animation
                      AnimatedBuilder(
                        animation: _trophyScale,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _trophyScale.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '\uD83C\uDFC6',
                              style: TextStyle(fontSize: 72),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Great job text
                      Text(
                        'Great Job!',
                        style: AppTypography.kidHeadline.copyWith(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        'You finished all your drills!',
                        style: AppTypography.kidBody.copyWith(
                          color: Colors.white.withAlpha(220),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Stars earned
                      AnimatedBuilder(
                        animation: _starsOpacity,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _starsOpacity.value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: Colors.white.withAlpha(60),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  totalStars.clamp(0, 8),
                                  (index) => const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 32,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '$totalStars Stars Earned!',
                                style: AppTypography.title.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Action buttons
                      KidButton(
                        label: 'SEE SUMMARY',
                        onPressed: _handleViewSummary,
                        backgroundColor: Colors.white,
                        textColor: AppColors.greenMain,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      TextButton(
                        onPressed: _handleGoHome,
                        child: Text(
                          'Go Home',
                          style: AppTypography.body.copyWith(
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple confetti painter
class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final colors = [
      AppColors.accent,
      Colors.white,
      AppColors.coral,
      AppColors.yellow,
    ];

    for (int i = 0; i < 20; i++) {
      final x = (size.width * ((i * 7 + 3) % 20) / 20);
      final startY = -20.0;
      final endY = size.height * 0.7;
      final y = startY + (endY - startY) * progress * ((i % 3 + 1) / 3);
      final color = colors[i % colors.length].withAlpha(
        (180 * (1 - progress * 0.5)).toInt(),
      );

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final rectSize = 6.0 + (i % 4) * 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y),
            width: rectSize,
            height: rectSize * 1.5,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
