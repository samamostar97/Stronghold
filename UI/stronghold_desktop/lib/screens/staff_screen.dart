import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/staff_member.dart';
import '../providers/staff_provider.dart';
import '../utils/api_client.dart';
import '../utils/validators.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

/// Jedan ekran za trenere (staffType=0) i nutricioniste (staffType=1) -
/// UI ih prikazuje kao dva odvojena navigaciona itema.
class StaffScreen extends StatefulWidget {
  final int staffType;
  final String singularLabel;

  const StaffScreen({
    super.key,
    required this.staffType,
    required this.singularLabel,
  });

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context
          .read<StaffProvider>()
          .load(widget.staffType, page: 1, searchText: ''),
    );
  }

  @override
  void didUpdateWidget(covariant StaffScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.staffType != widget.staffType) {
      _searchController.clear();
      context.read<StaffProvider>().load(widget.staffType, page: 1, searchText: '');
    }
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

  Future<void> _openForm({StaffMember? existing}) async {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: existing?.firstName ?? '');
    final lastNameController = TextEditingController(text: existing?.lastName ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final biographyController = TextEditingController(text: existing?.biography ?? '');
    int workStart = existing?.workStartHour ?? 8;
    int workEnd = existing?.workEndHour ?? 16;
    String? imageBase64;
    String? imageFileName;
    String? serverError;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(existing == null
                    ? 'Novi ${widget.singularLabel}'
                    : 'Izmjena - ${existing.fullName}'),
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
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: firstNameController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Ime',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Unesite ime.' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Prezime',
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Unesite prezime.'
                              : null,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Unesite e-mail adresu.';
                            }
                            if (!emailRegex.hasMatch(v.trim())) {
                              return 'Unesite validan e-mail u formatu: ime@domena.com';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Telefon',
                            hintText: '061-123-456',
                          ),
                          inputFormatters: [PhoneInputFormatter()],
                          validator: Validators.phone,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // radno vrijeme - osnova za slobodne satnice termina
                    Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: workStart,
                          decoration: const InputDecoration(
                            labelText: 'Početak radnog vremena',
                          ),
                          items: [
                            for (var hour = 6; hour <= 20; hour++)
                              DropdownMenuItem(value: hour, child: Text('$hour:00')),
                          ],
                          onChanged: (value) =>
                              setDialogState(() => workStart = value ?? 8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: workEnd,
                          decoration: const InputDecoration(
                            labelText: 'Kraj radnog vremena',
                          ),
                          items: [
                            for (var hour = 7; hour <= 23; hour++)
                              DropdownMenuItem(value: hour, child: Text('$hour:00')),
                          ],
                          validator: (value) => (value ?? 0) <= workStart
                              ? 'Kraj mora biti nakon početka.'
                              : null,
                          onChanged: (value) =>
                              setDialogState(() => workEnd = value ?? 16),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: biographyController,
                      decoration: const InputDecoration(
                        labelText: 'Biografija',
                      ),
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Unesite biografiju.'
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
                  'firstName': firstNameController.text.trim(),
                  'lastName': lastNameController.text.trim(),
                  'staffType': widget.staffType,
                  'biography': biographyController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'workStartHour': workStart,
                  'workEndHour': workEnd,
                  'imageBase64': imageBase64,
                };
                try {
                  final provider = context.read<StaffProvider>();
                  if (existing == null) {
                    await provider.insert(widget.staffType, body);
                  } else {
                    await provider.update(widget.staffType, existing.id, body);
                  }
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess(existing == null
                      ? '${widget.singularLabel} je dodan.'
                      : 'Podaci su izmijenjeni.');
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

  Future<void> _delete(StaffMember staff) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje',
      message: 'Obrisati "${staff.fullName}"? Ova akcija je nepovratna.',
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<StaffProvider>().delete(widget.staffType, staff.id);
      _showSuccess('"${staff.fullName}" je obrisan.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();

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
                  labelText: 'Pretraga (ime, prezime)',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onSubmitted: (value) => provider.load(widget.staffType,
                    page: 1, searchText: value.trim()),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.person_add_outlined),
              label: Text('Novi ${widget.singularLabel}'),
              onPressed: () => _openForm(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.staff.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema zapisa za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Slika')),
                              DataColumn(label: Text('Ime i prezime')),
                              DataColumn(label: Text('E-mail')),
                              DataColumn(label: Text('Telefon')),
                              DataColumn(label: Text('Radno vrijeme')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final staff in provider.staff)
                                DataRow(cells: [
                                  DataCell(
                                    staff.hasImage
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              provider
                                                  .imageUri(staff.id)
                                                  .toString(),
                                              headers: provider.imageHeaders(),
                                            ),
                                          )
                                        : CircleAvatar(
                                            child: Text(staff.firstName[0])),
                                  ),
                                  DataCell(Text(staff.fullName)),
                                  DataCell(Text(staff.email)),
                                  DataCell(Text(staff.phone)),
                                  DataCell(Text(
                                      '${staff.workStartHour}:00 - ${staff.workEndHour}:00')),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Izmijeni',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _openForm(existing: staff),
                                    ),
                                    IconButton(
                                      tooltip: 'Obriši',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(staff),
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
          onPageChanged: (page) => provider.load(widget.staffType, page: page),
        ),
      ],
    );
  }
}
