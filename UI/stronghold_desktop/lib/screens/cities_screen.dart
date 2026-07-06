import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cities_provider.dart';
import '../utils/api_client.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

/// CRUD ekran za gradove (referentna tabela) - template za ostale CRUD ekrane.
class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CitiesProvider>().load(page: 1, searchName: ''),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString()), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm({int? id, String? currentName}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: currentName ?? '');
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(id == null ? 'Novi grad' : 'Izmjena grada')),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: 360,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Naziv grada',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Unesite naziv grada.'
                        : null,
                  ),
                  if (serverError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      serverError!,
                      style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Odustani'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  final provider = context.read<CitiesProvider>();
                  if (id == null) {
                    await provider.insert(nameController.text.trim());
                  } else {
                    await provider.update(id, nameController.text.trim());
                  }
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess(id == null
                      ? 'Grad "${nameController.text.trim()}" je dodan.'
                      : 'Grad je izmijenjen.');
                } on ApiException catch (e) {
                  setDialogState(() => serverError = e.message);
                }
              },
              child: const Text('Sačuvaj'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(int id, String name) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje grada',
      message: 'Obrisati grad "$name"? Ova akcija je nepovratna.',
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<CitiesProvider>().delete(id);
      _showSuccess('Grad "$name" je obrisan.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CitiesProvider>();

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
                onSubmitted: (value) => provider.load(page: 1, searchName: value.trim()),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Novi grad'),
              onPressed: () => _openForm(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.cities.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema gradova za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Naziv')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final city in provider.cities)
                                DataRow(cells: [
                                  DataCell(Text(city.name)),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Izmijeni',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () =>
                                          _openForm(id: city.id, currentName: city.name),
                                    ),
                                    IconButton(
                                      tooltip: 'Obriši',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(city.id, city.name),
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
