import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/constants.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/settings.dart' hide AppTheme;
import '../../providers/settings_provider.dart';

/// Settings screen with streak goal, PIN, notifications, and account management
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(settingsProvider.notifier).loadSettings();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/auth/login');
    }
  }

  Future<void> _handleChangeStreakGoal() async {
    final currentSettings =
        ref.read(settingsProvider).settings ?? UserSettings.defaults();
    final currentGoal = currentSettings.streakGoal ?? 'THREE_PER_WEEK';

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _StreakGoalDialog(currentGoal: currentGoal),
    );

    if (selected != null && selected != currentGoal && mounted) {
      await ref.read(settingsProvider.notifier).updateStreakGoal(selected);
    }
  }

  Future<void> _handleChangePIN() async {
    if (mounted) {
      context.push('/settings/change-pin');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for error state changes and show SnackBar
    ref.listen<SettingsState>(settingsProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(settingsProvider.notifier).clearError();
      }
    });

    final settingsState = ref.watch(settingsProvider);
    final authState = ref.watch(authProvider);
    final settings = settingsState.settings ?? UserSettings.defaults();

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: settingsState.isLoading && settingsState.settings == null
            ? const LoadingView(message: 'Loading settings...')
            : Column(
                children: [
                  // White header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    color: AppColors.white,
                    child: Text(
                      'Settings',
                      style: AppTypography.formTitle.copyWith(
                        color: AppColors.gray800,
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Account section
                          _SectionHeader(title: 'Account'),
                          const SizedBox(height: AppSpacing.sm),
                          _SettingsGroup(
                            children: [
                              _SettingsItem(
                                icon: Icons.email_outlined,
                                title: 'Email',
                                subtitle: authState.user?.email ?? 'Not set',
                              ),
                              _SettingsItem(
                                icon: Icons.lock_outline,
                                title: 'Change PIN',
                                subtitle: 'Update your parent PIN',
                                onTap: _handleChangePIN,
                                showChevron: true,
                              ),
                              _SettingsItem(
                                icon: Icons.password,
                                title: 'Change Password',
                                subtitle: 'Update your account password',
                                onTap: () => context.push('/settings/change-password'),
                                showChevron: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Practice section
                          _SectionHeader(title: 'Practice'),
                          const SizedBox(height: AppSpacing.sm),
                          _SettingsGroup(
                            children: [
                              _SettingsItem(
                                icon: Icons.local_fire_department,
                                title: 'Practice Goal',
                                subtitle: settings.streakGoalDisplayName,
                                onTap: _handleChangeStreakGoal,
                                showChevron: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Notifications section
                          _SectionHeader(title: 'Notifications'),
                          const SizedBox(height: AppSpacing.sm),
                          _SettingsGroup(
                            children: [
                              _SettingsItem(
                                icon: Icons.notifications_outlined,
                                title: 'Reminders',
                                subtitle: settings.notificationsEnabled
                                    ? 'Enabled'
                                    : 'Disabled',
                                trailing: Switch(
                                  value: settings.notificationsEnabled,
                                  activeTrackColor: AppColors.greenMain,
                                  onChanged: (value) {
                                    ref.read(settingsProvider.notifier).updateNotifications(
                                          enabled: value,
                                        );
                                  },
                                ),
                              ),
                              _SettingsItem(
                                icon: Icons.volume_up_outlined,
                                title: 'Sounds',
                                subtitle: settings.soundEnabled
                                    ? 'Enabled'
                                    : 'Disabled',
                                trailing: Switch(
                                  value: settings.soundEnabled,
                                  activeTrackColor: AppColors.greenMain,
                                  onChanged: (value) {
                                    ref
                                        .read(settingsProvider.notifier)
                                        .updateSound(enabled: value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // About section
                          _SectionHeader(title: 'About'),
                          const SizedBox(height: AppSpacing.sm),
                          _SettingsGroup(
                            children: [
                              _SettingsItem(
                                icon: Icons.info_outline,
                                title: 'Version',
                                subtitle: '1.0.0',
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),

                          // Logout — danger style
                          _SettingsGroup(
                            children: [
                              _SettingsItem(
                                icon: Icons.logout,
                                title: 'Log Out',
                                subtitle: 'Sign out of your account',
                                onTap: _handleLogout,
                                isDanger: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Section header
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.caption.copyWith(
        color: AppColors.gray500,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Grouped settings container with dividers
class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.drillCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (index < children.length - 1)
                Divider(height: 1, indent: 60, color: AppColors.gray200),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Individual settings item
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;
  final bool isDanger;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.showChevron = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDanger ? AppColors.coral : AppColors.greenMain;
    final titleColor = isDanger ? AppColors.coral : AppColors.gray800;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: titleColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              const Icon(Icons.chevron_right, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}

/// Streak goal selection dialog
class _StreakGoalDialog extends StatefulWidget {
  final String currentGoal;

  const _StreakGoalDialog({required this.currentGoal});

  @override
  State<_StreakGoalDialog> createState() => _StreakGoalDialogState();
}

class _StreakGoalDialogState extends State<_StreakGoalDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentGoal;
  }

  String _goalLabel(String goal) {
    switch (goal) {
      case 'DAILY':
        return 'Daily (7x/week)';
      case 'FIVE_PER_WEEK':
        return '5x per week';
      case 'THREE_PER_WEEK':
        return '3x per week';
      case 'TWO_PER_WEEK':
        return '2x per week';
      default:
        return goal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Practice Goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppConstants.streakGoals.map((goal) {
          return RadioListTile<String>(
            title: Text(_goalLabel(goal)),
            value: goal,
            groupValue: _selected,
            activeColor: AppColors.greenMain,
            onChanged: (value) {
              setState(() {
                _selected = value!;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
