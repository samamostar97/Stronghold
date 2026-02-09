import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

final addressServiceProvider = Provider<AddressService>((ref) {
  return AddressService(ref.watch(apiClientProvider));
});

final addressProvider = FutureProvider<AddressResponse?>((ref) async {
  return ref.watch(addressServiceProvider).getMyAddress();
});
