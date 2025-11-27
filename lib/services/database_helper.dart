import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/friend.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(kDatabaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: kDatabaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create Friends table
    await db.execute('''
      CREATE TABLE $kTableFriends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        notes TEXT,
        totalBalance REAL NOT NULL DEFAULT 0.0,
        lastPaidDate TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create Transactions table
    await db.execute('''
      CREATE TABLE $kTableTransactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        friendId INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        claimedBy TEXT,
        notes TEXT,
        type TEXT NOT NULL DEFAULT 'payment',
        FOREIGN KEY (friendId) REFERENCES $kTableFriends (id) ON DELETE CASCADE
      )
    ''');

    // Seed initial data for immediate user experience
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Insert dummy friends
    final friendIds = <int>[];
    
    final vince = await db.insert(kTableFriends, {
      'name': 'Vince',
      'notes': 'Main account holder',
      'totalBalance': 800.0,
      'lastPaidDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'isActive': 1,
    });
    friendIds.add(vince);

    final josh = await db.insert(kTableFriends, {
      'name': 'Josh',
      'notes': 'Coworker',
      'totalBalance': 500.0,
      'lastPaidDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'isActive': 1,
    });
    friendIds.add(josh);

    final sarah = await db.insert(kTableFriends, {
      'name': 'Sarah',
      'notes': 'Friend from college',
      'totalBalance': 300.0,
      'lastPaidDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'isActive': 1,
    });
    friendIds.add(sarah);

    // Insert dummy transactions
    await db.insert(kTableTransactions, {
      'friendId': vince,
      'amount': 500.0,
      'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'claimedBy': 'Vince',
      'notes': 'Coffee shop payment',
      'type': 'payment',
    });

    await db.insert(kTableTransactions, {
      'friendId': vince,
      'amount': 300.0,
      'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'claimedBy': 'Vince',
      'notes': 'Grocery shopping',
      'type': 'payment',
    });

    await db.insert(kTableTransactions, {
      'friendId': josh,
      'amount': 500.0,
      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'claimedBy': 'Josh',
      'notes': 'Monthly rent contribution',
      'type': 'payment',
    });

    await db.insert(kTableTransactions, {
      'friendId': sarah,
      'amount': 200.0,
      'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'claimedBy': 'Sarah',
      'notes': 'Birthday gift fund',
      'type': 'payment',
    });

    await db.insert(kTableTransactions, {
      'friendId': sarah,
      'amount': 100.0,
      'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'claimedBy': 'Sarah',
      'notes': 'Movie tickets',
      'type': 'payment',
    });
  }

  // ==================== FRIEND OPERATIONS ====================

  Future<int> insertFriend(Friend friend) async {
    final db = await database;
    return await db.insert(kTableFriends, friend.toMap());
  }

  Future<List<Friend>> getAllFriends() async {
    final db = await database;
    final result = await db.query(
      kTableFriends,
      orderBy: 'name ASC',
    );
    return result.map((map) => Friend.fromMap(map)).toList();
  }

  Future<List<Friend>> getActiveFriends() async {
    final db = await database;
    final result = await db.query(
      kTableFriends,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return result.map((map) => Friend.fromMap(map)).toList();
  }

  Future<Friend?> getFriend(int id) async {
    final db = await database;
    final result = await db.query(
      kTableFriends,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Friend.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateFriend(Friend friend) async {
    final db = await database;
    return await db.update(
      kTableFriends,
      friend.toMap(),
      where: 'id = ?',
      whereArgs: [friend.id],
    );
  }

  Future<int> deleteFriend(int id) async {
    final db = await database;
    // This will cascade delete all transactions due to FOREIGN KEY constraint
    return await db.delete(
      kTableFriends,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await database;
    
    // Use database transaction to ensure atomicity
    return await db.transaction((txn) async {
      // Insert the transaction
      final transactionId = await txn.insert(
        kTableTransactions,
        transaction.toMap(),
      );

      // Update friend's total balance
      final friend = await getFriend(transaction.friendId);
      if (friend != null) {
        final newBalance = friend.totalBalance + transaction.amount;
        await txn.update(
          kTableFriends,
          {
            'totalBalance': newBalance,
            'lastPaidDate': transaction.date.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [transaction.friendId],
        );
      }

      return transactionId;
    });
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final result = await db.query(
      kTableTransactions,
      orderBy: 'date DESC',
    );
    return result.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByFriend(int friendId) async {
    final db = await database;
    final result = await db.query(
      kTableTransactions,
      where: 'friendId = ?',
      whereArgs: [friendId],
      orderBy: 'date DESC',
    );
    return result.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      kTableTransactions,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    
    // Need to recalculate friend balance if amount changed
    return await db.transaction((txn) async {
      // Get old transaction
      final oldResult = await txn.query(
        kTableTransactions,
        where: 'id = ?',
        whereArgs: [transaction.id],
        limit: 1,
      );
      
      if (oldResult.isEmpty) return 0;
      
      final oldTransaction = TransactionModel.fromMap(oldResult.first);
      final difference = transaction.amount - oldTransaction.amount;

      // Update transaction
      final updateCount = await txn.update(
        kTableTransactions,
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      // Update friend balance if amount changed
      if (difference != 0) {
        final friend = await getFriend(transaction.friendId);
        if (friend != null) {
          await txn.update(
            kTableFriends,
            {'totalBalance': friend.totalBalance + difference},
            where: 'id = ?',
            whereArgs: [transaction.friendId],
          );
        }
      }

      return updateCount;
    });
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    
    return await db.transaction((txn) async {
      // Get transaction details before deleting
      final result = await txn.query(
        kTableTransactions,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (result.isEmpty) return 0;
      
      final transaction = TransactionModel.fromMap(result.first);

      // Delete transaction
      final deleteCount = await txn.delete(
        kTableTransactions,
        where: 'id = ?',
        whereArgs: [id],
      );

      // Update friend's balance (subtract the deleted transaction amount)
      final friend = await getFriend(transaction.friendId);
      if (friend != null) {
        await txn.update(
          kTableFriends,
          {'totalBalance': friend.totalBalance - transaction.amount},
          where: 'id = ?',
          whereArgs: [transaction.friendId],
        );
      }

      return deleteCount;
    });
  }

  // ==================== UTILITY OPERATIONS ====================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(kTableTransactions);
    await db.delete(kTableFriends);
  }

  Future<void> importData({
    required List<Friend> friends,
    required List<TransactionModel> transactions,
  }) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete(kTableTransactions);
      await txn.delete(kTableFriends);

      // Insert friends
      for (final friend in friends) {
        await txn.insert(kTableFriends, friend.toMap());
      }

      // Insert transactions
      for (final transaction in transactions) {
        await txn.insert(kTableTransactions, transaction.toMap());
      }
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
