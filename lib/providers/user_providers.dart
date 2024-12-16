import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom/models/cart/cart_model.dart';
import 'package:nomnom/models/orders/firebase_delivery_model.dart';
import 'package:nomnom/models/orders/order_model.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/services/api/auth.dart';
import 'package:nomnom/services/api/cart_api.dart';
import 'package:nomnom/services/api/order_api.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';

final currentUserProvider = StateProvider<UserModel?>((reff) => null);
final currentLocationProvider = StateProvider<UserAddress?>((ref) => null);
final selectedLocationProvider = StateProvider<UserAddress?>((ref) => null);
final currentUserCartProvider = StateProvider<List<CartModel>>((ref) => []);
final CartApi _cartApi = CartApi();
final OrderApi _orderApi = OrderApi();
final AuthApi _authApi = AuthApi();
final futureCartProvider = FutureProvider<List<CartModel>>((ref) async {
  final result = await _cartApi.get();
  ref.read(currentUserCartProvider.notifier).update((e) => result);
  return result;
});

final FirebaseFirestoreSupport _firebaseSupport = FirebaseFirestoreSupport();
// final futureActiveOrderProvider = FutureProvider<void>((ref) async {
//   final r = ref.read(activeOrderProvider);
//   if (r == null || r.isEmpty) {
//     final result = await _orderApi.activeOrders();
//     ref.read(activeOrderProvider.notifier).update((r) => result);
//     for (OrderState res in result) {
//       _firebaseSupport.updateStatus(refcode: res.reference, status: res.status);
//     }
//   }
// });
// final futureHistoryOrderProvider = FutureProvider<void>((ref) async {
//   final r = ref.read(activeOrderProvider);
//   if (r == null || r.isEmpty) {
//     final result = await _orderApi.history();
//     ref.read(historyOrderProvider.notifier).update((r) => result);
//     for (OrderState res in result) {
//       _firebaseSupport.updateStatus(refcode: res.reference, status: res.status);
//     }
//   }
// });
final activeOrdersProvider = StateProvider<List<DeliveryModel>>((ref) => []);
final pastOrdersProvider = StateProvider<List<DeliveryModel>>((ref) => []);
final clientPointProvider = StateProvider<double>((ref) => 0.0);
final futureClientPointsProvider = FutureProvider((ref) async {
  final double points = await _authApi.getPoints();
  final prov = ref.read(clientPointProvider.notifier).update((r) => points);
  return;
});
