import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/routes/route.gr.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/service_locator.dart';
import 'package:handyman/core/utils.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:handyman/domain/services/messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagingServiceImpl implements MessagingService {
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  MessagingServiceImpl._() {
    _initPlugins();
  }

  // Creates an instance of the class and initializes plugins
  static MessagingServiceImpl get instance => MessagingServiceImpl._();

  static void _initPlugins() async {
    // initialise the plugin. `logo_colored` needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('logo_colored');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onSelectNotification: _selectNotification);

    // Request notification permissions
    final msgService = sl.get<FirebaseMessaging>();
    msgService.requestNotificationPermissions(const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: true));
    msgService.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      debugPrint("Settings registered: $settings");
    });
    final token = await msgService.getToken();
    debugPrint("MessagingServiceImpl._initPlugins: Token => $token");

    var prefsProvider = PrefsProvider.instance;
    debugPrint("User id => ${prefsProvider.userId}");
    var dataService = sl.get<DataService>();
    var currentUser = prefsProvider.userType == kCustomerString
        ? await dataService.getCustomerById(id: prefsProvider.userId)?.first
        : await dataService.getArtisanById(id: prefsProvider.userId)?.first;
    if (currentUser != null) {
      debugPrint("User => ${currentUser?.user}");

      // Update user token
      var updatedUser = currentUser.user.copyWith(token: token);
      debugPrint(
          "MessagingServiceImpl._initPlugins: Updated user => $updatedUser");
      await dataService.updateUser(currentUser);
    }

    // FIXME: Failed to push notification when sent from console
    // Configure messaging
    msgService.configure(
      // onBackgroundMessage: (Map<String, dynamic> message) async {
      //   debugPrint("onBackgroundMessage: $message");
      // },
      onMessage: (Map<String, dynamic> message) async {
        // final notification = message["notification"];
        debugPrint("onMessage: $message");
        // final title = notification["title"];
        // final body = notification["body"];
        // showNotification(
        //   title: notification["title"],
        //   body: notification["body"],
        //   payload: notification["data"]?.toString(),
        // );
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        debugPrint("onResume: $message");
      },
    );
  }

  @override
  void showNotification(
      {String title,
      String body,
      String channel = NotificationUtils.BOOKING_CHANNEL,
      dynamic payload}) async {
    // get user login state
    var preferences = await sl.getAsync<SharedPreferences>();
    final isLoggedIn = preferences.getString(PrefsUtils.USER_ID) != null;

    if (isLoggedIn) {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel,
        channel,
        channel == NotificationUtils.BOOKING_CHANNEL
            ? 'Get booking request notifications'
            : 'Conversation notifications',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: jsonEncode(
          NotificationPayload(
              payload?.toJson(),
              channel == NotificationUtils.BOOKING_CHANNEL
                  ? PayloadType.BOOKING
                  : PayloadType.CONVERSATION),
        ),
      );
    }
  }

  static Future _selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    // Send user to notifications page
    ExtendedNavigator.root.push(
      Routes.notificationPage,
      arguments: NotificationPageArguments(
        payload: NotificationPayload.fromJson(jsonDecode(payload)),
      ),
    );
  }

  static Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    debugPrint("_onDidReceiveLocalNotification => $title");
  }

  @override
  Future<bool> getNotificationPermissions() async =>
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
}
