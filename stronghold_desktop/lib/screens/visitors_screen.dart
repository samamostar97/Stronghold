import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../providers/visit_provider.dart';
import '../providers/user_provider.dart';
import '../utils/debouncer.dart';
import '../utils/error_handler.dart';
import '../widgets/back_button.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/gradient_button.dart';
import '../widgets/hover_icon_button.dart';
import '../widgets/small_button.dart';
import '../widgets/success_animation.dart';
import '../widgets/error_animation.dart';
import '../widgets/shared_admin_header.dart';

/// Refactored Current Visitors Screen using Riverpod
class VisitorsScreen extends ConsumerStatefulWidget {
  const VisitorsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends ConsumerState<VisitorsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentVisitorsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckOut(CurrentVisitorResponse visitor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: 'Potvrda check-out',
        message: 'Želite li odjaviti korisnika "${visitor.fullName}"?',
        confirmText: 'Check-out',
      ),
    );

    if (confirmed != true) return;

    try {
      if (visitor.visitId == 0) {
        throw Exception('Invalid visit ID. Please refresh and try again.');
      }

      await ref.read(currentVisitorsProvider.notifier).checkOut(visitor.visitId);
      if (mounted) showSuccessAnimation(context);
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: ErrorHandler.getContextualMessage(e, 'check-out'),
        );
      }
    }
  }

  Future<void> _openCheckInDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _CheckInDialog(),
    );

    if (result == true && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) showSuccessAnimation(context);
      ref.read(currentVisitorsProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentVisitorsProvider);

    if (widget.embedded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 1200
              ? 40.0
              : constraints.maxWidth > 800
                  ? 24.0
                  : 16.0;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: _buildMainContent(constraints, state),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bg1, AppColors.bg2],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > 1200
                  ? 40.0
                  : constraints.maxWidth > 800
                      ? 24.0
                      : 16.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SharedAdminHeader(),
                    const SizedBox(height: 20),
                    AppBackButton(onTap: () => Navigator.of(context).maybePop()),
                    const SizedBox(height: 20),
                    Expanded(child: _buildMainContent(constraints, state)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BoxConstraints constraints, CurrentVisitorsState state) {
    return Container(
      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 30 : 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitleRow(constraints, state),
          const SizedBox(height: 24),
          _buildActionBar(constraints),
          const SizedBox(height: 24),
          Expanded(child: _buildContent(constraints, state)),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BoxConstraints constraints, CurrentVisitorsState state) {
    final countText = '${state.visitors.length} korisnika';

    return Row(
      children: [
        Expanded(
          child: Text(
            'Korisnici trenutno u teretani',
            style: TextStyle(
              fontSize: constraints.maxWidth > 600 ? 28 : 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentLight],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                countText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        HoverIconButton(
          icon: Icons.refresh,
          onTap: () => ref.read(currentVisitorsProvider.notifier).load(),
          tooltip: 'Osvježi',
        ),
      ],
    );
  }

  Widget _buildActionBar(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 700;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchInput(
            controller: _searchController,
            hintText: 'Pretraži trenutne korisnike...',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          GradientButton(
            text: '+ Check-in korisnika',
            onTap: _openCheckInDialog,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _SearchInput(
            controller: _searchController,
            hintText: 'Pretraži trenutne korisnike...',
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 16),
        GradientButton(
          text: '+ Check-in korisnika',
          onTap: _openCheckInDialog,
        ),
      ],
    );
  }

  Widget _buildContent(BoxConstraints constraints, CurrentVisitorsState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Greška pri učitavanju',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: 'Pokušaj ponovo',
              onTap: () => ref.read(currentVisitorsProvider.notifier).load(),
            ),
          ],
        ),
      );
    }

    if (state.visitors.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(
              'Nema korisnika u teretani',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Filter visitors based on search
    final filteredVisitors = ref.read(currentVisitorsProvider.notifier)
        .filterVisitors(_searchController.text);

    if (filteredVisitors.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(
              'Nema rezultata za "${_searchController.text}"',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return _VisitorsTable(
      visitors: filteredVisitors,
      onCheckOut: _handleCheckOut,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

abstract class _TableFlex {
  static const int username = 2;
  static const int fullName = 3;
  static const int checkInTime = 2;
  static const int duration = 2;
  static const int actions = 2;
}

class _VisitorsTable extends StatelessWidget {
  const _VisitorsTable({
    required this.visitors,
    required this.onCheckOut,
  });

  final List<CurrentVisitorResponse> visitors;
  final ValueChanged<CurrentVisitorResponse> onCheckOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const _TableHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: visitors.length,
                itemBuilder: (context, i) => _VisitorTableRow(
                  visitor: visitors[i],
                  isLast: i == visitors.length - 1,
                  onCheckOut: () => onCheckOut(visitors[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: const Row(
        children: [
          _HeaderCell(text: 'Korisničko ime', flex: _TableFlex.username),
          _HeaderCell(text: 'Ime i prezime', flex: _TableFlex.fullName),
          _HeaderCell(text: 'Vrijeme dolaska', flex: _TableFlex.checkInTime),
          _HeaderCell(text: 'Trajanje', flex: _TableFlex.duration),
          _HeaderCell(text: 'Akcija', flex: _TableFlex.actions, alignRight: true),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text, required this.flex, this.alignRight = false});

  final String text;
  final int flex;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _VisitorTableRow extends StatefulWidget {
  const _VisitorTableRow({
    required this.visitor,
    required this.isLast,
    required this.onCheckOut,
  });

  final CurrentVisitorResponse visitor;
  final bool isLast;
  final VoidCallback onCheckOut;

  @override
  State<_VisitorTableRow> createState() => _VisitorTableRowState();
}

class _VisitorTableRowState extends State<_VisitorTableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? AppColors.panel.withValues(alpha: 0.5) : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            _DataCell(text: widget.visitor.username, flex: _TableFlex.username),
            _DataCell(text: widget.visitor.fullName, flex: _TableFlex.fullName),
            _DataCell(text: widget.visitor.checkInTimeFormatted, flex: _TableFlex.checkInTime),
            _DataCell(text: widget.visitor.durationFormatted, flex: _TableFlex.duration),
            Expanded(
              flex: _TableFlex.actions,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SmallButton(
                    text: 'Check-out',
                    color: AppColors.accent,
                    onTap: widget.onCheckOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH INPUT
// ─────────────────────────────────────────────────────────────────────────────

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        filled: true,
        fillColor: AppColors.panel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.muted),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.muted, size: 20),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                },
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK-IN DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _CheckInDialog extends ConsumerStatefulWidget {
  const _CheckInDialog();

  @override
  ConsumerState<_CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends ConsumerState<_CheckInDialog> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);

  List<UserResponse> _searchResults = [];
  bool _searching = false;
  bool _checkingIn = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() => _searchUsers(query));
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _searching = true);

    try {
      await ref.read(userListProvider.notifier).setSearch(query);
      final state = ref.read(userListProvider);
      if (mounted) {
        setState(() {
          _searchResults = state.data?.items ?? [];
          _searching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _checkInUser(UserResponse user) async {
    setState(() => _checkingIn = true);

    try {
      await ref.read(currentVisitorsProvider.notifier).checkIn(user.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, false);
        showErrorAnimation(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Check-in korisnika',
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
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Pretraži po imenu ili korisničkom imenu...',
                  hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.panel,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_searching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_checkingIn) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 16),
              Text(
                'Prijava u tijeku...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Nema rezultata za "${_searchController.text}"',
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Unesite ime ili korisničko ime za pretragu',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (ctx, i) {
        final user = _searchResults[i];
        return _UserSearchResultTile(
          user: user,
          onCheckIn: () => _checkInUser(user),
        );
      },
    );
  }
}

class _UserSearchResultTile extends StatefulWidget {
  const _UserSearchResultTile({
    required this.user,
    required this.onCheckIn,
  });

  final UserResponse user;
  final VoidCallback onCheckIn;

  @override
  State<_UserSearchResultTile> createState() => _UserSearchResultTileState();
}

class _UserSearchResultTileState extends State<_UserSearchResultTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _hover ? AppColors.panel : AppColors.panel.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hover ? AppColors.border : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.user.firstName.isNotEmpty
                    ? widget.user.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.user.firstName} ${widget.user.lastName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.user.username,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SmallButton(
              text: 'Check-in',
              color: AppColors.accent,
              onTap: widget.onCheckIn,
            ),
          ],
        ),
      ),
    );
  }
}
