import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page.dart';

class CartButton extends StatelessWidget {
  const CartButton(
      {super.key,
      this.mainColor = Colors.white,
      this.textColor = const Color(0xffFF9E1B)});
  final Color mainColor;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, ref, child) {
      final cartFuture = ref.watch(futureCartProvider);
      return cartFuture.when(
        data: (data) {
          //     late double subtotal = _selectedOptions
          // .map((e) => e.variation.price)
          // .fold(0.0, (sum, price) => sum + price)
          // final int itemsCount = data.any((e) => e.);
          final int itemCount = data
              .map((e) => e.items.length) // Get the count of items in each cart
              .fold(0, (sum, count) => sum + count);
          return IconButton(
              onPressed: () async {
                await Navigator.push(
                    context, MaterialPageRoute(builder: (_) => CartPage()));
              },
              icon: Badge.count(
                backgroundColor: mainColor,
                count: itemCount,
                textColor: textColor,
                child: ImageIcon(
                  AssetImage("assets/icons/bag.png"),
                  color: mainColor,
                ),
              ));
        },
        error: (error, s) => Container(),
        loading: () => IconButton(
          onPressed: () async {
            await Navigator.push(
                context, MaterialPageRoute(builder: (_) => CartPage()));
          },
          icon: Badge.count(
            backgroundColor: mainColor,
            count: 0,
            textColor: textColor,
            child: ImageIcon(
              AssetImage("assets/icons/bag.png"),
              color: mainColor,
            ),
          ),
        ),
      );
    });
  }
}
