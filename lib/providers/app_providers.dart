import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom/models/merchant/merchant.dart';
import 'package:nomnom/models/raw_category.dart';
import 'package:nomnom/models/settings/area_settings.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/app.dart';
import 'package:nomnom/services/api/store_api.dart';

final AppApi _api = AppApi();
final exploreCategoriesProvider =
    FutureProvider<List<RawCategory>>((ref) async {
  return await _api.getPredefinedCategories();
});
final StoreApi _storeApi = StoreApi();
final navigationRestaurantFutureProvider =
    FutureProvider<List<Merchant>>((ref) async {
  final currentLocation = ref.watch(selectedLocationProvider);
  final result = await _storeApi.search(city: currentLocation?.city);
  ref.read(navigationRestaurantProvider.notifier).update((r) => result);
  return result;
});
final navigationRestaurantProvider = StateProvider<List<Merchant>>((ref) => []);
final areaSettingsProvider = StateProvider<AreaSetting?>((ref) => null);
final addressChoiceProvider = StateProvider<List<UserAddress>?>((ref) => null);
final addressVisibilityProvider = StateProvider<bool>((ref) => false);
final cartLoadingProvider = StateProvider<bool>((ref) => false);
