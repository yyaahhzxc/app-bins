import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kPaddingMedium),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceColorDark : kSurfaceColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(
          // REVERTED: withValues -> withOpacity
          color: isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.2)
        ),
        boxShadow: [
          BoxShadow(
            // REVERTED: withValues -> withOpacity
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? kTextPrimaryDark : const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? kTextPrimaryDark : kTextPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}