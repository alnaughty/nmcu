import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/extensions/duration.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/auth.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/firebase/phone_auth_service.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage(
      {super.key, required this.verificationID, required this.phoneNumber});
  final String verificationID;
  final String phoneNumber;
  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage>
    with ColorPalette {
  late String verificationID = widget.verificationID;
  final OtpFieldController otpController = OtpFieldController();
  final PhoneAuthService _auth = PhoneAuthService.instance;
  final AuthApi _authApi = AuthApi();
  final DataCacher _cacher = DataCacher.instance;
  bool isLoading = false;
  Duration resendDuration = Duration(minutes: 1);
  Timer? _timer;
  void startTime() {
    _timer = Timer.periodic(1.seconds, (timer) {
      if (resendDuration.inSeconds > 0) {
        resendDuration -= 1.seconds;
        if (mounted) setState(() {});
      } else {
        timer.cancel();
      }
    });
    if (mounted) setState(() {});
  }

  void resetTimer() {
    resendDuration = Duration(minutes: 1);
    startTime();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTime();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> resend() async {
    setState(() {
      isLoading = true;
    });
    await _auth.verifyPhone(widget.phoneNumber, (newID) {
      setState(() {
        isLoading = false;
        verificationID = newID;
      });
      resetTimer();
    });
  }

  Future<void> verifyOTP(String otp) async {
    await _cacher.signInMethod(0);
    setState(() {
      isLoading = true;
    });
    final User? user =
        await _auth.verifyOTP(verificationID: verificationID, otp: otp);
    if (user == null) {
      isLoading = false;
      if (mounted) setState(() {});
      return;
    }
    final String? tok = await user.getIdToken();
    final String uid = user.uid;
    print("UID: $uid");
    if (tok == null) {
      isLoading = false;
      if (mounted) setState(() {});
      return;
    }
    await Future.wait([
      _cacher.setFirebaseToken(tok),
      _cacher.saveUID(uid),
      _cacher.signInMethod(0),
      _cacher.setLoginTypeValue(widget.phoneNumber),
    ]);
    final String? accessToken = await _authApi.signIn(tok);
    if (accessToken == null) {
      // GO TO CREATE DETAILS
      print("SHOW CREATE DETAILS");
      setState(() {
        isLoading = false;
      });
      context.go("/account-completion-page");
      // context.go("/register-details/1/${widget.phoneNumber}");
    } else {
      print(_cacher.getSignInMethod());
      _cacher.setUserToken(accessToken);
      final UserModel? user = await _authApi.getUserDetails();
      if (user == null) {
        print("SHOW CREATE DETAILS");
        setState(() {
          isLoading = false;
        });
        context.go('/account-completion-page');
        return;
      } else if (user.firstname.isEmpty ||
          user.lastname.isEmpty ||
          user.email.isEmpty ||
          (user.phoneNumber == null || user.phoneNumber!.isEmpty)) {
        context.go("/account-completion-page", extra: user);
        return;
      }
      ref.read(addressChoiceProvider.notifier).update((r) => user.addresses);
      ref.read(currentUserProvider.notifier).update((r) => user);
      context.go('/navigation-page');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: !isLoading,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                body: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(20),
                      // Center(
                      //   child: Image.asset(
                      //     "assets/images/logo-1.png",
                      //     width: size.width * .4,
                      //   ),
                      // ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter the code\nwe sent you",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(5),
                          Text(
                            "We sent it to +63${widget.phoneNumber}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      SizedBox(
                        width: double.infinity,
                        child: LayoutBuilder(builder: (context, c) {
                          return OTPTextField(
                            // onChanged: (t) {
                            //   if(t.length == 6){

                            //   }
                            //   // setState(() {
                            //   //   isComplete = t.length == 6;
                            //   //   otp = t;
                            //   // });
                            // },
                            onCompleted: (t) async {
                              print("CODE : $t");
                              setState(() {
                                isLoading = true;
                              });
                              await verifyOTP(t);
                              setState(() {
                                isLoading = false;
                              });

                              // setState(() {
                              //   isComplete = true;
                              //   otp = t;
                              // });23
                            },
                            controller: otpController,
                            length: 6,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 20),
                            fieldStyle: FieldStyle.box,
                            fieldWidth: c.maxWidth / 6.5,
                            otpFieldStyle: OtpFieldStyle(
                              enabledBorderColor: textField.darken(),
                              focusBorderColor: orangePalette,
                              backgroundColor: Colors.white,
                            ),
                            outlineBorderRadius: 6,
                          );
                        }),
                      ),
                      const Gap(10),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Resend ",
                            recognizer: TapGestureRecognizer()
                              ..onTap = resendDuration.inSeconds <= 0
                                  ? () async {
                                      print("RESEND");

                                      await resend();
                                      // await send();
                                    }
                                  : null,
                            style: TextStyle(
                              color: resendDuration.inSeconds <= 0
                                  ? orangePalette
                                  : Colors.black,
                              fontWeight: resendDuration.inSeconds <= 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    "code ${resendDuration.inSeconds > 0 ? "available in ${resendDuration.formatDuration()}" : ""}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading) ...{
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(.5),
                  child: Center(
                    child: CustomLoader(
                      label: "",
                    ),
                  ),
                ),
              )
            }
          ],
        ),
      ),
    );
  }
}
