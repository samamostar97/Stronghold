import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/seminars_provider.dart';
import '../widgets/seminars_table.dart';

class SeminarHistoryScreen extends ConsumerStatefulWidget {
  const SeminarHistoryScreen({super.key});

  @override
  ConsumerState<SeminarHistoryScreen> createState() =>
      _SeminarHistoryScreenState();
}

class _SeminarHistoryScreenState extends ConsumerState<SeminarHistoryScreen> {
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
      ref.read(seminarHistoryFilterProvider.notifier).update(SeminarsFilter(
        search: value.isEmpty ? null : value,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(seminarHistoryProvider);
    final filter = ref.watch(seminarHistoryFilterProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      Text('Historija seminara', style: AppTextStyles.h2)),
              SizedBox(
                width: 280,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Pretrazi seminare...',
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
          historyAsync.when(
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
                  onPressed: () => ref.invalidate(seminarHistoryProvider),
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
                    .read(seminarHistoryFilterProvider.notifier)
                    .update(filter.copyWith(pageNumber: page));
              },
              onEdit: (_) {},
              onDelete: (_) {},
              showActions: false,
            ),
          ),
        ],
      ),
    );
  }
}
