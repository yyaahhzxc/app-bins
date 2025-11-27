import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/friend.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class AppState extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Theme State
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Friends State
  List<Friend> _friends = [];
  List<Friend> get friends => _friends;
  List<Friend> get activeFriends =>
      _friends.where((f) => f.isActive).toList();

  // Transactions State
  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  // Loading State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AppState() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadData();
  }

  // ==================== THEME OPERATIONS ====================

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  // ==================== DATA LOADING ====================

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _friends = await _dbHelper.getAllFriends();
      _transactions = await _dbHelper.getAllTransactions();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== FRIEND OPERATIONS ====================

  Future<bool> addFriend(Friend friend) async {
    try {
      final id = await _dbHelper.insertFriend(friend);
      await loadData();
      return id > 0;
    } catch (e) {
      debugPrint('Error adding friend: $e');
      return false;
    }
  }

  Future<bool> updateFriend(Friend friend) async {
    try {
      final count = await _dbHelper.updateFriend(friend);
      await loadData();
      return count > 0;
    } catch (e) {
      debugPrint('Error updating friend: $e');
      return false;
    }
  }

  Future<bool> deleteFriend(int id) async {
    try {
      final count = await _dbHelper.deleteFriend(id);
      await loadData();
      return count > 0;
    } catch (e) {
      debugPrint('Error deleting friend: $e');
      return false;
    }
  }

  Friend? getFriendById(int id) {
    try {
      return _friends.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Friend> searchFriends(String query) {
    if (query.isEmpty) return activeFriends;
    
    final lowerQuery = query.toLowerCase();
    return activeFriends.where((friend) {
      return friend.name.toLowerCase().contains(lowerQuery) ||
          friend.notes.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final id = await _dbHelper.addTransaction(transaction);
      await loadData();
      return id > 0;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      final count = await _dbHelper.updateTransaction(transaction);
      await loadData();
      return count > 0;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final count = await _dbHelper.deleteTransaction(id);
      await loadData();
      return count > 0;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  List<TransactionModel> getTransactionsByFriend(int friendId) {
    return _transactions.where((t) => t.friendId == friendId).toList();
  }

  List<TransactionModel> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactions.where((t) {
      return t.date.isAfter(start) && t.date.isBefore(end);
    }).toList();
  }

  // ==================== STATISTICS ====================

  double get totalCollectedToday {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _transactions
        .where((t) => t.date.isAfter(startOfDay) && t.date.isBefore(endOfDay))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalCollectedWeek {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return _transactions
        .where((t) => t.date.isAfter(startOfWeekDay))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalBalance {
    return _friends.fold(0.0, (sum, f) => sum + f.totalBalance);
  }

  List<Friend> getUnpaidToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return activeFriends.where((friend) {
      if (friend.lastPaidDate == null) return true;
      return friend.lastPaidDate!.isBefore(startOfDay);
    }).toList();
  }

  // ==================== FILTERING & SORTING ====================

  List<TransactionModel> filterTransactionsByPeriod(String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        final weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'All':
      default:
        return _transactions;
    }

    return _transactions.where((t) => t.date.isAfter(startDate)).toList();
  }

  List<Friend> sortFriends(String sortBy) {
    final friendsCopy = List<Friend>.from(activeFriends);

    switch (sortBy) {
      case 'Name':
        friendsCopy.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Balance':
        friendsCopy.sort((a, b) => b.totalBalance.compareTo(a.totalBalance));
        break;
      case 'Last Paid':
        friendsCopy.sort((a, b) {
          if (a.lastPaidDate == null) return 1;
          if (b.lastPaidDate == null) return -1;
          return b.lastPaidDate!.compareTo(a.lastPaidDate!);
        });
        break;
    }

    return friendsCopy;
  }

  // ==================== DATA IMPORT/EXPORT ====================

  String exportData() {
    try {
      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'friends': _friends.map((f) => f.toJson()).toList(),
        'transactions': _transactions.map((t) => t.toJson()).toList(),
      };
      return jsonEncode(data);
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return '';
    }
  }

  Future<bool> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final friendsList = (data['friends'] as List)
          .map((f) => Friend.fromJson(f as Map<String, dynamic>))
          .toList();
      
      final transactionsList = (data['transactions'] as List)
          .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
          .toList();

      await _dbHelper.importData(
        friends: friendsList,
        transactions: transactionsList,
      );
      
      await loadData();
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  Future<bool> resetData() async {
    try {
      await _dbHelper.clearAllData();
      await loadData();
      return true;
    } catch (e) {
      debugPrint('Error resetting data: $e');
      return false;
    }
  }

  // ==================== UTILITY ====================

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatDateTime(DateTime date) {
    return DateFormat('MMMM dd, yyyy • h:mm a').format(date);
  }
}
