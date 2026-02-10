import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/constants.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../providers/sessions_provider.dart';
import '../widgets/pin_verification_dialog.dart';
import '../widgets/star_reward_animation.dart';

/// Kid-friendly drill execution screen
class KidDrillScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const KidDrillScreen({super.key, required this.sessionId});

  @override
  ConsumerState<KidDrillScreen> createState() => _KidDrillScreenState();
}

class _KidDrillScreenState extends ConsumerState<KidDrillScreen>
    with TickerProviderStateMixin {
  bool _showReward = false;
  bool _isCompletingDrill = false;

  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _handleDrillDone() async {
    if (_isCompletingDrill) return;

    // Show PIN verification dialog
    final verified = await showPinVerificationDialog(context, ref);
    if (!verified || !mounted) return;

    setState(() {
      _isCompletingDrill = true;
    });

    // Complete the drill via API
    final success =
        await ref.read(activeSessionProvider.notifier).completeDrill();

    if (!mounted) return;

    if (success) {
      // Show star reward animation
      setState(() {
        _showReward = true;
        _isCompletingDrill = false;
      });
    } else {
      setState(() {
        _isCompletingDrill = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again!')),
        );
      }
    }
  }

  void _onRewardComplete() {
    if (!mounted) return;

    setState(() {
      _showReward = false;
    });

    final sessionState = ref.read(activeSessionProvider);

    // Check if all drills are done
    if (!sessionState.hasMoreDrills ||
        sessionState.session?.allDrillsCompleted == true) {
      // Complete the session and navigate to complete screen
      ref.read(activeSessionProvider.notifier).completeSession();
      context.go('/session/${widget.sessionId}/complete');
    }
    // Otherwise, the screen rebuilds to show the next drill
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(activeSessionProvider);
    final session = sessionState.session;
    final currentDrill = sessionState.currentDrill;

    if (session == null || currentDrill == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final drillIndex = sessionState.currentDrillIndex;
    final totalDrills = session.drills.length;
    final drill = currentDrill.drill;

    return KidModeScaffold(
      headerContent: Column(
        children: [
          // Progress dots + drill counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Drill ${drillIndex + 1} of $totalDrills',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              // Star indicators
              Row(
                children: List.generate(totalDrills, (index) {
                  final isCompleted = index < drillIndex;
                  final isCurrent = index == drillIndex;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      isCompleted
                          ? Icons.star_rounded
                          : isCurrent
                              ? Icons.star_half_rounded
                              : Icons.star_outline_rounded,
                      size: 22,
                      color: isCompleted || isCurrent
                          ? AppColors.accent
                          : Colors.white.withAlpha(100),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress dots
          ProgressDots(
            total: totalDrills,
            current: drillIndex,
          ),
        ],
      ),
      bodyContent: Stack(
        children: [
          // Main drill content
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),

                // Drill category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    drill?.skillCategory ?? 'Practice',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Drill name (large, kid-friendly)
                Text(
                  drill?.name ?? 'Drill ${drillIndex + 1}',
                  style: AppTypography.kidHeadline.copyWith(
                    color: AppColors.gray800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Drill illustration placeholder
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.blueLight.withAlpha(80),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_golf,
                        size: 56,
                        color: AppColors.secondary.withAlpha(150),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          drill?.description ?? '',
                          style: AppTypography.body.copyWith(
                            color: AppColors.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Instructions card — orangeLight background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'How to do it',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.gray800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        drill?.instructions ??
                            'Follow the drill instructions!',
                        style: AppTypography.body.copyWith(
                          color: AppColors.gray700,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Stars to earn
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 28,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Earn ${AppConstants.starsPerDrill} stars!',
                      style: AppTypography.kidBody.copyWith(
                        color: AppColors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Extra space for the button
                const SizedBox(height: 120),
              ],
            ),
          ),

          // "I DID IT!" button at the bottom — orange KidButton
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                );
              },
              child: SafeArea(
                top: false,
                child: KidButton(
                  label: 'I DID IT!',
                  onPressed: _isCompletingDrill ? null : _handleDrillDone,
                  backgroundColor: AppColors.accent,
                  isLoading: _isCompletingDrill,
                ),
              ),
            ),
          ),

          // Star reward overlay
          if (_showReward)
            Container(
              color: Colors.black.withAlpha(120),
              child: Center(
                child: StarRewardAnimation(
                  starsEarned: AppConstants.starsPerDrill,
                  onComplete: _onRewardComplete,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
