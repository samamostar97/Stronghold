import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supplier.dart';
import '../providers/suppliers_provider.dart';
import '../utils/api_client.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pagination_bar.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _searchController = TextEditingController();

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneRegex = RegExp(r'^[0-9+\-\/\s]{6,30}$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SuppliersProvider>().load(page: 1, searchName: ''),
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

  Future<void> _openForm({Supplier? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final emailController =
        TextEditingController(text: existing?.contactEmail ?? '');
    final phoneController =
        TextEditingController(text: existing?.contactPhone ?? '');
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                    existing == null ? 'Novi dobavljač' : 'Izmjena dobavljača'),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: 420,
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
                      labelText: 'Naziv dobavljača',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Unesite naziv dobavljača.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Kontakt e-mail',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Unesite kontakt e-mail.';
                      }
                      if (!_emailRegex.hasMatch(v.trim())) {
                        return 'Unesite validan e-mail u formatu: ime@domena.com';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Kontakt telefon',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Unesite kontakt telefon.';
                      }
                      if (!_phoneRegex.hasMatch(v.trim())) {
                        return 'Unesite validan broj telefona u formatu: +387-33-123-456';
                      }
                      return null;
                    },
                  ),
                  if (serverError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      serverError!,
                      style: TextStyle(
                          color: Theme.of(dialogContext).colorScheme.error),
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
                final body = {
                  'name': nameController.text.trim(),
                  'contactEmail': emailController.text.trim(),
                  'contactPhone': phoneController.text.trim(),
                };
                try {
                  final provider = context.read<SuppliersProvider>();
                  if (existing == null) {
                    await provider.insert(body);
                  } else {
                    await provider.update(existing.id, body);
                  }
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess(existing == null
                      ? 'Dobavljač "${body['name']}" je dodan.'
                      : 'Dobavljač je izmijenjen.');
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

  Future<void> _delete(Supplier supplier) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje dobavljača',
      message: 'Obrisati dobavljača "${supplier.name}"? Ova akcija je nepovratna.',
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<SuppliersProvider>().delete(supplier.id);
      _showSuccess('Dobavljač "${supplier.name}" je obrisan.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SuppliersProvider>();

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
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (value) =>
                    provider.load(page: 1, searchName: value.trim()),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Novi dobavljač'),
              onPressed: () => _openForm(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.suppliers.isEmpty
                  ? const Center(child: Text('Nema dobavljača za prikaz.'))
                  : Card(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Naziv')),
                              DataColumn(label: Text('E-mail')),
                              DataColumn(label: Text('Telefon')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final supplier in provider.suppliers)
                                DataRow(cells: [
                                  DataCell(Text(supplier.name)),
                                  DataCell(Text(supplier.contactEmail)),
                                  DataCell(Text(supplier.contactPhone)),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Izmijeni',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () =>
                                          _openForm(existing: supplier),
                                    ),
                                    IconButton(
                                      tooltip: 'Obriši',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(supplier),
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
