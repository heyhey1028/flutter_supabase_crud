import 'package:flutter/material.dart';
import 'package:flutter_supabase_crud/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/todo.dart';

// showCreateTodoModal function
Future<void> showUpdateTodoModal(BuildContext context, Todo todo) async {
  await showDialog(
    context: context,
    builder: (context) {
      return UpdateTodoModal(todo: todo);
    },
  );
}

class UpdateTodoModal extends StatefulWidget {
  const UpdateTodoModal({required this.todo, super.key});

  final Todo todo;

  @override
  State<UpdateTodoModal> createState() => _UpdateTodoModalState();
}

class _UpdateTodoModalState extends State<UpdateTodoModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool isLoading = false;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              setState(() {
                isLoading = true;
              });
              try {
                await Supabase.instance.client.from('todos').update({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'updated_at': DateTime.now().toIso8601String(),
                }).match({'id': widget.todo.id});
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
                if (context.mounted) showErrorSnackBar(context, message: e.toString());
              }

              setState(() {
                isLoading = false;
              });
            }
          },
          child: isLoading ? const CircularProgressIndicator() : const Text('Update'),
        ),
      ],
    );
  }
}
