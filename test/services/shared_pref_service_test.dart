import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traininpink_workout_task/models/exercise.dart';
import 'package:traininpink_workout_task/services/shared_pref_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferenceService', () {
    late SharedPreferencesService sharedPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPrefs = SharedPreferencesService();
      await sharedPrefs.init();
    });

    tearDown(() {
      SharedPreferencesService.reset();
    });

    test('setExercises and getExercises should work correctly', () async {
      final exercises = [
        Exercise(
          id: '1',
          name: 'Push up',
          category: 'Chest',
          targetSets: 3,
          targetType: TargetType.reps,
          isCompleted: false,
        ),
        Exercise(
          id: '2',
          name: 'Plank',
          category: 'Core',
          targetSets: 60,
          targetType: TargetType.time,
          isCompleted: true,
        ),
      ];

      await sharedPrefs.setExercises(exercises);

      final retrievedExercises = sharedPrefs.getExercises();

      expect(retrievedExercises.length, 2);
      expect(retrievedExercises[0].id, '1');
      expect(retrievedExercises[0].name, 'Push up');
      expect(retrievedExercises[0].targetType, TargetType.reps);
      expect(retrievedExercises[1].id, '2');
      expect(retrievedExercises[1].isCompleted, true);
      expect(retrievedExercises[1].targetType, TargetType.time);
    });

    test('getExercises should return empty list if no data is stored', () {
      final retrievedExercises = sharedPrefs.getExercises();
      expect(retrievedExercises, isEmpty);
    });
  });
}
