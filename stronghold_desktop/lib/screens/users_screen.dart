import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/user_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/crud_list_scaffold.dart';
import '../widgets/error_animation.dart';
import '../widgets/success_animation.dart';
import '../widgets/user_add_dialog.dart';
import '../widgets/user_edit_dialog.dart';
import '../widgets/users_table.dart';
import '../widgets/user_detail_drawer.dart';
import '../utils/error_handler.dart';

/// Users management screen using CrudListScaffold.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  UserResponse? _detailUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userListProvider.notifier).load();
    });
  }

  Future<void> _addUser() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => const UserAddDialog(),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _editUser(UserResponse user) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => UserEditDialog(user: user),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  Future<void> _deleteUser(UserResponse user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Potvrda brisanja',
        message:
            'Jeste li sigurni da zelite obrisati korisnika "${user.username}"?',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(userListProvider.notifier).delete(user.id);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message: ErrorHandler.getContextualMessage(e, 'delete-user'));
      }
    }
  }

  void _showDetails(UserResponse user) {
    setState(() => _detailUser = user);
  }

  void _closeDetails() {
    setState(() => _detailUser = null);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);
    final notifier = ref.read(userListProvider.notifier);

    return Stack(
      children: [
        CrudListScaffold<UserResponse, UserQueryFilter>(
          title: 'Upravljanje korisnicima',
          state: state,
          onRefresh: notifier.refresh,
          onSearch: notifier.setSearch,
          onSort: notifier.setOrderBy,
          onPageChanged: notifier.goToPage,
          onAdd: _addUser,
          searchHint: 'Pretrazi korisnike...',
          addButtonText: '+ Dodaj korisnika',
          sortOptions: const [
            SortOption(value: null, label: 'Zadano'),
            SortOption(value: 'firstname', label: 'Ime (A-Z)'),
            SortOption(value: 'lastname', label: 'Prezime (A-Z)'),
            SortOption(value: 'datedesc', label: 'Najnovije prvo'),
          ],
          tableBuilder: (items) => UsersTable(
            users: items,
            onEdit: _editUser,
            onDelete: _deleteUser,
            onDetails: _showDetails,
          ),
        ),
        if (_detailUser != null)
          UserDetailDrawer(
            user: _detailUser!,
            onClose: _closeDetails,
            onEdit: () {
              final user = _detailUser!;
              _closeDetails();
              _editUser(user);
            },
          ),
      ],
    );
  }
}
