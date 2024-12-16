import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/views/landing_children/video_player.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: NomNomVideoPlayer(),
              // child: Image.asset(
              //   "assets/images/landing_background.png",
              //   fit: BoxFit.cover,
              // ),
            ),
            Positioned.fill(
                child: Container(
              color: Colors.black.withOpacity(.3),
            )),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      height: 65,
                    ),
                    const Gap(20),
                    Text(
                      "We Deliver your\nCravings".capitalizeWords(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Column(
                    children: [
                      MaterialButton(
                        height: 50,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        color: Colors.white,
                        onPressed: () {
                          context.go("/main-login-page");
                        },
                        child: Center(
                          child: Text(
                            "Get Started",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      // const Gap(10),
                      // MaterialButton(
                      //   onPressed: () {},
                      //   color: Colors.transparent,
                      //   elevation: 0,
                      //   height: 50,
                      //   shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(6),
                      //       side: BorderSide(
                      //         color: Colors.white,
                      //       )),
                      //   child: Center(
                      //     child: Text(
                      //       "Sign up",
                      //       style: TextStyle(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w500),
                      //     ),
                      //   ),
                      // ),
                      // const Gap(10),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            "© Nomnom 2024 - Help & Support",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ))
                      // Text("© Nomnom 2024 - Help & Support")
                    ],
                  ),
                ),
              ),
            )
            // Positioned.fill(
            //   child: Column(
            //     children: [
            //       Container()
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
