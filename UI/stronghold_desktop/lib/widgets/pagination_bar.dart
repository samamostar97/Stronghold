import 'package:flutter/material.dart';

/// Kontrole paginacije ispod tabela - koriste ih svi pregledi.
class PaginationBar extends StatelessWidget {
  final int page;
  final int pageSize;
  final int totalCount;
  final ValueChanged<int> onPageChanged;

  const PaginationBar({
    super.key,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
  });

  int get _totalPages => totalCount == 0 ? 1 : ((totalCount - 1) ~/ pageSize) + 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Ukupno: $totalCount'),
        const SizedBox(width: 16),
        IconButton(
          tooltip: 'Prethodna stranica',
          icon: const Icon(Icons.chevron_left),
          onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
        ),
        Text('$page / $_totalPages'),
        IconButton(
          tooltip: 'Sljedeća stranica',
          icon: const Icon(Icons.chevron_right),
          onPressed: page < _totalPages ? () => onPageChanged(page + 1) : null,
        ),
      ],
    );
  }
}
