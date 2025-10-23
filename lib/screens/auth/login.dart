import 'package:flutter/material.dart';
import 'package:mytodo/app/provider/auth.provider.dart';
import 'package:mytodo/app/routes/app.route.dart';
// import 'package:mytodo/app/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: auth.emailError,
                    border: const OutlineInputBorder(),
                  ),
                  // validator: Validators.email,
                  onSaved: (v) => email = v!.trim(),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  initialValue: password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: auth.passwordError,
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  // validator: Validators.required,
                  onSaved: (v) => password = v!.trim(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: auth.loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            _formKey.currentState!.save();
                            try {
                              await auth.login(email, password);
                              if (context.mounted) {
                                context.go('/todos');
                              }
                            } catch (e) {
                              debugPrint(e.toString());

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())));
                              }
                            }
                          },
                    child: auth.loading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
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
                          'Register Now',
                        ),
                        onTap: () {
                          context.goNamed(RouteName.register);
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
      ),
    );
  }
}
