import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mytodo/app/provider/auth.provider.dart';
import 'package:mytodo/screens/auth/login.dart';
import 'package:mytodo/screens/auth/register.dart';
import 'package:mytodo/screens/todos/todo_create.dart';
import 'package:mytodo/screens/todos/todo_list.dart';
import 'package:provider/provider.dart';

GoRouter createRouter(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  return GoRouter(
    initialLocation: authProvider.isAuthenticated ? '/todos' : '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuth = authProvider.isAuthenticated;

      // Don't redirect if still initializing (shouldn't happen now, but safety check)
      if (authProvider.isInitializing) {
        return null;
      }

      if (!isAuth &&
          state.location != '/login' &&
          state.location != '/register') {
        return '/login';
      }

      if (isAuth &&
          (state.location == '/login' || state.location == '/register')) {
        return '/todos';
      }

      return null;
    },
    routes: [
      GoRoute(
        name: RouteName.login,
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        name: RouteName.register,
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
          name: RouteName.todo,
          path: '/todos',
          builder: (_, __) => const TodoListScreen(),
          routes: [
            GoRoute(
              name: RouteName.createTodo,
              path: 'create',
              builder: (_, __) => const TodoCreateScreen(),
            ),
          ]),
    ],
  );
}

class RouteName {
  static String login = "login";
  static String register = "register";
  static String todo = "todo.index";
  static String createTodo = "todo.create";
}
