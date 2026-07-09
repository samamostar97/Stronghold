import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/supplier.dart';
import '../providers/suppliers_provider.dart';
import '../utils/api_client.dart';

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _phoneRegex = RegExp(r'^[0-9+\-\/\s]{6,30}$');

/// Forma za kreiranje/izmjenu dobavljaca - koristi je tab Dobavljaci
/// i brzo dodavanje sa forme suplementa.
/// Vraca sacuvanog dobavljaca ili null ako je korisnik odustao.
Future<Supplier?> showSupplierFormDialog(
  BuildContext context, {
  Supplier? existing,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name ?? '');
  final emailController =
      TextEditingController(text: existing?.contactEmail ?? '');
  final phoneController =
      TextEditingController(text: existing?.contactPhone ?? '');
  String? serverError;

  return showDialog<Supplier>(
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
