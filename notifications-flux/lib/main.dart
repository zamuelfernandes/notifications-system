import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants/constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flux App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int step = 0;

  late final DatabaseReference _dataTokenReference;

  List dataBaseDesk = [];

  Color selectedColor = Colors.deepPurple;
  Color unselectedColor = const Color(0xff333333);

  Color firstStepColor = const Color(0xffffffff);
  Color secondStepColor = const Color(0xffffffff);
  Color thirdStepColor = const Color(0xffffffff);

  handleSendNotification(String title, String body, String token) async {
    debugPrint(
      'THE REQUEST:\n - TITLE: $title\n - BODY: $body\n - TOKEN: $token\n - - -',
    );
    const url =
        "https://fcm.googleapis.com/v1/projects/${Constants.projectNumber}/messages:send";

    Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {"body": body, "title": title}
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": Constants.sendNotificationToken,
          "Contet-Type": "application/json",
          "Accept-Encoding": "gzip, deflate, br"
        },
        body: json.encode(message),
      );

      debugPrint('$response');

      if (response.statusCode == 200) {
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response.Body: ${response.body}");
      } else {
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response.Body: ${response.body}");
      }
    } catch (e) {
      debugPrint('ERROR CAUGHT on handleSendNotification: $e');
    }
  }

  @override
  void initState() {
    firstStepColor = unselectedColor;
    secondStepColor = unselectedColor;
    thirdStepColor = unselectedColor;
    init();

    super.initState();
  }

  init() async {
    _dataTokenReference = FirebaseDatabase.instance.ref('deskTokens');
    dataBaseDesk = await tokensInTheDesk();
  }

  checkDatabase() async {
    List data = await tokensInTheDesk();
    setState(() {
      dataBaseDesk = data;
    });
  }

  //VERIFICAR SE A MESA JA ESTA CRIADA E QUEM ESTÁ NA MESA ---------------------
  Future<List> tokensInTheDesk() async {
    List databaseMesa = [];

    try {
      final tokenListSnapshot = await _dataTokenReference.get();

      if (tokenListSnapshot.value != null) {
        databaseMesa = tokenListSnapshot.value as List;

        return databaseMesa;
      } else {
        debugPrint('Mesa nula');
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  setColor() {
    if (step == 0) {
      firstStepColor = selectedColor;
      secondStepColor = unselectedColor;
      thirdStepColor = unselectedColor;
    } else if (step == 1) {
      firstStepColor = unselectedColor;
      secondStepColor = selectedColor;
      thirdStepColor = unselectedColor;
    } else if (step == 2) {
      firstStepColor = unselectedColor;
      secondStepColor = unselectedColor;
      thirdStepColor = selectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //------------------------ INIT STEPS ----------------------------
              TextButton(
                onPressed: () {
                  checkDatabase();
                  setState(() {
                    for (String token in dataBaseDesk) {
                      handleSendNotification(
                        'Recebemos seu Pedido!',
                        'Seu café está sendo preparado na nossa cozinha e jaja estará a caminho!',
                        token,
                      );
                    }
                    setColor();
                  });
                },
                child: const Text(
                  'Iniciar Preparo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //--------------------- LISTA DE ETAPAS  -------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.coffee_maker_outlined,
                        size: 150,
                        color: firstStepColor,
                      ),
                      Text(
                        'PREPARANDO\nSEU CAFÉ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: firstStepColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.coffee,
                        size: 150,
                        color: secondStepColor,
                      ),
                      Text(
                        'AGUARDANDO\nENTREGADOR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: secondStepColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delivery_dining_outlined,
                        size: 150,
                        color: thirdStepColor,
                      ),
                      Text(
                        'SEU CAFÉ ESTÁ\nA CAMINHO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: thirdStepColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              //----------------------- STEPS CHANGE  --------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () {
                        checkDatabase();
                        setState(() {
                          if (step > 0 && step <= 2) {
                            step--;
                            setColor();
                          }

                          if (step == 0) {
                            for (String token in dataBaseDesk) {
                              handleSendNotification(
                                'Recebemos seu Pedido!',
                                'Seu café está sendo preparado na nossa cozinha e jaja estará a caminho!',
                                token,
                              );
                            }
                          } else if (step == 1) {
                            for (String token in dataBaseDesk) {
                              handleSendNotification(
                                'Pedido Pronto!',
                                'Estamos aguardando um motoboy estar disponível para enviarmos seu café!',
                                token,
                              );
                            }
                          } else if (step == 2) {
                            for (String token in dataBaseDesk) {
                              handleSendNotification(
                                'Café a Caminho!',
                                'O motoboy ja pegou seu pedido e está levando até você! Muito obrigado!"',
                                token,
                              );
                            }
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 80,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'SELECT STEP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Card(
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () {
                        checkDatabase();
                        setState(() {
                          if (step >= 0 && step < 2) {
                            step++;
                            setColor();
                          }

                          if (step == 0) {
                            for (String token in dataBaseDesk) {
                              handleSendNotification(
                                'Recebemos seu Pedido!',
                                'Seu café está sendo preparado na nossa cozinha e jaja estará a caminho!',
                                token,
                              );
                            }
                          } else if (step == 1) {
                            for (String token in dataBaseDesk) {
                              handleSendNotification(
                                'Pedido Pronto!',
                                'Estamos aguardando um motoboy estar disponível para enviarmos seu café!',
                                token,
                              );
                            }
                          } else if (step == 2) {
                            for (String token in dataBaseDesk) {
                              handleSendNotification(
                                'Café a Caminho!',
                                'O motoboy ja pegou seu pedido e está levando até você! Muito obrigado!"',
                                token,
                              );
                            }
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 80,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
