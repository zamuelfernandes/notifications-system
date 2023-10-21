// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable, argument_type_not_assignable_to_error_handler
import 'dart:async';

import 'package:awesome_notification/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RealTimeScreen extends StatefulWidget {
  const RealTimeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<RealTimeScreen> createState() => _RealTimeScreenState();
}

class _RealTimeScreenState extends State<RealTimeScreen> {
  String _name = '...';

  FirebaseException? _error;
  late final DatabaseReference _dataReference;
  late StreamSubscription<DatabaseEvent> _dataSubscription;

  final TextEditingController _dataController = TextEditingController();

  @override
  initState() {
    super.initState();
    init();
  }

  void init() async {
    /// INICIALIZANDO A REFERENCIA
    _dataReference = FirebaseDatabase.instance.ref('name');

    /// PEGANDO VALOR QUE JA ESTEJA NO BANCO
    try {
      final nameSnapshot = await _dataReference.get();
      _name = nameSnapshot.value as String;

      print(
        'Connected to directly configured database and read '
        '${nameSnapshot.value}',
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    _dataSubscription = _dataReference.onValue.listen(
      (DatabaseEvent event) {
        setState(() {
          _error = null;
          if (event.snapshot.value != null && event.snapshot.value != _name) {
            _name = (event.snapshot.value ?? '...') as String;
            pushNotify(title: "Name Changed", body: "The new name is: $_name");
          }
        });
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        setState(() {
          _error = error;
        });
      },

      /// OUTRAS FUNÇÕES ÚTEIS
      // onDone: () {},
    );
  }

  pushNotify({required String title, required String body}) async {
    await NotificationService.showNotification(
      title: title,
      body: body,
    );
  }

  sendName() async {
    /// EXEMPLO DE QUE EXISTEM FUNÇÕES ÚTEIS CASO PRECISE
    /// await _dataReference.set(ServerValue.increment(1));
    String data = _dataController.text;
    try {
      await _dataReference.set(data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'THIS IS THE _error: ${_error == null ? 'Nothing' : _error!.message}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronize Notification'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'The name in Firebase Realtime Database is:',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextField(
                    controller: _dataController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(3),
                      filled: true,
                      fillColor: Colors.white,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 17,
                        color: Colors.black54,
                      ),
                      prefixIconColor: Colors.black54,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black38,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.deepPurple,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: TextButton(
                        onPressed: sendName,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Send Name'),
                            SizedBox(width: 10),
                            Icon(
                              Icons.send_rounded,
                              color: Colors.deepPurple,
                              size: 35,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
