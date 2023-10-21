import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notification/services/notification_service.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  String? theToken = '...';

  late final DatabaseReference _dataTokenReference;

  void searchToken() async {
    String? token = await NotificationService.requestFirebaseToken();
    setState(() {
      theToken = token;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    _dataTokenReference = FirebaseDatabase.instance.ref('deskTokens');
  }

  void addMyTokenToTheDesk() async {
    List _mesa = [];
    List _databaseMesa = [];

    try {
      //VERIFICAR SE A MESA JA ESTA CRIADA E QUEM ESTÁ NA MESA -----------------
      final _tokenListSnapshot = await _dataTokenReference.get();

      if (_tokenListSnapshot.value != null) {
        _databaseMesa = _tokenListSnapshot.value as List;
        _mesa += _databaseMesa;

        print(_mesa);
      }

      //ADICIONAR MEU TOKEN A MESA ---------------------------------------------
      final myToken = await NotificationService.requestFirebaseToken();
      if (_mesa.contains(myToken)) {
        print('Token ja registrado!');

        _mesa.add(myToken);

        await _dataTokenReference.set(_mesa);
      } else {
        _mesa.add(myToken);

        await _dataTokenReference.set(_mesa);

        print('Novo token registrado!');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Notification'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              children: [
                const Text(
                  'THIS IS YOUR TOKEN:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SelectableText(
                  '$theToken',
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    searchToken();
                    addMyTokenToTheDesk();
                  },
                  child: const Text('Press Here to get Token'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
