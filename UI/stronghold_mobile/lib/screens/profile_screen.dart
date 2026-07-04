import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../providers/profile_provider.dart';
import '../utils/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Moj profil')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    child: Text(
                      profile.firstName[0],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(profile.fullName,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Center(child: Text('@${profile.username}')),
                const SizedBox(height: 24),
                _infoTile(Icons.email_outlined, 'E-mail', profile.email),
                _infoTile(Icons.phone_outlined, 'Telefon', profile.phone),
                _infoTile(Icons.home_outlined, 'Adresa',
                    profile.streetAddress ?? 'Nije unesena'),
                _infoTile(Icons.location_city_outlined, 'Grad',
                    profile.cityName ?? 'Nije odabran'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Izmijeni podatke'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Promijeni lozinku'),
                  onPressed: () => _openChangePassword(context),
                ),
              ],
            ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _openChangePassword(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Promjena lozinke')),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Trenutna lozinka',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Unesite trenutnu lozinku.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nova lozinka',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Unesite novu lozinku.';
                    if (v.length < 4) {
                      return 'Lozinka mora imati najmanje 4 znaka.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Potvrdite novu lozinku',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v != newController.text ? 'Lozinke se ne podudaraju.' : null,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Odustani'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await context.read<ProfileProvider>().changePassword(
                        oldPassword: oldController.text,
                        newPassword: newController.text,
                      );
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _showSuccess('Lozinka je uspješno promijenjena.');
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
}

/// Izmjena licnih podataka - grad je dropdown iz baze, slika preko image pickera.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  int? _selectedCityId;
  List<City> _cities = [];
  String? _imageBase64;
  String? _serverError;
  bool _saving = false;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneRegex = RegExp(r'^[0-9+\-\/\s]{6,30}$');

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile!;
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _streetController = TextEditingController(text: profile.streetAddress ?? '');
    _selectedCityId = profile.cityId;
    _loadCities();
  }

  Future<void> _loadCities() async {
    final cities = await context.read<ProfileProvider>().loadCities();
    if (mounted) setState(() => _cities = cities);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _imageBase64 = base64Encode(bytes));
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await context.read<ProfileProvider>().update(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            streetAddress: _streetController.text.trim().isEmpty
                ? null
                : _streetController.text.trim(),
            cityId: _selectedCityId,
            imageBase64: _imageBase64,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Podaci profila su izmijenjeni.')),
        );
      }
    } on ApiException catch (e) {
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izmjena podataka')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ime',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Unesite ime.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prezime',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Unesite prezime.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Unesite e-mail adresu.';
                    }
                    if (!_emailRegex.hasMatch(v.trim())) {
                      return 'Unesite validan e-mail u formatu: ime@domena.com';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Unesite broj telefona.';
                    }
                    if (!_phoneRegex.hasMatch(v.trim())) {
                      return 'Unesite validan broj telefona u formatu: 061-123-456';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Ulica i broj',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _selectedCityId,
                  decoration: const InputDecoration(
                    labelText: 'Grad',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int>(value: null, child: Text('Bez grada')),
                    for (final city in _cities)
                      DropdownMenuItem(value: city.id, child: Text(city.name)),
                  ],
                  onChanged: (value) => setState(() => _selectedCityId = value),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.image_outlined),
                  label: Text(_imageBase64 == null
                      ? 'Promijeni profilnu sliku'
                      : 'Nova slika odabrana'),
                  onPressed: _pickImage,
                ),
                if (_serverError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _serverError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sačuvaj'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
