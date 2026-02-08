import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/faq_models.dart';
import '../providers/faq_provider.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_loading_indicator.dart';

class FaqScreen extends ConsumerWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqsAsync = ref.watch(allFaqsProvider);

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
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    ),
                    const Expanded(
                      child: Text(
                        'Česta pitanja',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: faqsAsync.when(
                  loading: () => const AppLoadingIndicator(),
                  error: (error, _) => AppErrorState(
                    message: error.toString().replaceFirst('Exception: ', ''),
                    onRetry: () => ref.invalidate(allFaqsProvider),
                  ),
                  data: (faqs) {
                    if (faqs.isEmpty) {
                      return const AppEmptyState(icon: Icons.help_outline, title: 'Nema čestih pitanja');
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: faqs.length,
                      itemBuilder: (context, index) => _buildFaqItem(context, faqs[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, Faq faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0f0f1a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe63946).withValues(alpha: 0.2), width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: const Color(0xFFe63946),
          collapsedIconColor: Colors.white.withValues(alpha: 0.5),
          title: Text(faq.question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(faq.answer, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
