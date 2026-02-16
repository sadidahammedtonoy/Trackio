
class Reminder {
  String id;
  String title;
  String description;
  DateTime dateTime;
  int notificationId; // Add this field

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.notificationId,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'dateTime': dateTime.toIso8601String(),
    'notificationId': notificationId,
  };

  factory Reminder.fromMap(String id, Map<String, dynamic> map) {
    return Reminder(
      id: id,
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
      notificationId: map['notificationId'] ?? id.hashCode,
    );
  }
}