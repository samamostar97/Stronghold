import 'package:flutter/material.dart';

import 'categories_screen.dart';
import 'suppliers_screen.dart';
import 'supplements_screen.dart';

/// Objedinjeni ekran prodavnice - suplementi sa pratecim sifarnicima
/// (kategorije i dobavljaci) u tabovima umjesto zasebnih stavki u navigaciji.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Suplementi'),
            Tab(text: 'Kategorije'),
            Tab(text: 'Dobavljači'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              SupplementsScreen(),
              CategoriesScreen(),
              SuppliersScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
