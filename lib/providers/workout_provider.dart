import 'package:flutter/material.dart';
import 'package:traininpink_workout_task/models/exercise.dart';
import 'package:traininpink_workout_task/services/storage_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final StorageService storageService;

  WorkoutProvider({required this.storageService});

  List<Exercise> exercises = [];
  bool isLoading = false;

  Future<void> _saveWorkout() async => await storageService.setExercises(exercises);

  Future<void> loadWorkout() async {
    isLoading = true;
    notifyListeners();
    exercises = storageService.getExercises();
    if (exercises.isEmpty) {
      exercises = await storageService.getOriginalExercises();
    }
    await _saveWorkout();
    isLoading = false;
    notifyListeners();
  }

  void reorderExercises(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final Exercise exercise = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, exercise);
    notifyListeners();
    await _saveWorkout();
  }

  void deleteExercise(String id) async {
    exercises.removeWhere((exercise) => exercise.id == id);
    notifyListeners();
    await _saveWorkout();
  }
}
