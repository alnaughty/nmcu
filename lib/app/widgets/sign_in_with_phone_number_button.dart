import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/mixins/color_palette.dart';

// ignore: must_be_immutable
class SignInWithPhoneNumberButton extends StatelessWidget with ColorPalette {
  SignInWithPhoneNumberButton(
      {super.key, required this.onTap, required this.label});
  final Function()? onTap;
  final String label;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      color: orangePalette,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageIcon(
            AssetImage(
              "assets/icons/phone.png",
            ),
            color: Colors.white,
          ),
          const Gap(10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
