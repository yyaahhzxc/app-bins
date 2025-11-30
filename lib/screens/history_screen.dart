import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Filters: 'Today', 'Week', 'Month', 'All'
  String _selectedFilter = 'All';
  DateTimeRange? _selectedDateRange;

  // Sort
  String _sortBy = 'Date'; // 'Date', 'Amount', 'Name'
  bool _isAscending = false; // Default newest first

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // 1. Filter Logic
    List<TransactionModel> filteredList = appState.transactions;
    final now = DateTime.now();

    if (_selectedDateRange != null) {
      filteredList = appState.getTransactionsByDateRange(
        _selectedDateRange!.start, 
        _selectedDateRange!.end
      );
    } else {
      switch (_selectedFilter) {
        case 'Today':
          filteredList = appState.getTransactionsByDateRange(
            DateTime(now.year, now.month, now.day), 
            DateTime(now.year, now.month, now.day, 23, 59, 59)
          );
          break;
        case 'Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          filteredList = appState.getTransactionsByDateRange(
             DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
             DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59)
          );
          break;
        case 'Month':
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          filteredList = appState.getTransactionsByDateRange(startOfMonth, endOfMonth);
          break;
        case 'All':
        default:
          // Keep all
          break;
      }
    }

    // 2. Search Logic (Optional, assuming Search is handled in AppState or locally if needed)
    // For now, we rely on the list we have.

    // 3. Sort Logic
    filteredList = appState.sortTransactions(filteredList, _sortBy, _isAscending);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kPaddingLarge),
              child: Column(
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: kPaddingMedium),

                  // Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Today'),
                        _buildFilterChip('Week'),
                        _buildFilterChip('Month'),
                        const SizedBox(width: 8),
                        
                        // Custom Date Range Pill
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
                              border: Border.all(color: isDark ? Colors.grey[700]! : kUnpaidContainerColor),
                              borderRadius: BorderRadius.circular(20),
                              color: _selectedDateRange != null 
                                ? (isDark ? kUnpaidContainerColorDark : kUnpaidContainerColor) 
                                : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today, 
                                  size: 14, 
                                  color: _selectedDateRange != null ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[600])
                                ),
                                if (_selectedDateRange != null) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDateRange = null;
                                        _selectedFilter = 'All';
                                      });
                                    },
                                    child: Icon(Icons.close, size: 16, color: primaryColor),
                                  )
                                ]
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kPaddingMedium),

                  // Sort Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Sort by: ', style: TextStyle(color: Colors.grey)),
                      PopupMenuButton<String>(
                        initialValue: _sortBy,
                        onSelected: (val) {
                          if (_sortBy == val) {
                            setState(() => _isAscending = !_isAscending);
                          } else {
                            setState(() {
                              _sortBy = val;
                              _isAscending = true;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Text(_sortBy, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                            Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: primaryColor),
                          ],
                        ),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'Date', child: Text('Date')),
                          const PopupMenuItem(value: 'Amount', child: Text('Amount')),
                          const PopupMenuItem(value: 'Name', child: Text('Name')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No transactions found', style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: kPaddingLarge),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildTransactionTile(context, appState, filteredList[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label && _selectedDateRange == null;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label;
              _selectedDateRange = null; // Clear custom range when preset selected
            });
          }
        },
        backgroundColor: Colors.transparent,
        selectedColor: primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? primaryColor : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? primaryColor : Colors.grey[300]!,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, AppState appState, TransactionModel tx) {
    final friend = appState.getFriendById(tx.friendId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(kPaddingMedium),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: kUnpaidContainerColor,
            child: Text(
              friend?.name.isNotEmpty == true ? friend!.name[0] : '?',
              style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend?.name ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  appState.formatDateTime(tx.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (tx.notes.isNotEmpty)
                  Text(
                    tx.notes,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                appState.formatCurrency(tx.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kPrimaryColor,
                ),
              ),
              if (tx.claimedBy.isNotEmpty)
                Text(
                  'by ${tx.claimedBy}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _selectedFilter = 'Custom'; 
      });
    }
  }
}