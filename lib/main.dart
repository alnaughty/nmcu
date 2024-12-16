import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:nomnom/app/widgets/restart_widget.dart';
import 'package:nomnom/firebase_options.dart';
import 'package:nomnom/nomnom_app.dart';
import 'package:nomnom/services/data_cacher.dart';

final GlobalKey<RestartWidgetState> restartKey =
    GlobalKey<RestartWidgetState>();
void main() async {
  final DataCacher _cacher = DataCacher.instance;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _cacher.init();
  await dotenv.load();
  runApp(
    RestartWidget(
      key: restartKey,
      child: ProviderScope(
        child: InAppNotification(child: NomnomApp()),
      ),
    ),
  );
}
