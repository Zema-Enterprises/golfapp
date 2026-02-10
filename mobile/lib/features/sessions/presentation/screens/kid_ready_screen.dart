import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../providers/sessions_provider.dart';

/// Kid-friendly countdown screen before drills start (3-2-1-GO!)
class KidReadyScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const KidReadyScreen({super.key, required this.sessionId});

  @override
  ConsumerState<KidReadyScreen> createState() => _KidReadyScreenState();
}

class _KidReadyScreenState extends ConsumerState<KidReadyScreen>
    with TickerProviderStateMixin {
  int _countdown = 3;
  bool _showGo = false;
  Timer? _timer;

  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _scaleController.forward(from: 0.0);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
        _scaleController.forward(from: 0.0);
      } else {
        setState(() {
          _showGo = true;
        });
        _scaleController.forward(from: 0.0);
        timer.cancel();

        // Navigate to drill screen after showing "GO!"
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            context.go('/session/${widget.sessionId}/drill');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getCountdownColor() {
    if (_showGo) return AppColors.greenMain;
    switch (_countdown) {
      case 3:
        return AppColors.coral;
      case 2:
        return AppColors.accent;
      case 1:
        return AppColors.secondary;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(activeSessionProvider);
    final drillCount = sessionState.session?.drills.length ?? 0;
    final color = _getCountdownColor();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withAlpha(200)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Motivational text at top
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Text(
                    _showGo ? 'Let\'s Play!' : 'Get Ready!',
                    style: AppTypography.kidHeadline.copyWith(
                      color: Colors.white.withAlpha(230),
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Big countdown number or GO
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withAlpha(100),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _showGo ? 'GO!' : '$_countdown',
                        style: AppTypography.kidHeadline.copyWith(
                          fontSize: _showGo ? 56 : 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Drill count info
                Text(
                  '$drillCount drills today',
                  style: AppTypography.kidBody.copyWith(
                    color: Colors.white.withAlpha(200),
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
