import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'data_table_widgets.dart';
import 'small_button.dart';
import 'status_pill.dart';

class OrdersTable extends StatelessWidget {
  const OrdersTable({
    super.key,
    required this.orders,
    required this.onViewDetails,
  });

  final List<OrderResponse> orders;
  final ValueChanged<OrderResponse> onViewDetails;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Narudzba #', flex: 1),
          TableHeaderCell(text: 'Korisnik', flex: 3),
          TableHeaderCell(text: 'Ukupno', flex: 2),
          TableHeaderCell(text: 'Datum', flex: 2),
          TableHeaderCell(text: 'Status', flex: 2),
          TableHeaderCell(text: 'Akcije', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final o = orders[i];
        return HoverableTableRow(
          index: i,
          isLast: i == orders.length - 1,
          child: Row(children: [
            TableDataCell(text: '#${o.id}', flex: 1),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.userFullName,
                      style: AppTextStyles.bodyBold,
                      overflow: TextOverflow.ellipsis),
                  Text(o.userEmail,
                      style: AppTextStyles.bodySm,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            TableDataCell(
                text: '${o.totalAmount.toStringAsFixed(2)} KM',
                flex: 2,
                muted: true),
            TableDataCell(
                text: DateFormat('dd.MM.yyyy HH:mm').format(o.purchaseDate),
                flex: 2),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: switch (o.status) {
                  OrderStatus.delivered => StatusPill.delivered(),
                  OrderStatus.cancelled => StatusPill.cancelled(),
                  _ => StatusPill.pending(),
                },
              ),
            ),
            TableActionCell(flex: 2, children: [
              SmallButton(
                text: 'Detalji',
                color: AppColors.secondary,
                onTap: () => onViewDetails(o),
              ),
            ]),
          ]),
        );
      },
    );
  }
}
