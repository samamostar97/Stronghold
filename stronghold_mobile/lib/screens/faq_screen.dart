import 'package:flutter/material.dart';
import '../models/faq_models.dart';
import '../services/faq_service.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<Faq>? _faqs;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final faqs = await FaqService.getFaqs();
      if (mounted) {
        setState(() {
          _faqs = faqs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Česta pitanja',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFe63946),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _loadFaqs,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe63946),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pokušaj ponovo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_faqs == null || _faqs!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nema čestih pitanja',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _faqs!.length,
      itemBuilder: (context, index) {
        final faq = _faqs![index];
        return _buildFaqItem(faq);
      },
    );
  }

  Widget _buildFaqItem(Faq faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0f0f1a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFe63946).withValues(alpha: 0.2),
          width: 1,
        ),
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
          title: Text(
            faq.question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
