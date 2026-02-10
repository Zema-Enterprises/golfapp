import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/constants.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../children/data/child.dart';
import '../../../children/providers/children_provider.dart';
import '../../../progress/providers/progress_provider.dart';
import '../../../sessions/presentation/widgets/pin_verification_dialog.dart';

/// Parent dashboard home screen — matches wireframe dashboard
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(childrenProvider.notifier).loadChildren();
    });
  }

  void _handleStartPractice(Child child) async {
    ref.read(childrenProvider.notifier).selectChild(child);

    final selectedDuration = await showDurationSelector(
      context,
      initialDuration: AppConstants.defaultSessionDuration,
    );

    if (selectedDuration != null && mounted) {
      context.push('/session/preview', extra: {
        'childId': child.id,
        'duration': selectedDuration,
      });
    }
  }

  void _handleChildTap(Child child) async {
    final currentChild = ref.read(childrenProvider).selectedChild;

    // Same child or first selection — no PIN needed
    if (currentChild == null || currentChild.id == child.id) {
      ref.read(childrenProvider.notifier).selectChild(child);
      return;
    }

    // Switching to a different child — require PIN
    final verified = await showPinVerificationDialog(context, ref);
    if (!verified || !mounted) return;

    ref.read(childrenProvider.notifier).selectChild(child);
  }

  void _handleAddChild() async {
    final result = await context.push<bool>('/child/add');
    if (result == true) {
      ref.read(childrenProvider.notifier).loadChildren();
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenState = ref.watch(childrenProvider);

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
                Text(
                  'Good morning! \uD83D\uDC4B',
                  style: AppTypography.body.copyWith(
                    color: AppColors.white.withAlpha(230),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ready to Practice?',
                  style: AppTypography.appTitle.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _buildBody(childrenState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ChildrenState state) {
    if (state.isLoading && state.children.isEmpty) {
      return const LoadingView(message: 'Loading profiles...');
    }

    if (state.error != null && state.children.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(childrenProvider.notifier).loadChildren(),
      );
    }

    if (state.children.isEmpty) {
      return _buildEmptyState();
    }

    return _buildChildrenList(state.children);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.greenPale,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Center(
                child: Text('\u26F3', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Welcome to Golf Playbook!',
              style: AppTypography.headline.copyWith(
                color: AppColors.gray800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your first child to get started with fun golf practice sessions.',
              style: AppTypography.body.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Add Child',
              icon: Icons.add,
              onPressed: _handleAddChild,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenList(List<Child> children) {
    return RefreshIndicator(
      onRefresh: () => ref.read(childrenProvider.notifier).loadChildren(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              'Your Children',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray700,
              ),
            ),
          ),
          // Child cards
          ...children.map((child) {
            final isSelected = ref.watch(childrenProvider).selectedChild?.id == child.id;
            return _ChildCardWithStreak(
              child: child,
              isSelected: isSelected,
              onTap: () => _handleChildTap(child),
              onStartPractice: isSelected ? () => _handleStartPractice(child) : null,
            );
          }),
          // Add child card (dashed border)
          _AddChildCard(onTap: _handleAddChild),
        ],
      ),
    );
  }
}

/// Dashed "Add Child" card — matches wireframe .add-child-card
class _AddChildCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddChildCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: AppColors.gray300,
        strokeWidth: 2,
        dashPattern: const [8, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                '\u2795',
                style: TextStyle(fontSize: 32, color: AppColors.gray400),
              ),
              const SizedBox(height: 10),
              Text(
                'Add Another Child',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Child card wrapper that fetches streak data
class _ChildCardWithStreak extends ConsumerWidget {
  final Child child;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onStartPractice;

  const _ChildCardWithStreak({
    required this.child,
    this.isSelected = false,
    this.onTap,
    this.onStartPractice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakInfoProvider(child.id));

    return ChildProfileCard(
      child: child,
      isSelected: isSelected,
      streakDays: streakAsync.whenOrNull(
        data: (streak) => streak.currentStreak,
      ),
      onTap: onTap,
      onStartPractice: onStartPractice,
    );
  }
}
