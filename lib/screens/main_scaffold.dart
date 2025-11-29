import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'people_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../models/friend.dart';

// Note: Ensure other imports are present as per previous files

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with SingleTickerProviderStateMixin {
  // ... (Keep existing state variables) ...
  int _selectedIndex = 0;
  bool _isFabOpen = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabRotateAnimation;
  
  final List<Widget> _screens = const [
    DashboardScreen(),
    PeopleScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabRotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) _fabAnimationController.forward();
      else _fabAnimationController.reverse();
    });
  }

  void _closeFab() {
    if (_isFabOpen) {
      setState(() {
        _isFabOpen = false;
        _fabAnimationController.reverse();
      });
    }
  }

  // Helper for Modals (Placeholder to avoid compilation error in this snippet)
  // You should keep your existing _showAddPersonModal and _showAddPaymentModal logic.
  // I am focusing on the build method fix below.
  void _showAddPaymentModal(BuildContext context) {} // Placeholder
  void _showAddPersonModal(BuildContext context) {} // Placeholder

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarColor = isDark ? const Color(0xFF1F1F2E) : const Color(0xFFEEF0FF);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_isFabOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeFab,
                // REVERTED: withValues -> withOpacity
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
            ),
          // ... (Rest of FAB logic remains the same, assuming imports are correct)
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ... FAB Items would go here ...
                FloatingActionButton(
                  onPressed: _toggleFab,
                  backgroundColor: isDark ? kUnpaidContainerColorDark : kUnpaidContainerColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isDark ? kSurfaceColorDark : Colors.white, width: 2),
                  ),
                  child: RotationTransition(
                    turns: _fabRotateAnimation,
                    child: Icon(_isFabOpen ? Icons.close : Icons.add, color: primaryColor, size: 32),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _closeFab();
          });
        },
        backgroundColor: navBarColor,
        indicatorColor: primaryColor,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Colors.white), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people, color: Colors.white), label: 'People'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history, color: Colors.white), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings, color: Colors.white), label: 'Settings'),
        ],
      ),
    );
  }
}