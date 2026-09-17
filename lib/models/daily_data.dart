import 'task.dart';

class DailyData {
  final List<Task> tasks;
  final String reflection;
  final DateTime updatedAt;

  DailyData({
    required this.tasks,
    required this.reflection,
    required this.updatedAt,
  });

  factory DailyData.empty() {
    return DailyData(
      tasks: [],
      reflection: '',
      updatedAt: DateTime.now(),
    );
  }

  DailyData copyWith({
    List<Task>? tasks,
    String? reflection,
    DateTime? updatedAt,
  }) {
    return DailyData(
      tasks: tasks ?? this.tasks,
      reflection: reflection ?? this.reflection,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tasks': tasks.map((task) => task.toMap()).toList(),
      'reflection': reflection,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DailyData.fromMap(
    Map<dynamic, dynamic> data,
  ) {
    final rawTasks = data['tasks'];

    final tasks = rawTasks is List
        ? rawTasks
            .whereType<Map>()
            .map(
              (item) => Task.fromMap(item),
            )
            .toList()
        : <Task>[];

    return DailyData(
      tasks: tasks,
      reflection: data['reflection']?.toString() ?? '',
      updatedAt: DateTime.tryParse(
            data['updatedAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}