import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../children/providers/children_provider.dart';
import 'progress_screen.dart';

/// Progress tab wrapper that reads the selected child from provider
class ProgressTabScreen extends ConsumerWidget {
  const ProgressTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);

    if (selectedChild == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Progress')),
        body: const EmptyStateView(
          title: 'No Child Selected',
          subtitle: 'Add a child from the Home tab to see progress.',
          icon: Icons.bar_chart_outlined,
        ),
      );
    }

    return ProgressScreen(childId: selectedChild.id);
  }
}
