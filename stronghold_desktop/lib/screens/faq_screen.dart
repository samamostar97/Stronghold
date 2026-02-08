import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/faq_provider.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/faq_table.dart';
import '../widgets/faq_dialog.dart';
import '../utils/error_handler.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(faqListProvider.notifier).load();
    });
  }

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
      tableBuilder: (items) => FaqTable(
        faqs: items,
        onEdit: _editFaq,
        onDelete: _deleteFaq,
      ),
    );
  }
}
