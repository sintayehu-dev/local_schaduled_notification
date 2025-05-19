import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'local_notification.dart';
import 'permission_handler.dart';

// Entry point of the application, initializes notifications and providers
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotification.initialize();
  runApp(ChangeNotifierProvider(
    create: (context) => PermissionHandler(),
    child: const MyApp(),
  ));
}

// Main application widget that sets up theme and home page
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Notification',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

// Stateful widget for the home page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late PermissionHandler permissionHandler;
  bool initialized = false;
  
  // Returns button text based on current notification permission status
  String getSimpleNotificationText() {
    if (permissionHandler.notificationPermission == EnNotificationPermission.granted) {
    return "send simple notification";
    }
    else if(permissionHandler.notificationPermission == EnNotificationPermission.denied) {
      return "request notification permission";
    }

    else if(permissionHandler.notificationPermission == EnNotificationPermission.permanentlyDenied) {
      return "permanently denied please go to settings and enable notification permission";
    }
    else {
      return "";
    }
  }

  // Handles button click actions based on current permission status
  Future<void> simpleNotificationButtonAction() async {
    if (permissionHandler.notificationPermission == EnNotificationPermission.granted) {
      await LocalNotification.sendNotification();
    }
    else if(permissionHandler.notificationPermission == EnNotificationPermission.denied) {
      await LocalNotification.requestPermission();
      await permissionHandler.checkNotificationPermission();
    }
    else if(permissionHandler.notificationPermission == EnNotificationPermission.permanentlyDenied) {
     openAppSettings();
     await permissionHandler.checkNotificationPermission();
    }
  }

    // Returns button text based on current notification permission status
  String getScheduledNotificationText() {
    // Check notification permission
    if (permissionHandler.notificationPermission == EnNotificationPermission.permanentlyDenied ||
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.permanentlyDenied) {
      return "permanently denied please go to settings and enable notification permission";
    }
    
    // Check if permissions are denied but can be requested
    if (permissionHandler.notificationPermission == EnNotificationPermission.denied ||
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.denied) {
      return "request notification permission";
    }
    
    // All permissions granted
    if (permissionHandler.notificationPermission == EnNotificationPermission.granted &&
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.granted) {
      return "send scheduled notification";
    }
    
    return "";
  }

  // Handles button click actions based on current permission status
  Future<void> scheduledNotificationButtonAction() async {
    // Check both required permissions
    bool notificationPermissionGranted = 
        permissionHandler.notificationPermission == EnNotificationPermission.granted;
    bool exactAlarmPermissionGranted = 
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.granted;
    
    if (notificationPermissionGranted && exactAlarmPermissionGranted) {
      // Both permissions granted, send notification
      await LocalNotification.scheduleNotification();
      return;
    }
    
    // Request any missing permissions
    if (!notificationPermissionGranted &&
        permissionHandler.notificationPermission != EnNotificationPermission.permanentlyDenied) {
      await LocalNotification.requestPermission();
    }
    
    if (!exactAlarmPermissionGranted &&
        permissionHandler.exactAlarmsPermission != EnNotificationPermission.permanentlyDenied) {
      await LocalNotification.requestExactAlarmsPermission();
    }
    
    // If any permission is permanently denied, open settings
    if (permissionHandler.notificationPermission == EnNotificationPermission.permanentlyDenied ||
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.permanentlyDenied) {
      openAppSettings();
    }
    
    // Refresh permissions after requests
    await permissionHandler.checkNotificationPermission();
  }

    // Returns button text based on current notification permission status
  String getPeriodicNotificationText() {
    // Check notification permission
    if (permissionHandler.notificationPermission == EnNotificationPermission.permanentlyDenied ||
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.permanentlyDenied) {
      return "permanently denied please go to settings and enable notification permission";
    }
    
    // Check if permissions are denied but can be requested
    if (permissionHandler.notificationPermission == EnNotificationPermission.denied ||
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.denied) {
      return "request notification permission";
    }
    
    // All permissions granted
    if (permissionHandler.notificationPermission == EnNotificationPermission.granted &&
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.granted) {
      return "start periodic notification";
    }
    
    return "";
  }

  // Handles button click actions based on current permission status
  Future<void> periodicNotificationButtonAction() async {
    // Check both required permissions
    bool notificationPermissionGranted = 
        permissionHandler.notificationPermission == EnNotificationPermission.granted;
    bool exactAlarmPermissionGranted = 
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.granted;
    
    if (notificationPermissionGranted && exactAlarmPermissionGranted) {
      // Both permissions granted, send notification
      await LocalNotification.startPeriodicNotification();
      return;
    }
    
    // Request any missing permissions
    if (!notificationPermissionGranted &&
        permissionHandler.notificationPermission != EnNotificationPermission.permanentlyDenied) {
      await LocalNotification.requestPermission();
    }
    
    if (!exactAlarmPermissionGranted &&
        permissionHandler.exactAlarmsPermission != EnNotificationPermission.permanentlyDenied) {
      await LocalNotification.requestExactAlarmsPermission();
    }
    
    // If any permission is permanently denied, open settings
    if (permissionHandler.notificationPermission == EnNotificationPermission.permanentlyDenied ||
        permissionHandler.exactAlarmsPermission == EnNotificationPermission.permanentlyDenied) {
      openAppSettings();
    }
    
    // Refresh permissions after requests
    await permissionHandler.checkNotificationPermission();
  }

  // Initializes state and sets up lifecycle observer
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // Cleans up resources when state is disposed
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Initializes permission handler from provider
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized == false) {
      permissionHandler = Provider.of<PermissionHandler>(context);
      initialized = true;
    }
  }
  
  // Checks notification permissions when app resumes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      permissionHandler.checkNotificationPermission();
    }
  }

  // Builds the UI with notification button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Local Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Simple Notification'),
            ElevatedButton(
              onPressed: () async {
                await simpleNotificationButtonAction();
              },
              child: Text(getSimpleNotificationText()),
            ),
             ElevatedButton(
              onPressed: () async {
                await scheduledNotificationButtonAction();
              },
              child: Text(getScheduledNotificationText()),
            ),
            ElevatedButton(
              onPressed: () async {
                await periodicNotificationButtonAction();
              },
              child: Text(getPeriodicNotificationText()),
            ),
            ElevatedButton(
              onPressed: () async {
                await LocalNotification.stopPeriodicNotification();
              },
              child: Text("stop periodic notification"),
            ),
          ],
        ),
      ),
    );
  }
}
