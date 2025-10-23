// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:mytodo/app/core/errors.dart';
import 'package:mytodo/app/repository/auth.repository.dart';
import 'package:mytodo/app/routes/app.route.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String passwordConfirm = '';

  String? errorName;
  String? errorEmail;
  String? errorPassword;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: const OutlineInputBorder(),
                    errorText: errorName,
                  ),
                  // validator: Validators.required,
                  onSaved: (v) => name = v!.trim()),
              const SizedBox(height: 10),
              TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    errorText: errorEmail,
                  ),
                  // validator: Validators.email,
                  onSaved: (v) => email = v!.trim()),
              const SizedBox(height: 10),
              TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    errorText: errorPassword,
                  ),
                  obscureText: true,
                  // validator: Validators.password,
                  onSaved: (v) => password = v!.trim()),
              const SizedBox(height: 10),
              TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  // validator: (v) {
                  //   if (v == null || v.isEmpty) return 'Required';
                  //   if (v != password) return 'Passwords do not match';
                  //   return null;
                  // },
                  onSaved: (v) => passwordConfirm = v!.trim()),
              const SizedBox(height: 10),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();
                        setState(() {
                          isLoading = true;
                          errorName = null;
                          errorEmail = null;
                          errorPassword = null;
                        });
                        try {
                          await authRepo.register(
                              name, email, password, passwordConfirm);
                          if (context.mounted) {
                            context.goNamed(RouteName.login);
                          }
                        } catch (e) {
                          if (e is ValidationException) {
                            setState(() {
                              if (e.details.containsKey('name')) {
                                errorName = e.details['name'][0];
                              }
                              if (e.details.containsKey('email')) {
                                errorEmail = e.details['email'][0];
                              }
                              if (e.details.containsKey('password')) {
                                errorPassword = e.details['password'][0];
                              }
                            });
                          } else {
                            debugPrint('unknown error');
                          }
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: InkWell(
                      child: const Text(
                        'login Now',
                      ),
                      onTap: () {
                        context.goNamed(RouteName.login);
                      },
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
