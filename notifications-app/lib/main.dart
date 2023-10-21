import 'package:awesome_notification/firebase_options.dart';
import 'package:awesome_notification/screens/local_screen.dart';
import 'package:awesome_notification/screens/realtime_screen.dart';
import 'package:awesome_notification/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/remote_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initializeNotification();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  List<Widget> bodyViews = const [
    RemoteScreen(),
    LocalScreen(),
    RealTimeScreen(),
  ];

  @override
  void initState() {
    NotificationService.startListeningNotificationEvents();
    NotificationService.requestFirebaseToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MainApp.navigatorKey,
      title: 'Awesome Notification Demo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        body: bodyViews[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(
              () {
                _currentIndex = index;
              },
            );
          },
          items: const [
            BottomNavigationBarItem(
              label: 'Remote',
              icon: Icon(Icons.wifi),
            ),
            BottomNavigationBarItem(
              label: 'Local',
              icon: Icon(Icons.smartphone),
            ),
            BottomNavigationBarItem(
              label: 'RealTime',
              icon: Icon(Icons.repeat_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
