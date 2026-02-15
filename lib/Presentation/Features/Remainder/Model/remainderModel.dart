class Reminder {
  String id;
  String title;
  String description;
  DateTime dateTime;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'dateTime': dateTime.toIso8601String(),
  };

  factory Reminder.fromMap(String id, Map<String, dynamic> map) {
    return Reminder(
      id: id,
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}
