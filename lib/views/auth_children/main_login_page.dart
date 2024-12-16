import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/routes.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/login_with_soc_med.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/auth.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/firebase/phone_auth_service.dart';

class MainLoginPage extends ConsumerStatefulWidget {
  const MainLoginPage({super.key});

  @override
  ConsumerState<MainLoginPage> createState() => _MainLoginPageState();
}

class _MainLoginPageState extends ConsumerState<MainLoginPage>
    with ColorPalette {
  static final PhoneAuthService _auth = PhoneAuthService.instance;
  final TextEditingController _controller = TextEditingController();

  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  final AuthApi _authApi = AuthApi();
  final DataCacher _cacher = DataCacher.instance;
  bool isLoading = false;
  Future<void> login(User user, int signInMethod) async {
    setState(() {
      isLoading = true;
    });
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
      _cacher.signInMethod(signInMethod),
      if (user.email != null) ...{
        _cacher.setLoginTypeValue(user.email!),
      }
    ]);
    final String? accessToken = await _authApi.signIn(tok);
    if (accessToken == null) {
      // GO TO CREATE DETAILS
      print("SHOW CREATE DETAILS");
      setState(() {
        isLoading = false;
      });
      context.go('/account-completion-page');
      // context.go("/register-details/1/${widget.phoneNumber}");
    } else {
      // _cacher.signInMethod(1);
      _cacher.setUserToken(accessToken);
      final UserModel? user = await _authApi.getUserDetails();
      if (user == null) {
        print("SHOW CREATE DETAILS");
        setState(() {
          isLoading = false;
        });
        context.go('/account-completion-page', extra: user);
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
      // ignore: use_build_context_synchronously
      context.go('/navigation-page');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                body: SizedBox(
                  width: double.infinity,
                  child: SafeArea(
                    bottom: false,
                    child: Form(
                      key: _kForm,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Gap(60),
                            Image.asset(
                              "assets/images/logo-1.png",
                              height: 120,
                            ),
                            const Gap(60),
                            Column(
                              children: [
                                Text(
                                  "Welcome back!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600),
                                ),
                                // const Gap(10),
                                Text(
                                  "Login using your phone number",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            const Gap(20),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (text) => text == null || text.isEmpty
                                  ? "Field cannot be empty"
                                  : !text.isValidPhoneNumber()
                                      ? "Must be a valid phone number"
                                      : null,
                              controller: _controller,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                  hintText: "Enter your number",
                                  hintStyle: TextStyle(
                                      color:
                                          Colors.grey.shade800.withOpacity(.4)),
                                  labelText: "Phone number",
                                  prefix: Padding(
                                    padding: const EdgeInsets.only(right: 7),
                                    child: Text("+63"),
                                  ),
                                  prefixStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                            const Gap(20),
                            MaterialButton(
                              height: 50,
                              color: orangePalette,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onPressed: () async {
                                if (_kForm.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await _auth.verifyPhone(
                                    _controller.text,
                                    (id) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      print("vID $id");
                                      context.push(
                                        "/main-login-page/otp-verification-page/$id/${_controller.text}",
                                      );
                                    },
                                  );
                                }
                              },
                              child: Center(
                                child: Text(
                                  "Log in",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            const Gap(20),
                            LoginWithSocMed(
                              onUserCallback: (user, type) async {
                                //0 = phone
                                //1 = google
                                //2 = apple
                                //3 = facebook
                                await login(user, type);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
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
            ))
          },
        ],
      ),
    );
  }
}
