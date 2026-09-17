import '../../models/task.dart';
import 'api_client.dart';

class TaskApiService {
  final ApiClient apiClient;

  TaskApiService(
    this.apiClient,
  );

  Future<List<Task>> getTasks(
    String date,
  ) async {
    final result = await apiClient.get(
      '/api/tasks/?date=$date',
    );

    final data = result['data'];

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => Task.fromServer(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<Task> createTask({
    required String title,
    required String date,
  }) async {
    final result = await apiClient.post(
      '/api/tasks/',
      body: {
        'title': title,
        'date': date,
      },
    );

    final data = result['data'];

    if (data is! Map) {
      throw Exception(
        'Invalid task response',
      );
    }

    return Task.fromServer(
      Map<String, dynamic>.from(data),
    );
  }

  Future<Task> updateTask({
    required String id,
    String? title,
    bool? completed,
  }) async {
    final result = await apiClient.put(
      '/api/tasks/$id',
      body: {
        if (title != null)
          'title': title,
        if (completed != null)
          'completed': completed,
      },
    );

    final data = result['data'];

    if (data is! Map) {
      throw Exception(
        'Invalid task response',
      );
    }

    return Task.fromServer(
      Map<String, dynamic>.from(data),
    );
  }

  Future<void> deleteTask(
    String id,
  ) async {
    await apiClient.delete(
      '/api/tasks/$id',
    );
  }

  Future<List<Task>> reorderTasks({
    required String date,
    required List<String> orderedIds,
  }) async {
    final result = await apiClient.put(
      '/api/tasks/reorder',
      body: {
        'date': date,
        'ordered_ids': orderedIds
            .map(
              (id) => int.parse(id),
            )
            .toList(),
      },
    );

    final data = result['data'];

    if (data is! List) {
      throw Exception(
        'Invalid reorder response',
      );
    }

    return data
        .whereType<Map>()
        .map(
          (item) => Task.fromServer(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}