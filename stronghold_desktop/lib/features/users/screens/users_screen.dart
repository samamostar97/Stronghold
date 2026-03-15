import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../data/users_repository.dart';
import '../models/user_response.dart';
import '../providers/users_provider.dart';
import '../widgets/users_table.dart';
import '../widgets/user_form_modal.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(usersFilterProvider.notifier).update(UsersFilter(
        search: value.isEmpty ? null : value,
      ));
    });
  }

  void _openCreateModal() {
    showDialog(
      context: context,
      builder: (_) => const UserFormModal(),
    );
  }

  void _openEditModal(UserResponse user) {
    showDialog(
      context: context,
      builder: (_) => UserFormModal(user: user),
    );
  }

  void _confirmDelete(UserResponse user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.sidebar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Obrisi korisnika', style: AppTextStyles.h3),
        content: Text(
          'Da li ste sigurni da zelite obrisati ${user.firstName} ${user.lastName}?',
          style: AppTextStyles.body.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Otkazi',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final repo = ref.read(usersRepositoryProvider);
                await repo.deleteUser(user.id);
                ref.invalidate(usersListProvider);
                if (mounted) {
                  AppSnackbar.success(context, '${user.firstName} ${user.lastName} je obrisan/a.');
                }
              } catch (e) {
                if (mounted) {
                  AppSnackbar.error(context, 'Greska: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Obrisi', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider);
    final filter = ref.watch(usersFilterProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Korisnici', style: AppTextStyles.h2)),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: _openCreateModal,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Dodaj korisnika',
                      style: AppTextStyles.button.copyWith(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 280,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Pretrazi korisnike...',
                    hintStyle:
                        AppTextStyles.bodySmall.copyWith(fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary, size: 18),
                    filled: true,
                    fillColor: AppColors.sidebar,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color:
                              AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          usersAsync.when(
            loading: () => Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
            error: (e, _) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Greska pri ucitavanju korisnika',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(usersListProvider),
                      child: Text('Pokusaj ponovo',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),
            data: (data) => UsersTable(
              users: data.items,
              currentPage: data.currentPage,
              totalPages: data.totalPages,
              onPageChanged: (page) {
                ref.read(usersFilterProvider.notifier).update(
                    filter.copyWith(pageNumber: page));
              },
              onEdit: _openEditModal,
              onDelete: _confirmDelete,
            ),
          ),
        ],
      ),
    );
  }
}
