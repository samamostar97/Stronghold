import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_dto.dart';
import '../models/membership_dto.dart';
import '../services/memberships_api.dart';

/// Screen for viewing a user's membership payment history
class MemberPaymentHistoryScreen extends StatefulWidget {
  const MemberPaymentHistoryScreen({
    super.key,
    required this.user,
  });

  final UserTableRowDTO user;

  @override
  State<MemberPaymentHistoryScreen> createState() => _MemberPaymentHistoryScreenState();
}

class _MemberPaymentHistoryScreenState extends State<MemberPaymentHistoryScreen> {
  List<MembershipPaymentRowDTO> _payments = [];
  bool _isLoading = true;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  static const int _pageSize = 10;

  final _dateFormat = DateFormat('dd.MM.yyyy.');

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await MembershipsApi.getUserPayments(
        widget.user.id,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _payments = result.items;
        _totalPages = result.totalPages;
        _totalCount = result.totalCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    _currentPage = page;
    _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_AppColors.bg1, _AppColors.bg2],
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
                    const _Header(),
                    const SizedBox(height: 20),
                    _BackButton(onTap: () => Navigator.of(context).maybePop()),
                    const SizedBox(height: 20),
                    Expanded(child: _buildMainContent(constraints)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 30 : 16),
      decoration: BoxDecoration(
        color: _AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title and user info section
          _buildUserInfoSection(constraints),
          const SizedBox(height: 24),
          Expanded(child: _buildContent(constraints)),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pregled uplata za:',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 16 : 14,
            color: _AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.user.firstName} ${widget.user.lastName}',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 28 : 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '@${widget.user.username}',
          style: TextStyle(
            fontSize: constraints.maxWidth > 600 ? 14 : 12,
            color: _AppColors.muted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _AppColors.accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Greska pri ucitavanju',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: _AppColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _GradientButton(text: 'Pokusaj ponovo', onTap: _loadPayments),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildTable(constraints)),
        if (_totalPages > 1) ...[
          const SizedBox(height: 20),
          _buildPagination(constraints),
        ],
      ],
    );
  }

  Widget _buildTable(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 700;
    final tableMinWidth = isNarrow ? 650.0 : null;

    return Container(
      decoration: BoxDecoration(
        color: _AppColors.panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isNarrow
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableMinWidth,
                  child: Column(
                    children: [
                      const _TableHeader(),
                      if (_payments.isEmpty)
                        const SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              'Nema uplata za ovog korisnika.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                      else
                        ...List.generate(
                          _payments.length,
                          (i) => _PaymentTableRow(
                            payment: _payments[i],
                            isLast: i == _payments.length - 1,
                            dateFormat: _dateFormat,
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  const _TableHeader(),
                  if (_payments.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Nema uplata za ovog korisnika.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _payments.length,
                        itemBuilder: (context, i) => _PaymentTableRow(
                          payment: _payments[i],
                          isLast: i == _payments.length - 1,
                          dateFormat: _dateFormat,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildPagination(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 500;

    if (isNarrow) {
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PaginationButton(
                  icon: Icons.chevron_left,
                  enabled: _currentPage > 1,
                  onTap: () => _goToPage(_currentPage - 1),
                ),
                const SizedBox(width: 8),
                for (int i = 1; i <= _totalPages; i++) ...[
                  _PaginationNumber(
                    number: i,
                    isActive: i == _currentPage,
                    onTap: () => _goToPage(i),
                  ),
                  if (i < _totalPages) const SizedBox(width: 4),
                ],
                const SizedBox(width: 8),
                _PaginationButton(
                  icon: Icons.chevron_right,
                  enabled: _currentPage < _totalPages,
                  onTap: () => _goToPage(_currentPage + 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ukupno: $_totalCount',
            style: const TextStyle(color: _AppColors.muted, fontSize: 14),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PaginationButton(
          icon: Icons.chevron_left,
          enabled: _currentPage > 1,
          onTap: () => _goToPage(_currentPage - 1),
        ),
        const SizedBox(width: 8),
        for (int i = 1; i <= _totalPages; i++) ...[
          _PaginationNumber(
            number: i,
            isActive: i == _currentPage,
            onTap: () => _goToPage(i),
          ),
          if (i < _totalPages) const SizedBox(width: 4),
        ],
        const SizedBox(width: 8),
        _PaginationButton(
          icon: Icons.chevron_right,
          enabled: _currentPage < _totalPages,
          onTap: () => _goToPage(_currentPage + 1),
        ),
        const SizedBox(width: 16),
        Text(
          'Ukupno: $_totalCount',
          style: const TextStyle(color: _AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }
}

// THEME COLORS

abstract class _AppColors {
  static const bg1 = Color(0xFF1A1D2E);
  static const bg2 = Color(0xFF16192B);
  static const card = Color(0xFF22253A);
  static const panel = Color(0xFF2A2D3E);
  static const border = Color(0xFF3A3D4E);
  static const muted = Color(0xFF8A8D9E);
  static const accent = Color(0xFFFF5757);
  static const accentLight = Color(0xFFFF6B6B);
}

// REUSABLE WIDGETS

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;

        return Row(
          children: [
            Row(
              children: [
                const Text('🏋️', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 10),
                Text(
                  'STRONGHOLD',
                  style: TextStyle(
                    fontSize: isCompact ? 18 : 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _AppColors.panel,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('👤'),
                  SizedBox(width: 8),
                  Text(
                    'Admin',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _GradientButton(text: '← Nazad', onTap: onTap),
    );
  }
}

class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.identity()..setTranslationRaw(0.0, _hover ? -2.0 : 0.0, 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_AppColors.accent, _AppColors.accentLight],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// TABLE WIDGETS

// Column flex values for responsive table layout
abstract class _TableFlex {
  static const int packageName = 3;
  static const int amountPaid = 2;
  static const int paymentDate = 2;
  static const int startDate = 2;
  static const int endDate = 2;
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _AppColors.border, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: const Row(
        children: [
          _HeaderCell(text: 'Naziv paketa članarine', flex: _TableFlex.packageName),
          _HeaderCell(text: 'Iznos uplate', flex: _TableFlex.amountPaid),
          _HeaderCell(text: 'Datum uplate', flex: _TableFlex.paymentDate),
          _HeaderCell(text: 'Početak članarine', flex: _TableFlex.startDate),
          _HeaderCell(text: 'Kraj članarine', flex: _TableFlex.endDate),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PaymentTableRow extends StatefulWidget {
  const _PaymentTableRow({
    required this.payment,
    required this.isLast,
    required this.dateFormat,
  });

  final MembershipPaymentRowDTO payment;
  final bool isLast;
  final DateFormat dateFormat;

  @override
  State<_PaymentTableRow> createState() => _PaymentTableRowState();
}

class _PaymentTableRowState extends State<_PaymentTableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? _AppColors.panel.withValues(alpha: 0.5) : Colors.transparent,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: _AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            _DataCell(text: widget.payment.packageName, flex: _TableFlex.packageName),
            _DataCell(
              text: '${widget.payment.amountPaid.toStringAsFixed(2)} KM',
              flex: _TableFlex.amountPaid,
            ),
            _DataCell(
              text: widget.dateFormat.format(widget.payment.paymentDate),
              flex: _TableFlex.paymentDate,
            ),
            _DataCell(
              text: widget.dateFormat.format(widget.payment.startDate),
              flex: _TableFlex.startDate,
            ),
            _DataCell(
              text: widget.dateFormat.format(widget.payment.endDate),
              flex: _TableFlex.endDate,
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
        maxLines: 1,
      ),
    );
  }
}

// PAGINATION WIDGETS

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled ? _AppColors.panel : _AppColors.panel.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.white : _AppColors.muted,
        ),
      ),
    );
  }
}

class _PaginationNumber extends StatelessWidget {
  const _PaginationNumber({
    required this.number,
    required this.isActive,
    required this.onTap,
  });

  final int number;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _AppColors.accent : _AppColors.panel,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
