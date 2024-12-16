import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';
import 'package:nomnom/views/navigation_children/drawer_children/orders_page.dart';
import 'package:nomnom/views/navigation_children/drawer_children/personal_information_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_app/restart_app.dart';

class DrawerContent {
  final String title;
  final Widget icon;
  final Widget? subtitle;
  final Function()? onTap;
  const DrawerContent({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.subtitle,
  });
}

class DrawerDisplay extends ConsumerStatefulWidget {
  const DrawerDisplay({super.key});

  @override
  ConsumerState<DrawerDisplay> createState() => _DrawerDisplayState();
}

class _DrawerDisplayState extends ConsumerState<DrawerDisplay>
    with ColorPalette {
  final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();
  final DataCacher _cacher = DataCacher.instance;
  Future<String> fetchAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "Version: ${packageInfo.version}";
  }

  late final List<DrawerContent> _content = [
    DrawerContent(
      title: "Orders",
      icon: ImageIcon(
        AssetImage("assets/icons/receipt.png"),
        size: 22,
        color: orangePalette,
      ),
      onTap: () async {
        await Navigator.push(
          context,
          PageRouteBuilder(pageBuilder: (context, a1, a2) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = a1.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: OrdersPage(),
            );
          }),
        );
      },
      subtitle: null,
    ),
    DrawerContent(
      title: "Personal Information",
      icon: ImageIcon(
        AssetImage("assets/icons/person.png"),
        size: 22,
        color: orangePalette,
      ),
      onTap: () async {
        await Navigator.push(
          context,
          PageRouteBuilder(pageBuilder: (context, a1, a2) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = a1.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: PersonalInformationPage(),
            );
          }),
        );
      },
      subtitle: null,
    ),
    DrawerContent(
      title: "Address",
      icon: ImageIcon(
        AssetImage("assets/icons/location.png"),
        size: 22,
        color: orangePalette,
      ),
      onTap: () {},
      subtitle: null,
    ),
    DrawerContent(
        title: "Notification",
        icon: Icon(
          Icons.notifications,
          color: orangePalette,
          size: 22,
        ),
        onTap: () {},
        subtitle: null),
    // DrawerContent(
    //   title: "Help & Support",
    //   icon: ImageIcon(
    //     AssetImage("assets/icons/customer_support.png"),
    //     size: 20,
    //     color: orangePalette,
    //   ),
    //   onTap: () {},
    //   subtitle: null,
    // ),
    DrawerContent(
      title: "About",
      icon: Icon(
        Icons.info,
        size: 22,
        color: orangePalette,
      ),
      // icon: ImageIcon(
      //   AssetImage("assets/icons/customer_support.png"),
      //   size: 20,
      //   color: orangePalette,
      // ),
      onTap: () {},
      subtitle: FutureBuilder(
        future: fetchAppVersion(),
        builder: (_, snapshot) => snapshot.hasData
            ? Text(
                snapshot.data ?? "No data",
                style: TextStyle(
                  fontSize: 12,
                  color: grey,
                ),
              )
            : Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 12,
                  color: grey,
                ),
              ),
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final points = ref.watch(clientPointProvider);
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: CustomLoader(
            color: darkGrey,
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: orangePalette,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/vector_background.png",
                    fit: BoxFit.cover,
                    color: Colors.white.withOpacity(.5),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: currentUser.profilePic,
                                fit: BoxFit.cover,
                                height: 60,
                                width: 60,
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser.fullname.capitalizeWords(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  currentUser.email,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: points.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: " nom nom coins",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ))
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: _content
                    .map((e) => InkWell(
                          onTap: e.onTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                e.icon,
                                const Gap(10),
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (e.subtitle != null) ...{
                                      const Gap(5),
                                      e.subtitle!
                                    },
                                  ],
                                ))
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  MaterialButton(
                    height: 50,
                    color: Colors.transparent,
                    elevation: 0,
                    onPressed: () async {
                      final currentUser = ref.watch(currentUserProvider);
                      if (currentUser == null) return;
                      final token = _cacher.getFcmToken();
                      if (token != null) {
                        await _firestore.removeToken(currentUser.id, token);
                      }
                      // _firestore.removeToken(id, token);
                      await _cacher.logout();
                      // print("LOGOUT");
                      // // context.pushReplacement("/");
                      // // RestartWidget.restartApp()
                      // // ignore: use_build_context_synchronously
                      // // RestartWidget.rebirth(context);
                      await Restart.restartApp();
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: orangePalette,
                          ),
                          const Gap(10),
                          Text("Logout")
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
