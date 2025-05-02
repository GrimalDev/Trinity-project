import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/config/routes.dart';

import 'package:trinity/utils/api/push_notifications.dart';
import '../firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Background message: ${message.notification?.title}");
}

Future<void> initFirebase(context) async {
  debugPrint("Initializing Firebase");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Firebase initialized");

  var skipToken = false;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    debugPrint("Notification permission denied");
    skipToken = true;
  } else {
    debugPrint("Notification permission granted");
  }

  if (Platform.isIOS && !skipToken) {
    String? apnsToken = await messaging.getAPNSToken();
    if (apnsToken == null) {
      debugPrint("APNs Token is not set");
      skipToken = true;
    } else {
      debugPrint("APNs Token: $apnsToken");
    }
  }

  if (!skipToken) {
    String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      debugPrint("FCM Token: $fcmToken");
      sendTokenToBackend(fcmToken);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message: ${message.notification?.title}");
      if (message.notification != null) {
        debugPrint("Notification body: ${message.notification?.body}");
      }

      ShadToaster.of(context).show(
        ShadToast(
          title: Text(
            message.notification?.title ?? 'Nouvelle Promotion!',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          description: Text(
            message.notification?.body ?? 'Découvrez nos nouvelles offres!',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          radius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.shade400, width: 1),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          duration: const Duration(seconds: 4),
          action: ShadButton.outline(
            child: Text('Voir'),
            onPressed: () {
              AppRoutes.of(context).navigateTo(AppRoutes.home);
            },
          ),
          closeIcon: const Icon(Icons.close, size: 18, color: Colors.white70),
          showCloseIconOnlyWhenHovered: false,
          alignment: Alignment.topCenter,
          offset: const Offset(0, 20),
        ),
      );
    });
  }
}
