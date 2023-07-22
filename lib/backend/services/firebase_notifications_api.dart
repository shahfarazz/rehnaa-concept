import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.defaultImportance,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future initLocalNotifications() async {
    // const iOS = IOSInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/launcher_icon');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(settings);

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!;

    await platform.createNotificationChannel(_androidChannel);
  }

  //create a function that takes message as input and uses _localNotifications to show the notification
  Future showNotification({required String title, required String body}) async {
    await _localNotifications.show(
      title.hashCode, // using the hashcode of the title as notification id
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@drawable/launcher_icon',
        ),
      ),
    );
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((event) {
      final notification = event.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/launcher_icon',
          ),
        ),
        payload: jsonEncode(event.toMap()),
      );
    });

    // FirebaseMessaging.instance.getInitialMessage().then()
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token is $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    await initPushNotifications();
    await initLocalNotifications();
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
  print('message title is ${message.notification!.title}');
  print('message body is ${message.notification!.body}');
  print('payload is ${message.data}');
}
