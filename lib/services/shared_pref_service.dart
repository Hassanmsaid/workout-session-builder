import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traininpink_workout_task/models/exercise.dart';

/// Global instance for shared preferences
final sharedPrefs = SharedPreferencesService();

class SharedPreferencesService {
  static SharedPreferences? _sharedPrefs;

  Future<SharedPreferences> init() async => _sharedPrefs ??= await SharedPreferences.getInstance();

  @visibleForTesting
  static void reset() => _sharedPrefs = null;

  Future<void> saveString(String key, String val) async => await _sharedPrefs?.setString(key, val);

  Future<void> setExercises(List<Exercise> exercises) async {
    String updatedJsonString = jsonEncode(exercises.map((e) => e.toJson()).toList());
    await saveString('exercises', updatedJsonString);
  }

  List<Exercise> getExercises() {
    String? jsonString = _sharedPrefs?.getString('exercises');
    List<dynamic> jsonList = jsonString != null ? jsonDecode(jsonString) : [];
    List<Exercise> exercises = jsonList.map((item) => Exercise.fromJson(item)).toList();
    return exercises;
  }
}
