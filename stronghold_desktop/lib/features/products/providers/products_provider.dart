import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/products_repository.dart';
import '../data/product_categories_repository.dart';
import '../data/suppliers_repository.dart';
import '../models/product_response.dart';
import '../models/product_category_response.dart';
import '../models/supplier_response.dart';

// Repositories
final productsRepositoryProvider = Provider((ref) => ProductsRepository());
final productCategoriesRepositoryProvider =
    Provider((ref) => ProductCategoriesRepository());
final suppliersRepositoryProvider = Provider((ref) => SuppliersRepository());

// --- Products ---

class ProductsFilter {
  final int pageNumber;
  final String? search;
  final int? categoryId;
  final int? supplierId;

  const ProductsFilter({
    this.pageNumber = 1,
    this.search,
    this.categoryId,
    this.supplierId,
  });

  ProductsFilter copyWith({
    int? pageNumber,
    String? search,
    int? categoryId,
    int? supplierId,
    bool clearCategory = false,
    bool clearSupplier = false,
  }) {
    return ProductsFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      supplierId: clearSupplier ? null : (supplierId ?? this.supplierId),
    );
  }
}

class ProductsFilterNotifier extends Notifier<ProductsFilter> {
  @override
  ProductsFilter build() => const ProductsFilter();

  void update(ProductsFilter filter) => state = filter;
}

final productsFilterProvider =
    NotifierProvider<ProductsFilterNotifier, ProductsFilter>(
        ProductsFilterNotifier.new);

final productsListProvider =
    FutureProvider.autoDispose<PagedProductResponse>((ref) async {
  final repo = ref.read(productsRepositoryProvider);
  final filter = ref.watch(productsFilterProvider);

  return repo.getProducts(
    pageNumber: filter.pageNumber,
    search: filter.search,
    categoryId: filter.categoryId,
    supplierId: filter.supplierId,
    orderBy: 'stock',
    orderDescending: false,
  );
});

// --- Categories (simple lookup, no pagination) ---

final categoriesListProvider =
    FutureProvider.autoDispose<List<ProductCategoryResponse>>((ref) async {
  final repo = ref.read(productCategoriesRepositoryProvider);
  return repo.getCategories();
});

// --- Suppliers ---

class SuppliersFilter {
  final int pageNumber;
  final String? search;

  const SuppliersFilter({this.pageNumber = 1, this.search});

  SuppliersFilter copyWith({int? pageNumber, String? search}) {
    return SuppliersFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
    );
  }
}

class SuppliersFilterNotifier extends Notifier<SuppliersFilter> {
  @override
  SuppliersFilter build() => const SuppliersFilter();

  void update(SuppliersFilter filter) => state = filter;
}

final suppliersFilterProvider =
    NotifierProvider<SuppliersFilterNotifier, SuppliersFilter>(
        SuppliersFilterNotifier.new);

final suppliersListProvider =
    FutureProvider.autoDispose<PagedSupplierResponse>((ref) async {
  final repo = ref.read(suppliersRepositoryProvider);
  final filter = ref.watch(suppliersFilterProvider);

  return repo.getSuppliers(
    pageNumber: filter.pageNumber,
    search: filter.search,
  );
});
