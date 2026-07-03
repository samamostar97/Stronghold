import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reviews_provider.dart';
import '../utils/formatters.dart';
import '../widgets/pagination_bar.dart';

/// Pregled recenzija - pretraga po korisniku ili suplementu.
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReviewsProvider>().load(page: 1, searchText: ''),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _stars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= rating ? Icons.star : Icons.star_border,
            size: 16,
            color: Colors.amber,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Pretraga (korisnik ili suplement)',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
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
              : provider.reviews.isEmpty
                  ? const Center(child: Text('Nema recenzija za prikaz.'))
                  : Card(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Korisnik')),
                              DataColumn(label: Text('Suplement')),
                              DataColumn(label: Text('Ocjena')),
                              DataColumn(label: Text('Komentar')),
                              DataColumn(label: Text('Datum')),
                            ],
                            rows: [
                              for (final review in provider.reviews)
                                DataRow(cells: [
                                  DataCell(Text(review.userFullName)),
                                  DataCell(SizedBox(
                                    width: 200,
                                    child: Text(review.supplementName,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                                  DataCell(_stars(review.rating)),
                                  DataCell(SizedBox(
                                    width: 320,
                                    child: Text(review.comment ?? '-',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2),
                                  )),
                                  DataCell(Text(Formatters.date(review.createdAt))),
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
