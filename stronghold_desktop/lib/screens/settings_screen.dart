import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/faq_provider.dart';
import '../providers/membership_package_provider.dart';
import '../providers/supplement_category_provider.dart';
import '../providers/supplier_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/categories/category_dialog.dart';
import '../widgets/faq/faq_dialog.dart';
import '../widgets/membership_packages/membership_package_add_dialog.dart';
import '../widgets/membership_packages/membership_package_edit_dialog.dart';
import '../widgets/settings/settings_categories_tab.dart';
import '../widgets/settings/settings_faq_tab.dart';
import '../widgets/settings/settings_packages_tab.dart';
import '../widgets/settings/settings_suppliers_tab.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/suppliers/supplier_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loadedTabs = <int>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Load first tab data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTabData(0);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadTabData(_tabController.index);
    }
  }

  void _loadTabData(int index) {
    if (_loadedTabs.contains(index)) return;
    _loadedTabs.add(index);
    switch (index) {
      case 0:
        ref.read(membershipPackageListProvider.notifier).load();
      case 1:
        ref.read(supplementCategoryListProvider.notifier).load();
      case 2:
        ref.read(supplierListProvider.notifier).load();
      case 3:
        ref.read(faqListProvider.notifier).load();
    }
  }

  // ── Membership Package CRUD ──────────────────────────────────────────

  Future<void> _addPackage() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => MembershipPackageAddDialog(
        onCreate: (request) async {
          await ref
              .read(membershipPackageListProvider.notifier)
              .create(request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editPackage(MembershipPackageResponse package) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => MembershipPackageEditDialog(
        package: package,
        onUpdate: (request) async {
          await ref
              .read(membershipPackageListProvider.notifier)
              .update(package.id, request);
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deletePackage(MembershipPackageResponse package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati paket "${package.packageName ?? ""}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(membershipPackageListProvider.notifier)
          .delete(package.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'delete-package'));
      }
    }
  }

  // ── Category CRUD ────────────────────────────────────────────────────

  Future<void> _addCategory() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => const CategoryDialog(),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
      ref.read(supplementCategoryListProvider.notifier).refresh();
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editCategory(SupplementCategoryResponse category) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => CategoryDialog(initial: category),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
      ref.read(supplementCategoryListProvider.notifier).refresh();
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteCategory(SupplementCategoryResponse category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati kategoriju "${category.name}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(supplementCategoryListProvider.notifier)
          .delete(category.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message:
                ErrorHandler.getContextualMessage(e, 'delete-category'));
      }
    }
  }

  // ── Supplier CRUD ────────────────────────────────────────────────────

  Future<void> _addSupplier() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => SupplierDialog(
        onSave: (name, website) async {
          await ref
              .read(supplierListProvider.notifier)
              .create(CreateSupplierRequest(name: name, website: website));
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editSupplier(SupplierResponse supplier) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => SupplierDialog(
        initial: supplier,
        onSave: (name, website) async {
          await ref.read(supplierListProvider.notifier).update(
                supplier.id,
                UpdateSupplierRequest(name: name, website: website),
              );
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteSupplier(SupplierResponse supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati dobavljaca "${supplier.name}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(supplierListProvider.notifier).delete(supplier.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message:
                ErrorHandler.getContextualMessage(e, 'delete-supplier'));
      }
    }
  }

  // ── FAQ CRUD ─────────────────────────────────────────────────────────

  Future<void> _addFaq() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => FaqDialog(
        onSave: (question, answer) async {
          await ref.read(faqListProvider.notifier).create(
                CreateFaqRequest(question: question, answer: answer),
              );
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editFaq(FaqResponse faq) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => FaqDialog(
        initial: faq,
        onSave: (question, answer) async {
          await ref.read(faqListProvider.notifier).update(
                faq.id,
                UpdateFaqRequest(question: question, answer: answer),
              );
        },
      ),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteFaq(FaqResponse faq) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message: 'Jeste li sigurni da zelite obrisati ovo pitanje?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(faqListProvider.notifier).delete(faq.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'delete-faq'));
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final pad =
                c.maxWidth > 1200 ? 40.0 : c.maxWidth > 800 ? 24.0 : 16.0;
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: pad, vertical: AppSpacing.xl),
              child: _mainContent(),
            );
          })
              .animate(delay: 200.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        ),
      ],
    );
  }

  Widget _mainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tabBar(),
        const SizedBox(height: AppSpacing.xl),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SettingsPackagesTab(
                onAdd: _addPackage,
                onEdit: _editPackage,
                onDelete: _deletePackage,
              ),
              SettingsCategoriesTab(
                onAdd: _addCategory,
                onEdit: _editCategory,
                onDelete: _deleteCategory,
              ),
              SettingsSuppliersTab(
                onAdd: _addSupplier,
                onEdit: _editSupplier,
                onDelete: _deleteSupplier,
              ),
              SettingsFaqTab(
                onAdd: _addFaq,
                onEdit: _editFaq,
                onDelete: _deleteFaq,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBar() {
    final tabs = [
      (label: 'Paketi', icon: LucideIcons.package2),
      (label: 'Kategorije', icon: LucideIcons.tag),
      (label: 'Dobavljaci', icon: LucideIcons.truck),
      (label: 'FAQ', icon: LucideIcons.helpCircle),
    ];

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.buttonRadius,
            boxShadow: [
              BoxShadow(
                color: AppColors.electric.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isActive = _tabController.index == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.deepBlue : Colors.transparent,
                      borderRadius: AppSpacing.badgeRadius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabs[i].icon,
                          size: 18,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            tabs[i].label,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
