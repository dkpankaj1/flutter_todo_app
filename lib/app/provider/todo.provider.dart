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

  void clearError() {
    _titleError = null;
    _descriptionError = null;
    notifyListeners();
  }

  Future<void> loadTodos() async {
    _loading = true;
    notifyListeners();

    try {
      _todoList = await _todoRepo.fetchTodo();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createTodos(String title, String description) async {
    _loading = true;
    notifyListeners();

    try {
      TodoModel todo =
          await _todoRepo.create({"title": title, "description": description});

      _todoList.insert(0, todo);
    } catch (e) {
      if (e is ValidationException) {
        _titleError = e.details['title'][0];
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

  Future<void> deleteTodo(int id) async {
    _loading = true;
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
        _error = 'Unknown error';
      }
      rethrow; // Re-throw to let the UI handle it
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
