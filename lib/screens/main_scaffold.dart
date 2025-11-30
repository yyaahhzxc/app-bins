import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../models/friend.dart';
import '../models/transaction_model.dart';
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
      if (_isFabOpen) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
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

  // ... (Modal methods same as previous logic) ...
  // Keeping this concise but complete for the full file replacement needed
  void _showAddPersonModal(BuildContext context) {
    _closeFab();
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: kPaddingLarge,
            right: kPaddingLarge,
            top: kPaddingMedium,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + kPaddingLarge,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Text('Add New Person', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: 'Name',
                  controller: nameController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Notes (Optional)',
                  controller: notesController,
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final success = await context.read<AppState>().addFriend(Friend(
                          name: nameController.text.trim(),
                          notes: notesController.text.trim(),
                        ));
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Person added successfully' : 'Failed to add person'),
                              backgroundColor: success ? kPrimaryColor : kErrorColor,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Save Person', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPaymentModal(BuildContext context) {
    _closeFab();
    final appState = context.read<AppState>();
    
    if (appState.activeFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a person first!'), backgroundColor: kErrorColor),
      );
      return;
    }

    final amountController = TextEditingController();
    final notesController = TextEditingController();
    Friend? selectedFriend = appState.activeFriends.first;
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: kPaddingLarge,
                right: kPaddingLarge,
                top: kPaddingMedium,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + kPaddingLarge,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 20),
                    Text('Record Payment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Friend>(
                          value: selectedFriend,
                          isExpanded: true,
                          items: appState.activeFriends.map((f) {
                            return DropdownMenuItem(
                              value: f,
                              child: Text(f.name, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => selectedFriend = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Amount',
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.attach_money),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid number';
                        if (double.parse(val) <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Date: ${appState.formatDate(selectedDate)}'),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Notes (Optional)',
                      controller: notesController,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate() && selectedFriend != null) {
                            final success = await context.read<AppState>().addTransaction(TransactionModel(
                              friendId: selectedFriend!.id!,
                              amount: double.parse(amountController.text),
                              date: selectedDate,
                              notes: notesController.text.trim(),
                              claimedBy: 'User',
                            ));
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success ? 'Payment recorded' : 'Failed to record payment'),
                                  backgroundColor: success ? kPrimaryColor : kErrorColor,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Save Payment', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                // REVERTED: withValues -> withOpacity
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
            ),
          
          if (_isFabOpen)
            Positioned(
              bottom: 100,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildFabItem(
                    icon: Icons.person_add,
                    label: 'Add Person',
                    onTap: () => _showAddPersonModal(context),
                  ),
                  const SizedBox(height: 16),
                  _buildFabItem(
                    icon: Icons.payments,
                    label: 'Add Payment',
                    onTap: () => _showAddPaymentModal(context),
                  ),
                ],
              ),
            ),

          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
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

  Widget _buildFabItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          onPressed: onTap,
          backgroundColor: Colors.white,
          child: Icon(icon, color: kPrimaryColor),
        ),
      ],
    );
  }
}