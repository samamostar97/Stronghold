import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/membership_packages_repository.dart';
import '../models/membership_package_response.dart';

class PackagesFilter {
  final int pageNumber;
  final String? search;

  const PackagesFilter({this.pageNumber = 1, this.search});

  PackagesFilter copyWith({int? pageNumber, String? search}) {
    return PackagesFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
    );
  }
}

class PackagesFilterNotifier extends Notifier<PackagesFilter> {
  @override
  PackagesFilter build() => const PackagesFilter();

  void update(PackagesFilter filter) => state = filter;
}

final packagesFilterProvider =
    NotifierProvider<PackagesFilterNotifier, PackagesFilter>(
        PackagesFilterNotifier.new);

final membershipPackagesListProvider =
    FutureProvider.autoDispose<PagedMembershipPackageResponse>((ref) async {
  final filter = ref.watch(packagesFilterProvider);
  final repo = ref.read(membershipPackagesRepositoryProvider);
  return repo.getPackages(
    pageNumber: filter.pageNumber,
    search: filter.search,
  );
});
