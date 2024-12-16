import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/services/network.dart';

class LocalNotificationViewer with ColorPalette, Network {
  LocalNotificationViewer._singleton();
  static final LocalNotificationViewer _instance =
      LocalNotificationViewer._singleton();
  static LocalNotificationViewer get instance => _instance;

  void showMessage(
    BuildContext context, {
    Duration duration = const Duration(seconds: 10),
    required String title,
    required String subtitle,
    String? link,
    Function()? onTap,
  }) async {
    InAppNotification.show(
      onTap: onTap,
      duration: duration,
      child: SafeArea(
        child: Container(
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(
            20,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: darkGrey.withOpacity(.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      context: context,
    );
  }
}
