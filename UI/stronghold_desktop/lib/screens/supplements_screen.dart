import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supplement.dart';
import '../models/supplement_category.dart';
import '../models/supplier.dart';
import '../providers/categories_provider.dart';
import '../providers/suppliers_provider.dart';
import '../providers/supplements_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SupplementsProvider>().load(page: 1, searchText: ''),
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

  Future<void> _openForm({Supplement? existing}) async {
    final categories = await context.read<CategoriesProvider>().loadAll();
    if (!mounted) return;
    final suppliers = await context.read<SuppliersProvider>().loadAll();
    if (!mounted) return;

    // forma se ne otvara ako preduslovi (FK tabele) nisu ispunjeni
    if (categories.isEmpty || suppliers.isEmpty) {
      _showError('Prvo dodajte barem jednu kategoriju i jednog dobavljača.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController =
        TextEditingController(text: existing?.price.toStringAsFixed(2) ?? '');
    final stockController =
        TextEditingController(text: existing?.stockQuantity.toString() ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    int? categoryId = existing?.categoryId;
    int? supplierId = existing?.supplierId;
    String? imageBase64;
    String? imageFileName;
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                    existing == null ? 'Novi suplement' : 'Izmjena suplementa'),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Naziv',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Unesite naziv suplementa.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Cijena (KM)',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final price =
                                double.tryParse((v ?? '').replaceAll(',', '.'));
                            if (price == null || price <= 0) {
                              return 'Unesite validnu cijenu, npr. 89.90';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stanje zaliha (kom)',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final stock = int.tryParse(v ?? '');
                            if (stock == null || stock < 0) {
                              return 'Unesite broj komada, npr. 25';
                            }
                            return null;
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: categoryId,
                          decoration: const InputDecoration(
                            labelText: 'Kategorija',
                          ),
                          items: [
                            for (final SupplementCategory category in categories)
                              DropdownMenuItem(
                                  value: category.id, child: Text(category.name)),
                          ],
                          validator: (value) =>
                              value == null ? 'Odaberite kategoriju.' : null,
                          onChanged: (value) =>
                              setDialogState(() => categoryId = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: supplierId,
                          decoration: const InputDecoration(
                            labelText: 'Dobavljač',
                          ),
                          items: [
                            for (final Supplier supplier in suppliers)
                              DropdownMenuItem(
                                  value: supplier.id, child: Text(supplier.name)),
                          ],
                          validator: (value) =>
                              value == null ? 'Odaberite dobavljača.' : null,
                          onChanged: (value) =>
                              setDialogState(() => supplierId = value),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Opis',
                      ),
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Unesite opis suplementa.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image_outlined),
                      label: Text(imageFileName ?? 'Odaberi sliku (PNG/JPEG)'),
                      onPressed: () async {
                        const typeGroup = XTypeGroup(
                          label: 'Slike',
                          extensions: ['png', 'jpg', 'jpeg'],
                        );
                        final file = await openFile(acceptedTypeGroups: [typeGroup]);
                        if (file == null) return;
                        final bytes = await file.readAsBytes();
                        setDialogState(() {
                          imageBase64 = base64Encode(bytes);
                          imageFileName = file.name;
                        });
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
                  'price':
                      double.parse(priceController.text.replaceAll(',', '.')),
                  'description': descriptionController.text.trim(),
                  'categoryId': categoryId,
                  'supplierId': supplierId,
                  'stockQuantity': int.parse(stockController.text),
                  'imageBase64': imageBase64,
                };
                try {
                  final provider = context.read<SupplementsProvider>();
                  if (existing == null) {
                    await provider.insert(body);
                  } else {
                    await provider.update(existing.id, body);
                  }
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess(existing == null
                      ? 'Suplement "${body['name']}" je dodan.'
                      : 'Suplement je izmijenjen.');
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

  Future<void> _delete(Supplement supplement) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje suplementa',
      message: 'Obrisati "${supplement.name}"? Ova akcija je nepovratna.',
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<SupplementsProvider>().delete(supplement.id);
      _showSuccess('"${supplement.name}" je obrisan.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplementsProvider>();

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
                    provider.load(page: 1, searchText: value.trim()),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Novi suplement'),
              onPressed: () => _openForm(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.supplements.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema suplemenata za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Slika')),
                              DataColumn(label: Text('Naziv')),
                              DataColumn(label: Text('Cijena')),
                              DataColumn(label: Text('Kategorija')),
                              DataColumn(label: Text('Dobavljač')),
                              DataColumn(label: Text('Zalihe')),
                              DataColumn(label: Text('Ocjena')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final supplement in provider.supplements)
                                DataRow(cells: [
                                  DataCell(
                                    supplement.hasImage
                                        ? Image.network(
                                            provider
                                                .imageUri(supplement.id)
                                                .toString(),
                                            headers: provider.imageHeaders(),
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.image_not_supported),
                                  ),
                                  DataCell(SizedBox(
                                    width: 220,
                                    child: Text(supplement.name,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                                  DataCell(
                                      Text(Formatters.money(supplement.price))),
                                  DataCell(Text(supplement.categoryName)),
                                  DataCell(Text(supplement.supplierName)),
                                  DataCell(Text('${supplement.stockQuantity}')),
                                  DataCell(Text(supplement.reviewCount > 0
                                      ? '${supplement.averageRating.toStringAsFixed(1)} (${supplement.reviewCount})'
                                      : '-')),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Izmijeni',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () =>
                                          _openForm(existing: supplement),
                                    ),
                                    IconButton(
                                      tooltip: 'Obriši',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(supplement),
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
