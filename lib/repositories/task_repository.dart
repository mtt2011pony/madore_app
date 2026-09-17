import '../models/task.dart';
import '../services/api/task_api_service.dart';

class TaskRepository {
  final TaskApiService apiService;

  TaskRepository(
    this.apiService,
  );

  Future<List<Task>> getTasks(
    String date,
  ) {
    return apiService.getTasks(
      date,
    );
  }

  Future<Task> createTask({
    required String title,
    required String date,
  }) {
    return apiService.createTask(
      title: title,
      date: date,
    );
  }

  Future<Task> updateTask({
    required String id,
    String? title,
    bool? completed,
  }) {
    return apiService.updateTask(
      id: id,
      title: title,
      completed: completed,
    );
  }

  Future<void> deleteTask(
    String id,
  ) {
    return apiService.deleteTask(
      id,
    );
  }

  Future<List<Task>> reorderTasks({
    required String date,
    required List<String> orderedIds,
  }) {
    return apiService.reorderTasks(
      date: date,
      orderedIds: orderedIds,
    );
  }
}