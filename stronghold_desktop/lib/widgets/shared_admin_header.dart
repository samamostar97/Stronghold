import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import '../screens/login_screen.dart';

class SharedAdminHeader extends StatelessWidget {
  const SharedAdminHeader({super.key});

  static const _panel = Color(0xFF22253A);
  static const _accent = Color(0xFFFF5757);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;

        return Row(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: Color(0xFFFF5757),
                  size: 32,
                ),
                const SizedBox(width: 10),
                Text(
                  'STRONGHOLD',
                  style: TextStyle(
                    fontSize: isCompact ? 18 : 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: _panel,
              onSelected: (value) async {
                if (value == 'logout') {
                  await TokenStorage.clear();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.white70, size: 20),
                      SizedBox(width: 12),
                      Text('Profil', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: _accent, size: 20),
                      const SizedBox(width: 12),
                      Text('Odjavi se', style: TextStyle(color: _accent)),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, color: Colors.white70, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Admin',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
