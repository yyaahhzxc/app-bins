import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'pill_card.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return PillCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: kPaddingSmall / 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: kBodySize,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: kPaddingSmall / 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: kCaptionSize,
                color: kTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
