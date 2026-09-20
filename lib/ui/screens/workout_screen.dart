import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traininpink_workout_task/models/exercise.dart';
import 'package:traininpink_workout_task/providers/workout_provider.dart';
import 'package:traininpink_workout_task/ui/screens/exercise_form_screen.dart';
import 'package:traininpink_workout_task/ui/widgets/exercise_item.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WorkoutProvider>();
      provider.loadWorkout();
    });
  }

  Future<void> _openExerciseForm({Exercise? current}) async {
    final provider = context.read<WorkoutProvider>();
    final Exercise? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExerciseFormScreen(exercise: current)),
    );
    if (result != null) {
      if (current == null) {
        provider.addNewExercise(result);
      } else {
        provider.updateExercise(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Screen')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await _openExerciseForm(),
        child: Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.exercises.isEmpty) {
            return const Center(child: Text('No exercises found'));
          }
          return ReorderableListView.builder(
            itemBuilder: (context, i) {
              final exercise = provider.exercises[i];
              return ExerciseItem(
                key: ValueKey(exercise.id),
                exercise: exercise,
                index: i,
                onToggleCompleted: () => provider.toggleExerciseCompletion(exercise.id),
                onTap: () async => await _openExerciseForm(current: exercise),
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete Exercise'),
                        content: const Text('Are you sure you want to delete this exercise?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteExercise(exercise.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
            itemCount: provider.exercises.length,
            onReorderItem: (oldIndex, newIndex) => provider.reorderExercises(oldIndex, newIndex),
          );
        },
      ),
    );
  }
}
