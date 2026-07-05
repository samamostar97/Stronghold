import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../utils/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pagination_bar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _searchController = TextEditingController();

  static const _statusLabels = {
    'Processing': 'U obradi',
    'Delivered': 'Dostavljeno',
    'Cancelled': 'Otkazano',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context
          .read<OrdersProvider>()
          .load(page: 1, searchText: '', clearStatus: true),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'Delivered' => Colors.green.shade700,
        'Cancelled' => Theme.of(context).colorScheme.error,
        _ => Colors.orange.shade800,
      };

  void _showDetails(Order order) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text('Narudžba #${order.id}')),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Kupac', order.userFullName),
                _detailRow('Datum', Formatters.dateTime(order.createdAt)),
                _detailRow('Status', _statusLabels[order.status] ?? order.status),
                _detailRow('Dostava',
                    '${order.deliveryStreet}, ${order.deliveryCityName}'),
                _detailRow('Stripe ID plaćanja', order.stripePaymentIntentId),
                if (order.cancellationReason != null)
                  _detailRow('Razlog otkazivanja', order.cancellationReason!),
                const Divider(height: 24),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Stavka')),
                    DataColumn(label: Text('Količina')),
                    DataColumn(label: Text('Cijena')),
                    DataColumn(label: Text('Iznos')),
                  ],
                  rows: [
                    for (final item in order.items)
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: 200,
                          child: Text(item.supplementName,
                              overflow: TextOverflow.ellipsis),
                        )),
                        DataCell(Text('${item.quantity}')),
                        DataCell(Text(Formatters.money(item.unitPrice))),
                        DataCell(Text(
                            Formatters.money(item.unitPrice * item.quantity))),
                      ]),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Ukupno: ${Formatters.money(order.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _deliver(Order order) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Potvrda isporuke',
      message: 'Označiti narudžbu #${order.id} kao dostavljenu? '
          'Kupac će dobiti e-mail i notifikaciju.',
      confirmLabel: 'Isporučeno',
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<OrdersProvider>().deliver(order.id);
      _showSuccess('Narudžba #${order.id} je označena kao dostavljena.');
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  Future<void> _cancel(Order order) async {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    String? serverError;
    bool processing = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text('Otkazivanje narudžbe #${order.id}')),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Otkazivanjem se kupcu vraća ${Formatters.money(order.totalAmount)} '
                  'na karticu putem Stripe povrata. Ova akcija je nepovratna.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Razlog otkazivanja',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Unesite razlog otkazivanja.'
                      : null,
                ),
                if (serverError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    serverError!,
                    style:
                        TextStyle(color: Theme.of(dialogContext).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Odustani'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: processing
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => processing = true);
                      try {
                        await context
                            .read<OrdersProvider>()
                            .cancel(order.id, reasonController.text.trim());
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        _showSuccess(
                            'Narudžba #${order.id} je otkazana, novac je vraćen kupcu.');
                      } on ApiException catch (e) {
                        setDialogState(() {
                          serverError = e.message;
                          processing = false;
                        });
                      }
                    },
              child: processing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Otkaži i vrati novac'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Pretraga po kupcu',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (value) =>
                    provider.load(page: 1, searchText: value.trim()),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String?>(
              value: provider.status,
              hint: const Text('Svi statusi'),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('Svi statusi')),
                for (final entry in _statusLabels.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (value) => value == null
                  ? provider.load(page: 1, clearStatus: true)
                  : provider.load(page: 1, status: value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.orders.isEmpty
                  ? const Center(child: Text('Nema narudžbi za prikaz.'))
                  : Card(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Broj')),
                              DataColumn(label: Text('Kupac')),
                              DataColumn(label: Text('Datum')),
                              DataColumn(label: Text('Iznos')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Akcije')),
                            ],
                            rows: [
                              for (final order in provider.orders)
                                DataRow(cells: [
                                  DataCell(Text('#${order.id}')),
                                  DataCell(Text(order.userFullName)),
                                  DataCell(
                                      Text(Formatters.dateTime(order.createdAt))),
                                  DataCell(
                                      Text(Formatters.money(order.totalAmount))),
                                  DataCell(Text(
                                    _statusLabels[order.status] ?? order.status,
                                    style: TextStyle(
                                      color: _statusColor(order.status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                                  DataCell(Row(children: [
                                    TextButton(
                                      onPressed: () => _showDetails(order),
                                      child: const Text('Detalji'),
                                    ),
                                    if (order.status == 'Processing') ...[
                                      TextButton(
                                        onPressed: () => _deliver(order),
                                        child: const Text('Isporučeno'),
                                      ),
                                      TextButton(
                                        onPressed: () => _cancel(order),
                                        child: const Text('Otkaži'),
                                      ),
                                    ],
                                  ])),
                                ]),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
        const SizedBox(height: 8),
        PaginationBar(
          page: provider.page,
          pageSize: provider.pageSize,
          totalCount: provider.totalCount,
          onPageChanged: (page) => provider.load(page: page),
        ),
      ],
    );
  }
}
