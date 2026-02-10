import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/avatar_emoji_mapper.dart';
import '../../data/avatar.dart';

/// Displays a child's avatar with equipped items in a paper-doll style layout.
/// Shows emojis for each equipped slot positioned around a central character.
class AvatarDisplay extends StatelessWidget {
  final List<AvatarItem> equippedItems;
  final Map<String, dynamic> avatarState;
  final double size;

  const AvatarDisplay({
    super.key,
    required this.equippedItems,
    required this.avatarState,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final hat = _findEquipped(ItemType.hat);
    final shirt = _findEquipped(ItemType.shirt);
    final shoes = _findEquipped(ItemType.shoes);
    final accessory = _findEquipped(ItemType.accessory);
    final club = _findEquipped(ItemType.clubSkin);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withAlpha(60),
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base character — uses selected avatar from avatarState
          Text(
            baseAvatarEmoji(avatarState['BASE_AVATAR'] as String?),
            style: TextStyle(fontSize: size * 0.35),
          ),

          // Hat — top center
          if (hat != null)
            Positioned(
              top: size * 0.02,
              child: _ItemSlot(emoji: itemEmoji(hat), size: size * 0.25),
            ),

          // Shirt — center left
          if (shirt != null)
            Positioned(
              left: size * 0.02,
              top: size * 0.35,
              child: _ItemSlot(emoji: itemEmoji(shirt), size: size * 0.22),
            ),

          // Shoes — bottom center
          if (shoes != null)
            Positioned(
              bottom: size * 0.02,
              child: _ItemSlot(emoji: itemEmoji(shoes), size: size * 0.22),
            ),

          // Club — right side
          if (club != null)
            Positioned(
              right: size * 0.02,
              top: size * 0.25,
              child: _ItemSlot(emoji: itemEmoji(club), size: size * 0.22),
            ),

          // Accessory — bottom right
          if (accessory != null)
            Positioned(
              right: size * 0.05,
              bottom: size * 0.1,
              child: _ItemSlot(emoji: itemEmoji(accessory), size: size * 0.2),
            ),
        ],
      ),
    );
  }

  AvatarItem? _findEquipped(ItemType type) {
    for (final item in equippedItems) {
      if (item.type == type) return item;
    }
    return null;
  }
}

/// Individual item slot showing an emoji with a subtle background
class _ItemSlot extends StatelessWidget {
  final String emoji;
  final double size;

  const _ItemSlot({required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.55),
        ),
      ),
    );
  }
}

/// Simple star balance display
class StarBalanceWidget extends StatelessWidget {
  final int availableStars;
  final double fontSize;

  const StarBalanceWidget({
    super.key,
    required this.availableStars,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.accent.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: fontSize + 4, color: AppColors.accent),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$availableStars',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
