import 'package:flutter/material.dart';
import 'package:flutter_supabase_crud/widgets/todo_widget.dart';

import '../models/todo.dart';

class TodoList extends StatelessWidget {
  const TodoList({
    required this.todoStream,
    super.key,
  });

  final Stream<List<Todo>> todoStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: todoStream,
      builder: (context, snapshot) {
        final todos = snapshot.data ?? [];

        return ListView(
          children: [
            for (final todo in todos) TodoWidget(todo: todo),
          ],
        );
      },
    );
  }
}
