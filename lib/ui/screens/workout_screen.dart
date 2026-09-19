import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traininpink_workout_task/providers/workout_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Screen')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.exercises.isEmpty) {
            return Center(child: Text('No exercises found'));
          }
          return ReorderableListView.builder(
            itemBuilder: (context, i) {
              final exercise = provider.exercises[i];
              return ExerciseItem(
                key: ValueKey(exercise.id),
                exercise: exercise,
                index: i,
                onToggleCompleted: () {},
                onTap: () {},
                onDelete: () {},
              );
            },
            itemCount: provider.exercises.length,
            onReorderItem: (oldIndex, newIndex) {
              provider.reorderExercises(oldIndex, newIndex);
            },
          );
        },
      ),
    );
  }
}
