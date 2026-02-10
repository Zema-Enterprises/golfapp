import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/avatar_svg_mapper.dart';
import '../../data/avatar.dart';

/// SVG-based layered avatar — base body + item layers stacked with same viewBox.
class SvgLayeredAvatar extends StatelessWidget {
  final String avatarKey;
  final List<AvatarItem> equippedItems;
  final double height;

  const SvgLayeredAvatar({
    super.key,
    required this.avatarKey,
    required this.equippedItems,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final width = height * 0.5;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withAlpha(30),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base body layer
          SvgPicture.asset(
            avatarBaseSvgPath(avatarKey),
            fit: BoxFit.contain,
          ),
          // Item layers — same viewBox, so they align perfectly
          for (final item in equippedItems)
            SvgPicture.asset(
              avatarItemSvgPath(item),
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }
}
