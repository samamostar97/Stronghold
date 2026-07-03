import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/api_client.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<AuthProvider>().login(
            _usernameController.text.trim(),
            _passwordController.text,
          );
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.fitness_center, size: 64),
                  const SizedBox(height: 8),
                  Text(
                    'Stronghold',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Korisničko ime ili e-mail',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Unesite korisničko ime ili e-mail.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Lozinka',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Unesite lozinku.' : null,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: loading ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Prijavi se'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                    child: const Text('Nemate nalog? Registrujte se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
