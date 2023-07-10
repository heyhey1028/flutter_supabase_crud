import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_supabase_crud/widgets/create_todo_modal.dart';
import 'package:flutter_supabase_crud/widgets/todo_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/todo.dart';
import '../utils/utils.dart';
import 'login_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userID = '';
  String userName = '';
  bool isLoggedIn = false;
  bool isLoading = false;
  late StreamSubscription<AuthState> _authStateChangesSubscription;
  late Stream<List<Todo>> todoStream;

  // Create a function that returns a StreamSubscription of AuthState
  StreamSubscription<AuthState> getAuthStateSubscription() {
    // Listen to the onAuthStateChange stream and return the state
    return Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      // If the user is signed in, update the state with their details
      if (state.event == AuthChangeEvent.signedIn) {
        final userData = state.session!.user;
        setState(() {
          isLoggedIn = true;
          userID = userData.id;
          userName = userData.userMetadata!['username'];
          todoStream = getTodoStream(userID);
        });
        // If the user is signed out, reset the state
      } else if (state.event == AuthChangeEvent.signedOut) {
        setState(() {
          isLoggedIn = false;
          userID = '';
          userName = '';
        });
      }
    });
  }

  Stream<List<Todo>> getTodoStream(String userID) {
    return Supabase.instance.client
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userID)
        .order(
          'updated_at',
        )
        .map(
          (events) {
            try {
              return events.map(Todo.fromJson).where((todo) => todo.isCompleted != true).toList();
            } catch (e) {
              print('something went wrong:$e');
            }
            return [];
          },
        );
  }

  @override
  void initState() {
    _authStateChangesSubscription = getAuthStateSubscription();
    super.initState();
  }

  @override
  void dispose() {
    _authStateChangesSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: isLoggedIn ? Text('Hi, $userName') : Text(widget.title),
        actions: [
          if (isLoggedIn)
            IconButton(
              onPressed: () => _logout(),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : isLoggedIn
                ? TodoList(todoStream: todoStream)
                :
                // login button with ElevatedButton
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('To Login'),
                  ),
      ),
      // floatingactionbutton with plus mark
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              onPressed: () => showCreateTodoModal(context),
              // onPressed: () => showUpsertTodoModal(context),
              tooltip: 'Add',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  /// Logs out the current user.
  ///
  /// If the logout process fails, the user is shown a snackbar with the error.
  ///
  /// If the logout process succeeds, the user is taken to the login screen.
  Future<void> _logout() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException catch (error) {
      showErrorSnackBar(context, message: error.message);
    } on Exception catch (error) {
      showErrorSnackBar(context, message: error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
