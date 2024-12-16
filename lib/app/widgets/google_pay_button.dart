import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pay/pay.dart';

class CustomGooglePayButton extends StatefulWidget {
  const CustomGooglePayButton(
      {super.key,
      required this.merchantName,
      required this.total,
      required this.onResult});
  final String merchantName;
  final double total;
  final ValueChanged<Map<String, dynamic>> onResult;
  @override
  State<CustomGooglePayButton> createState() => _CustomGooglePayButtonState();
}

class _CustomGooglePayButtonState extends State<CustomGooglePayButton> {
  String? jsonCredentials;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      jsonCredentials = await rootBundle.loadString("gpay.json");
      setState(() {});
    });
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
    if (jsonCredentials == null) {
      return Container();
    }
    return GooglePayButton(
      height: 50,
      width: double.infinity,
      onPaymentResult: widget.onResult,
      paymentConfiguration:
          PaymentConfiguration.fromJsonString(jsonCredentials!),
      paymentItems: [
        PaymentItem(
          type: PaymentItemType.total,
          label: "Nom Nom Delivery App",
          amount: widget.total.toStringAsFixed(2),
          status: PaymentItemStatus.final_price,
        )
      ],
    );

    // return FutureBuilder(
    //     future: rootBundle.loadString("gpay.json"),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasError || !snapshot.hasData) {
    //         print(snapshot);
    //         return Container();
    //       }
    // return GooglePayButton(
    //   height: 50,
    //   width: double.infinity,
    //   onPaymentResult: widget.onResult,
    //   paymentConfiguration:
    //       PaymentConfiguration.fromJsonString(snapshot.data!),
    //   paymentItems: [
    //     PaymentItem(
    //       type: PaymentItemType.total,
    //       label: "Nom Nom Delivery App",
    //       amount: widget.total.toStringAsFixed(2),
    //       status: PaymentItemStatus.final_price,
    //     )
    //   ],
    // );
    //     });
    // return GooglePayButton(
    //   paymentConfiguration: null,
    //   paymentItems: [],
    // );
  }
}
