import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/friend.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';

class PersonInfoModal extends StatefulWidget {
  final Friend friend;

  const PersonInfoModal({super.key, required this.friend});

  @override
  State<PersonInfoModal> createState() => _PersonInfoModalState();
}

class _PersonInfoModalState extends State<PersonInfoModal> {
  // State 0: Personal Info, 1: Payment Info
  int _selectedTab = 0; 
  bool _isEditing = false; // State for the Edit View (4th image)

  // Edit Controllers
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.friend.name);
    _notesController = TextEditingController(text: widget.friend.notes);
    _isActive = widget.friend.isActive;
  }

  @override
  Widget build(BuildContext context) {
    // If editing, show the Edit View (Image 4)
    if (_isEditing) {
      return _buildEditView(context);
    }

    // Otherwise show the Info View (Images 2 & 3)
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Tall modal
      padding: const EdgeInsets.only(top: kPaddingMedium),
      child: Column(
        children: [
          // Modal Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: kPaddingMedium),

          // Title
          const Text(
            'Person Info',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: kPaddingLarge),

          // Custom Tab Switcher
          Container(
            margin: const EdgeInsets.symmetric(horizontal: kPaddingLarge),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton('Personal Info', 0),
                const SizedBox(width: kPaddingMedium),
                _buildTabButton('Payment Info', 1),
              ],
            ),
          ),
          const SizedBox(height: kPaddingLarge),

          // Content Area
          Expanded(
            child: _selectedTab == 0
                ? _buildPersonalInfoTab()
                : _buildPaymentInfoTab(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: kPrimaryColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // IMAGE 2: Personal Info View
  Widget _buildPersonalInfoTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingLarge),
      child: Column(
        children: [
          CustomTextField(
            label: 'Person Name',
            controller: TextEditingController(text: widget.friend.name),
            readOnly: true,
            showClearButton: false,
          ),
          const SizedBox(height: kPaddingMedium),
          CustomTextField(
            label: 'Notes',
            controller: TextEditingController(text: widget.friend.notes),
            readOnly: true,
            showClearButton: false,
          ),
          const Spacer(),
          
          // Edit Button (Bottom Right)
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Edit', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: kPaddingLarge),
        ],
      ),
    );
  }

  // IMAGE 3: Payment Info View
  Widget _buildPaymentInfoTab(BuildContext context) {
    final appState = context.watch<AppState>();
    // Logic to filter transactions would go here, currently using all for demo
    final transactions = appState.getTransactionsByFriend(widget.friend.id!);

    return Column(
      children: [
        const Text(
          'Payment Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
        ),
        Text(
          'Last Paid: ${widget.friend.lastPaidDate != null ? appState.formatDate(widget.friend.lastPaidDate!) : "Never"}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: kPaddingMedium),

        // Filter Chips (Visual only for now)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: kPaddingLarge),
          child: Row(
            children: [
              _buildFilterChip('Today', true),
              _buildFilterChip('This Week', false),
              _buildFilterChip('This Month', false),
              _buildFilterChip('All', false),
            ],
          ),
        ),
        const SizedBox(height: kPaddingMedium),

        // Transactions List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(kPaddingLarge),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: kPaddingMedium),
            itemBuilder: (context, index) {
              final tx = transactions[index];
                return Container(
                padding: const EdgeInsets.all(kPaddingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  // REVERTED: withValues -> withOpacity
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    // REVERTED: withValues -> withOpacity
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.formatCurrency(tx.amount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appState.formatDate(tx.date)} • ${appState.formatTime(tx.date)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      'Claimed by: ${tx.claimedBy}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? kPrimaryColor : Colors.grey[300]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  // IMAGE 4: Edit View
  Widget _buildEditView(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: kPaddingMedium,
        left: kPaddingLarge,
        right: kPaddingLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + kPaddingLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: kPaddingMedium),
          const Text(
            'Person Info',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: kPaddingLarge),

          CustomTextField(
            label: 'Person Name',
            controller: _nameController,
          ),
          const SizedBox(height: kPaddingMedium),
          CustomTextField(
            label: 'Notes',
            controller: _notesController,
          ),
          const SizedBox(height: kPaddingLarge),

          // Show Person Toggle
          Row(
            children: [
              const Text(
                'Show Person',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                activeColor: Colors.white,
                activeTrackColor: kPrimaryColor,
              ),
            ],
          ),
          const Spacer(),

          // Cancel / Confirm Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Revert changes or just exit edit mode?
                    // Wireframe shows "Cancel" which usually means go back to read-only
                    setState(() {
                      _isEditing = false;
                      _nameController.text = widget.friend.name; // Reset
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(color: kPrimaryColor),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: kPrimaryColor)),
                ),
              ),
              const SizedBox(width: kPaddingMedium),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Save changes
                    final appState = context.read<AppState>();
                    final updatedFriend = widget.friend.copyWith(
                      name: _nameController.text,
                      notes: _notesController.text,
                      isActive: _isActive,
                    );
                    
                    await appState.updateFriend(updatedFriend);
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Close modal on save
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Person updated successfully')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: kPaddingLarge),
        ],
      ),
    );
  }
}

// Extension to help with time formatting if not in AppState yet
extension AppStateTimeExtension on AppState {
  String formatTime(DateTime date) {
    // Basic time formatter if one doesn't exist in AppState
    return "${date.hour > 12 ? date.hour - 12 : date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}";
  }
}