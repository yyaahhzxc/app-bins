class TransactionModel {
  final int? id;
  final int friendId;
  final double amount;
  final DateTime date;
  final String claimedBy;
  final String notes;
  final String type; // 'payment' or 'debt'

  TransactionModel({
    this.id,
    required this.friendId,
    required this.amount,
    required this.date,
    this.claimedBy = '',
    this.notes = '',
    this.type = 'payment',
  });

  // Convert Transaction to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'friendId': friendId,
      'amount': amount,
      'date': date.toIso8601String(),
      'claimedBy': claimedBy,
      'notes': notes,
      'type': type,
    };
  }

  // Create Transaction from Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      friendId: map['friendId'] as int,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      claimedBy: map['claimedBy'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      type: map['type'] as String? ?? 'payment',
    );
  }

  // Create a copy with modified fields
  TransactionModel copyWith({
    int? id,
    int? friendId,
    double? amount,
    DateTime? date,
    String? claimedBy,
    String? notes,
    String? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      claimedBy: claimedBy ?? this.claimedBy,
      notes: notes ?? this.notes,
      type: type ?? this.type,
    );
  }

  // For JSON export/import
  Map<String, dynamic> toJson() => toMap();
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel.fromMap(json);
}
