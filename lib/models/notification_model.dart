class NotificationModel {
  final int? id;
  final String time; // Format: "12:00 PM"
  final String description;
  final bool isActive;

  NotificationModel({
    this.id,
    required this.time,
    required this.description,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'description': description,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      time: map['time'] as String,
      description: map['description'] as String,
      isActive: (map['isActive'] as int) == 1,
    );
  }

  NotificationModel copyWith({
    int? id,
    String? time,
    String? description,
    bool? isActive,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      time: time ?? this.time,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}