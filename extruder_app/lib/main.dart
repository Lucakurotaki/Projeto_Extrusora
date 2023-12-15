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

  dynamic temperature = {};
  Map preset = {};

  List presetKeys = [];

  late TextEditingController controller;

  String name = '';

  @override
  void initState() {
    super.initState();
    _extruderDataFetch();

    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  void _extruderDataFetch() {
    dBRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map;

      temperature = data['temperature'];
      final velocity = data['velocity'];
      preset = data['preset'] as Map;

      presetKeys = preset.keys.toList();

      setState(() {
        heaterSwitch = temperature['button'] as bool;
        motorSwitch = velocity['button'] as bool;
      });
    });
  }

  void _updateDB(String path, String key, value) async {
    await dBRef.child(path).update({
      key: value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[400],
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.deepPurple),
        ),
      ),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.greenAccent[400],
            ),
            child: const Text(
              'Presets',
              style: TextStyle(fontSize: 25, color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: presetKeys.length,
              itemBuilder: (context, index) {
                return Dismissible(
                    key: Key(presetKeys[index]),
                    confirmDismiss: (direction) async {
                      return await _deleteConfirmationDialog(context);
                    },
                    onDismissed: (direction) { 

                      _updateDB('preset', presetKeys[index], null);
                    },
                    child: ListTile(
                      title: Text(presetKeys[index]),
                      onTap: () {
                        Map selectedPreset = preset[presetKeys[index]] as Map;
                        for (var key in selectedPreset.keys) {
                          _updateDB('temperature/controller/$key', 'control',
                              selectedPreset[key]);
                        }
                        Navigator.pop(context);
                      },
                    ));
              })
        ],
      )),
      body: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                    value: heaterSwitch,
                    onChanged: ((value) {
                      setState(() {
                        heaterSwitch = value;
                        _updateDB("temperature", "button", heaterSwitch);
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
                        _updateDB("velocity", "button", motorSwitch);
                      });
                    })),
                const Text('Motor')
              ],
            ),
          ]),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  heaterSwitch == true
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ComponentCard(
                                'heater01', 'temperature', 'Aquecedor 1', '°C'),
                            ComponentCard(
                                'heater02', 'temperature', 'Aquecedor 2', '°C'),
                            ComponentCard(
                                'heater03', 'temperature', 'Aquecedor 3', '°C'),
                            ComponentCard(
                                'heater04', 'temperature', 'Aquecedor 4', '°C'),
                          ],
                        )
                      : const SizedBox(),
                  const Divider(),
                  motorSwitch == true
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ComponentCard(
                                'motor', 'velocity', 'Velocidade', 'rpm'),
                          ],
                        )
                      : const SizedBox(),
                  const Divider(),
                  heaterSwitch == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: TextButton(
                            onPressed: () async {
                              final name = await saveDialog();
                              if (name == null || name.isEmpty) return;
                              setState(() {
                                this.name = name;
                              });
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.greenAccent[400],
                                fixedSize: const Size.fromWidth(100)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [Icon(Icons.save), Text('Salvar')],
                            ),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<String?> saveDialog() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text(
              "Salvar configuração como: ",
              style: TextStyle(fontSize: 20),
            ),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Nome",
              ),
              controller: controller,
            ),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(onPressed: cancel, child: const Text('Cancelar')),
                TextButton(onPressed: submit, child: const Text('Salvar')),
              ])
            ],
          ));

  void submit() {
    String presetName = controller.text;

    final tempController = temperature['controller'];
    num heater1 = tempController['heater01']['control'];
    num heater2 = tempController['heater02']['control'];
    num heater3 = tempController['heater03']['control'];
    num heater4 = tempController['heater04']['control'];

    dynamic presetTemps = {
      "heater01": heater1,
      "heater02": heater2,
      "heater03": heater3,
      "heater04": heater4
    };

    _updateDB("preset", presetName, presetTemps);
    Navigator.of(context).pop(controller.text);
  }

  void cancel() {
    Navigator.of(context).pop();
  }

  Future<bool> _deleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação de Exclusão'),
          content: const Text('Deseja realmente excluir o item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
