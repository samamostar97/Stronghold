import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/feedback_dialog.dart';
import '../utils/input_decoration_utils.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  bool _isLoading = false;
  bool _codeSent = false;

  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showFeedback({required bool isSuccess, required String message}) async {
    if (isSuccess) {
      await showSuccessFeedback(context, message);
    } else {
      await showErrorFeedback(context, message);
    }
  }

  Future<void> _handleSendCode() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _codeSent = true;
      });
      await _showFeedback(isSuccess: true, message: 'Kod je poslan na vašu email adresu');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final error = ref.read(authProvider).error ?? 'Greska prilikom slanja koda';
      await _showFeedback(isSuccess: false, message: error);
    }
  }

  Future<void> _handleResendCode() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _isLoading = false);
      await _showFeedback(isSuccess: true, message: 'Kod je ponovo poslan na vašu email adresu');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final error = ref.read(authProvider).error ?? 'Greska prilikom slanja koda';
      await _showFeedback(isSuccess: false, message: error);
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      await _showFeedback(isSuccess: true, message: 'Lozinka uspješno resetovana');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final error = ref.read(authProvider).error ?? 'Greska prilikom resetovanja lozinke';
      await _showFeedback(isSuccess: false, message: error);
    }
  }

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('EMAIL'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSendCode(),
            decoration: buildStrongholdInputDecoration(hintText: 'Unesite email adresu', prefixIcon: Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Molimo unesite email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Unesite ispravnu email adresu';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe63946),
                disabledBackgroundColor: const Color(0xFFe63946).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('POŠALJI KOD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep() {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('KOD'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _codeController,
            style: const TextStyle(color: Colors.white, letterSpacing: 8),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            maxLength: 6,
            decoration: buildStrongholdInputDecoration(hintText: '------', prefixIcon: Icons.pin_outlined).copyWith(counterText: ''),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Molimo unesite kod';
              if (value.length != 6) return 'Kod mora imati 6 cifara';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('NOVA LOZINKA'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.next,
            decoration: buildStrongholdInputDecoration(
              hintText: 'Unesite novu lozinku',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white.withValues(alpha: 0.5)),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Molimo unesite novu lozinku';
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
            onFieldSubmitted: (_) => _handleResetPassword(),
            decoration: buildStrongholdInputDecoration(
              hintText: 'Ponovite novu lozinku',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white.withValues(alpha: 0.5)),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Molimo potvrdite lozinku';
              if (value != _newPasswordController.text) return 'Lozinke se ne podudaraju';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe63946),
                disabledBackgroundColor: const Color(0xFFe63946).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('RESETUJ LOZINKU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : _handleResendCode,
              child: Text('Pošalji kod ponovo', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1a1a2e), Color(0xFF16213e)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
                    const Expanded(child: Text('Zaboravljena lozinka', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center)),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFe63946).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(_codeSent ? Icons.lock_reset : Icons.email_outlined, size: 48, color: const Color(0xFFe63946)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _codeSent ? 'Unesite kod i novu lozinku' : 'Unesite email adresu vašeg računa',
                        style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f0f1a),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFe63946).withValues(alpha: 0.2), width: 1),
                        ),
                        child: !_codeSent ? _buildEmailStep() : _buildResetStep(),
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
}
