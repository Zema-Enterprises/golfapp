import 'package:flutter/material.dart';
import '../../features/children/data/child.dart';
import '../theme/app_theme.dart';
import '../utils/avatar_emoji_mapper.dart';

/// Child profile card for dashboard display — matches wireframe .child-card
class ChildProfileCard extends StatelessWidget {
  final Child child;
  final int? streakDays;
  final int? sessionsThisWeek;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onStartPractice;

  const ChildProfileCard({
    super.key,
    required this.child,
    this.streakDays,
    this.sessionsThisWeek,
    this.isSelected = false,
    this.onTap,
    this.onStartPractice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.greenPale : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: isSelected ? AppShadows.standard : AppShadows.card,
        border: isSelected
            ? Border.all(color: AppColors.greenMain, width: 2.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: avatar + name/info
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.blueLight, AppColors.blueSky],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getChildEmoji(),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: AppTypography.title.copyWith(
                              color: AppColors.gray800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${child.ageBandDisplayName} \u2022 ${child.skillLevelDisplayName}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.greenMain,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 16, color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                // Stats row
                Row(
                  children: [
                    _StatItem(
                      emoji: '\u2B50',
                      value: child.availableStars.toString(),
                      label: 'Stars',
                    ),
                    const SizedBox(width: 20),
                    if (streakDays != null)
                      _StatItem(
                        emoji: '\uD83D\uDD25',
                        value: '$streakDays',
                        label: 'Day Streak',
                      ),
                    if (sessionsThisWeek != null) ...[
                      const SizedBox(width: 20),
                      _StatItem(
                        emoji: '\uD83D\uDCC5',
                        value: '$sessionsThisWeek',
                        label: 'This Week',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 15),
                // Start practice button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStartPractice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Start Practice Session',
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getChildEmoji() {
    return baseAvatarEmoji(child.avatarState['BASE_AVATAR'] as String?);
  }
}

/// Stats item with emoji + value + label
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
        Text(
          '$emoji $value',
          style: AppTypography.title.copyWith(
            color: AppColors.gray800,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.gray500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
