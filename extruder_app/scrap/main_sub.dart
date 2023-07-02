import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:extruder_app/firebase_options.dart';
import 'package:segment_display/segment_display.dart';
import 'dart:async';

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

  num displayHeater_01 = 0;
  num displayHeater_02 = 0;
  num displayHeater_03 = 0;
  num displayHeater_04 = 0;

  num motorVel = 0;

  bool setHeater_01 = false;
  bool incrementHeater_01 = false;
  bool decrementHeater_01 = false;

  bool setHeater_02 = false;
  bool incrementHeater_02 = false;
  bool decrementHeater_02 = false;

  bool setHeater_03 = false;
  bool incrementHeater_03 = false;
  bool decrementHeater_03 = false;

  bool setHeater_04 = false;
  bool incrementHeater_04 = false;
  bool decrementHeater_04 = false;

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

      final tempContr = temperature['controller'];

      setState(() {
        heaterSwitch = temperature['button'] as bool;
        motorSwitch = velocity['button'] as bool;

        final heater01 = tempContr['heater01'];
        final heater02 = tempContr['heater02'];
        final heater03 = tempContr['heater03'];
        final heater04 = tempContr['heater04'];

        displayHeater_01 = heater01['disp_temp'] as num;
        setHeater_01 = heater01['set_temp'] as bool;
        incrementHeater_01 = heater01['inc_temp'] as bool;
        decrementHeater_01 = heater01['dec_temp'] as bool;

        displayHeater_02 = heater02['disp_temp'] as num;
        setHeater_02 = heater02['set_temp'] as bool;
        incrementHeater_02 = heater02['inc_temp'] as bool;
        decrementHeater_02 = heater02['dec_temp'] as bool;

        displayHeater_03 = heater03['disp_temp'] as num;
        setHeater_03 = heater03['set_temp'] as bool;
        incrementHeater_03 = heater03['inc_temp'] as bool;
        decrementHeater_03 = heater03['dec_temp'] as bool;

        displayHeater_04 = heater04['disp_temp'] as num;
        setHeater_04 = heater04['set_temp'] as bool;
        incrementHeater_04 = heater04['inc_temp'] as bool;
        decrementHeater_04 = heater04['dec_temp'] as bool;

        motorVel = velocity['controller'] as num;
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
                  flex: 1,
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
                                    _setDB("temperature", "button", heaterSwitch);
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
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Card(
                      child: Column(
                        children: [
                          const Text('Aquecedor 1'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Center(
                                  child: SevenSegmentDisplay(
                                value: '$displayHeater_01',
                                size: 4,
                              )),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    setHeater_01 = true;
                                    _setDB('temperature/controller/heater01', 'set_temp', setHeater_01);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        setHeater_01 = false;
                                        _setDB('temperature/controller/heater01', 'set_temp', setHeater_01);
                                      });
                                    });
                                  });
                                },
                                icon: const Icon(
                                    Icons.radio_button_checked_outlined),
                                iconSize: 35,
                              ),
                              IconButton(
                                  onPressed: () {
                                  setState(() {
                                    incrementHeater_01 = true;
                                    _setDB('temperature/controller/heater01', 'inc_temp', incrementHeater_01);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        incrementHeater_01 = false;
                                        _setDB('temperature/controller/heater01', 'inc_temp', incrementHeater_01);
                                      });
                                    });
                                  });
                                },
                                  icon: const Icon(
                                    Icons.arrow_circle_up_outlined,
                                  ),
                                  iconSize: 35),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    decrementHeater_01 = true;
                                    _setDB('temperature/controller/heater01', 'dec_temp', decrementHeater_01);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        decrementHeater_01 = false;
                                        _setDB('temperature/controller/heater01', 'dec_temp', decrementHeater_01);
                                      });
                                    });
                                  });
                                },
                                icon: const Icon(
                                    Icons.arrow_circle_down_outlined),
                                iconSize: 35,
                              )
                            ],
                          ),
                          const Text('')
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          const Text('Aquecedor 2'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Center(
                                  child: SevenSegmentDisplay(
                                value: '$displayHeater_02',
                                size: 4,
                              )),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    setHeater_02 = true;
                                    _setDB('temperature/controller/heater02', 'set_temp', setHeater_02);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        setHeater_02 = false;
                                        _setDB('temperature/controller/heater02', 'set_temp', setHeater_02);
                                      });
                                    });
                                  });
                                },
                                icon: const Icon(
                                    Icons.radio_button_checked_outlined),
                                iconSize: 35,
                              ),
                              IconButton(
                                  onPressed: () {
                                  setState(() {
                                    incrementHeater_02 = true;
                                    _setDB('temperature/controller/heater02', 'inc_temp', incrementHeater_02);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        incrementHeater_02 = false;
                                        _setDB('temperature/controller/heater02', 'inc_temp', incrementHeater_02);
                                      });
                                    });
                                  });
                                },
                                  icon: const Icon(
                                    Icons.arrow_circle_up_outlined,
                                  ),
                                  iconSize: 35),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    decrementHeater_02 = true;
                                    _setDB('temperature/controller/heater02', 'dec_temp', decrementHeater_02);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        decrementHeater_02 = false;
                                        _setDB('temperature/controller/heater02', 'dec_temp', decrementHeater_02);
                                      });
                                    });
                                  });
                                },
                                icon: const Icon(
                                    Icons.arrow_circle_down_outlined),
                                iconSize: 35,
                              )
                            ],
                          ),
                          const Text('')
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          const Text('Aquecedor 3'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Center(
                                  child: SevenSegmentDisplay(
                                value: '$displayHeater_03',
                                size: 4,
                              )),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    setHeater_03 = true;
                                    _setDB('temperature/controller/heater03', 'set_temp', setHeater_03);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        setHeater_03 = false;
                                        _setDB('temperature/controller/heater03', 'set_temp', setHeater_03);
                                      });
                                    });
                                  });
                                },
                                icon: const Icon(
                                    Icons.radio_button_checked_outlined),
                                iconSize: 35,
                              ),
                              IconButton(
                                  onPressed: () {
                                  setState(() {
                                    incrementHeater_03 = true;
                                    _setDB('temperature/controller/heater03', 'inc_temp', incrementHeater_03);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        incrementHeater_03 = false;
                                        _setDB('temperature/controller/heater03', 'inc_temp', incrementHeater_03);
                                      });
                                    });
                                  });
                                },
                                  icon: const Icon(
                                    Icons.arrow_circle_up_outlined,
                                  ),
                                  iconSize: 35),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    decrementHeater_03 = true;
                                    _setDB('temperature/controller/heater03', 'dec_temp', decrementHeater_03);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        decrementHeater_03 = false;
                                        _setDB('temperature/controller/heater03', 'dec_temp', decrementHeater_03);
                                      });
                                    });
                                  });
                                },
                                icon: const Icon(
                                    Icons.arrow_circle_down_outlined),
                                iconSize: 35,
                              )
                            ],
                          ),
                          const Text('')
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          const Text('Aquecedor 4'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Center(
                                  child: SevenSegmentDisplay(
                                value: '$displayHeater_04',
                                size: 4,
                              )),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    setHeater_04 = true;
                                    _setDB('temperature/controller/heater04', 'set_temp', setHeater_04);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        setHeater_04 = false;
                                        _setDB('temperature/controller/heater04', 'set_temp', setHeater_04);
                                      });
                                    });
                                  });
                                },
                                icon: const Icon(
                                    Icons.radio_button_checked_outlined),
                                iconSize: 35,
                              ),
                              IconButton(
                                  onPressed: () {
                                  setState(() {
                                    incrementHeater_04 = true;
                                    _setDB('temperature/controller/heater04', 'inc_temp', incrementHeater_04);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        incrementHeater_04 = false;
                                        _setDB('temperature/controller/heater04', 'inc_temp', incrementHeater_04);
                                      });
                                    });
                                  });
                                },
                                  icon: const Icon(
                                    Icons.arrow_circle_up_outlined,
                                  ),
                                  iconSize: 35),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    decrementHeater_04 = true;
                                    _setDB('temperature/controller/heater04', 'dec_temp', decrementHeater_04);
                                    Timer(const Duration(milliseconds: 500), (){
                                      setState(() {
                                        decrementHeater_04 = false;
                                        _setDB('temperature/controller/heater04', 'dec_temp', decrementHeater_04);
                                      });
                                    });
                                  });
                                },
                                icon: const Icon(
                                    Icons.arrow_circle_down_outlined),
                                iconSize: 35,
                              )
                            ],
                          ),
                          const Text('')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Card(
                          child: ListTile(
                            title: Center(
                              child: Text(
                                '$motorVel rpm',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.blue[900]),
                              ),
                            ),
                            subtitle: const Center(
                              child: Text('Velocidade'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }
}
