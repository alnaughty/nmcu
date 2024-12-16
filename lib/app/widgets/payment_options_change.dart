import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PaymentOptionsChange extends StatelessWidget {
  const PaymentOptionsChange(
      {super.key,
      required this.initialOption,
      required this.newOptionCallback});
  final int initialOption;
  final ValueChanged<int> newOptionCallback;
  static final List<Map<String, dynamic>> contents = [
    {
      "leading": Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFFFF9E1B),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: ImageIcon(
            AssetImage("assets/icons/wallet.png"),
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      "title": "Cash On Delivery",
      "subtitle": "Pay when order arrives",
    },
    {
      "leading": Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFFFF9E1B),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: ImageIcon(
            AssetImage("assets/icons/card.png"),
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      "title": "Online Payment",
      "subtitle": "Pay immediately, hassle-free",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.all(15),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),
              const Gap(20),
              Center(
                  child: Text(
                "Payment method",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              )),
              Divider(),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  final Map<String, dynamic> item = contents[i];
                  return InkWell(
                    onTap: () {
                      newOptionCallback(i);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        item['leading'],
                        const Gap(15),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              item['subtitle'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFABABAB)),
                            ),
                          ],
                        )),
                        const Gap(5),
                        Row(
                          children: [
                            if (initialOption == i) ...{
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Color(0xFFE1E1E1),
                                ),
                                child: Text(
                                  "Current Method",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            }
                          ],
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, i) => const Gap(5),
                itemCount: contents.length,
              )
            ],
          ),
        ),
      ),
    );
  }
}
