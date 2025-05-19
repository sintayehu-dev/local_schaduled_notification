import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

/// Class that handles all local notification functionality
class LocalNotification {
  /// Plugin instance for managing local notifications
  static final _flutterLocalNotificationsPlugin =
           FlutterLocalNotificationsPlugin();
  
  /// Initializes the notification plugin with platform-specific settings
  static Future<void> initialize() async {
    // Configure Android notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configure iOS notification settings
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine platform-specific settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: iosInitializationSettings);

    // Initialize the plugin with settings
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));
  }

  /// Sends an immediate notification with predefined content
  static Future sendNotification() async {
    // Configure Android-specific notification details
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'channelDescription',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      ticker: 'ticker',
    );

    // Create cross-platform notification details
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // Display the notification
    await _flutterLocalNotificationsPlugin.show(
      0,
      'title',
      'body',
      notificationDetails,
      payload: 'item x',
    );
  }

  /// Requests permission to show notifications on the appropriate platform
  static Future<bool?> requestPermission() async {
    if (Platform.isIOS) {
      // Request iOS-specific permissions
      return await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      // Request Android notification permissions
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return null;
    }
    return null;
  }

  static Future scheduleNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'channelDescription',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();
    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'title',
      'body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
static Future<bool?> requestExactAlarmsPermission() async {
    if (Platform.isIOS) {
      // Request iOS-specific permissions
      return true;
    }
    else if (Platform.isAndroid) {
      // Request Android notification permissions
      await _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestExactAlarmsPermission();
    }
    return null;
  }

  static Future startPeriodicNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'periodic_channel_id',
      'periodic_channel_name',
      channelDescription: 'periodic_channel_description',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();
    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      4,
      'this is a periodic notification',
      'this is a periodic notification body',
      RepeatInterval.everyMinute,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );  
  }
  static Future stopPeriodicNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
  
