import 'package:flutter/material.dart';
import 'package:mytodo/app/core/errors.dart';
import 'package:mytodo/app/model/todo_model.dart';
import 'package:mytodo/app/repository/todo_repository.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository _todoRepo = TodoRepository();

  String? _error;
  String? get error => _error;

  bool _loading = false;
  bool get loading => _loading;

  String? _titleError;
  String? get titleError => _titleError;

  String? _descriptionError;
  String? get descriptionError => _descriptionError;

  List<TodoModel> _todoList = [];
  List<TodoModel> get todoList => _todoList;

  // Filter todos by completion status
  List<TodoModel> get completedTodos =>
      _todoList.where((todo) => todo.isCompleted).toList();
  List<TodoModel> get incompleteTodos =>
      _todoList.where((todo) => !todo.isCompleted).toList();

  void clearError() {
    _error = null;
    _titleError = null;
    _descriptionError = null;
    notifyListeners();
  }

  Future<void> loadTodos() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _todoList = await _todoRepo.fetchTodo();
    } catch (e) {
      _error = e.toString();
      debugPrint(e.toString());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createTodos(String title, String description) async {
    _loading = true;
    _titleError = null;
    _descriptionError = null;
    _error = null;
    notifyListeners();

    try {
      TodoModel todo =
          await _todoRepo.create({"title": title, "description": description});

      _todoList.insert(0, todo);
    } catch (e) {
      if (e is ValidationException) {
        _titleError = e.details['title']?[0];
        _descriptionError = e.details['description']?[0];
      } else if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Unknown error';
      }
      rethrow; // Re-throw to let the UI handle it
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateTodo(
      int id, String title, String description, bool isCompleted) async {
    _loading = true;
    _titleError = null;
    _descriptionError = null;
    _error = null;
    notifyListeners();

    try {
      TodoModel updatedTodo = await _todoRepo.update(id, {
        "title": title,
        "description": description,
        "is_completed": isCompleted
      });

      int index = _todoList.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todoList[index] = updatedTodo;
      }
    } catch (e) {
      if (e is ValidationException) {
        _titleError = e.details['title']?[0];
        _descriptionError = e.details['description']?[0];
      } else if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Unknown error occurred while updating todo';
      }
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTodoCompletion(int id) async {
    // Find the todo to toggle
    int index = _todoList.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    TodoModel todo = _todoList[index];
    bool newCompletionStatus = !todo.isCompleted;

    // Optimistically update the UI
    _todoList[index] = todo.copyWith(isCompleted: newCompletionStatus);
    notifyListeners();

    try {
      await _todoRepo.update(id, {
        "title": todo.title,
        "description": todo.description,
        "is_completed": newCompletionStatus
      });
    } catch (e) {
      // Revert the change if the API call fails
      _todoList[index] = todo;
      _error = 'Failed to update todo completion status';
      notifyListeners();
      debugPrint('Error toggling todo completion: ${e.toString()}');
    }
  }

  Future<void> deleteTodo(int id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      bool status = await _todoRepo.delete(id);
      if (status) {
        _todoList.removeWhere((todo) => todo.id == id);
      }
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Unknown error occurred while deleting todo';
      }
      rethrow; // Re-throw to let the UI handle it
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  TodoModel? getTodoById(int id) {
    try {
      return _todoList.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }
}
