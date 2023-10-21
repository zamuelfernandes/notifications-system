import 'package:awesome_notification/main.dart';
import 'package:awesome_notification/screens/second_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class NotificationService extends ChangeNotifier {
  /// *********************************************
  ///             SINGLETON PATTERN
  /// *********************************************

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// *********************************************
  ///             OBSERVER PATTERN
  /// *********************************************

  String _firebaseToken = '';
  String get firebaseToken => _firebaseToken;

  String _nativeToken = '';
  String get nativeToken => _nativeToken;

  ReceivedAction? initialAction;

  /// ***********************************************************************///
  ///               INITIALIZATION LOCAL NOTIFICATIONS METHODS
  /// ***********************************************************************///
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  /// Use este método para detectar quando uma nova notificação ou agendamento é criado
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  /// Use este método para detectar toda vez que uma nova notificação é exibida
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  /// Use este método para detectar se o usuário dispensou uma notificação
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  /// Use este método para detectar quando o usuário toca em uma notificação ou botão de ação
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {
      MainApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => SecondScreen(dataFromNotification: payload),
        ),
      );
    } else {
      MainApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => SecondScreen(dataFromNotification: payload),
        ),
      );
    }
  }

  /// Inform the paramethers and use this method to show the notification
  /// Informe os parâmetros e use este método para mostrar a notificação
  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
              interval: interval,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }

  /// ***********************************************************************///
  ///               INITIALIZATION REMOTE NOTIFICATIONS METHODS
  /// ***********************************************************************///
  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    await Firebase.initializeApp();
    await AwesomeNotificationsFcm().initialize(
      onFcmSilentDataHandle: NotificationService.mySilentDataHandle,
      onFcmTokenHandle: NotificationService.myFcmTokenHandle,
      onNativeTokenHandle: NotificationService.myNativeTokenHandle,
      debug: debug,
    );
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  ///  *********************************************
  ///     REMOTE NOTIFICATION EVENTS
  ///  *********************************************

  /// Use this method to execute on background when a silent data arrives
  /// (even while terminated)
  /// Use este método para executar em segundo plano quando um dado silencioso chegar
  /// (mesmo quando encerrado)
  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    Fluttertoast.showToast(
      msg: 'Silent data received',
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 16,
    );

    print('"SilentData": ${silentData.toString()}');

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      print("bg");
    } else {
      print("FOREGROUND");
    }

    print('mySilentDataHandle received a FcmSilentData execution');
    await executeLongTaskInBackground();
  }

  /// Use this method to detect when a new fcm token is received
  /// Use este método para detectar quando um novo token fcm é recebido
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {
    Fluttertoast.showToast(
      msg: 'Fcm token received',
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 16,
    );
    debugPrint('Firebase Token:"$token"');

    _instance._firebaseToken = token;
    _instance.notifyListeners();
  }

  /// Use this method to detect when a new native token is received
  /// Use este método para detectar quando um novo token nativo é recebido
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    Fluttertoast.showToast(
      msg: 'Native token received',
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 16,
    );
    debugPrint('Native Token:"$token"');

    _instance._nativeToken = token;
    _instance.notifyListeners();
  }

  ///  *********************************************
  ///            BACKGROUND TASKS TEST
  ///  *********************************************

  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
    print("long task done");
  }

  ///  *********************************************
  ///           REMOTE TOKEN REQUESTS
  ///  *********************************************

  static Future<String> requestFirebaseToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        return await AwesomeNotificationsFcm().requestFirebaseAppToken();
      } catch (exception) {
        debugPrint('$exception');
      }
    } else {
      debugPrint('Firebase is not available on this project');
    }
    return '';
  }
}
