import 'package:flutter/material.dart';
import 'package:mytodo/app/provider/auth.provider.dart';
import 'package:mytodo/app/routes/app.route.dart';
import 'package:mytodo/screens/splash_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show splash screen while checking authentication
        if (authProvider.isInitializing) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        }

        // Show main app after authentication check is complete
        return MaterialApp.router(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          routerConfig: createRouter(context),
        );
      },
    );
  }
}
