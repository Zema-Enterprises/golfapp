import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../children/providers/children_provider.dart';
import '../../data/progress.dart';
import '../../providers/progress_provider.dart';

/// Progress overview screen showing stats, streak, and achievements
class ProgressScreen extends ConsumerWidget {
  final String childId;

  const ProgressScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(progressStatsProvider(childId));
    final streakAsync = ref.watch(streakInfoProvider(childId));
    final childrenState = ref.watch(childrenProvider);
    final child =
        childrenState.children.where((c) => c.id == childId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // Orange gradient header
          GradientHeader(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, Color(0xFFE65100)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${child?.name ?? "Child"}\'s Progress',
                  style: AppTypography.appTitle.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep up the great work!',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: statsAsync.when(
              data: (stats) => streakAsync.when(
                data: (streak) => _buildContent(context, stats, streak),
                loading: () => const LoadingView(message: 'Loading streak...'),
                error: (e, _) => _buildContent(context, stats, null),
              ),
              loading: () => const LoadingView(message: 'Loading progress...'),
              error: (error, _) => ErrorView(
                message: 'Failed to load progress',
                onRetry: () {
                  ref.invalidate(progressStatsProvider(childId));
                  ref.invalidate(streakInfoProvider(childId));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProgressStats stats,
    StreakInfo? streak,
  ) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2x2 Stats grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    emoji: '\u2B50',
                    value: '${stats.availableStars}',
                    label: 'Available Stars',
                    bgColor: AppColors.orangeLight,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _StatCard(
                    emoji: '\uD83C\uDF1F',
                    value: '${stats.totalStars}',
                    label: 'Total Earned',
                    bgColor: AppColors.greenPale,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    emoji: '\u26F3',
                    value: '${stats.totalSessions}',
                    label: 'Sessions',
                    bgColor: AppColors.blueLight.withAlpha(80),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _StatCard(
                    emoji: '\uD83D\uDD25',
                    value: '${streak?.currentStreak ?? 0}',
                    label: 'Week Streak',
                    bgColor: AppColors.coral.withAlpha(30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Streak card
            if (streak != null) ...[
              _StreakCard(streak: streak),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Suggested Focus card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
                border: Border(
                  left: BorderSide(
                    color: AppColors.secondary,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested Focus',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Keep practicing to build consistency! Try to complete ${streak?.sessionsRemaining ?? 3} more sessions this week.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Achievements section
            Text(
              'Achievements',
              style: AppTypography.title.copyWith(
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _AchievementsList(stats: stats, streak: streak),
          ],
        ),
      ),
    );
  }
}

/// Stats card for the 2x2 grid
class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color bgColor;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headline.copyWith(
              color: AppColors.gray800,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Streak progress card
class _StreakCard extends StatelessWidget {
  final StreakInfo streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.coral.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Text('\uD83D\uDD25', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${streak.currentStreak} Week Streak',
                      style: AppTypography.title.copyWith(
                        color: AppColors.gray800,
                      ),
                    ),
                    Text(
                      'Goal: ${streak.goalDisplayName}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray800,
                ),
              ),
              Text(
                '${streak.weeklySessionCount}/${streak.weeklyGoal} sessions',
                style: AppTypography.caption.copyWith(
                  color: streak.goalMet ? AppColors.greenMain : AppColors.gray500,
                  fontWeight: streak.goalMet ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: streak.weeklyProgress,
              minHeight: 10,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(
                streak.goalMet ? AppColors.greenMain : AppColors.accent,
              ),
            ),
          ),
          if (!streak.goalMet && streak.sessionsRemaining > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${streak.sessionsRemaining} more session${streak.sessionsRemaining == 1 ? '' : 's'} to reach your goal!',
              style: AppTypography.caption.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Achievements list
class _AchievementsList extends StatelessWidget {
  final ProgressStats stats;
  final StreakInfo? streak;

  const _AchievementsList({required this.stats, this.streak});

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();

    return Column(
      children: achievements.map((achievement) {
        return _AchievementTile(
          icon: achievement.icon,
          title: achievement.title,
          description: achievement.description,
          isUnlocked: achievement.isUnlocked,
        );
      }).toList(),
    );
  }

  List<_Achievement> _getAchievements() {
    return [
      _Achievement(
        icon: Icons.star,
        title: 'First Star',
        description: 'Earn your first star',
        isUnlocked: stats.totalStars >= 1,
      ),
      _Achievement(
        icon: Icons.sports_golf,
        title: 'First Session',
        description: 'Complete your first practice session',
        isUnlocked: stats.totalSessions >= 1,
      ),
      _Achievement(
        icon: Icons.local_fire_department,
        title: 'On Fire',
        description: 'Achieve a 3-week streak',
        isUnlocked: (streak?.longestStreak ?? 0) >= 3,
      ),
      _Achievement(
        icon: Icons.emoji_events,
        title: 'Star Collector',
        description: 'Earn 50 total stars',
        isUnlocked: stats.totalStars >= 50,
      ),
      _Achievement(
        icon: Icons.military_tech,
        title: 'Dedicated',
        description: 'Complete 10 practice sessions',
        isUnlocked: stats.totalSessions >= 10,
      ),
      _Achievement(
        icon: Icons.workspace_premium,
        title: 'Golf Pro',
        description: 'Complete 50 sessions',
        isUnlocked: stats.completedSessions >= 50,
      ),
    ];
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String description;
  final bool isUnlocked;

  const _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });
}

class _AchievementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isUnlocked;

  const _AchievementTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.accent.withAlpha(25)
                  : AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isUnlocked ? AppColors.accent : AppColors.gray400,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isUnlocked ? AppColors.gray800 : AppColors.gray500,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle, color: AppColors.greenMain, size: 24)
          else
            const Icon(Icons.lock_outline, color: AppColors.gray300, size: 24),
        ],
      ),
    );
  }
}
