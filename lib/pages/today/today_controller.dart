import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/task.dart';
import '../../repositories/reflection_repository.dart';
import '../../repositories/task_repository.dart';
import '../../services/api/calendar_api_service.dart';
import '../../services/local/local_storage_service.dart';

class TodayController extends ChangeNotifier {
  final TaskRepository taskRepository;
  final ReflectionRepository reflectionRepository;
  final CalendarApiService calendarApiService;
  final LocalStorageService localStorage;

  TodayController({
    required this.taskRepository,
    required this.reflectionRepository,
    required this.calendarApiService,
    required this.localStorage,
  });

  String currentKey = _todayKey();

  List<Task> tasks = [];

  String reflection = '';

  bool isLoading = false;

  bool isSavingReflection = false;

  bool isReordering = false;

  String? errorMessage;

  int streak = 0;

  List<CalendarDay> calendarDays = [];

  Timer? _reflectionDebounce;

  static String _todayKey() {
    final now = DateTime.now();

    return _formatDate(now);
  }

  static String _formatDate(
    DateTime date,
  ) {
    final year = date.year.toString().padLeft(
          4,
          '0',
        );

    final month = date.month.toString().padLeft(
          2,
          '0',
        );

    final day = date.day.toString().padLeft(
          2,
          '0',
        );

    return '$year-$month-$day';
  }

  double get completionRate {
    if (tasks.isEmpty) {
      return 0;
    }

    final completed = tasks
        .where(
          (task) => task.done,
        )
        .length;

    return completed / tasks.length;
  }

  Future<void> loadDay(
    String dayKey,
  ) async {
    currentKey = dayKey;
    errorMessage = null;
    isLoading = true;

    notifyListeners();

    try {
      final results = await Future.wait([
        taskRepository.getTasks(
          dayKey,
        ),
        reflectionRepository.getReflection(
          dayKey,
        ),
      ]);

      tasks = results[0] as List<Task>;
      reflection = results[1] as String;

      await _loadStreak();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadDay(
      currentKey,
    );
  }

  Future<void> addTask(
    String title,
  ) async {
    final trimmedTitle = title.trim();

    if (trimmedTitle.isEmpty) {
      return;
    }

    errorMessage = null;

    try {
      final task =
          await taskRepository.createTask(
        title: trimmedTitle,
        date: currentKey,
      );

      tasks = [
        ...tasks,
        task,
      ];

      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTask(
    Task task,
  ) async {
    final oldDone = task.done;

    task.done = !oldDone;

    notifyListeners();

    try {
      final updated =
          await taskRepository.updateTask(
        id: task.id,
        completed: task.done,
      );

      final index = tasks.indexWhere(
        (item) => item.id == task.id,
      );

      if (index != -1) {
        tasks[index] = updated;
      }

      await _loadStreak();

      notifyListeners();
    } catch (error) {
      task.done = oldDone;

      errorMessage = error.toString();

      notifyListeners();
    }
  }

  Future<void> deleteTask(
    Task task,
  ) async {
    final index = tasks.indexWhere(
      (item) => item.id == task.id,
    );

    if (index == -1) {
      return;
    }

    final oldTasks = List<Task>.from(
      tasks,
    );

    tasks.removeAt(index);

    errorMessage = null;

    notifyListeners();

    try {
      await taskRepository.deleteTask(
        task.id,
      );

      await _loadStreak();

      notifyListeners();
    } catch (error) {
      tasks = oldTasks;
      errorMessage = error.toString();

      notifyListeners();
    }
  }

  Future<void> updateTaskTitle(
    Task task,
    String newTitle,
  ) async {
    final trimmedTitle =
        newTitle.trim();

    if (trimmedTitle.isEmpty) {
      return;
    }

    final index = tasks.indexWhere(
      (item) => item.id == task.id,
    );

    if (index == -1) {
      return;
    }

    final oldTitle =
        tasks[index].title;

    tasks[index].title =
        trimmedTitle;

    errorMessage = null;

    notifyListeners();

    try {
      final updated =
          await taskRepository.updateTask(
        id: task.id,
        title: trimmedTitle,
      );

      tasks[index] = updated;

      notifyListeners();
    } catch (error) {
      tasks[index].title =
          oldTitle;

      errorMessage = error.toString();

      notifyListeners();
    }
  }

  void onReflectionChanged(
    String value,
  ) {
    reflection = value;

    errorMessage = null;

    notifyListeners();

    _reflectionDebounce?.cancel();

    _reflectionDebounce =
        Timer(
      const Duration(
        milliseconds: 800,
      ),
      () {
        saveReflection(
          value,
        );
      },
    );
  }

  Future<void> saveReflection(
    String value,
  ) async {
    _reflectionDebounce?.cancel();

    reflection = value;

    isSavingReflection = true;

    notifyListeners();

    try {
      await reflectionRepository.saveReflection(
        currentKey,
        value,
      );
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSavingReflection = false;

      notifyListeners();
    }
  }

  Future<void> reorderTasks(
    int oldIndex,
    int newIndex,
  ) async {
    if (isReordering) {
      return;
    }

    if (oldIndex < 0 ||
        oldIndex >= tasks.length) {
      return;
    }

    if (newIndex < 0 ||
        newIndex > tasks.length) {
      return;
    }

    final oldTasks =
        List<Task>.from(tasks);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item =
        tasks.removeAt(oldIndex);

    tasks.insert(
      newIndex,
      item,
    );

    errorMessage = null;
    isReordering = true;

    notifyListeners();

    try {
      final orderedIds = tasks
          .map(
            (task) => task.id,
          )
          .toList();

      final updatedTasks =
          await taskRepository.reorderTasks(
        date: currentKey,
        orderedIds: orderedIds,
      );

      tasks = updatedTasks;
    } catch (error) {
      tasks = oldTasks;
      errorMessage = error.toString();
    } finally {
      isReordering = false;

      notifyListeners();
    }
  }

  Future<void> loadCalendar() async {
    try {
      calendarDays =
          await calendarApiService
              .getCalendar();

      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();

      notifyListeners();
    }
  }

  Future<void> _loadStreak() async {
    try {
      streak = await calendarApiService.getStreak(currentKey);
    } catch (_) {
      streak = 0;
    }
  }

  Future<void> loadCalendarAndStreak() async {
    try {
      final results = await Future.wait([
        calendarApiService.getCalendar(),
        calendarApiService.getStreak(currentKey),
      ]);

      calendarDays =
          results[0] as List<CalendarDay>;

      streak =
          results[1] as int;

      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();

      notifyListeners();
    }
  }

  List<String> getAvailableDays() {
    return calendarDays
        .map(
          (day) => day.date,
        )
        .where(
          (date) => date.isNotEmpty,
        )
        .toList();
  }

  int calculateStreak() {
    return streak;
  }

  CalendarDay? findCalendarDay(
    String date,
  ) {
    for (final day in calendarDays) {
      if (day.date == date) {
        return day;
      }
    }

    return null;
  }

  @override
  void dispose() {
    _reflectionDebounce?.cancel();

    super.dispose();
  }
}