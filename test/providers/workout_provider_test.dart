import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traininpink_workout_task/models/exercise.dart';
import 'package:traininpink_workout_task/providers/workout_provider.dart';
import 'package:traininpink_workout_task/services/storage_service.dart';

class FakeStorageService implements StorageService {
  List<Exercise> exercises = [];
  List<Exercise> originalExercises = [];
  bool setExercisesCalled = false;

  @override
  List<Exercise> getExercises() => exercises;

  @override
  Future<List<Exercise>> getOriginalExercises() async => originalExercises;

  @override
  Future<void> setExercises(List<Exercise> newExercises) async {
    exercises = newExercises;
    setExercisesCalled = true;
  }

  @override
  Future<SharedPreferences> init() async => throw UnimplementedError();

  @override
  Future<void> saveString(String key, String val) async {}
}

void main() {
  late WorkoutProvider provider;
  late FakeStorageService fakeStorage;

  final testExercises = [
    Exercise(
      id: '1',
      name: 'Push up',
      category: 'Chest',
      targetSets: 3,
      targetType: TargetType.reps,
      targetValue: 10,
      isCompleted: false,
    ),
    Exercise(
      id: '2',
      name: 'Squat',
      category: 'Legs',
      targetSets: 3,
      targetType: TargetType.reps,
      targetValue: 15,
      isCompleted: true,
    ),
  ];

  setUp(() {
    fakeStorage = FakeStorageService();
    provider = WorkoutProvider(storageService: fakeStorage);
  });

  group('WorkoutProvider Tests', () {
    test('loadWorkout loads exercises from storage and calculates progress', () async {
      fakeStorage.exercises = List.from(testExercises);

      await provider.loadWorkout();

      expect(provider.exercises.length, 2);
      expect(provider.totalCount, 2);
      expect(provider.completedCount, 1);
      expect(provider.progress, 0.5);
    });

    test('loadWorkout falls back to original exercises if storage is empty', () async {
      fakeStorage.exercises = [];
      fakeStorage.originalExercises = List.from(testExercises);

      await provider.loadWorkout();

      expect(provider.exercises.length, 2);
      expect(provider.exercises.first.id, '1');
    });

    test('addNewExercise adds exercise and saves', () async {
      final newExercise = Exercise(
        id: '3',
        name: 'Plank',
        category: 'Core',
        targetSets: 3,
        targetType: TargetType.time,
        targetValue: 60,
      );

      provider.exercises = List.from(testExercises);

      await provider.addNewExercise(newExercise);

      expect(provider.exercises.length, 3);
      expect(provider.exercises.last.name, 'Plank');
      expect(fakeStorage.setExercisesCalled, true);
    });

    test('deleteExercise removes exercise and saves', () async {
      provider.exercises = List.from(testExercises);

      await provider.deleteExercise('1');

      expect(provider.exercises.length, 1);
      expect(provider.exercises.first.id, '2');
      expect(fakeStorage.setExercisesCalled, true);
    });

    test('reorderExercises reorders correctly', () async {
      provider.exercises = List.from(testExercises); // [1, 2]

      await provider.reorderExercises(0, 1); // Move 1 to position 1

      expect(provider.exercises[0].id, '2');
      expect(provider.exercises[1].id, '1');
      expect(fakeStorage.setExercisesCalled, true);
    });

    test('toggleExerciseCompletion toggles status and saves', () async {
      provider.exercises = [
        Exercise(
          id: '1',
          name: 'Test',
          category: 'Test',
          targetSets: 1,
          targetType: TargetType.reps,
          targetValue: 10,
          isCompleted: false,
        ),
      ];

      await provider.toggleExerciseCompletion('1');

      expect(provider.exercises.first.isCompleted, true);
      expect(fakeStorage.setExercisesCalled, true);

      await provider.toggleExerciseCompletion('1');
      expect(provider.exercises.first.isCompleted, false);
    });

    test('updateExercise updates specific exercise and saves', () async {
      provider.exercises = List.from(testExercises);
      final updated = Exercise(
        id: '1',
        name: 'Push up Updated',
        category: 'Chest',
        targetSets: 4,
        targetType: TargetType.reps,
        targetValue: 20,
      );

      await provider.updateExercise(updated);

      expect(provider.exercises.first.name, 'Push up Updated');
      expect(provider.exercises.first.targetValue, 20);
      expect(provider.exercises.first.targetSets, 4);
      expect(fakeStorage.setExercisesCalled, true);
    });
  });
}
