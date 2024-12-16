import 'package:flutter/material.dart';
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/routes.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ignore: must_be_immutable
class NomnomApp extends StatelessWidget with ColorPalette {
  NomnomApp({super.key});
  static final RouteConfig _config = RouteConfig.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Nom Nom Delivery",
      debugShowCheckedModeBanner: false,
      routerConfig: _config.router,
      localizationsDelegates: const [
        EasyDateTimelineLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale("en", 'PH'), Locale("fil", 'PH')],
      theme: ThemeData(
        fontFamily: "Poppins",
        datePickerTheme: const DatePickerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        buttonTheme: ButtonThemeData(
            buttonColor: orangePalette,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            )),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black.withOpacity(.2),
          ),
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: textField.darken(),
              width: 1,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: textField.darken(),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: textField.darken(),
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: orangePalette),
        scaffoldBackgroundColor: scaffoldColor,
        secondaryHeaderColor: green,
      ),
    );
  }
}
