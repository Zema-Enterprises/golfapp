import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';

/// Welcome/landing screen — first screen for unauthenticated users
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.welcomeScreen,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: AppShadows.large,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.golf_course,
                      size: 56,
                      color: AppColors.gray800,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Title
                Text(
                  'Junior Golf\nPlaybook',
                  style: AppTypography.appTitle.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Subtitle
                Text(
                  'Fun practice sessions for young\ngolfers and their parents',
                  style: AppTypography.body.copyWith(
                    color: AppColors.white.withAlpha(230),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                // Buttons
                PrimaryButton(
                  label: 'Get Started',
                  onPressed: () => context.go('/auth/register'),
                  backgroundColor: AppColors.white,
                  textColor: AppColors.greenDark,
                ),
                const SizedBox(height: 15),
                SecondaryButton(
                  label: 'I Have an Account',
                  onPressed: () => context.go('/auth/login'),
                  borderColor: AppColors.white,
                  textColor: AppColors.white,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
