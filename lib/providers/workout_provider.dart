import 'package:flutter/material.dart';
import 'package:traininpink_workout_task/models/exercise.dart';
import 'package:traininpink_workout_task/services/storage_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final StorageService storageService;

  WorkoutProvider({required this.storageService});

  List<Exercise> exercises = [];
  bool isLoading = false;

  Future<void> loadWorkout() async {
    isLoading = true;
    notifyListeners();
    exercises = storageService.getExercises();
    if (exercises.isEmpty) {
      exercises = await storageService.getOriginalExercises();
    }
    isLoading = false;
    notifyListeners();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final Exercise exercise = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, exercise);
    notifyListeners();
  }
}
