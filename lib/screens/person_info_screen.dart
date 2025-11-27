import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/friend.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/pill_card.dart';

class PersonInfoScreen extends StatefulWidget {
  final Friend friend;

  const PersonInfoScreen({super.key, required this.friend});

  @override
  State<PersonInfoScreen> createState() => _PersonInfoScreenState();
}

class _PersonInfoScreenState extends State<PersonInfoScreen> {
  String _selectedTab = 'Personal Info';
  String _filterPeriod = 'Today';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Person Info',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTextOnPrimary,
          ),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kTextOnPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditPersonModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Switcher
          Container(
            padding: const EdgeInsets.all(kPaddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Personal Info'),
                ),
                const SizedBox(width: kPaddingSmall),
                Expanded(
                  child: _buildTabButton('Payment Info'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _selectedTab == 'Personal Info'
                ? _buildPersonalInfo(appState)
                : _buildPaymentInfo(appState),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = _selectedTab == title;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTab = title;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? kPrimaryColor : Colors.grey[300],
        foregroundColor: isSelected ? kTextOnPrimary : kTextPrimary,
      ),
      child: Text(title),
    );
  }

  Widget _buildPersonalInfo(AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kPaddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Person Name',
                  style: TextStyle(
                    fontSize: kCaptionSize,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: kPaddingSmall / 2),
                Text(
                  widget.friend.name,
                  style: const TextStyle(
                    fontSize: kTitleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kPaddingMedium),
          PillCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: kCaptionSize,
                    fontWeight: FontWeight.w600,
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: kPaddingSmall / 2),
                Text(
                  widget.friend.notes.isEmpty ? 'No notes' : widget.friend.notes,
                  style: const TextStyle(
                    fontSize: kBodySize,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kPaddingMedium),
          PillCard(
            child: Row(
              children: [
                const Text(
                  'Show Person',
                  style: TextStyle(
                    fontSize: kBodySize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: widget.friend.isActive,
                  onChanged: (value) async {
                    final updatedFriend = widget.friend.copyWith(isActive: value);
                    await appState.updateFriend(updatedFriend);
                    setState(() {});
                  },
                  activeTrackColor: kPrimaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(AppState appState) {
    final transactions = appState
        .filterTransactionsByPeriod(_filterPeriod)
        .where((t) => t.friendId == widget.friend.id)
        .toList();

    return Column(
      children: [
        // Filter Chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('Today'),
              const SizedBox(width: kPaddingSmall),
              _buildFilterChip('This Week'),
              const SizedBox(width: kPaddingSmall),
              _buildFilterChip('This Month'),
              const SizedBox(width: kPaddingSmall),
              _buildFilterChip('All'),
            ],
          ),
        ),

        // Payment Summary Header
        Container(
          padding: const EdgeInsets.all(kPaddingMedium),
          child: PillCard(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: kTitleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: kPaddingSmall / 2),
                Text(
                  'Last Paid: ${widget.friend.lastPaidDate != null ? appState.formatDate(widget.friend.lastPaidDate!) : "Never"}',
                  style: const TextStyle(
                    fontSize: kCaptionSize,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Transactions List
        Expanded(
          child: transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: kPaddingMedium),
                      Text(
                        'No payments found',
                        style: TextStyle(
                          fontSize: kTitleSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(kPaddingMedium),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: kPaddingMedium),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return PillCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appState.formatCurrency(transaction.amount),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: kPaddingSmall / 2),
                          Text(
                            appState.formatDateTime(transaction.date),
                            style: const TextStyle(
                              fontSize: kCaptionSize,
                              color: kTextSecondary,
                            ),
                          ),
                          const SizedBox(height: kPaddingSmall / 2),
                          Text(
                            'Claimed by: ${transaction.claimedBy}',
                            style: const TextStyle(
                              fontSize: kBodySize,
                            ),
                          ),
                          if (transaction.notes.isNotEmpty) ...[
                            const SizedBox(height: kPaddingSmall / 2),
                            Text(
                              transaction.notes,
                              style: TextStyle(
                                fontSize: kCaptionSize,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterPeriod == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterPeriod = label;
          });
        }
      },
      selectedColor: kPrimaryColor,
      labelStyle: TextStyle(
        color: isSelected ? kTextOnPrimary : kTextPrimary,
      ),
    );
  }

  void _showEditPersonModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: widget.friend.name);
    final notesController = TextEditingController(text: widget.friend.notes);
    final appState = context.read<AppState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
      ),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: kPaddingMedium,
            right: kPaddingMedium,
            top: kPaddingMedium,
            bottom: MediaQuery.of(context).viewInsets.bottom + kPaddingMedium,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modal Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: kPaddingMedium),
                
                // Title
                const Text(
                  'Person Info',
                  style: TextStyle(
                    fontSize: kHeadingSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: kPaddingLarge),

                // Person Name
                CustomTextField(
                  label: 'Person Name',
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kPaddingMedium),

                // Notes
                CustomTextField(
                  label: 'Notes',
                  controller: notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: kPaddingLarge),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: kPaddingMedium),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final updatedFriend = widget.friend.copyWith(
                              name: nameController.text,
                              notes: notesController.text,
                            );

                            final success = await appState.updateFriend(updatedFriend);
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Person updated successfully'),
                                    backgroundColor: kPrimaryColor,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to update person'),
                                    backgroundColor: kErrorColor,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('Confirm'),
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
