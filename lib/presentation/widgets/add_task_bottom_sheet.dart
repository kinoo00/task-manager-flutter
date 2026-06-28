import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/presentation/providers/task_provider.dart';
import 'package:task_manager/presentation/widgets/custom_button.dart';
import 'package:task_manager/presentation/widgets/custom_text_field.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  final int projectId;
  const AddTaskBottomSheet({super.key, required this.projectId});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _priority = 'Medium';
  String _status = 'Pending';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final notifier = ref.read(taskProvider(widget.projectId).notifier);
    await notifier.addTask(title, _priority, _status);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _titleController,
              label: 'Task Title',
              validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              items: ['Low', 'Medium', 'High'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _priority = val!),
              decoration: const InputDecoration(labelText: 'Priority'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['Pending', 'In Progress', 'Done'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _status = val!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 24),
            CustomButton(onPressed: _submit, label: 'Add Task'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}