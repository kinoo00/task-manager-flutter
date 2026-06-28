import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/presentation/providers/project_provider.dart';
import 'package:task_manager/presentation/widgets/custom_button.dart';
import 'package:task_manager/presentation/widgets/custom_text_field.dart';

class AddProjectBottomSheet extends ConsumerStatefulWidget {
  const AddProjectBottomSheet({super.key});

  @override
  ConsumerState<AddProjectBottomSheet> createState() => _AddProjectBottomSheetState();
}

class _AddProjectBottomSheetState extends ConsumerState<AddProjectBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'Active';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // Call addProject (we need to implement this)
    final notifier = ref.read(projectProvider.notifier);
    await notifier.addProject(title, description, _status);
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
            const Text('Add New Project', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _titleController,
              label: 'Project Title',
              validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description (optional)',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['Active', 'Completed'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _status = val!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 24),
            CustomButton(onPressed: _submit, label: 'Add Project'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}