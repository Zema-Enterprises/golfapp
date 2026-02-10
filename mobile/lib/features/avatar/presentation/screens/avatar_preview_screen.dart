import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/avatar_emoji_mapper.dart';
import '../../../../shared/utils/avatar_svg_mapper.dart';
import '../../data/avatar.dart';
import '../widgets/svg_layered_avatar.dart';

/// Dev/test page to preview all avatar models with all item combinations.
/// Navigate to /dev/avatar-preview to access.
class AvatarPreviewScreen extends StatefulWidget {
  const AvatarPreviewScreen({super.key});

  @override
  State<AvatarPreviewScreen> createState() => _AvatarPreviewScreenState();
}

class _AvatarPreviewScreenState extends State<AvatarPreviewScreen> {
  static final _allItems = <ItemType, List<_PreviewItem>>{
    ItemType.hat: [
      _PreviewItem('Golf Cap', 'golf cap'),
      _PreviewItem('Bucket Hat', 'bucket hat'),
      _PreviewItem('Sun Visor', 'sun visor'),
      _PreviewItem('Champion Cap', 'champion cap'),
    ],
    ItemType.shirt: [
      _PreviewItem('Green Polo', 'green polo'),
      _PreviewItem('Striped Polo', 'striped polo'),
      _PreviewItem('Pro Jersey', 'pro jersey'),
    ],
    ItemType.shoes: [
      _PreviewItem('White Sneakers', 'white sneakers'),
      _PreviewItem('Golf Shoes', 'golf shoes'),
    ],
    ItemType.clubSkin: [
      _PreviewItem('Classic Putter', 'classic putter'),
      _PreviewItem('Golden Putter', 'golden putter'),
    ],
    ItemType.accessory: [
      _PreviewItem('Golf Glove', 'golf glove'),
      _PreviewItem('Cool Sunglasses', 'cool sunglasses'),
    ],
  };

  final Map<ItemType, String?> _equipped = {
    for (final t in ItemType.values) t: null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: const Text('Avatar Preview'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray800,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => setState(() {
              for (final t in ItemType.values) {
                _equipped[t] = null;
              }
            }),
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => setState(() {
              for (final entry in _allItems.entries) {
                _equipped[entry.key] = entry.value.first.name;
              }
            }),
            child: const Text('Equip All'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // All 6 avatars with current equipment
            Text(
              'All Models (current equipment)',
              style: AppTypography.title.copyWith(color: AppColors.gray800),
            ),
            const SizedBox(height: 12),
            _buildAvatarRow(),
            const SizedBox(height: 24),

            // Item selectors per slot
            ..._allItems.entries.expand((entry) => [
              _buildSlotSelector(entry.key, entry.value),
              const SizedBox(height: 16),
            ]),

            const SizedBox(height: 24),

            // Full matrix: each item on each avatar
            Text(
              'Item x Model Matrix',
              style: AppTypography.title.copyWith(color: AppColors.gray800),
            ),
            const SizedBox(height: 12),
            ..._allItems.entries.expand((entry) => [
              _buildItemTypeMatrix(entry.key, entry.value),
              const SizedBox(height: 24),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarRow() {
    final equipped = _buildEquippedItems();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: avatarBaseKeys.map((key) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SvgLayeredAvatar(
              avatarKey: key,
              equippedItems: equipped,
              height: 220,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSlotSelector(ItemType type, List<_PreviewItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _typeLabel(type),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.gray800),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildItemChip(
                label: 'None',
                emoji: '-',
                isSelected: _equipped[type] == null,
                onTap: () => setState(() => _equipped[type] = null),
              ),
              const SizedBox(width: 8),
              ...items.map((item) {
                final isSelected = _equipped[type] == item.name;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildItemChip(
                    label: item.displayName,
                    emoji: itemNameEmoji(item.name),
                    isSelected: isSelected,
                    onTap: () => setState(() => _equipped[type] = item.name),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.greenPale : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.greenMain : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.greenMain : AppColors.gray600,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTypeMatrix(ItemType type, List<_PreviewItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.purple.withAlpha(20),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            _typeLabel(type),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.purple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          final fakeItem = AvatarItem(
            id: 'preview-${item.name}',
            type: type,
            name: item.displayName,
            unlockStars: 0,
            rarity: Rarity.common,
            isPremium: false,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      itemNameEmoji(item.name),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.displayName,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: avatarBaseKeys.map((avatarKey) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SvgLayeredAvatar(
                          avatarKey: avatarKey,
                          equippedItems: [fakeItem],
                          height: 180,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<AvatarItem> _buildEquippedItems() {
    final items = <AvatarItem>[];
    for (final entry in _equipped.entries) {
      if (entry.value != null) {
        items.add(AvatarItem(
          id: 'preview-${entry.value}',
          type: entry.key,
          name: entry.value!,
          unlockStars: 0,
          rarity: Rarity.common,
          isPremium: false,
        ));
      }
    }
    return items;
  }

  String _typeLabel(ItemType type) {
    switch (type) {
      case ItemType.hat:
        return 'Hats';
      case ItemType.shirt:
        return 'Shirts';
      case ItemType.shoes:
        return 'Shoes';
      case ItemType.clubSkin:
        return 'Clubs';
      case ItemType.accessory:
        return 'Accessories';
    }
  }
}

class _PreviewItem {
  final String displayName;
  final String name;
  const _PreviewItem(this.displayName, this.name);
}
