import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:nomnom/app/routes.dart';
import 'package:nomnom/app/widgets/picker_pin.dart';
import 'package:nomnom/views/splash_screen.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  @override
  // ignore: library_private_types_in_public_api
  RestartWidgetState createState() => RestartWidgetState();
}

class RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  Future<void> restartApp() async {
    // await Future.delayed(600.ms);
    setState(() {
      key = UniqueKey(); // Forces the widget tree to rebuild.
    });
    // Navigate to the root by replacing the current route
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Navigator.of(context, rootNavigator: true).pushReplacement(
    //     MaterialPageRoute(builder: (context) => widget.child),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
