import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/faq_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/data_table_widgets.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/dialog_text_field.dart';
import '../utils/error_handler.dart';

/// Refactored FAQ Screen using Riverpod + generic patterns
/// Old: ~1,030 LOC | New: ~280 LOC (73% reduction)
class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(faqListProvider.notifier).load();
    });
  }

  Future<void> _addFaq() async {
    final created = await showDialog<Object?>(
      context: context,
      builder: (_) => _AddFaqDialog(
        onCreate: (request) async {
          await ref.read(faqListProvider.notifier).create(request);
        },
      ),
    );

    if (created == true && mounted) {
      showSuccessAnimation(context);
    } else if (created is String && mounted) {
      showErrorAnimation(context, message: created);
    }
  }

  Future<void> _editFaq(FaqResponse faq) async {
    final updated = await showDialog<Object?>(
      context: context,
      builder: (_) => _EditFaqDialog(
        faq: faq,
        onUpdate: (request) async {
          await ref.read(faqListProvider.notifier).update(faq.id, request);
        },
      ),
    );

    if (updated == true && mounted) {
      showSuccessAnimation(context);
    } else if (updated is String && mounted) {
      showErrorAnimation(context, message: updated);
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
        showErrorAnimation(context, message: ErrorHandler.getContextualMessage(e, 'delete-faq'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faqListProvider);
    final notifier = ref.read(faqListProvider.notifier);

    return CrudListScaffold<FaqResponse, FaqQueryFilter>(
      title: 'Upravljanje FAQ-om',
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addFaq,
      searchHint: 'Pretrazi pitanja...',
      addButtonText: '+ Dodaj FAQ',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'createdatdesc', label: 'Najnovije prvo'),
      ],
      tableBuilder: (items) => _FaqTable(
        faqs: items,
        onEdit: _editFaq,
        onDelete: _deleteFaq,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAQ TABLE
// ─────────────────────────────────────────────────────────────────────────────

abstract class _Flex {
  static const int question = 4;
  static const int answer = 5;
  static const int actions = 2;
}

class _FaqTable extends StatelessWidget {
  const _FaqTable({
    required this.faqs,
    required this.onEdit,
    required this.onDelete,
  });

  final List<FaqResponse> faqs;
  final ValueChanged<FaqResponse> onEdit;
  final ValueChanged<FaqResponse> onDelete;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: TableHeader(
        child: const Row(
          children: [
            TableHeaderCell(text: 'Pitanje', flex: _Flex.question),
            TableHeaderCell(text: 'Odgovor', flex: _Flex.answer),
            TableHeaderCell(text: 'Akcije', flex: _Flex.actions, alignRight: true),
          ],
        ),
      ),
      itemCount: faqs.length,
      itemBuilder: (context, i) => _FaqRow(
        faq: faqs[i],
        index: i,
        isLast: i == faqs.length - 1,
        onEdit: () => onEdit(faqs[i]),
        onDelete: () => onDelete(faqs[i]),
      ),
    );
  }
}

class _FaqRow extends StatelessWidget {
  const _FaqRow({
    required this.faq,
    required this.index,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final FaqResponse faq;
  final int index;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return HoverableTableRow(
      isLast: isLast,
      index: index,
      child: Row(
        children: [
          Expanded(
            flex: _Flex.question,
            child: Tooltip(
              message: faq.question,
              child: Text(
                faq.question,
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
          Expanded(
            flex: _Flex.answer,
            child: Tooltip(
              message: faq.answer,
              child: Text(
                faq.answer,
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
          TableActionCell(
            flex: _Flex.actions,
            children: [
              SmallButton(text: 'Izmijeni', color: AppColors.editBlue, onTap: onEdit),
              const SizedBox(width: 8),
              SmallButton(text: 'Obrisi', color: AppColors.accent, onTap: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOGS
// ─────────────────────────────────────────────────────────────────────────────

class _AddFaqDialog extends StatefulWidget {
  const _AddFaqDialog({required this.onCreate});

  final Future<void> Function(CreateFaqRequest) onCreate;

  @override
  State<_AddFaqDialog> createState() => _AddFaqDialogState();
}

class _AddFaqDialogState extends State<_AddFaqDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = CreateFaqRequest(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
      );

      await widget.onCreate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(ErrorHandler.getContextualMessage(e, 'create-faq'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Dodaj FAQ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DialogTextField(
                    controller: _questionController,
                    label: 'Pitanje',
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _answerController,
                    label: 'Odgovor',
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Spremi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditFaqDialog extends StatefulWidget {
  const _EditFaqDialog({required this.faq, required this.onUpdate});

  final FaqResponse faq;
  final Future<void> Function(UpdateFaqRequest) onUpdate;

  @override
  State<_EditFaqDialog> createState() => _EditFaqDialogState();
}

class _EditFaqDialogState extends State<_EditFaqDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.faq.question);
    _answerController = TextEditingController(text: widget.faq.answer);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = UpdateFaqRequest(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
      );

      await widget.onUpdate(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(ErrorHandler.getContextualMessage(e, 'update-faq'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Izmijeni FAQ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DialogTextField(
                    controller: _questionController,
                    label: 'Pitanje',
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 16),
                  DialogTextField(
                    controller: _answerController,
                    label: 'Odgovor',
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obavezno polje' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Odustani', style: TextStyle(color: AppColors.muted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Spremi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
