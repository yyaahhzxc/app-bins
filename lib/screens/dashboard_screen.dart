import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/friend.dart';
import '../utils/constants.dart';
import '../widgets/stats_card.dart';
import '../widgets/friend_list_tile.dart';
import '../widgets/pill_card.dart';
import '../widgets/custom_text_field.dart';
import '../models/transaction_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Vince's App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTextOnPrimary,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
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
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Total Collected Today',
                            value: appState.formatCurrency(
                              appState.totalCollectedToday,
                            ),
                            subtitle: appState.formatDate(DateTime.now()),
                          ),
                        ),
                        const SizedBox(width: kPaddingMedium),
                        Expanded(
                          child: StatsCard(
                            title: 'Total Collected This Week',
                            value: appState.formatCurrency(
                              appState.totalCollectedWeek,
                            ),
                            subtitle: _getWeekRange(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kPaddingLarge),

                    // Unpaid Today Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Unpaid Today',
                          style: TextStyle(
                            fontSize: kHeadingSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showAddPaymentModal(context),
                          icon: const Icon(Icons.add_circle, size: 32),
                          color: kPrimaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: kPaddingMedium),

                    // Unpaid Friends List
                    _buildUnpaidList(context, appState),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUnpaidList(BuildContext context, AppState appState) {
    final unpaidFriends = appState.getUnpaidToday();

    if (unpaidFriends.isEmpty) {
      return PillCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(kPaddingLarge),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: kPaddingMedium),
                Text(
                  'All caught up!',
                  style: TextStyle(
                    fontSize: kTitleSize,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: kPaddingSmall),
                Text(
                  'No unpaid transactions today',
                  style: TextStyle(
                    fontSize: kBodySize,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: unpaidFriends.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: kPaddingMedium),
      itemBuilder: (context, index) {
        final friend = unpaidFriends[index];
        return FriendListTile(
          friend: friend,
          onTap: () => _showAddPaymentModal(context, friend: friend),
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

  void _showAddPaymentModal(BuildContext context, {Friend? friend}) {
    final formKey = GlobalKey<FormState>();
    final appState = context.read<AppState>();
    
    Friend? selectedFriend = friend;
    final amountController = TextEditingController();
    final claimedByController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      'Add New Payment',
                      style: TextStyle(
                        fontSize: kHeadingSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: kPaddingLarge),

                    // Person Name Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Person Name',
                          style: TextStyle(
                            fontSize: kBodySize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: kPaddingSmall),
                        DropdownButtonFormField<Friend>(
                          initialValue: selectedFriend,
                          decoration: InputDecoration(
                            hintText: 'Select person',
                            suffixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(kBorderRadius),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a person';
                            }
                            return null;
                          },
                          items: appState.activeFriends.map((f) {
                            return DropdownMenuItem<Friend>(
                              value: f,
                              child: Text(f.name),
                            );
                          }).toList(),
                          onChanged: (Friend? value) {
                            setState(() {
                              selectedFriend = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: kPaddingMedium),

                    // Payment Amount
                    CustomTextField(
                      label: 'Payment',
                      hintText: 'Enter amount',
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.currency_exchange),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: kPaddingMedium),

                    // Claimed By
                    CustomTextField(
                      label: 'Claimed by',
                      hintText: 'Enter name',
                      controller: claimedByController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter who claimed this';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: kPaddingMedium),

                    // Notes
                    CustomTextField(
                      label: 'Notes',
                      hintText: 'Optional notes',
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
                                final transaction = TransactionModel(
                                  friendId: selectedFriend!.id!,
                                  amount: double.parse(amountController.text),
                                  date: DateTime.now(),
                                  claimedBy: claimedByController.text,
                                  notes: notesController.text,
                                  type: 'payment',
                                );

                                final success = await appState.addTransaction(transaction);
                                
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Payment added successfully'),
                                        backgroundColor: kPrimaryColor,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to add payment'),
                                        backgroundColor: kErrorColor,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text('Add Payment'),
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
      },
    );
  }
}
