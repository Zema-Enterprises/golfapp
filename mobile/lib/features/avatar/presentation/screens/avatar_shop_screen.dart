import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/avatar_emoji_mapper.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../children/providers/children_provider.dart';
import '../../data/avatar.dart';
import '../../providers/avatar_provider.dart';
import '../widgets/svg_layered_avatar.dart';

/// Avatar shop screen where children can purchase and equip items
class AvatarShopScreen extends ConsumerStatefulWidget {
  final String childId;

  const AvatarShopScreen({super.key, required this.childId});

  @override
  ConsumerState<AvatarShopScreen> createState() => _AvatarShopScreenState();
}

class _AvatarShopScreenState extends ConsumerState<AvatarShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _itemTypes = ItemType.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _itemTypes.length, vsync: this);

    Future.microtask(() {
      ref.read(avatarProvider.notifier).loadAvatar(widget.childId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase(AvatarItem item) async {
    final avatarState = ref.read(avatarProvider).avatarState;
    if (avatarState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading avatar data, please try again...')),
      );
      ref.read(avatarProvider.notifier).loadAvatar(widget.childId);
      return;
    }

    final child = ref.read(childrenProvider).selectedChild;
    if ((child?.availableStars ?? 0) < item.unlockStars) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough stars!')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.isFree ? 'Get Free Item' : 'Purchase Item'),
        content: Text(
          item.isFree
              ? 'Add ${item.name} to your collection for free?'
              : 'Buy ${item.name} for ${item.unlockStars} stars?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(item.isFree ? 'Get it!' : 'Buy'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref.read(avatarProvider.notifier).purchaseItem(
          childId: widget.childId,
          itemId: item.id,
        );

    if (success && mounted) {
      // Refresh child data to update star balance
      await ref.read(childrenProvider.notifier).loadChildren();
      // Re-select the same child so it doesn't switch
      final children = ref.read(childrenProvider).children;
      final current = children.where((c) => c.id == widget.childId).firstOrNull;
      if (current != null) {
        ref.read(childrenProvider.notifier).selectChild(current);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (item.isFree ? 'Got ${item.name}!' : 'Purchased ${item.name}!')
                : 'Purchase failed',
          ),
        ),
      );
    }
  }

  Future<void> _handleEquip(AvatarItem item) async {
    await ref.read(avatarProvider.notifier).equipItem(
          childId: widget.childId,
          itemId: item.id,
        );
  }

  Future<void> _handleUnequip(ItemType type) async {
    await ref.read(avatarProvider.notifier).unequipItem(
          childId: widget.childId,
          category: type,
        );
  }

  @override
  Widget build(BuildContext context) {
    final avatarData = ref.watch(avatarProvider);
    final shopAsync = ref.watch(shopDataProvider);
    final selectedChild = ref.watch(childrenProvider).selectedChild;
    final availableStars = selectedChild?.availableStars ?? 0;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // Purple gradient header with avatar and child name
          _buildHeader(avatarData, availableStars, selectedChild?.name),

          // Tabs
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.purple,
              unselectedLabelColor: AppColors.gray500,
              indicatorColor: AppColors.purple,
              tabs: _itemTypes.map((type) {
                return Tab(
                  text: _typeTabLabel(type),
                  icon: Icon(_typeIcon(type), size: 20),
                );
              }).toList(),
            ),
          ),

          // Shop content
          Expanded(
            child: shopAsync.when(
              data: (shopData) => _buildShopContent(shopData, avatarData),
              loading: () => const LoadingView(message: 'Loading shop...'),
              error: (error, _) => ErrorView(
                message: 'Failed to load shop',
                onRetry: () => ref.invalidate(shopDataProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AvatarStateData avatarData, int availableStars, String? childName) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.purpleHeader,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.header),
          bottomRight: Radius.circular(AppRadius.header),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
          child: Column(
            children: [
              // Title row with star count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avatar Shop',
                        style: AppTypography.appTitle.copyWith(color: Colors.white),
                      ),
                      if (childName != null)
                        Text(
                          'Shopping for $childName',
                          style: AppTypography.body.copyWith(
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                    ],
                  ),
                  // Star balance
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 18, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          '$availableStars',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Avatar display — full-body SVG with equipped items
              if (avatarData.avatarState != null)
                SvgLayeredAvatar(
                  avatarKey: (avatarData.avatarState!.avatarState['BASE_AVATAR'] as String?) ?? 'boy_light',
                  equippedItems: avatarData.avatarState!.equippedItems,
                  height: 200,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopContent(ShopData shopData, AvatarStateData avatarData) {
    final avatarState = avatarData.avatarState;

    return TabBarView(
      controller: _tabController,
      children: _itemTypes.map((type) {
        final items = shopData.getItemsByType(type);
        if (items.isEmpty) {
          return const EmptyStateView(
            title: 'No items yet',
            subtitle: 'Check back soon!',
            icon: Icons.shopping_bag_outlined,
          );
        }
        return _buildItemGrid(items, avatarState);
      }).toList(),
    );
  }

  Widget _buildItemGrid(List<AvatarItem> items, AvatarState? avatarState) {
    final childStars = ref.watch(childrenProvider).selectedChild?.availableStars ?? 0;
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = avatarState?.ownsItem(item.id) ?? false;
        final isEquipped =
            avatarState?.getEquippedItemId(item.type) == item.id;
        final canAfford = childStars >= item.unlockStars;

        return _ShopItemCard(
          item: item,
          isOwned: isOwned,
          isEquipped: isEquipped,
          canAfford: canAfford,
          onPurchase: () => _handlePurchase(item),
          onEquip: () => _handleEquip(item),
          onUnequip: () => _handleUnequip(item.type),
        );
      },
    );
  }

  String _typeTabLabel(ItemType type) {
    switch (type) {
      case ItemType.hat:
        return 'Hats';
      case ItemType.shirt:
        return 'Shirts';
      case ItemType.shoes:
        return 'Shoes';
      case ItemType.accessory:
        return 'Accessories';
      case ItemType.clubSkin:
        return 'Clubs';
    }
  }

  IconData _typeIcon(ItemType type) {
    switch (type) {
      case ItemType.hat:
        return Icons.face;
      case ItemType.shirt:
        return Icons.checkroom;
      case ItemType.shoes:
        return Icons.ice_skating;
      case ItemType.accessory:
        return Icons.auto_awesome;
      case ItemType.clubSkin:
        return Icons.sports_golf;
    }
  }
}

/// Individual shop item card
class _ShopItemCard extends StatelessWidget {
  final AvatarItem item;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;
  final VoidCallback onUnequip;

  const _ShopItemCard({
    required this.item,
    required this.isOwned,
    required this.isEquipped,
    required this.canAfford,
    required this.onPurchase,
    required this.onEquip,
    required this.onUnequip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.drillCard,
        border: isEquipped
            ? Border.all(color: AppColors.greenMain, width: 2)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item image area with emoji
          Expanded(
            child: Container(
              color: _rarityColor.withAlpha(20),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      itemEmoji(item),
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                  // Rarity badge
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: _rarityColor,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        item.rarityDisplayName,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  if (isEquipped)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.greenMain,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Item info + action
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray800,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _buildActionRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    if (isEquipped) {
      return SizedBox(
        width: double.infinity,
        height: 28,
        child: OutlinedButton(
          onPressed: onUnequip,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            side: const BorderSide(color: AppColors.greenMain),
            foregroundColor: AppColors.greenMain,
          ),
          child: const Text('Equipped', style: TextStyle(fontSize: 11)),
        ),
      );
    }

    if (isOwned) {
      return SizedBox(
        width: double.infinity,
        height: 28,
        child: ElevatedButton(
          onPressed: onEquip,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.purple,
          ),
          child: const Text('Equip', style: TextStyle(fontSize: 11)),
        ),
      );
    }

    if (item.isFree) {
      return SizedBox(
        width: double.infinity,
        height: 28,
        child: ElevatedButton(
          onPressed: onPurchase,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.greenMain,
          ),
          child: const Text('Free!', style: TextStyle(fontSize: 11)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 28,
      child: ElevatedButton(
        onPressed: canAfford ? onPurchase : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.gray300,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 12),
            const SizedBox(width: 2),
            Text('${item.unlockStars}', style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Color get _rarityColor {
    switch (item.rarity) {
      case Rarity.common:
        return AppColors.gray500;
      case Rarity.uncommon:
        return AppColors.greenMain;
      case Rarity.rare:
        return AppColors.secondary;
      case Rarity.legendary:
        return AppColors.accent;
    }
  }
}
