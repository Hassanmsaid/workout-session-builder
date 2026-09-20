import 'package:flutter/material.dart';
import 'package:traininpink_workout_task/models/exercise.dart';

class ExerciseFormScreen extends StatefulWidget {
  const ExerciseFormScreen({super.key, this.exercise});

  final Exercise? exercise;

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _setsController;
  late final TextEditingController _valueController;
  late TargetType _targetType;

  @override
  void initState() {
    super.initState();
    final existing = widget.exercise;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _categoryController = TextEditingController(text: existing?.category ?? '');
    _setsController = TextEditingController(text: (existing?.targetSets ?? 3).toString());
    _valueController = TextEditingController(text: (existing?.targetValue ?? 10).toString());
    _targetType = existing?.targetType ?? TargetType.reps;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _setsController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.exercise?.id ?? 'ex-${DateTime.now().microsecondsSinceEpoch}';
    final result = Exercise(
      id: id,
      name: _nameController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? 'General'
          : _categoryController.text.trim(),
      targetSets: int.parse(_setsController.text),
      targetType: _targetType,
      targetValue: int.parse(_valueController.text),
      isCompleted: widget.exercise?.isCompleted ?? false,
    );
    Navigator.of(context).pop(result);
  }

  String? _requiredPositiveInt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 'Enter a whole number > 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exercise != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit exercise' : 'Add exercise')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Push, Legs, Core',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _setsController,
              decoration: const InputDecoration(labelText: 'Target sets'),
              keyboardType: TextInputType.number,
              validator: _requiredPositiveInt,
            ),
            const SizedBox(height: 12),
            SegmentedButton<TargetType>(
              segments: const [
                ButtonSegment(value: TargetType.reps, label: Text('Reps')),
                ButtonSegment(value: TargetType.time, label: Text('Time (s)')),
              ],
              selected: {_targetType},
              onSelectionChanged: (selection) {
                setState(() => _targetType = selection.first);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: _targetType == TargetType.time ? 'Seconds per set' : 'Reps per set',
              ),
              keyboardType: TextInputType.number,
              validator: _requiredPositiveInt,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(isEditing ? 'Save changes' : 'Add exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
