import 'package:flutter/material.dart';
import 'package:mytodo/app/provider/todo.provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mytodo/app/routes/app.route.dart';
import 'package:provider/provider.dart';

class TodoCreateScreen extends StatefulWidget {
  const TodoCreateScreen({super.key});

  @override
  State<TodoCreateScreen> createState() => _TodoCreateScreenState();
}

class _TodoCreateScreenState extends State<TodoCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = "";
  String description = "";

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Todo",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: title,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    errorText: todoProvider.titleError,
                    border: const OutlineInputBorder(),
                  ),
                  // validator: Validators.email,
                  onSaved: (v) => title = v!.trim(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  // validator: Validators.email,
                  onSaved: (v) => description = v!.trim(),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: todoProvider.loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            _formKey.currentState!.save();
                            try {
                              await todoProvider.createTodos(
                                  title, description);
                              if (context.mounted) {
                                // Clear the form on successful creation
                                setState(() {
                                  title = "";
                                  description = "";
                                });
                                // Navigate back to todo list
                                context.goNamed(RouteName.todo);
                              }
                            } catch (e) {
                              debugPrint(
                                  'Error creating todo: ${e.toString()}');
                            }
                          },
                    child: todoProvider.loading
                        ? const CircularProgressIndicator()
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
