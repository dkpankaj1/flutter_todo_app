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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Create New Todo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: todoProvider.loading ? null : () => context.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.add_task,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add New Todo',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    ),
                                    Text(
                                      'What do you want to accomplish?',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title *',
                              hintText: 'Enter todo title...',
                              errorText: todoProvider.titleError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.title,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description (optional)',
                              hintText: 'Enter description...',
                              errorText: todoProvider.descriptionError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.description,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            maxLines: 4,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: todoProvider.loading ? null : _createTodo,
                      child: todoProvider.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_task),
                                SizedBox(width: 8),
                                Text(
                                  'Create Todo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (todoProvider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              todoProvider.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tip: Keep your todos clear and actionable!',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _createTodo() async {
    if (!_formKey.currentState!.validate()) return;

    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    try {
      await todoProvider.createTodos(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );

      if (context.mounted) {
        // Clear the form on successful creation
        _titleController.clear();
        _descriptionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Todo created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Navigate back to todo list
        context.goNamed(RouteName.todo);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
