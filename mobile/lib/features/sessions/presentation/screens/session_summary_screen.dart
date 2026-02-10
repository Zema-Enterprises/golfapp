import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/constants.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/session.dart';
import '../../providers/sessions_provider.dart';

/// Session summary showing drills completed and stars earned
class SessionSummaryScreen extends ConsumerWidget {
  final String sessionId;

  const SessionSummaryScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(activeSessionProvider);
    final session = sessionState.session;

    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.gray100,
        body: const ErrorView(message: 'Session not found'),
      );
    }

    final completedDrills =
        session.drills.where((d) => d.isCompleted).toList();
    final totalStars = completedDrills.length * AppConstants.starsPerDrill;
    final allCompleted = completedDrills.length == session.drills.length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.greenHeader,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref.read(activeSessionProvider.notifier).clearSession();
                        context.go('/');
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Session Summary',
                      style: AppTypography.title.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),

              // White summary card
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Main summary card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          boxShadow: AppShadows.large,
                        ),
                        child: Column(
                          children: [
                            // Status icon
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: allCompleted
                                    ? AppColors.greenPale
                                    : AppColors.orangeLight,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  allCompleted ? '\uD83C\uDFC6' : '\u23F0',
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Status text
                            Text(
                              allCompleted ? 'All Done!' : 'Session Ended',
                              style: AppTypography.headline.copyWith(
                                color: AppColors.gray800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _SummaryStat(
                                  emoji: '\u26F3',
                                  value: '${completedDrills.length}/${session.drills.length}',
                                  label: 'Drills',
                                ),
                                _SummaryStat(
                                  emoji: '\u2B50',
                                  value: '$totalStars',
                                  label: 'Stars',
                                ),
                                _SummaryStat(
                                  emoji: '\uD83C\uDFAF',
                                  value: '${session.drills.isNotEmpty ? (completedDrills.length / session.drills.length * 100).round() : 0}%',
                                  label: 'Complete',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Unlock notification (if all completed)
                      if (allCompleted)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.orangeLight,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Row(
                            children: [
                              const Text('\uD83C\uDF1F', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'You earned $totalStars stars! Visit the Avatar Shop to unlock new items.',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.gray800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Drills breakdown header
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Drills Completed',
                          style: AppTypography.title.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Drill result cards
                      ...session.drills.map((sessionDrill) {
                        return _DrillResultCard(sessionDrill: sessionDrill);
                      }),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),

              // Bottom action buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: 'Back to Dashboard',
                      icon: Icons.home,
                      backgroundColor: Colors.white,
                      textColor: AppColors.greenMain,
                      onPressed: () {
                        ref.read(activeSessionProvider.notifier).clearSession();
                        context.go('/');
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SecondaryButton(
                      label: 'Practice Again',
                      icon: Icons.replay,
                      borderColor: Colors.white,
                      textColor: Colors.white,
                      onPressed: () {
                        ref.read(activeSessionProvider.notifier).clearSession();
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Summary stat item with emoji
class _SummaryStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _SummaryStat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.title.copyWith(
            color: AppColors.gray800,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}

/// Individual drill result card
class _DrillResultCard extends StatelessWidget {
  final SessionDrill sessionDrill;

  const _DrillResultCard({required this.sessionDrill});

  @override
  Widget build(BuildContext context) {
    final drill = sessionDrill.drill;
    final isCompleted = sessionDrill.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.drillCard,
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.greenPale
                  : AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.remove,
              size: 20,
              color: isCompleted
                  ? AppColors.greenMain
                  : AppColors.gray500,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Drill info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drill?.name ?? 'Drill',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  drill?.skillCategory ?? '',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          // Stars earned
          if (isCompleted)
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 2),
                Text(
                  '+${AppConstants.starsPerDrill}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Text(
              'Skipped',
              style: AppTypography.caption.copyWith(
                color: AppColors.gray500,
              ),
            ),
        ],
      ),
    );
  }
}
