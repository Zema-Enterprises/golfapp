import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Scaffold for kid-mode screens: gradient bg + white content area.
/// Used by kid_ready, kid_drill, session_complete screens.
class KidModeScaffold extends StatelessWidget {
  final Widget headerContent;
  final Widget bodyContent;
  final LinearGradient gradient;
  final double topRadius;

  const KidModeScaffold({
    super.key,
    required this.headerContent,
    required this.bodyContent,
    this.gradient = AppGradients.kidMode,
    this.topRadius = AppRadius.header,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header in gradient area
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 20,
                ),
                child: headerContent,
              ),
              // White content area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(topRadius),
                      topRight: Radius.circular(topRadius),
                    ),
                  ),
                  child: bodyContent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
