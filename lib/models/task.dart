class Task {
  final String id;
  String title;
  bool done;
  DateTime createdAt;
  DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.done = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'done': done,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> data) {
    return Task(
      id: data['id'].toString(),
      title: data['title']?.toString() ?? '',
      done: data['done'] == true,
      createdAt: DateTime.parse(
        data['createdAt'].toString(),
      ),
      updatedAt: DateTime.parse(
        data['updatedAt'].toString(),
      ),
    );
  }

  factory Task.fromServer(Map<String, dynamic> data) {
    final now = DateTime.now();

    return Task(
      id: data['id'].toString(),
      title: data['title']?.toString() ?? '',
      done: data['completed'] == true,
      createdAt: DateTime.tryParse(
            data['created_at']?.toString() ?? '',
          ) ??
          now,
      updatedAt: now,
    );
  }
}