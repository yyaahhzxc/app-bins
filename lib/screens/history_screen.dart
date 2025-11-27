import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../widgets/pill_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterPeriod = 'All';
  String _sortBy = 'Name';
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final transactions = appState.filterTransactionsByPeriod(_filterPeriod);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTextOnPrimary,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter and Sort Section
          Container(
            padding: const EdgeInsets.all(kPaddingMedium),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: kPaddingSmall),
                      _buildFilterChip('Today'),
                      const SizedBox(width: kPaddingSmall),
                      _buildFilterChip('This Week'),
                      const SizedBox(width: kPaddingSmall),
                      _buildFilterChip('This Month'),
                    ],
                  ),
                ),
                const SizedBox(height: kPaddingMedium),

                // Sort and Date Picker Row
                Row(
                  children: [
                    const Icon(Icons.sort, color: kPrimaryColor),
                    const SizedBox(width: kPaddingSmall),
                    const Text(
                      'Sort by:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: kPaddingSmall),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        underline: Container(),
                        items: ['Name', 'Date', 'Amount']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _sortBy = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      color: kPrimaryColor,
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
              ],
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
                          Icons.history,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: kPaddingMedium),
                        Text(
                          'No payment history',
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
                      final friend = appState.getFriendById(transaction.friendId);

                      return PillCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    friend?.name ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: kTitleSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: kPaddingSmall / 2),
                                  Text(
                                    appState.formatDateTime(transaction.date),
                                    style: const TextStyle(
                                      fontSize: kCaptionSize,
                                      color: kTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              appState.formatCurrency(transaction.amount),
                              style: const TextStyle(
                                fontSize: kTitleSize,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
