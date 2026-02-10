import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/constants.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../children/providers/children_provider.dart';
import '../../data/session.dart';
import '../../providers/sessions_provider.dart';

/// Session preview screen showing generated drills before starting
class SessionPreviewScreen extends ConsumerStatefulWidget {
  final String childId;
  final String duration;

  const SessionPreviewScreen({
    super.key,
    required this.childId,
    required this.duration,
  });

  @override
  ConsumerState<SessionPreviewScreen> createState() => _SessionPreviewScreenState();
}

class _SessionPreviewScreenState extends ConsumerState<SessionPreviewScreen> {
  @override
  void initState() {
    super.initState();
    // Generate session when screen loads
    Future.microtask(() {
      ref.read(activeSessionProvider.notifier).generateSession(
            childId: widget.childId,
            durationMinutes: widget.duration,
          );
    });
  }

  void _handleStartSession() {
    final session = ref.read(activeSessionProvider).session;
    if (session != null) {
      context.go('/session/${session.id}/play');
    }
  }

  void _handleCancel() {
    ref.read(activeSessionProvider.notifier).clearSession();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(activeSessionProvider);
    final childrenState = ref.watch(childrenProvider);
    final child = childrenState.children.where((c) => c.id == widget.childId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // Green gradient header
          GradientHeader(
            gradient: AppGradients.greenHeader,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button row
                Row(
                  children: [
                    GestureDetector(
                      onTap: _handleCancel,
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
                    Expanded(
                      child: Text(
                        'Practice Preview',
                        style: AppTypography.title.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${child?.name ?? "Child"}\'s Session',
                  style: AppTypography.appTitle.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.duration} minutes',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _buildBody(sessionState, child?.name ?? 'Child'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ActiveSessionState state, String childName) {
    if (state.isLoading && state.session == null) {
      return const LoadingView(message: 'Generating practice session...');
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () {
          ref.read(activeSessionProvider.notifier).generateSession(
                childId: widget.childId,
                durationMinutes: widget.duration,
              );
        },
      );
    }

    if (state.session == null) {
      return const LoadingView(message: 'Preparing drills...');
    }

    return _buildPreviewContent(state.session!, childName);
  }

  Widget _buildPreviewContent(Session session, String childName) {
    final drillCount = session.drills.length;
    final totalStars = drillCount * AppConstants.starsPerDrill;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                _SessionStatsRow(
                  drillCount: drillCount,
                  duration: widget.duration,
                  totalStars: totalStars,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Drills header
                Text(
                  'Today\'s Drills',
                  style: AppTypography.title.copyWith(
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Drill list
                ...session.drills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sessionDrill = entry.value;
                  return _DrillPreviewCard(
                    index: index + 1,
                    sessionDrill: sessionDrill,
                  );
                }),
              ],
            ),
          ),
        ),

        // Bottom action
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tip for parents
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Hand the device to your child when you\'re ready to start!',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Start button
              PrimaryButton(
                label: 'Start Practice',
                onPressed: _handleStartSession,
                icon: Icons.play_arrow,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Stats row showing drills, duration, stars
class _SessionStatsRow extends StatelessWidget {
  final int drillCount;
  final String duration;
  final int totalStars;

  const _SessionStatsRow({
    required this.drillCount,
    required this.duration,
    required this.totalStars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            emoji: '\u26F3',
            value: drillCount.toString(),
            label: 'Drills',
          ),
          Container(width: 1, height: 40, color: AppColors.gray200),
          _StatItem(
            emoji: '\u23F1',
            value: '$duration min',
            label: 'Duration',
          ),
          Container(width: 1, height: 40, color: AppColors.gray200),
          _StatItem(
            emoji: '\u2B50',
            value: totalStars.toString(),
            label: 'Stars',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatItem({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
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

/// Individual drill preview card with numbered circle
class _DrillPreviewCard extends StatelessWidget {
  final int index;
  final SessionDrill sessionDrill;

  const _DrillPreviewCard({
    required this.index,
    required this.sessionDrill,
  });

  @override
  Widget build(BuildContext context) {
    final drill = sessionDrill.drill;

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
          // Numbered circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.greenPale,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.greenMain,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Drill info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drill?.name ?? 'Drill $index',
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
          // Stars
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppColors.accent),
              const SizedBox(width: 2),
              Text(
                '${AppConstants.starsPerDrill}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
