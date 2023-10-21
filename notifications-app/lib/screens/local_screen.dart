import 'package:awesome_notification/services/notification_service.dart';
import 'package:awesome_notification/widgets/notification_button.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class LocalScreen extends StatelessWidget {
  const LocalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Notification'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NotificationButton(
            text: "Normal Notification",
            onPressed: () async {
              await NotificationService.showNotification(
                title: "Title of the notification",
                body: "Body of the notification",
              );
            },
          ),
          NotificationButton(
            text: "Notification With Summary",
            onPressed: () async {
              await NotificationService.showNotification(
                title: "Title of the notification",
                body: "Body of the notification",
                summary: "Small Summary",
                notificationLayout: NotificationLayout.Inbox,
              );
            },
          ),
          NotificationButton(
            text: "Progress Bar Notification",
            onPressed: () async {
              await NotificationService.showNotification(
                title: "Title of the notification",
                body: "Body of the notification",
                summary: "Small Summary",
                notificationLayout: NotificationLayout.ProgressBar,
              );
            },
          ),
          NotificationButton(
            text: "Message Notification",
            onPressed: () async {
              await NotificationService.showNotification(
                title: "Title of the notification",
                body: "Body of the notification",
                summary: "Small Summary",
                notificationLayout: NotificationLayout.Messaging,
              );
            },
          ),
          NotificationButton(
            text: "Big Image Notification",
            onPressed: () async {
              await NotificationService.showNotification(
                title: "Title of the notification",
                body: "Body of the notification",
                summary: "Small Summary",
                notificationLayout: NotificationLayout.BigPicture,
                bigPicture:
                    "https://files.tecnoblog.net/wp-content/uploads/2019/09/emoji.jpg",
              );
            },
          ),
          NotificationButton(
            text: "Action Buttons Notification",
            onPressed: () async {
              await NotificationService.showNotification(
                title: "Title of the notification",
                body: "Body of the notification",
                payload: {
                  "navigate": "true",
                  "data": "this is the payload in a internal notification",
                },
                actionButtons: [
                  NotificationActionButton(
                    key: 'check',
                    label: 'Check it out',
                    actionType: ActionType.SilentAction,
                    color: Colors.green,
                  )
                ],
              );
            },
          ),
          NotificationButton(
            text: "Scheduled Notification",
            onPressed: () async {
              await NotificationService.showNotification(
                title: "Scheduled Notification",
                body: "Notification was fired after 5 seconds",
                scheduled: true,
                interval: 5,
              );
            },
          ),
        ],
      ),
    );
  }
}
