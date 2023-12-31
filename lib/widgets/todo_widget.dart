import 'package:flutter/material.dart';
import 'package:flutter_supabase_crud/models/todo.dart';
import 'package:flutter_supabase_crud/widgets/upsert_todo_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/utils.dart';

class TodoWidget extends StatefulWidget {
  const TodoWidget({
    required this.todo,
    super.key,
  });

  final Todo todo;

  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  bool isCompleted = false;

  @override
  void initState() {
    isCompleted = widget.todo.isCompleted;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Card(
        child: Row(
          children: [
            IconButton(
              onPressed: () => markAsCompleted(context, widget.todo),
              icon: isCompleted ? const Icon(Icons.radio_button_checked) : const Icon(Icons.radio_button_off),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.todo.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.todo.description ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          // onPressed: () => showUpdateTodoModal(context, widget.todo),
                          onPressed: () => delete(context, widget.todo),
                          child: const Text('DELETE'),
                        ),
                        TextButton(
                          // onPressed: () => showUpdateTodoModal(context, widget.todo),
                          onPressed: () => showUpsertTodoModal(context, widget.todo),
                          child: const Text('EDIT'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> markAsCompleted(BuildContext context, Todo todo) async {
    setState(() => isCompleted = true);
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      await Supabase.instance.client.from('todos').update({
        'is_completed': true,
      }).match({'id': todo.id});
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, message: e.toString());
    }
  }

  Future<void> delete(BuildContext context, Todo todo) async {
    try {
      await Supabase.instance.client.from('todos').delete().match({'id': todo.id});
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, message: e.toString());
    }
  }
}
