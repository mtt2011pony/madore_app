import 'package:flutter/material.dart';

import '../../../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskItem({
    super.key,
    required this.task,
    required this.index,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        onDelete();
      },
      background: _deleteBackground(
        Alignment.centerLeft,
      ),
      secondaryBackground: _deleteBackground(
        Alignment.centerRight,
      ),
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: Icon(
                    Icons.drag_indicator,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ),

              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onToggle,
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 0.85,
                        child: Checkbox(
                          value: task.done,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) {
                            onToggle();
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 2,
                      ),

                      Expanded(
                        child: Text(
                          task.title,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            decoration: task.done
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.done
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              IconButton(
                tooltip: 'Edit task',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 34,
                  minHeight: 34,
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                onPressed: onEdit,
              ),

              const SizedBox(
                width: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteBackground(
    Alignment alignment,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      alignment: alignment,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}
