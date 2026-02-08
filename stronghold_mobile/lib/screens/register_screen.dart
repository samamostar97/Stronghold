import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/input_decoration_utils.dart';
import 'login_success_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Field-specific server errors
  String? _usernameError;
  String? _emailError;
  String? _phoneError;

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    _usernameError = null;
    _emailError = null;
    _phoneError = null;
  }

  void _setFieldError(String message) {
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('username')) {
      _usernameError = message;
    } else if (lowerMessage.contains('email')) {
      _emailError = message;
    } else if (lowerMessage.contains('broj')) {
      _phoneError = message;
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _clearFieldErrors());

    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final authState = ref.read(authProvider);
      final user = authState.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginSuccessScreen(
              userName: user.displayName,
              userImageUrl: user.profileImageUrl,
              hasActiveMembership: user.hasActiveMembership,
            ),
          ),
        );
      }
    } catch (e) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        setState(() => _setFieldError(error));
        _formKey.currentState!.validate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.error;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Registracija',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFe63946).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_add_outlined, size: 48, color: Color(0xFFe63946)),
                      ),
                      const SizedBox(height: 16),
                      Text('Kreirajte novi racun', style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6))),
                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f0f1a),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFe63946).withValues(alpha: 0.2), width: 1),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('IME'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _firstNameController,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                decoration: buildStrongholdInputDecoration(hintText: 'Unesite vase ime', prefixIcon: Icons.badge_outlined),
                                validator: (value) => value == null || value.isEmpty ? 'Molimo unesite ime' : null,
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('PREZIME'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _lastNameController,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                decoration: buildStrongholdInputDecoration(hintText: 'Unesite vase prezime', prefixIcon: Icons.badge_outlined),
                                validator: (value) => value == null || value.isEmpty ? 'Molimo unesite prezime' : null,
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('EMAIL'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: buildStrongholdInputDecoration(hintText: 'Unesite email adresu', prefixIcon: Icons.email_outlined),
                                validator: (value) {
                                  if (_emailError != null) return _emailError;
                                  if (value == null || value.isEmpty) return 'Molimo unesite email';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Unesite ispravnu email adresu';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('BROJ TELEFONA'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                decoration: buildStrongholdInputDecoration(hintText: '061 123 456', prefixIcon: Icons.phone_outlined),
                                validator: (value) {
                                  if (_phoneError != null) return _phoneError;
                                  if (value == null || value.isEmpty) return 'Molimo unesite broj telefona';
                                  final phoneRegex = RegExp(r'^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$');
                                  if (!phoneRegex.hasMatch(value)) return 'Format: 061 123 456 ili +387 61 123 456';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('KORISNICKO IME'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.next,
                                decoration: buildStrongholdInputDecoration(hintText: 'Odaberite korisnicko ime', prefixIcon: Icons.person_outline),
                                validator: (value) {
                                  if (_usernameError != null) return _usernameError;
                                  if (value == null || value.isEmpty) return 'Molimo unesite korisnicko ime';
                                  if (value.length < 3) return 'Korisnicko ime mora imati najmanje 3 karaktera';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('LOZINKA'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.next,
                                decoration: buildStrongholdInputDecoration(
                                  hintText: 'Kreirajte lozinku',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white.withValues(alpha: 0.5)),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Molimo unesite lozinku';
                                  if (value.length < 6) return 'Lozinka mora imati najmanje 6 karaktera';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('POTVRDITE LOZINKU'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleRegister(),
                                decoration: buildStrongholdInputDecoration(
                                  hintText: 'Ponovite lozinku',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white.withValues(alpha: 0.5)),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Molimo potvrdite lozinku';
                                  if (value != _passwordController.text) return 'Lozinke se ne podudaraju';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),

                              if (errorMessage != null && _usernameError == null && _emailError == null && _phoneError == null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFFe63946).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Color(0xFFe63946), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(errorMessage, style: const TextStyle(color: Color(0xFFe63946), fontSize: 13))),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFe63946),
                                    disabledBackgroundColor: const Color(0xFFe63946).withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('REGISTRUJ SE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Vec imate racun? ', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text('Prijavite se', style: TextStyle(color: Color(0xFFe63946), fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1));
  }
}
