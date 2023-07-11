import 'package:flutter/material.dart';
import 'package:flutter_supabase_crud/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// showCreateTodoModal function
Future<void> showCreateTodoModal(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) {
      return const CreateTodoModal();
    },
  );
}

class CreateTodoModal extends StatefulWidget {
  const CreateTodoModal({Key? key}) : super(key: key);

  @override
  State<CreateTodoModal> createState() => _CreateTodoModalState();
}

class _CreateTodoModalState extends State<CreateTodoModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

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
                await Supabase.instance.client.from('todos').insert({
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
          child: isLoading ? const CircularProgressIndicator() : const Text('Create'),
        ),
      ],
    );
  }
}
