import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/friend.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';
import '../services/database_helper.dart';

class AppState extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Theme State (0: Light, 1: System, 2: Dark)
  int _themeMode = 0; 
  int get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == 2; // Simple getter for checking dark

  // Friends State
  List<Friend> _friends = [];
  List<Friend> get friends => _friends;
  List<Friend> get activeFriends => _friends.where((f) => f.isActive).toList();
  List<Friend> get archivedFriends => _friends.where((f) => !f.isActive).toList();

  // Transactions State
  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;
  
  // Notifications State
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  // Loading State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AppState() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _friends = await _dbHelper.getAllFriends();
      _transactions = await _dbHelper.getAllTransactions();
      _notifications = await _dbHelper.getAllNotifications();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ==================== THEME ====================
  
  void setThemeMode(int mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // ==================== NOTIFICATIONS ====================

  Future<bool> addNotification(NotificationModel notification) async {
    try {
      await _dbHelper.addNotification(notification);
      await loadData();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateNotification(NotificationModel notification) async {
    try {
      await _dbHelper.updateNotification(notification);
      await loadData();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(int id) async {
    try {
      await _dbHelper.deleteNotification(id);
      await loadData();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== FRIENDS & TRANSACTIONS (Keep existing methods) ====================
  // (Paste all previous friend/transaction methods here: searchFriends, sortFriends, etc.)
  // For brevity in this response, I assume you keep the existing logic. 
  // I will include the critical ones to ensure compilation.
  
  Future<bool> addFriend(Friend friend) async {
    await _dbHelper.insertFriend(friend);
    await loadData();
    return true;
  }
  
  Future<bool> updateFriend(Friend friend) async {
    await _dbHelper.updateFriend(friend);
    await loadData();
    return true;
  }
  
  Future<bool> deleteFriend(int id) async {
    await _dbHelper.deleteFriend(id);
    await loadData();
    return true;
  }

  List<Friend> sortFriends(List<Friend> sourceList, String sortBy, bool ascending) {
     final friendsCopy = List<Friend>.from(sourceList);
    switch (sortBy) {
      case 'Name':
        friendsCopy.sort((a, b) => 
          ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name)
        );
        break;
      case 'Last Paid':
        friendsCopy.sort((a, b) {
          final dateA = a.lastPaidDate ?? DateTime(1900);
          final dateB = b.lastPaidDate ?? DateTime(1900);
          return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
        break;
    }
    return friendsCopy;
  }
  
  List<Friend> searchFriends(String query, {bool searchArchived = false}) {
    final sourceList = searchArchived ? archivedFriends : activeFriends;
    if (query.isEmpty) return sourceList;
    final lowerQuery = query.toLowerCase();
    return sourceList.where((friend) {
      return friend.name.toLowerCase().contains(lowerQuery) ||
          friend.notes.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    await _dbHelper.addTransaction(transaction);
    await loadData();
    return true;
  }
  
  List<TransactionModel> getTransactionsByFriend(int friendId) {
    return _transactions.where((t) => t.friendId == friendId).toList();
  }
  
  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return _transactions.where((t) => t.date.isAfter(startDay) && t.date.isBefore(endDay)).toList();
  }
  
  List<TransactionModel> searchTransactions(String query, {List<TransactionModel>? sourceList}) {
    final list = sourceList ?? _transactions;
    if (query.isEmpty) return list;
    final lowerQuery = query.toLowerCase();
    return list.where((t) {
      final friend = getFriendById(t.friendId);
      return (friend?.name.toLowerCase() ?? '').contains(lowerQuery) || 
             t.claimedBy.toLowerCase().contains(lowerQuery) || 
             t.notes.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  List<TransactionModel> sortTransactions(List<TransactionModel> list, String sortBy, bool ascending) {
    final copy = List<TransactionModel>.from(list);
    switch (sortBy) {
      case 'Name':
        copy.sort((a, b) {
          final nameA = getFriendById(a.friendId)?.name ?? '';
          final nameB = getFriendById(b.friendId)?.name ?? '';
          return ascending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });
        break;
      case 'Date':
        copy.sort((a, b) => ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
        break;
      case 'Amount':
        copy.sort((a, b) => ascending ? a.amount.compareTo(b.amount) : b.amount.compareTo(a.amount));
        break;
    }
    return copy;
  }

  Friend? getFriendById(int id) {
    try {
      return _friends.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
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
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _transactions
        .where((t) => t.date.isAfter(startOfWeekDay))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<Friend> getUnpaidToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return activeFriends.where((friend) {
      if (friend.lastPaidDate == null) return true;
      return friend.lastPaidDate!.isBefore(startOfDay);
    }).toList();
  }

  // ==================== DATA MANAGEMENT ====================
  String exportData() {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
      'friends': _friends.map((f) => f.toJson()).toList(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  Future<bool> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final friendsList = (data['friends'] as List).map((f) => Friend.fromJson(f)).toList();
      final transactionsList = (data['transactions'] as List).map((t) => TransactionModel.fromJson(t)).toList();
      await _dbHelper.importData(friends: friendsList, transactions: transactionsList);
      await loadData();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetData() async {
    await _dbHelper.clearAllData();
    await loadData();
    return true;
  }

  // ==================== UTILITY ====================
  String formatCurrency(double amount) => NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(amount);
  String formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);
  String formatTime(DateTime date) => DateFormat('h:mm a').format(date);
  String formatDateTime(DateTime date) => DateFormat('MMMM dd, yyyy • h:mm a').format(date);
}