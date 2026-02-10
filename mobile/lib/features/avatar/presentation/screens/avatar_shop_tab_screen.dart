import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../children/providers/children_provider.dart';
import 'avatar_shop_screen.dart';

/// Avatar shop tab wrapper that reads the selected child from provider
class AvatarShopTabScreen extends ConsumerWidget {
  const AvatarShopTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);

    if (selectedChild == null) {
      return const Scaffold(
        body: EmptyStateView(
          title: 'No Child Selected',
          subtitle: 'Add a child from the Home tab to visit the shop.',
          icon: Icons.shopping_bag_outlined,
        ),
      );
    }

    return AvatarShopScreen(key: ValueKey(selectedChild.id), childId: selectedChild.id);
  }
}
