import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import 'package:provider/provider.dart';

class FriendListTile extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onTap;

  const FriendListTile({
    super.key,
    required this.friend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(kPaddingMedium),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : kSurfaceColor,
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: kPrimaryColor,
              radius: 24,
              child: Text(
                friend.name.isNotEmpty 
                    ? friend.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: kTextOnPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: kPaddingMedium),
            
            // Name and Last Paid Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: const TextStyle(
                      fontSize: kTitleSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (friend.lastPaidDate != null)
                    Text(
                      'Last Paid: ${appState.formatDate(friend.lastPaidDate!)}',
                      style: TextStyle(
                        fontSize: kCaptionSize,
                        color: isDark ? Colors.grey[400] : kTextSecondary,
                      ),
                    ),
                ],
              ),
            ),
            
            // Balance
            Text(
              appState.formatCurrency(friend.totalBalance),
              style: TextStyle(
                fontSize: kTitleSize,
                fontWeight: FontWeight.bold,
                color: friend.totalBalance > 0 ? kPrimaryColor : kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
