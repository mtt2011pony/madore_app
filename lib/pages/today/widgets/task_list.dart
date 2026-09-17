import 'package:flutter/material.dart';

import '../../../models/task.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  final Future<void> Function(
    Task task,
  ) onToggle;

  final Future<void> Function(
    Task task,
  ) onDelete;

  final Future<void> Function(
    Task task,
  ) onEdit;

  final Future<void> Function(
    int oldIndex,
    int newIndex,
  ) onReorder;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(
        top: 2,
        bottom: 2,
      ),
      itemCount: tasks.length,
      buildDefaultDragHandles: false,
      onReorder: onReorder,
      proxyDecorator: (
        child,
        index,
        animation,
      ) {
        return Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          child: child,
        );
      },
      itemBuilder: (
        context,
        index,
      ) {
        final task = tasks[index];

        return TaskItem(
          key: ValueKey(task.id),
          task: task,
          index: index,
          onToggle: () {
            onToggle(task);
          },
          onDelete: () {
            onDelete(task);
          },
          onEdit: () {
            onEdit(task);
          },
        );
      },
    );
  }
}
