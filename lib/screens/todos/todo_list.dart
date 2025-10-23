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

class _TodoListScreenState extends State<TodoListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0; // 0: All, 1: Incomplete, 2: Completed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    // Clear any previous errors when entering the screen
    todoProvider.clearError();
    WidgetsBinding.instance.addPostFrameCallback(
        (context) async => await todoProvider.loadTodos());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Todos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: authProvider.loading
                  ? null
                  : () async => await authProvider.logout(),
              icon: authProvider.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.exit_to_app, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              tooltip: 'Logout',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() => _selectedFilter = index),
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.list, size: 18),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      'All (${todoProvider.todoList.length})',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pending_actions, size: 18),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      'Pending (${todoProvider.incompleteTodos.length})',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 18),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      'Done (${todoProvider.completedTodos.length})',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteName.createTodo),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        label: const Text(
          'Add Todo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add),
        elevation: 8,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.grey.shade50,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTodoList(todoProvider.todoList, todoProvider),
            _buildTodoList(todoProvider.incompleteTodos, todoProvider),
            _buildTodoList(todoProvider.completedTodos, todoProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList(List<TodoModel> todos, TodoProvider todoProvider) {
    if (todoProvider.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading todos...'),
          ],
        ),
      );
    }

    if (todoProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              todoProvider.error ?? "Unknown error",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => todoProvider.loadTodos(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFilter == 0
                  ? Icons.assignment_outlined
                  : _selectedFilter == 1
                      ? Icons.pending_actions_outlined
                      : Icons.check_circle_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 0
                  ? 'No todos yet'
                  : _selectedFilter == 1
                      ? 'No pending todos'
                      : 'No completed todos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 0
                  ? 'Add your first todo to get started!'
                  : _selectedFilter == 1
                      ? 'All caught up! Great job!'
                      : 'Complete some todos to see them here.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            if (_selectedFilter == 0) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(RouteName.createTodo),
                icon: const Icon(Icons.add),
                label: const Text('Add Todo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => todoProvider.loadTodos(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (ctx, index) => const SizedBox(height: 12),
        itemCount: todos.length,
        itemBuilder: (ctx, index) {
          final TodoModel todo = todos[index];
          return _buildTodoCard(todo, todoProvider);
        },
      ),
    );
  }

  Widget _buildTodoCard(TodoModel todo, TodoProvider todoProvider) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: todo.isCompleted
              ? LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                )
              : LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => todoProvider.toggleTodoCompletion(todo.id),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: todo.isCompleted
                              ? Colors.green
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: todo.isCompleted
                            ? Colors.green
                            : Colors.transparent,
                      ),
                      child: todo.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      todo.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color:
                                todo.isCompleted ? Colors.grey.shade600 : null,
                          ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          context
                              .pushNamed(RouteName.editTodo, pathParameters: {
                            'id': todo.id.toString(),
                          });
                          break;
                        case 'delete':
                          _showDeleteDialog(todo, todoProvider);
                          break;
                        case 'toggle':
                          todoProvider.toggleTodoCompletion(todo.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              todo.isCompleted
                                  ? Icons.undo
                                  : Icons.check_circle,
                              color: todo.isCompleted
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(todo.isCompleted
                                ? 'Mark Incomplete'
                                : 'Mark Complete'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            const Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (todo.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    todo.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: todo.isCompleted
                              ? Colors.grey.shade500
                              : Colors.grey.shade700,
                        ),
                  ),
                ),
              ],
              if (todo.createdAt != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(todo.createdAt!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                      ),
                      if (todo.isCompleted) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Completed',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(TodoModel todo, TodoProvider todoProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text('Confirm Delete'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete ? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await todoProvider.deleteTodo(todo.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Todo deleted successfully!'),
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
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting todo: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
