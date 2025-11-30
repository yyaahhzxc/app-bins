import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../widgets/stats_card.dart';
import '../widgets/fade_in_slide.dart'; // Import the animation

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final containerColor = isDark ? kUnpaidContainerColorDark : kUnpaidContainerColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Vince's App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? kTextPrimaryDark : kTextOnPrimary,
          ),
        ),
        backgroundColor: isDark ? kSurfaceColorDark : kPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => appState.loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(kPaddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animate Stats Cards
                    FadeInSlide(
                      index: 0,
                      child: StatsCard(
                        title: 'Total Collected Today',
                        value: appState.formatCurrency(appState.totalCollectedToday),
                        subtitle: appState.formatDate(DateTime.now()),
                      ),
                    ),
                    const SizedBox(height: kPaddingMedium),
                    FadeInSlide(
                      index: 1,
                      child: StatsCard(
                        title: 'Total Collected This Week',
                        value: appState.formatCurrency(appState.totalCollectedWeek),
                        subtitle: _getWeekRange(context),
                      ),
                    ),
                    const SizedBox(height: kPaddingLarge),
                    
                    // Unpaid Container
                    FadeInSlide(
                      index: 2,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(kPaddingMedium),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Unpaid Today',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: kPaddingMedium),
                            _buildUnpaidList(context, appState),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUnpaidList(BuildContext context, AppState appState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listItemColor = isDark ? kListItemColorDark : kListItemColor;
    final textColor = isDark ? kTextPrimaryDark : const Color(0xFF333333);

    final unpaidFriends = appState.getUnpaidToday();
    if (unpaidFriends.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: kPaddingLarge),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text('All clear for today!', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: unpaidFriends.length,
      separatorBuilder: (context, index) => const SizedBox(height: kPaddingSmall),
      itemBuilder: (context, index) {
        final friend = unpaidFriends[index];
        // Animate individual list items
        return FadeInSlide(
          index: index + 3, // Start index after the main cards
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium, vertical: kPaddingLarge),
            decoration: BoxDecoration(
              color: listItemColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(friend.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
                Text(appState.formatCurrency(friend.totalBalance), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getWeekRange(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final formatter = context.read<AppState>();
    return '${formatter.formatDate(startOfWeek)} - ${formatter.formatDate(endOfWeek)}';
  }
}