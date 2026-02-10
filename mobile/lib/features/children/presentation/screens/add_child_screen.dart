import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/avatar_emoji_mapper.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/child.dart';
import '../../providers/children_provider.dart';

/// Screen for adding a new child profile
class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedAvatar = 'boy_medium';
  AgeBand _selectedAgeBand = AgeBand.age6to8;
  SkillLevel _selectedSkillLevel = SkillLevel.beginner;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final request = CreateChildRequest(
      name: _nameController.text.trim(),
      ageBand: _selectedAgeBand,
      skillLevel: _selectedSkillLevel,
      avatarState: {'BASE_AVATAR': _selectedAvatar},
    );

    final child = await ref.read(childrenProvider.notifier).createChild(request);
    if (child != null && mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenState = ref.watch(childrenProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: AppColors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.close, size: 20, color: AppColors.gray600),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Add Child',
                    style: AppTypography.formTitle.copyWith(
                      color: AppColors.gray800,
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message
                      if (childrenState.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(25),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  childrenState.error!,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Avatar selection
                      Text(
                        'Choose an Avatar',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildAvatarGrid(),
                      const SizedBox(height: AppSpacing.xl),

                      // Name field
                      Text(
                        'Child\'s Name',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Enter name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Age band — horizontal flex selector
                      Text(
                        'Age Group',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: AgeBand.values.map((band) {
                          final isSelected = band == _selectedAgeBand;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedAgeBand = band),
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: band != AgeBand.values.last ? 10 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.greenPale : AppColors.white,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: isSelected ? AppColors.greenMain : AppColors.gray300,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _getAgeBandEmoji(band),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getAgeBandLabel(band),
                                      style: AppTypography.caption.copyWith(
                                        color: isSelected ? AppColors.greenMain : AppColors.gray600,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Skill level — vertical selector with emoji
                      Text(
                        'Experience Level',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...SkillLevel.values.map((level) {
                        final isSelected = level == _selectedSkillLevel;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSkillLevel = level),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.greenPale : AppColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected ? AppColors.greenMain : AppColors.gray300,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _getSkillLevelEmoji(level),
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getSkillLevelLabel(level),
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: isSelected ? AppColors.greenMain : AppColors.gray800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getSkillLevelSubtitle(level),
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.gray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: AppColors.greenMain,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, size: 16, color: Colors.white),
                                  )
                                else
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.gray300, width: 2),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.xl),

                      // Save button
                      PrimaryButton(
                        label: 'Add Child',
                        onPressed: _handleSave,
                        isLoading: childrenState.isLoading,
                        icon: Icons.add,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAgeBandEmoji(AgeBand band) {
    switch (band) {
      case AgeBand.age4to6:
        return '\uD83D\uDC76';
      case AgeBand.age6to8:
        return '\uD83E\uDDD2';
      case AgeBand.age8to10:
        return '\uD83E\uDDD1';
    }
  }

  String _getAgeBandLabel(AgeBand band) {
    switch (band) {
      case AgeBand.age4to6:
        return '4-6 yrs';
      case AgeBand.age6to8:
        return '6-8 yrs';
      case AgeBand.age8to10:
        return '8-10 yrs';
    }
  }

  String _getSkillLevelEmoji(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return '\uD83C\uDF31';
      case SkillLevel.intermediate:
        return '\u26F3';
      case SkillLevel.advanced:
        return '\uD83C\uDFC6';
    }
  }

  String _getSkillLevelLabel(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'New to Golf';
      case SkillLevel.intermediate:
        return 'Some Experience';
      case SkillLevel.advanced:
        return 'Experienced';
    }
  }

  String _getSkillLevelSubtitle(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'Just getting started with golf';
      case SkillLevel.intermediate:
        return 'Knows the basics, building skills';
      case SkillLevel.advanced:
        return 'Ready for challenging drills';
    }
  }

  Widget _buildAvatarGrid() {
    final entries = baseAvatarEmojis.entries.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final key = entries[index].key;
        final emoji = entries[index].value;
        final isSelected = key == _selectedAvatar;
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatar = key),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.greenPale : AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? AppColors.greenMain : AppColors.gray300,
                width: isSelected ? 2.5 : 1.5,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                ),
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.greenMain,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
