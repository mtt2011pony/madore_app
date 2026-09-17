import 'package:flutter/material.dart';

import '../../data/quote.dart';
import '../../models/task.dart';
import '../../services/api/calendar_api_service.dart';
import 'today_controller.dart';
import 'widgets/daily_quote_card.dart';
import 'widgets/reflection_input.dart';
import 'widgets/task_input.dart';
import 'widgets/task_list.dart';
import 'widgets/today_header.dart';
import '../../services/auth/auth_controller.dart';

class TodayPage extends StatefulWidget {
  final TodayController controller;
  final AuthController authController;

  const TodayPage({
    super.key,
    required this.controller,
    required this.authController,
  });

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late final TextEditingController taskController;

  late final TextEditingController reflectionController;

  TodayController get controller => widget.controller;

  @override
  void initState() {
    super.initState();

    taskController = TextEditingController();

    reflectionController = TextEditingController();

    controller.addListener(
      _onControllerChanged,
    );

    controller.loadDay(
      controller.currentKey,
    );

    controller.loadCalendarAndStreak();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }

    if (reflectionController.text != controller.reflection) {
      reflectionController.text = controller.reflection;

      reflectionController.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: reflectionController.text.length,
        ),
      );
    }

    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(
      _onControllerChanged,
    );

    taskController.dispose();
    reflectionController.dispose();

    super.dispose();
  }

  Future<void> _addTask() async {
    final text = taskController.text.trim();

    if (text.isEmpty) {
      return;
    }

    await controller.addTask(
      text,
    );

    taskController.clear();

    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _toggleTask(
    Task task,
  ) async {
    await controller.toggleTask(
      task,
    );
  }

  Future<void> _deleteTask(
    Task task,
  ) async {
    await controller.deleteTask(
      task,
    );
  }

  Future<void> _editTask(
    Task task,
  ) async {
    final textController = TextEditingController(
      text: task.title,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Edit task',
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Task title',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              final text = value.trim();

              if (text.isEmpty) {
                return;
              }

              Navigator.of(
                dialogContext,
              ).pop(text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final text = textController.text.trim();

                if (text.isEmpty) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(text);
              },
              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );

    textController.dispose();

    if (result == null) {
      return;
    }

    final newTitle = result.trim();

    if (newTitle.isEmpty ||
        newTitle == task.title) {
      return;
    }

    await controller.updateTaskTitle(
      task,
      newTitle,
    );
  }

  Future<void> _saveReflection(
    String value,
  ) async {
    controller.onReflectionChanged(
      value,
    );
  }

  Future<void> _openCalendar() async {
    await controller.loadCalendar();

    if (!mounted) {
      return;
    }

    final days = [...controller.calendarDays]
      ..sort(
        (a, b) => b.date.compareTo(
          a.date,
        ),
      );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        if (days.isEmpty) {
          return const SafeArea(
            child: SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'No history yet',
                ),
              ),
            ),
          );
        }

        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
              padding: const EdgeInsets.all(
                14,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];

                return _buildCalendarDay(
                  day,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarDay(
    CalendarDay day,
  ) {
    final percentage =
        (day.completionRate * 100).round();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            day.completionRate >= 1
                ? Icons.check
                : day.taskCount > 0
                    ? Icons.access_time
                    : Icons.remove,
          ),
        ),
        title: Text(
          day.date,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            'Done: '
            '${day.completedCount} / '
            '${day.taskCount}   '
            '$percentage%',
          ),
        ),
        trailing: day.hasReflection
            ? const Icon(
                Icons.edit_note,
              )
            : null,
        onTap: () async {
          Navigator.of(
            context,
          ).pop();

          await controller.loadDay(
            day.date,
          );
        },
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final quote = DailyQuote.getToday(
      controller.currentKey,
    );

    final streak = controller.calculateStreak();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text(
          'Madore',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () async {
              await widget.authController.logout();
            },
          ),
          IconButton(
            tooltip: 'Calendar',
            icon: const Icon(
              Icons.calendar_month,
            ),
            onPressed: _openCalendar,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            12,
            10,
            12,
            10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DailyQuoteCard(
                quote: quote,
              ),

              const SizedBox(
                height: 10,
              ),

              TodayHeader(
                date: controller.currentKey,
                streak: streak,
                completionRate: controller.completionRate,
              ),

              const SizedBox(
                height: 10,
              ),

              // 52px，和 TaskItem 保持一致
              TaskInput(
                controller: taskController,
                onAdd: _addTask,
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                'Tasks',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              // Task 区域占据页面剩余的大部分空间
              Expanded(
                child: controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : TaskList(
                        tasks: controller.tasks,
                        onToggle: _toggleTask,
                        onDelete: _deleteTask,
                        onEdit: _editTask,
                        onReorder: controller.reorderTasks,
                      ),
              ),

              const SizedBox(
                height: 6,
              ),

              const Text(
                'Reflection',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              // Reflection 保留底部空间，但不抢 Task 区域高度
              SizedBox(
                height: 72,
                child: ReflectionInput(
                  controller: reflectionController,
                  onChanged: _saveReflection,
                ),
              ),

              if (controller.isSavingReflection)
                const Padding(
                  padding: EdgeInsets.only(
                    top: 3,
                  ),
                  child: Text(
                    'Saving...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ),

              if (controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 3,
                  ),
                  child: Text(
                    controller.errorMessage!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
