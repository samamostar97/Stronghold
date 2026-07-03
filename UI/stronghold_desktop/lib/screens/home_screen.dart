import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stronghold'),
        actions: [
          IconButton(
            tooltip: 'Odjava',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Dobrodošli, ${user?.firstName ?? ''}!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
