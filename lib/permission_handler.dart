import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

// Defines possible notification permission states
enum EnNotificationPermission {
  granted,
  denied,
  permanentlyDenied,
}

class PermissionHandler extends ChangeNotifier {
  // Current notification permission status
  EnNotificationPermission notificationPermission =
    EnNotificationPermission.denied;

  // Retrieves current notification permission status from the system
  Future<EnNotificationPermission> getNotificationPermission() async {
    var status = await Permission.notification.status;
    return convertStatus(status);
  }

  // Checks and updates notification permission status, notifying listeners of changes
  Future checkNotificationPermission() async {
    notificationPermission = await getNotificationPermission();
    notifyListeners();
  }
  
  // Converts system permission status to our custom enum type
  EnNotificationPermission convertStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return EnNotificationPermission.granted;
      case PermissionStatus.denied:
        return EnNotificationPermission.denied;
      case PermissionStatus.permanentlyDenied:
        return EnNotificationPermission.permanentlyDenied;
      default:
        return EnNotificationPermission.denied;
    }
  }
}