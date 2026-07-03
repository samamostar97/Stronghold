import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/faq_provider.dart';

/// Read-only pregled cesto postavljanih pitanja.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<FaqProvider>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FaqProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Česta pitanja')),
      body: provider.loading && provider.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final item = provider.items[index];
                return Card(
                  child: ExpansionTile(
                    title: Text(item.question),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(item.answer),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
