import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/friend.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/fade_in_slide.dart';

class PersonInfoModal extends StatefulWidget {
  final Friend friend;

  const PersonInfoModal({super.key, required this.friend});

  @override
  State<PersonInfoModal> createState() => _PersonInfoModalState();
}

class _PersonInfoModalState extends State<PersonInfoModal> {
  int _selectedTab = 0; 
  bool _isEditing = false; 

  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late bool _isActive;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.friend.name);
    _notesController = TextEditingController(text: widget.friend.notes);
    _isActive = widget.friend.isActive;
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return _buildEditView(context);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: kPaddingMedium),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: kPaddingMedium),
          
          Hero(
            tag: 'friend_name_${widget.friend.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.friend.name, 
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: kPaddingLarge),

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.transparent,
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

  Widget _buildPersonalInfoTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingLarge),
      child: FadeInSlide(
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
      ),
    );
  }

  Widget _buildPaymentInfoTab(BuildContext context) {
    final appState = context.watch<AppState>();
    final transactions = appState.getTransactionsByFriend(widget.friend.id!);

    return FadeInSlide(
      child: Column(
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
          Text(
            'Last Paid: ${widget.friend.lastPaidDate != null ? appState.formatDate(widget.friend.lastPaidDate!) : 'Never'}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: kPaddingMedium),

          Expanded(
            child: transactions.isEmpty 
            ? Center(child: Text('No transactions yet', style: TextStyle(color: Colors.grey[400])))
            : ListView.separated(
              padding: const EdgeInsets.all(kPaddingLarge),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: kPaddingMedium),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Container(
                  padding: const EdgeInsets.all(kPaddingMedium),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appState.formatDate(tx.date)} • ${appState.formatTime(tx.date)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: kPaddingMedium,
        left: kPaddingLarge,
        right: kPaddingLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + kPaddingLarge,
      ),
      child: Form(
        key: _formKey,
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
              'Edit Person Info',
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
              validator: (val) => val == null || val.trim().isEmpty ? 'Name cannot be empty' : null,
            ),
            const SizedBox(height: kPaddingMedium),
            CustomTextField(
              label: 'Notes',
              controller: _notesController,
            ),
            const SizedBox(height: kPaddingLarge),

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
                  // REVERTED: activeThumbColor -> activeColor
                  activeThumbColor: Colors.white,
                  activeTrackColor: kPrimaryColor,
                ),
              ],
            ),
            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _nameController.text = widget.friend.name; 
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
                      if (_formKey.currentState!.validate()) {
                        final appState = context.read<AppState>();
                        final updatedFriend = widget.friend.copyWith(
                          name: _nameController.text.trim(),
                          notes: _notesController.text.trim(),
                          isActive: _isActive,
                        );
                        
                        await appState.updateFriend(updatedFriend);
                        
                        if (context.mounted) {
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Person updated successfully')),
                          );
                        }
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
      ),
    );
  }
}