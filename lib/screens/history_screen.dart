import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Sort State
  String _sortBy = 'Date'; // Default sort
  bool _isAscending = false; // Default newest first

  // Filter State
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // 1. Filter by Date Range (if selected)
    List<TransactionModel> filteredList = _selectedDateRange == null
        ? appState.transactions
        : appState.getTransactionsByDateRange(_selectedDateRange!.start, _selectedDateRange!.end);

    // 2. Sort the filtered list
    List<TransactionModel> sortedList = appState.sortTransactions(filteredList, _sortBy, _isAscending);

    // 3. Apply Search
    final finalTransactions = appState.searchTransactions(_searchQuery, sourceList: sortedList);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kPaddingLarge),
              child: Column(
                children: [
                  const Text(
                    'Payments',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: kPaddingLarge),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search payments...',
                      suffixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: kPaddingLarge,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: kPaddingMedium),

                  // Sort & Date Filter Row
                  Row(
                    children: [
                      const Icon(Icons.sort, size: 20),
                      const SizedBox(width: 8),
                      
                      // Sort Clickable
                      PopupMenuButton<String>(
                        initialValue: _sortBy,
                        onSelected: (String item) {
                          setState(() {
                            if (_sortBy == item) {
                              _isAscending = !_isAscending;
                            } else {
                              _sortBy = item;
                              // Default directions
                              if (item == 'Date') _isAscending = false; // Newest first
                              else _isAscending = true; // A-Z, 0-9
                            }
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(value: 'Name', child: Text('Name')),
                          const PopupMenuItem<String>(value: 'Date', child: Text('Date')),
                          const PopupMenuItem<String>(value: 'Amount', child: Text('Amount')),
                        ],
                        child: Row(
                          children: [
                            Text(
                              'Sort by: $_sortBy',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Icon(
                              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),

                      // Date Range Filter Pill (With Clear Button!)
                      InkWell(
                        onTap: () => _pickDateRange(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 12, 
                            right: _selectedDateRange != null ? 8 : 12, 
                            top: 8, 
                            bottom: 8
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: kUnpaidContainerColor),
                            borderRadius: BorderRadius.circular(20),
                            color: _selectedDateRange != null ? kUnpaidContainerColor.withValues(alpha: 0.2) : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today, 
                                size: 16, 
                                color: kPrimaryColor
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getDateLabel(),
                                style: const TextStyle(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor
                                ),
                              ),
                              // The Clear 'X' Button appears only when a range is selected
                              if (_selectedDateRange != null) ...[
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedDateRange = null;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Payments List
            Expanded(
              child: finalTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No payments found',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          if (_selectedDateRange != null)
                             Padding(
                               padding: const EdgeInsets.only(top: 16.0),
                               child: TextButton(
                                 onPressed: () => setState(() => _selectedDateRange = null),
                                 child: const Text('Clear Date Filter'),
                               ),
                             ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: kPaddingLarge),
                      itemCount: finalTransactions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = finalTransactions[index];
                        final friend = appState.getFriendById(tx.friendId);
                        
                        return InkWell(
                          onTap: () => _showPaymentInfoModal(context, appState, tx, friend),
                          child: Container(
                            padding: const EdgeInsets.all(kPaddingMedium),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EAF6), // Lavender/Blue
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        friend?.name ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        appState.formatDate(tx.date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  appState.formatCurrency(tx.amount),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for button label
  String _getDateLabel() {
    if (_selectedDateRange == null) return 'Select Date';
    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end;
    
    // Check if same day
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${_shortMonth(start)} ${start.day}';
    }
    
    return '${_shortMonth(start)} ${start.day} - ${_shortMonth(end)} ${end.day}';
  }

  String _shortMonth(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[d.month - 1];
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: kPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _showPaymentInfoModal(BuildContext context, AppState appState, TransactionModel tx, dynamic friend) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: kPaddingLarge,
            right: kPaddingLarge,
            top: kPaddingMedium,
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
              const SizedBox(height: kPaddingLarge),
              const Text(
                'Payment Info',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
              const SizedBox(height: kPaddingLarge),

              CustomTextField(
                label: 'Person Name',
                controller: TextEditingController(text: friend?.name ?? 'Unknown'),
                readOnly: true,
                showClearButton: false,
              ),
              const SizedBox(height: kPaddingMedium),

              CustomTextField(
                label: 'Payment',
                controller: TextEditingController(text: appState.formatCurrency(tx.amount)),
                readOnly: true,
                showClearButton: false,
                prefixIcon: const Icon(Icons.attach_money, color: kPrimaryColor),
              ),
              const SizedBox(height: kPaddingMedium),

              CustomTextField(
                label: 'Claimed by',
                controller: TextEditingController(text: tx.claimedBy),
                readOnly: true,
                showClearButton: false,
              ),
              const SizedBox(height: kPaddingMedium),

              CustomTextField(
                label: 'Notes',
                controller: TextEditingController(text: tx.notes),
                readOnly: true,
                showClearButton: false,
              ),
              const SizedBox(height: kPaddingLarge),
            ],
          ),
        );
      },
    );
  }
}