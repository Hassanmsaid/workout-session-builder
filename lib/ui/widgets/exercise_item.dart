import 'package:flutter/material.dart';
import 'package:traininpink_workout_task/models/exercise.dart';

class ExerciseItem extends StatelessWidget {
  const ExerciseItem({
    super.key,
    required this.exercise,
    required this.index,
    required this.onToggleCompleted,
    required this.onTap,
    required this.onDelete,
  });

  final Exercise exercise;
  final int index;
  final VoidCallback onToggleCompleted;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(exercise.id),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: exercise.isCompleted, onChanged: (_) => onToggleCompleted()),
        title: Text(
          exercise.name,
          style: TextStyle(decoration: exercise.isCompleted ? TextDecoration.lineThrough : null),
        ),
        subtitle: Text('${exercise.category} · ${exercise.targetLabel}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.only(left: 4, right: 8),
                child: Icon(Icons.drag_handle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
