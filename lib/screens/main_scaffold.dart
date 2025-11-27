import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/friend.dart'; // <--- ADDED THIS IMPORT
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import 'dashboard_screen.dart';
import 'people_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with SingleTickerProviderStateMixin {
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
                child: Container(color: Colors.black.withValues(alpha: 0.6)),
              ),
            ),
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isFabOpen) ...[
                  _buildFabMenuItem(
                    context, 'Add New Payment', Icons.payments_outlined,
                    () { _closeFab(); _showAddPaymentModal(context); }
                  ),
                  const SizedBox(height: 16),
                  _buildFabMenuItem(
                    context, 'Add New Person', Icons.person_add_outlined,
                    () { _closeFab(); _showAddPersonModal(context); }
                  ),
                  const SizedBox(height: 16),
                ],
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people, color: Colors.white),
            label: 'People',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history, color: Colors.white),
            label: 'History',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings, color: Colors.white),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildFabMenuItem(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? kSurfaceColorDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
          ),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? kUnpaidContainerColorDark : kUnpaidContainerColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? kSurfaceColorDark : Colors.white, width: 2),
            ),
            child: Icon(icon, color: primaryColor),
          ),
        ),
      ],
    );
  }

  void _showAddPersonModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    final appState = context.read<AppState>();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final titleColor = isDark ? kTextPrimaryDark : kPrimaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 24),
                Text(
                  'Add New Person',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titleColor),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Person Name',
                  controller: nameController,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Notes',
                  controller: notesController,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          side: BorderSide(color: primaryColor),
                        ),
                        child: Text('Cancel', style: TextStyle(color: primaryColor)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final success = await appState.addFriend(Friend(
                              name: nameController.text,
                              notes: notesController.text,
                            ));
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: const Text('Person added successfully'), backgroundColor: primaryColor),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Add Person', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPaymentModal(BuildContext context, {Friend? friend}) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final claimedByController = TextEditingController();
    final notesController = TextEditingController();
    final appState = context.read<AppState>();
    
    final personController = TextEditingController(text: friend?.name ?? '');
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final titleColor = isDark ? kTextPrimaryDark : kPrimaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 24),
                Text(
                  'Add New Payment',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titleColor),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Person Name',
                  controller: personController,
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  readOnly: true, 
                  onTap: () async {
                    // Logic to search person could go here
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Payment',
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.attach_money, color: primaryColor),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val) == null) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Claimed by',
                  controller: claimedByController,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Notes',
                  controller: notesController,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          side: BorderSide(color: primaryColor),
                        ),
                        child: Text('Cancel', style: TextStyle(color: primaryColor)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final friendObj = appState.activeFriends.firstWhere(
                              (f) => f.name == personController.text,
                              orElse: () => appState.activeFriends.isNotEmpty 
                                  ? appState.activeFriends.first 
                                  : Friend(name: 'Unknown'),
                            );

                            if (friendObj.id == null) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a valid person'), backgroundColor: kErrorColor),
                              );
                              return;
                            }

                            final success = await appState.addTransaction(TransactionModel(
                              friendId: friendObj.id!,
                              amount: double.parse(amountController.text),
                              date: DateTime.now(),
                              claimedBy: claimedByController.text,
                              notes: notesController.text,
                            ));

                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: const Text('Payment added successfully'), backgroundColor: primaryColor),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Add Payment', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}