import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traininpink_workout_task/providers/workout_provider.dart';
import 'package:traininpink_workout_task/services/storage_service.dart';
import 'package:traininpink_workout_task/ui/screens/workout_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => WorkoutProvider(storageService: StorageService()),
      child: MaterialApp(
        title: 'Workout',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Color(0xFF656756))),
        home: const WorkoutScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: const Text('Workout Screen')),
    );
  }
}
