import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'component_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ExtruderApp());
}

class ExtruderApp extends StatelessWidget {
  const ExtruderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extruder App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Extruder App Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference dBRef = FirebaseDatabase.instance.ref();

  bool heaterSwitch = false;
  bool motorSwitch = false;

  @override
  void initState() {
    super.initState();
    _extruderDataFetch();
  }

  void _extruderDataFetch() {
    dBRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map;

      final temperature = data['temperature'];
      final velocity = data['velocity'];

      setState(() {
        heaterSwitch = temperature['button'] as bool;
        motorSwitch = velocity['button'] as bool;
      });
    });
  }

  void _setDB(String path, String key, value) async {
    await dBRef.child(path).update({
      key: value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.greenAccent[700],
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                  flex: 2,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Switch(
                                value: heaterSwitch,
                                onChanged: ((value) {
                                  setState(() {
                                    heaterSwitch = value;
                                    _setDB(
                                        "temperature", "button", heaterSwitch);
                                  });
                                })),
                            const Text('Aquecimento')
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Switch(
                                value: motorSwitch,
                                onChanged: ((value) {
                                  setState(() {
                                    motorSwitch = value;
                                    _setDB("velocity", "button", motorSwitch);
                                  });
                                })),
                            const Text('Motor')
                          ],
                        ),
                      ])),
              const Divider(),
              const Expanded(
                flex: 7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ComponentCard('heater01', 'temperature','Aquecedor 1', '°C'),
                    ComponentCard('heater02', 'temperature','Aquecedor 2', '°C'),
                    ComponentCard('heater03', 'temperature','Aquecedor 3', '°C'),
                    ComponentCard('heater04', 'temperature','Aquecedor 4', '°C'),
                  ],
                ),
              ),
              const Divider(),
              const Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ComponentCard('motor', 'velocity','Velocidade', 'rpm'),
                    ],
                  )),
            ],
          ),
        ));
  }
}
