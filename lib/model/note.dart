class Note {
  String id;
  String title;
  String description;
  String priority;
  String color;
  DateTime date;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.color,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'color': color,
      'date': date.toUtc().toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['_id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      color: map['color'],
      date: DateTime.parse(map['date'])
          .toLocal(),
    );
  }
}
