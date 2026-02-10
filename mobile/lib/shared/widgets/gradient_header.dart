import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable gradient header with rounded bottom corners.
/// Used by dashboard, session preview, progress, avatar shop headers.
class GradientHeader extends StatelessWidget {
  final LinearGradient gradient;
  final Widget child;
  final double bottomRadius;
  final EdgeInsets padding;

  const GradientHeader({
    super.key,
    required this.gradient,
    required this.child,
    this.bottomRadius = AppRadius.header,
    this.padding = const EdgeInsets.only(
      left: 20,
      right: 20,
      top: 60,
      bottom: 25,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(bottomRadius),
          bottomRight: Radius.circular(bottomRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
