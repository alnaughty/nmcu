import 'package:flutter/material.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/cart_menu_listing.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/checkout_page_children/for_a_friend_page.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/checkout_page_children/place_order_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.data});
  final CheckoutData data;
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.data.isForFriend) {
      return PlaceOrderForFriendPage(data: widget.data);
    } else {
      return PlaceOrderPage(data: widget.data);
    }
    // return Padding(
    //   padding: const EdgeInsets.all(20),
    //   child: Column(
    //     children: [],
    //   ),
    // );
  }
}
