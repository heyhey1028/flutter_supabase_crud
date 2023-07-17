import 'package:flutter/material.dart';
import 'package:flutter_supabase_crud/models/todo.dart';
import 'package:flutter_supabase_crud/widgets/todo_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/utils.dart';

/// search page with search bar on top
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchResults = <Todo>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // search bar with search icon button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search Title',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
                onSubmitted: (value) async => await _onSubmitted(context, value),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: searchResults.map((e) => TodoWidget(todo: e)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// search todo by title
  Future<void> _onSubmitted(BuildContext context, String searchWord) async {
    try {
      final result = await Supabase.instance.client.from('todos').select().textSearch(
            'title',
            "'$searchWord'",
          );
      final datas = result.map<Todo>(Todo.fromJson).toList();
      setState(() {
        searchResults.clear();
        searchResults.addAll(datas);
      });
    } catch (e) {
      showErrorSnackBar(context, message: e.toString());
    }
  }
}
