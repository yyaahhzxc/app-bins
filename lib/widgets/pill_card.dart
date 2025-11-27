import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PillCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const PillCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ?? (isDark ? const Color(0xFF1E1E1E) : kSurfaceColor);

    final card = Container(
      padding: padding ?? const EdgeInsets.all(kPaddingMedium),
      decoration: BoxDecoration(
        color: defaultColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: card,
      );
    }

    return card;
  }
}
