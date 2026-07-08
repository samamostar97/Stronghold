import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supplement_category.dart';
import '../providers/categories_provider.dart';
import '../utils/api_client.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CategoriesProvider>().load(page: 1, searchName: ''),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _openForm({SupplementCategory? existing}) async {
    final saved = await showCategoryFormDialog(context, existing: existing);
    if (saved == null || !mounted) return;
    _showSuccess(existing == null
        ? 'Kategorija "${saved.name}" je dodana.'
        : 'Kategorija je izmijenjena.');
  }

  Future<void> _delete(SupplementCategory category) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje kategorije',
      message: 'Obrisati kategoriju "${category.name}"? Ova akcija je nepovratna.',
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<CategoriesProvider>().delete(category.id);
      _showSuccess('Kategorija "${category.name}" je obrisana.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Pretraga po nazivu',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onSubmitted: (value) =>
                    provider.load(page: 1, searchName: value.trim()),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Nova kategorija'),
              onPressed: () => _openForm(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.categories.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema kategorija za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Naziv')),
                              DataColumn(label: Text('Opis')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final category in provider.categories)
                                DataRow(cells: [
                                  DataCell(Text(category.name)),
                                  DataCell(SizedBox(
                                    width: 420,
                                    child: Text(category.description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2),
                                  )),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Izmijeni',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () =>
                                          _openForm(existing: category),
                                    ),
                                    IconButton(
                                      tooltip: 'Obriši',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(category),
                                    ),
                                  ])),
                                ]),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
        const SizedBox(height: 8),
        PaginationBar(
          page: provider.page,
          pageSize: provider.pageSize,
          totalCount: provider.totalCount,
          onPageChanged: (page) => provider.load(page: page),
        ),
      ],
    );
  }
}
