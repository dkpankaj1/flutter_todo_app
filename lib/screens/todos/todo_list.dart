import 'package:flutter/material.dart';
import 'package:mytodo/app/model/todo_model.dart';
import 'package:mytodo/app/provider/auth.provider.dart';
import 'package:mytodo/app/provider/todo.provider.dart';
import 'package:mytodo/app/routes/app.route.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    // Clear any previous errors when entering the screen
    todoProvider.clearError();
    WidgetsBinding.instance.addPostFrameCallback(
        (context) async => await todoProvider.loadTodos());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Todos",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              onPressed: authProvider.loading
                  ? null
                  : () async => await authProvider.logout(),
              icon: authProvider.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Icon(Icons.exit_to_app),
              style: IconButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white),
            )
          ],
        ),
        floatingActionButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            context.pushNamed(RouteName.createTodo);
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => todoProvider.loadTodos(),
                child: todoProvider.loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : todoProvider.error != null
                        ? Text(todoProvider.error ?? "Error")
                        : ListView.separated(
                            separatorBuilder: (ctx, index) =>
                                const Divider(height: 5),
                            itemCount: todoProvider.todoList.length,
                            itemBuilder: (ctx, index) {
                              final TodoModel todo =
                                  todoProvider.todoList[index];
                              return ListTile(
                                title: Text(todo.title),
                                subtitle: Text(todo.description),
                                trailing: IconButton(
                                    onPressed: () async {
                                      // Show confirmation dialog
                                      final bool? shouldDelete =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: Text(
                                                'Are you sure you want to delete "${todo.title}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      // Only delete if user confirmed
                                      if (shouldDelete == true) {
                                        try {
                                          await todoProvider
                                              .deleteTodo(todo.id);
                                        } catch (e) {
                                          debugPrint(
                                              'Error Deleting todo: ${e.toString()}');
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.delete)),
                              );
                            },
                          ),
              ),
            ),
          ],
        ));
  }
}
