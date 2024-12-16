import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/auth.dart';
import 'package:nomnom/services/data_cacher.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with ColorPalette {
  final DataCacher _cacher = DataCacher.instance;
  final AuthApi _api = AuthApi();

  Future<void> init() async {
    await Future.delayed(1500.ms);
    final String? token = _cacher.getUserToken();
    print("$token");
    if (token == null) {
      context.pushReplacement('/landing-page');
    } else {
      final UserModel? user = await _api.getUserDetails();
      print("USER : $user");
      if (user == null) {
        //go to account completion
        context.pushReplacement("/account-completion-page");
      } else {
        if (user.firstname.isEmpty ||
            user.lastname.isEmpty ||
            user.email.isEmpty ||
            (user.phoneNumber == null || user.phoneNumber!.isEmpty)) {
          context.pushReplacement("/account-completion-page", extra: user);
          return;
        }
        ref.read(addressChoiceProvider.notifier).update((r) => user.addresses);
        ref.read(currentUserProvider.notifier).update((r) => user);
        context.pushReplacement("/navigation-page");
        // go to navigation page
      }
      //go to validation page
      // context.go('/login-page');
    }
    // ignore: use_build_context_synchronously
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await init();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo-1.png",
                height: 135,
              ),
              const Gap(20),
              CustomLoader(
                color: darkGrey,
                label: "Checking data, Please wait",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
