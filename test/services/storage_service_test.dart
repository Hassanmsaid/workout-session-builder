import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traininpink_workout_task/models/exercise.dart';
import 'package:traininpink_workout_task/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferenceService', () {
    late StorageService sharedPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPrefs = StorageService();
      await sharedPrefs.init();
    });

    tearDown(() {
      StorageService.reset();
    });

    test('saveString should store a string value', () async {
      await sharedPrefs.saveString('testKey', 'testValue');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('testKey'), 'testValue');
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
          targetValue: 15,
        ),
        Exercise(
          id: '2',
          name: 'Plank',
          category: 'Core',
          targetSets: 60,
          targetType: TargetType.time,
          isCompleted: true,
          targetValue: 30,
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

    test('setExercises should overwrite existing data', () async {
      final exercises1 = [
        Exercise(
          id: '1',
          name: 'Exercise 1',
          category: 'Cat 1',
          targetSets: 1,
          targetType: TargetType.reps,
          targetValue: 15,
        ),
      ];
      final exercises2 = [
        Exercise(
          id: '2',
          name: 'Exercise 2',
          category: 'Cat 2',
          targetSets: 2,
          targetType: TargetType.time,
          targetValue: 30,
        ),
      ];

      await sharedPrefs.setExercises(exercises1);
      await sharedPrefs.setExercises(exercises2);

      final retrievedExercises = sharedPrefs.getExercises();
      expect(retrievedExercises.length, 1);
      expect(retrievedExercises[0].id, '2');
    });

    test('setExercises with empty list should store empty list', () async {
      await sharedPrefs.setExercises([]);
      final retrievedExercises = sharedPrefs.getExercises();
      expect(retrievedExercises, isEmpty);
    });

    test('getExercises should return empty list if no data is stored', () {
      final retrievedExercises = sharedPrefs.getExercises();
      expect(retrievedExercises, isEmpty);
    });

    test('getOriginalExercises should return exercises from asset bundle', () async {
      const mockJson = [
        {
          "id": "ex-1",
          "name": "Mock Push-ups",
          "category": "Push",
          "targetSets": 3,
          "targetType": "reps",
          "isCompleted": false,
          'targetValue': 30,
        },
      ];

      // The key for rootBundle.loadString is 'assets/exercises.json'
      // however, the channel 'flutter/assets' receives the asset key.
      // We need to handle the specific asset key if multiple assets are involved,
      // but for this test, we can just return the mock JSON.
      // Actually, rootBundle.loadString prepends nothing if the path is provided as is.
      // But we need to make sure the message matches or we return null.

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (ByteData? message) async {
          final String key = utf8.decode(message!.buffer.asUint8List());
          if (key == 'assets/exercises.json') {
            return utf8.encoder.convert(jsonEncode(mockJson)).buffer.asByteData();
          }
          return null;
        },
      );

      final exercises = await sharedPrefs.getOriginalExercises();

      expect(exercises.length, 1);
      expect(exercises[0].id, 'ex-1');
      expect(exercises[0].name, 'Mock Push-ups');
    });
  });
}
