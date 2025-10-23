# Flutter Todo App (with Laravel API)

This document provides an **industrial-level Flutter implementation** for a Todo app integrated with Laravel API authentication and CRUD endpoints.  
It uses the following technologies:
- **State Management:** Provider
- **Routing:** GoRouter
- **HTTP Client:** Dio
- **Local Storage:** SharedPreferences

---

## 🧠 Laravel API Endpoints

| Method | Endpoint | Controller |
|--------|-----------|-------------|
| POST | api/login | Api\AuthController@login |
| POST | api/logout | Api\AuthController@logout |
| POST | api/register | Api\RegisterController@register |
| GET | api/todos | Api\TodoController@index |
| POST | api/todos | Api\TodoController@store |
| GET | api/todos/{todo} | Api\TodoController@show |
| PUT/PATCH | api/todos/{todo} | Api\TodoController@update |
| DELETE | api/todos/{todo} | Api\TodoController@destroy |

---

## 📂 Project Structure

```
lib/
 ├── main.dart
 ├── app_router.dart
 ├── core/
 │   ├── dio_client.dart
 │   ├── exceptions.dart
 │   └── storage_service.dart
 ├── providers/
 │   ├── auth_provider.dart
 │   └── todo_provider.dart
 ├── models/
 │   └── todo.dart
 ├── screens/
 │   ├── login_screen.dart
 │   ├── register_screen.dart
 │   ├── todo_list_screen.dart
 │   └── todo_form_screen.dart
 └── widgets/
     └── todo_tile.dart
```

---

## ⚙️ Step 1: Dio Client Setup

```dart
// lib/core/dio_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://your-laravel-api.com/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );

  static Dio get dio => _dio;

  static Future<void> setAuthHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }
}
```

---

## ⚙️ Step 2: Auth Provider

```dart
// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    try {
      final response = await DioClient.dio.post('login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      _isAuthenticated = true;
      notifyListeners();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    try {
      await DioClient.dio.post('logout');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      _isAuthenticated = false;
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }
}
```

---

## 🧩 Todo Model

```dart
// lib/models/todo.dart
class Todo {
  final int id;
  final String title;
  final String description;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        isCompleted: json['is_completed'] ?? false,
      );
}
```

---

## 📦 Todo Provider

```dart
// lib/providers/todo_provider.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/todo.dart';
import '../core/dio_client.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  Future<void> fetchTodos() async {
    try {
      final res = await DioClient.dio.get('todos');
      _todos = (res.data as List).map((e) => Todo.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTodo(String title, String description) async {
    try {
      final res = await DioClient.dio.post('todos', data: {
        'title': title,
        'description': description,
      });
      _todos.add(Todo.fromJson(res.data));
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }
}
```

---

## 🧭 Routing (GoRouter)

```dart
// lib/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/todo_list_screen.dart';
import 'providers/auth_provider.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuth = authProvider.isAuthenticated;
      if (!isAuth && state.matchedLocation != '/login') return '/login';
      if (isAuth && state.matchedLocation == '/login') return '/todos';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, _) => const LoginScreen()),
      GoRoute(path: '/todos', builder: (context, _) => const TodoListScreen()),
    ],
  );
}
```

---

## 🏁 Main Entry

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/todo_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final router = createRouter(auth);
          return MaterialApp.router(
            title: 'Flutter Todo App',
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
```

---

## 🧠 Notes

- Add robust **exception handling** using `try/catch` and `DioException`.
- Laravel’s API must return JSON with clear error messages.
- Use **Bearer Token** authentication from Sanctum or Passport.
- Use `notifyListeners()` after any state mutation in providers.

---

**✅ Ready for industrial-grade Flutter-Laravel Todo App integration.**
