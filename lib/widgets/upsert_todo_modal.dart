import 'package:flutter/material.dart';
import 'package:flutter_supabase_crud/models/todo.dart';
import 'package:flutter_supabase_crud/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// showUpsertTodoModal function
Future<void> showUpsertTodoModal(BuildContext context, [Todo? todo]) async {
  await showDialog(
    context: context,
    builder: (context) {
      return UpsertTodoModal(todo: todo);
    },
  );
}

class UpsertTodoModal extends StatefulWidget {
  const UpsertTodoModal({
    super.key,
    this.todo,
  });

  final Todo? todo;

  @override
  State<UpsertTodoModal> createState() => _UpsertTodoModalState();
}

class _UpsertTodoModalState extends State<UpsertTodoModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool isLoading = false;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.todo?.title);
    _descriptionController = TextEditingController(text: widget.todo?.description);
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
                await Supabase.instance.client.from('todos').upsert({
                  'id': widget.todo?.id,
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'is_completed': false,
                  'user_id': Supabase.instance.client.auth.currentUser!.id,
                });
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
          child: isLoading ? const CircularProgressIndicator() : const Text('Upsert'),
        ),
      ],
    );
  }
}
