import 'package:flutter/material.dart';

import 'package:pickture/core/theme/app_colors.dart';
import 'package:pickture/presentation/widgets/swipe/swipe_direction.dart';

class SwipeOverlay extends StatelessWidget {
  const SwipeOverlay({
    super.key,
    required this.direction,
    required this.opacity,
  });

  final SwipeDirection? direction;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (direction == null || opacity <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: _color.withValues(alpha: opacity * 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            _icon,
            size: 80,
            color: Colors.white.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }

  Color get _color {
    switch (direction!) {
      case SwipeDirection.left:
        return AppColors.delete;
      case SwipeDirection.right:
        return AppColors.keep;
      case SwipeDirection.up:
        return AppColors.favorite;
    }
  }

  IconData get _icon {
    switch (direction!) {
      case SwipeDirection.left:
        return Icons.delete_rounded;
      case SwipeDirection.right:
        return Icons.check_circle_rounded;
      case SwipeDirection.up:
        return Icons.star_rounded;
    }
  }
}
