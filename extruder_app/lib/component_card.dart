import 'package:extruder_app/component_iconbutton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ComponentCard extends StatefulWidget {
  final component;
  final componentType;
  final lable;
  final unit;

  const ComponentCard(this.component, this.componentType, this.lable, this.unit, {super.key});

  @override
  State<ComponentCard> createState() => _ComponentCardState();
}

class _ComponentCardState extends State<ComponentCard> {
  
  num sensor = 0;
  num control = 0;

  bool increment = false;
  bool decrement = false;

  @override
  void initState() {
    super.initState();
    _extruderDataFetch();
  }

  void _extruderDataFetch() {
    final componentType = widget.componentType;

    DatabaseReference dBRef =
      FirebaseDatabase.instance.ref('$componentType/controller/');

    final componentRef = dBRef.child('${widget.component}');

    componentRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map;

      setState(() {
        sensor = data['sensor'] as num;
        control = data['control'] as num;
        increment = data['increment'] as bool;
        decrement = data['decrement'] as bool;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    final componentType = widget.componentType;
    final lable = widget.lable;
    final unit = widget.unit;

    return Card(
      child: Column(
        children: [
          Text(lable),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('$sensor $unit', style: TextStyle(fontSize: 18, color: Colors.redAccent[700]),),
                  Text('$control $unit', style: TextStyle(fontSize: 18, color: Colors.green[900]),),
                ],
              ),
              ComponentIconButton(component, componentType, 'increment', increment, Icons.arrow_circle_up_outlined),
              ComponentIconButton(component, componentType, 'decrement', decrement, Icons.arrow_circle_down_outlined),
            ],
          ),
          const Text('')
        ],
      ),
    );
  }
}
