import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/services/firebase/apple_auth_service.dart';
import 'package:nomnom/services/firebase/facebook_auth_service.dart';
import 'package:nomnom/services/firebase/google_auth_service.dart';

class LoginWithSocMed extends StatelessWidget {
  const LoginWithSocMed({super.key, required this.onUserCallback});
  final Function(User, int) onUserCallback;
  static final GoogleAuthService _google = GoogleAuthService.instance;
  static final AppleAuthService _apple = AppleAuthService.instance;
  static final FacebookAuthService _facebook = FacebookAuthService.instance;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
            const Gap(10),
            Text(
              "or login using",
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey.shade400),
            ),
            const Gap(10),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
        const Gap(15),
        //0 = phone
        //1 = google
        //2 = apple
        //3 = facebook
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            button(
              () async {
                final user = await _apple.signIn();
                if (user != null) {
                  print("SIGN IN!");
                  onUserCallback(user, 2);
                }
              },
              label: "Apple ID",
              assetPath: "assets/icons/apple.png",
            ),
            button(() async {
              final user = await _google.signIn();
              if (user != null) {
                onUserCallback(user, 1);
              }
            }, label: "Google", assetPath: "assets/icons/google.png"),
            button(() async {
              final user = await _facebook.signIn();
              if (user != null) {
                onUserCallback(user, 3);
              }
            }, label: "Facebook", assetPath: "assets/icons/facebook.png")
            // MaterialButton(
            //   shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(6),
            //       side: BorderSide(
            //         color: Colors.grey.shade400,
            //       )),
            //   onPressed: () {},
            //   height: 50,
            //   child: Row(
            //     children: [
            //       ImageIcon(
            //         AssetImage(
            //           "assets/icons/apple.png",
            //         ),
            //       ),
            //       const Gap(10),
            //       Text(
            //         "Apple ID",
            //         style: TextStyle(fontWeight: FontWeight.w500),
            //       )
            //     ],
            //   ),
            // )
            // TextButton.icon(
            //   onPressed: () {},
            //   label: Text("Apple ID"),
            //   icon: ImageIcon(AssetImage("assets/icons/apple.png")),
            // ),
          ],
        )
      ],
    );
  }

  button(Function() onTap,
          {required String label, required String assetPath}) =>
      MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: Colors.grey.shade400,
            )),
        onPressed: onTap,
        height: 50,
        child: Row(
          children: [
            Image.asset(
              assetPath,
              width: 20,
              height: 20,
            ),
            // ImageIcon(
            //   AssetImage(
            //     assetPath,
            //   ),
            // ),
            const Gap(5),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            )
          ],
        ),
      );
}
