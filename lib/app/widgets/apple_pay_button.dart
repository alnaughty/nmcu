import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:pay/pay.dart';

class CustomApplePayButton extends StatefulWidget {
  const CustomApplePayButton(
      {super.key,
      required this.merchantName,
      required this.total,
      required this.items,
      required this.onResult});
  final String merchantName;
  final List<PaymentItem> items;
  final double total;
  final Function(Map<String, dynamic>) onResult;
  @override
  State<CustomApplePayButton> createState() => _CustomApplePayButtonState();
}

class _CustomApplePayButtonState extends State<CustomApplePayButton> {
  // late final PaymentItem item = PaymentItem(
  //     type: PaymentItemType.total,
  //     label: "Nom Nom Delivery App",
  //     amount: widget.total.toStringAsFixed(2),
  //     status: PaymentItemStatus.final_price);

  @override
  void initState() {
    //  final jsonCredentials =
    //     await rootBundle.loadString('send-message-prereq.json');
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: rootBundle.loadString("apay.json"),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Container();
          }
          return Center(
            child: ApplePayButton(
              loadingIndicator: CustomLoader(
                label: "Waiting for payment",
              ),
              width: size.width,
              height: 50,
              cornerRadius: 6,
              onPaymentResult: widget.onResult,
              paymentConfiguration:
                  PaymentConfiguration.fromJsonString(snapshot.data!),
              paymentItems: widget.items,
            ),
          );
        });
    // return ApplePayButton(
    //   paymentConfiguration: null,
    //   paymentItems: [],
    // );
  }
}
