import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/membership_package.dart';
import '../providers/packages_provider.dart';
import '../utils/api_client.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PackagesProvider>().load(page: 1, searchName: ''),
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

  Future<void> _openForm({MembershipPackage? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController =
        TextEditingController(text: existing?.price.toStringAsFixed(2) ?? '');
    final durationController =
        TextEditingController(text: existing?.durationDays.toString() ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(existing == null ? 'Novi paket' : 'Izmjena paketa'),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
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
                      labelText: 'Naziv paketa',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Unesite naziv paketa.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Cijena (KM)',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final price = double.tryParse((value ?? '').replaceAll(',', '.'));
                            if (price == null || price <= 0) {
                              return 'Unesite validnu cijenu, npr. 40.00';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: durationController,
                          decoration: const InputDecoration(
                            labelText: 'Trajanje (dana)',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final days = int.tryParse(value ?? '');
                            if (days == null || days < 1) {
                              return 'Unesite broj dana, npr. 30';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Opis',
                    ),
                    maxLines: 3,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Unesite opis paketa.'
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
                final body = {
                  'name': nameController.text.trim(),
                  'price': double.parse(priceController.text.replaceAll(',', '.')),
                  'durationDays': int.parse(durationController.text),
                  'description': descriptionController.text.trim(),
                };
                try {
                  final provider = context.read<PackagesProvider>();
                  if (existing == null) {
                    await provider.insert(body);
                  } else {
                    await provider.update(existing.id, body);
                  }
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess(existing == null
                      ? 'Paket "${body['name']}" je dodan.'
                      : 'Paket je izmijenjen.');
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

  Future<void> _delete(MembershipPackage package) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje paketa',
      message: 'Obrisati paket "${package.name}"? Ova akcija je nepovratna.',
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<PackagesProvider>().delete(package.id);
      _showSuccess('Paket "${package.name}" je obrisan.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackagesProvider>();

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
              label: const Text('Novi paket'),
              onPressed: () => _openForm(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.packages.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema paketa za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Naziv')),
                              DataColumn(label: Text('Cijena')),
                              DataColumn(label: Text('Trajanje')),
                              DataColumn(label: Text('Opis')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final package in provider.packages)
                                DataRow(cells: [
                                  DataCell(Text(package.name)),
                                  DataCell(Text('${package.price.toStringAsFixed(2)} KM')),
                                  DataCell(Text('${package.durationDays} dana')),
                                  DataCell(
                                    SizedBox(
                                      width: 320,
                                      child: Text(
                                        package.description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Izmijeni',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _openForm(existing: package),
                                    ),
                                    IconButton(
                                      tooltip: 'Obriši',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(package),
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
