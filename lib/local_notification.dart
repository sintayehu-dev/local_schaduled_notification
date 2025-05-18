import 'package:flutter/material.dart';
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
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
        );

    // Combine platform-specific settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: iosInitializationSettings);

    // Initialize the plugin with settings
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
    }
    else if (Platform.isAndroid) {
      // Request Android notification permissions
      await _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
      return null;
    }
    return null;
  }
}