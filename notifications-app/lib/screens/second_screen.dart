// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:flutter/material.dart';

import 'package:awesome_notification/main.dart';

class SecondScreen extends StatelessWidget {
  Map<String, String?>? dataFromNotification;

  SecondScreen({
    Key? key,
    this.dataFromNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICATION SCREEN'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              children: [
                const Spacer(),
                const Center(
                  child: Text(
                    "Navigated from notification",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                // This icon button has been added fot ios navigation
                IconButton(
                  onPressed: () => MainApp.navigatorKey.currentState?.pop(),
                  icon: const Icon(
                    Icons.arrow_circle_left_outlined,
                    color: Colors.deepPurple,
                    size: 35,
                  ),
                ),
                const Spacer(),
                Text(
                  '$dataFromNotification',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
