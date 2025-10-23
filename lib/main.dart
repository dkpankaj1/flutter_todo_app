import 'package:flutter/material.dart';
import 'package:mytodo/app/provider/auth.provider.dart';
import 'package:mytodo/app/provider/todo.provider.dart';
import 'package:mytodo/app/repository/auth.repository.dart';
import 'package:mytodo/app/core/api_client.dart';
import 'package:mytodo/screens/app.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepo = AuthRepository();
  final authProvider = AuthProvider(authRepo);

  // Set up unauthorized callback for API client
  ApiClient().setUnauthorizedCallback(() {
    authProvider.handleUnauthorized();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
