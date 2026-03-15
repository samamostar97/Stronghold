import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../data/membership_packages_repository.dart';
import '../data/memberships_repository.dart';
import '../models/membership_package_response.dart';
import '../providers/memberships_provider.dart';
import '../../users/data/users_repository.dart';

class AssignMembershipModal extends ConsumerStatefulWidget {
  const AssignMembershipModal({super.key});

  @override
  ConsumerState<AssignMembershipModal> createState() =>
      _AssignMembershipModalState();
}

class _AssignMembershipModalState
    extends ConsumerState<AssignMembershipModal> {
  // User search
  final _userSearchController = TextEditingController();
  Timer? _userDebounce;
  List<Map<String, dynamic>> _userResults = [];
  bool _userSearching = false;
  Map<String, dynamic>? _selectedUser;

  // Package selection
  List<MembershipPackageResponse> _packages = [];
  bool _loadingPackages = true;
  MembershipPackageResponse? _selectedPackage;

  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    _userDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    try {
      final repo = ref.read(membershipPackagesRepositoryProvider);
      final result = await repo.getPackages(pageSize: 100);
      if (mounted) {
        setState(() {
          _packages = result.items;
          _loadingPackages = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPackages = false);
    }
  }

  void _onUserSearch(String value) {
    _userDebounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _userResults = []);
      return;
    }
    _userDebounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _userSearching = true);
      try {
        final repo = ref.read(usersRepositoryProvider);
        final results = await repo.searchUsers(value.trim());
        if (mounted) setState(() => _userResults = results);
      } catch (_) {}
      if (mounted) setState(() => _userSearching = false);
    });
  }

  Future<void> _submit() async {
    if (_selectedUser == null || _selectedPackage == null) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(membershipsRepositoryProvider);
      await repo.assignMembership(
        userId: _selectedUser!['id'] as int,
        membershipPackageId: _selectedPackage!.id,
      );
      ref.invalidate(activeMembershipsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, 'Clanarina uspjesno dodijeljena.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.sidebar,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                        child: Text('Dodaj clanarinu',
                            style: AppTextStyles.h2)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                    color: Colors.white.withValues(alpha: 0.06), height: 1),
                const SizedBox(height: 20),

                // User search
                Text('Korisnik',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                const SizedBox(height: 6),
                if (_selectedUser != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_selectedUser!['firstName']} ${_selectedUser!['lastName']}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontSize: 13),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _selectedUser = null;
                            _userSearchController.clear();
                          }),
                          child: const Icon(Icons.close,
                              color: AppColors.textSecondary, size: 16),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      TextField(
                        controller: _userSearchController,
                        onChanged: _onUserSearch,
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Pretrazi korisnike...',
                          hintStyle: AppTextStyles.bodySmall
                              .copyWith(fontSize: 13),
                          prefixIcon: _userSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  ),
                                )
                              : const Icon(Icons.search,
                                  color: AppColors.textSecondary, size: 18),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color:
                                    Colors.white.withValues(alpha: 0.06)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color:
                                    Colors.white.withValues(alpha: 0.06)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.primary
                                    .withValues(alpha: 0.4)),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      if (_userResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _userResults.length,
                            itemBuilder: (_, i) {
                              final user = _userResults[i];
                              return InkWell(
                                onTap: () => setState(() {
                                  _selectedUser = user;
                                  _userResults = [];
                                  _userSearchController.clear();
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Text(
                                    '${user['firstName']} ${user['lastName']} (${user['email']})',
                                    style: AppTextStyles.body
                                        .copyWith(fontSize: 13),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Package dropdown
                Text('Paket clanarine',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                const SizedBox(height: 6),
                if (_loadingPackages)
                  const SizedBox(
                    height: 44,
                    child: Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary)),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedPackage?.id,
                        hint: Text('Odaberi paket',
                            style: AppTextStyles.bodySmall
                                .copyWith(fontSize: 13)),
                        isExpanded: true,
                        dropdownColor: AppColors.background,
                        items: _packages.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              '${p.name} (${p.price.toStringAsFixed(2)} KM)',
                              style: AppTextStyles.body
                                  .copyWith(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          setState(() {
                            _selectedPackage =
                                _packages.firstWhere((p) => p.id == id);
                          });
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Info
                if (_selectedPackage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Text('Detalji clanarine',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pocetak: ${_formatDate(DateTime.now())}',
                          style:
                              AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Istek: ${_formatDate(DateTime.now().add(const Duration(days: 30)))}',
                          style:
                              AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trajanje: 30 dana',
                          style:
                              AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: (_submitting ||
                            _selectedUser == null ||
                            _selectedPackage == null)
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Dodijeli clanarinu',
                            style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';
  }
}
