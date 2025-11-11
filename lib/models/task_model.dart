class Task {
  String id;
  String title;
  DateTime date;

  Task({required this.id, required this.title, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        date: DateTime.parse(json['date']),
      );
}
