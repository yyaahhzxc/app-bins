class Friend {
  final int? id;
  final String name;
  final String notes;
  final double totalBalance;
  final DateTime? lastPaidDate;
  final bool isActive;

  Friend({
    this.id,
    required this.name,
    this.notes = '',
    this.totalBalance = 0.0,
    this.lastPaidDate,
    this.isActive = true,
  });

  // Convert Friend to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'totalBalance': totalBalance,
      'lastPaidDate': lastPaidDate?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  // Create Friend from Map
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] as int?,
      name: map['name'] as String,
      notes: map['notes'] as String? ?? '',
      totalBalance: (map['totalBalance'] as num?)?.toDouble() ?? 0.0,
      lastPaidDate: map['lastPaidDate'] != null
          ? DateTime.parse(map['lastPaidDate'] as String)
          : null,
      isActive: (map['isActive'] as int?) == 1,
    );
  }

  // Create a copy with modified fields
  Friend copyWith({
    int? id,
    String? name,
    String? notes,
    double? totalBalance,
    DateTime? lastPaidDate,
    bool? isActive,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      totalBalance: totalBalance ?? this.totalBalance,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      isActive: isActive ?? this.isActive,
    );
  }

  // For JSON export/import
  Map<String, dynamic> toJson() => toMap();
  factory Friend.fromJson(Map<String, dynamic> json) => Friend.fromMap(json);
}
