import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supplement_category.dart';
import '../providers/categories_provider.dart';
import '../utils/api_client.dart';

/// Forma za kreiranje/izmjenu kategorije - koristi je tab Kategorije
/// i brzo dodavanje sa forme suplementa.
/// Vraca sacuvanu kategoriju ili null ako je korisnik odustao.
Future<SupplementCategory?> showCategoryFormDialog(
  BuildContext context, {
  SupplementCategory? existing,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name ?? '');
  final descriptionController =
      TextEditingController(text: existing?.description ?? '');
  String? serverError;

  return showDialog<SupplementCategory>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                  existing == null ? 'Nova kategorija' : 'Izmjena kategorije'),
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
                    labelText: 'Naziv kategorije',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Unesite naziv kategorije.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Opis',
                  ),
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Unesite opis kategorije.'
                      : null,
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
                'description': descriptionController.text.trim(),
              };
              try {
                final provider = context.read<CategoriesProvider>();
                final saved = existing == null
                    ? await provider.insert(body)
                    : await provider.update(existing.id, body);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(saved);
                }
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
