import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/login/login_branding_panel.dart';
import '../widgets/login/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        const Expanded(flex: 55, child: LoginBrandingPanel()),
        Expanded(
          flex: 45,
          child: Container(
              color: AppColors.surfaceSolid, child: const LoginForm()),
        ),
      ]),
    );
  }
}
