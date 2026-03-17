import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../providers/seminars_provider.dart';
import '../widgets/seminar_form_modal.dart';
import '../widgets/seminars_table.dart';

class SeminarsScreen extends ConsumerStatefulWidget {
  const SeminarsScreen({super.key});

  @override
  ConsumerState<SeminarsScreen> createState() => _SeminarsScreenState();
}

class _SeminarsScreenState extends ConsumerState<SeminarsScreen> {
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
      ref.read(seminarsFilterProvider.notifier).update(SeminarsFilter(
        search: value.isEmpty ? null : value,
      ));
    });
  }

  Future<void> _deleteSeminar(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.sidebar,
        title: Text('Brisanje seminara', style: AppTextStyles.h3),
        content: Text('Obrisati "$name"?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Odustani', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Obrisi',
                style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final repo = ref.read(seminarsRepositoryProvider);
      await repo.deleteSeminar(id);
      ref.invalidate(seminarsProvider);
      if (mounted) AppSnackbar.success(context, '"$name" je obrisan.');
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Greska: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final seminarsAsync = ref.watch(seminarsProvider);
    final filter = ref.watch(seminarsFilterProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Seminari', style: AppTextStyles.h2)),
              SizedBox(
                width: 280,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Pretrazi seminare...',
                    hintStyle: AppTextStyles.bodySmall.copyWith(fontSize: 13),
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
                          color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const SeminarFormModal(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Dodaj seminar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: AppTextStyles.button.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          seminarsAsync.when(
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
                        strokeWidth: 2, color: AppColors.primary)),
              ),
            ),
            error: (e, _) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(seminarsProvider),
                  child: Text('Pokusaj ponovo',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary)),
                ),
              ),
            ),
            data: (data) => SeminarsTable(
              seminars: data.items,
              currentPage: data.currentPage,
              totalPages: data.totalPages,
              onPageChanged: (page) {
                ref
                    .read(seminarsFilterProvider.notifier)
                    .update(filter.copyWith(pageNumber: page));
              },
              onEdit: (seminar) {
                showDialog(
                  context: context,
                  builder: (_) => SeminarFormModal(seminar: seminar),
                );
              },
              onDelete: (seminar) =>
                  _deleteSeminar(seminar.id, seminar.name),
            ),
          ),
        ],
      ),
    );
  }
}
