import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/payments_provider.dart';
import '../utils/formatters.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/stretch_scroll.dart';
import '../widgets/empty_state.dart';

/// Historija svih uplata clanarina u sistemu.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PaymentsProvider>().load(page: 1, clearUser: true),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Pretraga po članu',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onSubmitted: (value) =>
                    provider.load(page: 1, searchText: value.trim()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.payments.isEmpty
                  ? const EmptyState(icon: Icons.inbox_outlined, message: 'Nema uplata za prikaz.')
                  : Card(
                      child: SingleChildScrollView(
                        child: StretchScroll(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Datum')),
                              DataColumn(label: Text('Član')),
                              DataColumn(label: Text('Paket')),
                              DataColumn(label: Text('Iznos')),
                            ],
                            rows: [
                              for (final payment in provider.payments)
                                DataRow(cells: [
                                  DataCell(Text(Formatters.dateTime(payment.paidAt))),
                                  DataCell(Text(payment.userFullName)),
                                  DataCell(Text(payment.packageName)),
                                  DataCell(Text(Formatters.money(payment.amount))),
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
