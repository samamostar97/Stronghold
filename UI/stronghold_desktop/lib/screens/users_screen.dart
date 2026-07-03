import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/user.dart';
import '../providers/cities_provider.dart';
import '../providers/users_provider.dart';
import '../utils/api_client.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<UsersProvider>().load(page: 1, searchText: ''),
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

  Widget _avatar(User user, {double radius = 18}) {
    final provider = context.read<UsersProvider>();
    if (!user.hasImage) {
      return CircleAvatar(radius: radius, child: Text(user.firstName[0]));
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(
        provider.imageUri(user.id).toString(),
        headers: provider.imageHeaders(),
      ),
    );
  }

  void _showDetails(User user) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text('Detalji korisnika')),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _avatar(user, radius: 40),
              const SizedBox(height: 16),
              _detailRow('Ime i prezime', user.fullName),
              _detailRow('Korisničko ime', user.username),
              _detailRow('E-mail', user.email),
              _detailRow('Telefon', user.phone),
              _detailRow('Rola', user.role == 'Admin' ? 'Administrator' : 'Član'),
              _detailRow('Adresa', user.streetAddress ?? '-'),
              _detailRow('Grad', user.cityName ?? '-'),
              _detailRow('Registrovan',
                  '${user.createdAt.day}.${user.createdAt.month}.${user.createdAt.year}.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _openForm({User? existing}) async {
    final cities = await context.read<CitiesProvider>().loadAll();
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: existing?.firstName ?? '');
    final lastNameController = TextEditingController(text: existing?.lastName ?? '');
    final usernameController = TextEditingController(text: existing?.username ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final passwordController = TextEditingController();
    final streetController = TextEditingController(text: existing?.streetAddress ?? '');
    int? selectedCityId = existing?.cityId;
    bool changePassword = false;
    String? imageBase64;
    String? imageFileName;
    String? serverError;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final phoneRegex = RegExp(r'^[0-9+\-\/\s]{6,30}$');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(existing == null ? 'Novi korisnik' : 'Izmjena korisnika'),
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
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Unesite ime.'
                              : null,
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
                    if (existing == null) ...[
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Korisničko ime',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Unesite korisničko ime.';
                          }
                          if (v.trim().length < 3) {
                            return 'Korisničko ime mora imati najmanje 3 znaka.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
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
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Unesite broj telefona.';
                            }
                            if (!phoneRegex.hasMatch(v.trim())) {
                              return 'Unesite validan broj telefona u formatu: 061-123-456';
                            }
                            return null;
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: streetController,
                          decoration: const InputDecoration(
                            labelText: 'Ulica i broj (opcionalno)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedCityId,
                          decoration: const InputDecoration(
                            labelText: 'Grad (opcionalno)',
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('Bez grada'),
                            ),
                            for (final City city in cities)
                              DropdownMenuItem(value: city.id, child: Text(city.name)),
                          ],
                          onChanged: (value) =>
                              setDialogState(() => selectedCityId = value),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    if (existing == null)
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Lozinka',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Unesite lozinku.';
                          if (v.length < 4) {
                            return 'Lozinka mora imati najmanje 4 znaka.';
                          }
                          return null;
                        },
                      )
                    else ...[
                      // izmjena NE zahtijeva lozinku - polje se otvara checkboxom
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Izmijeni lozinku'),
                        value: changePassword,
                        onChanged: (value) => setDialogState(() {
                          changePassword = value ?? false;
                          if (!changePassword) passwordController.clear();
                        }),
                      ),
                      if (changePassword)
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Nova lozinka',
                          ),
                          validator: (v) {
                            if (!changePassword) return null;
                            if (v == null || v.isEmpty) {
                              return 'Unesite novu lozinku.';
                            }
                            if (v.length < 4) {
                              return 'Lozinka mora imati najmanje 4 znaka.';
                            }
                            return null;
                          },
                        ),
                    ],
                    const SizedBox(height: 16),
                    Row(children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.image_outlined),
                        label: Text(imageFileName ?? 'Odaberi sliku (PNG/JPEG)'),
                        onPressed: () async {
                          const typeGroup = XTypeGroup(
                            label: 'Slike',
                            extensions: ['png', 'jpg', 'jpeg'],
                          );
                          final file =
                              await openFile(acceptedTypeGroups: [typeGroup]);
                          if (file == null) return;
                          final bytes = await file.readAsBytes();
                          setDialogState(() {
                            imageBase64 = base64Encode(bytes);
                            imageFileName = file.name;
                          });
                        },
                      ),
                    ]),
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
                try {
                  final provider = context.read<UsersProvider>();
                  if (existing == null) {
                    await provider.insert({
                      'firstName': firstNameController.text.trim(),
                      'lastName': lastNameController.text.trim(),
                      'username': usernameController.text.trim(),
                      'email': emailController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'password': passwordController.text,
                      'role': 1,
                      'streetAddress': streetController.text.trim().isEmpty
                          ? null
                          : streetController.text.trim(),
                      'cityId': selectedCityId,
                      'imageBase64': imageBase64,
                    });
                  } else {
                    await provider.update(existing.id, {
                      'firstName': firstNameController.text.trim(),
                      'lastName': lastNameController.text.trim(),
                      'email': emailController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'newPassword':
                          changePassword ? passwordController.text : null,
                      'streetAddress': streetController.text.trim().isEmpty
                          ? null
                          : streetController.text.trim(),
                      'cityId': selectedCityId,
                      'imageBase64': imageBase64,
                    });
                  }
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess(existing == null
                      ? 'Korisnik "${firstNameController.text.trim()}" je dodan.'
                      : 'Podaci korisnika su izmijenjeni.');
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

  Future<void> _delete(User user) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje korisnika',
      message: 'Obrisati korisnika "${user.fullName}"? Ova akcija je nepovratna.',
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<UsersProvider>().delete(user.id);
      _showSuccess('Korisnik "${user.fullName}" je obrisan.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsersProvider>();

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
                  labelText: 'Pretraga (ime, prezime, korisničko ime)',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onSubmitted: (value) =>
                    provider.load(page: 1, searchText: value.trim()),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Novi korisnik'),
              onPressed: () => _openForm(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.users.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema korisnika za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Slika')),
                              DataColumn(label: Text('Ime')),
                              DataColumn(label: Text('Prezime')),
                              DataColumn(label: Text('Korisničko ime')),
                              DataColumn(label: Text('E-mail')),
                              DataColumn(label: Text('Telefon')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final user in provider.users)
                                DataRow(cells: [
                                  DataCell(_avatar(user)),
                                  DataCell(Text(user.firstName)),
                                  DataCell(Text(user.lastName)),
                                  DataCell(Text(user.username)),
                                  DataCell(Text(user.email)),
                                  DataCell(Text(user.phone)),
                                  DataCell(Row(children: [
                                    IconButton(
                                      tooltip: 'Detalji',
                                      icon: const Icon(Icons.visibility_outlined),
                                      onPressed: () => _showDetails(user),
                                    ),
                                    IconButton(
                                      tooltip: 'Izmijeni',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _openForm(existing: user),
                                    ),
                                    IconButton(
                                      tooltip: 'Obriši',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(user),
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
