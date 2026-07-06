import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/api_client.dart';

/// Reset lozinke u dva koraka: e-mail -> kod iz e-maila + nova lozinka.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _codeSent = false;
  bool _processing = false;
  String? _error;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processing = true);
    try {
      await context.read<ApiClient>().post('/api/auth/forgot-password', body: {
        'email': _emailController.text.trim(),
      });
      setState(() => _codeSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Ako nalog postoji, kod za reset je poslan na uneseni e-mail.'),
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _resetPassword() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processing = true);
    try {
      await context.read<ApiClient>().post('/api/auth/reset-password', body: {
        'email': _emailController.text.trim(),
        'code': _codeController.text.trim(),
        'newPassword': _passwordController.text,
      });
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Lozinka je promijenjena. Prijavite se novom lozinkom.')),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset lozinke')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _codeSent
                      ? 'Unesite kod iz e-maila i novu lozinku.'
                      : 'Unesite e-mail adresu naloga - poslat ćemo vam kod za reset.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  autofocus: true,
                  enabled: !_codeSent,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Unesite e-mail adresu.';
                    }
                    if (!_emailRegex.hasMatch(v.trim())) {
                      return 'Unesite validan e-mail u formatu: ime@domena.com';
                    }
                    return null;
                  },
                ),
                if (_codeSent) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Kod iz e-maila (6 cifara)',
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (v) => v == null || v.trim().length != 6
                        ? 'Kod ima tačno 6 cifara.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nova lozinka',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Unesite novu lozinku.';
                      if (v.length < 4) {
                        return 'Lozinka mora imati najmanje 4 znaka.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Potvrdite novu lozinku',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v != _passwordController.text
                        ? 'Lozinke se ne podudaraju.'
                        : null,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed:
                      _processing ? null : (_codeSent ? _resetPassword : _sendCode),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _processing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_codeSent ? 'Promijeni lozinku' : 'Pošalji kod'),
                  ),
                ),
                if (_codeSent)
                  TextButton(
                    onPressed: _processing
                        ? null
                        : () => setState(() => _codeSent = false),
                    child: const Text('Pošalji kod ponovo'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
