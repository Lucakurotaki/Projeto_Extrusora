import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComponentCard extends StatefulWidget {
  final String component;
  final String componentType;
  final String lable;
  final String unit;

  const ComponentCard(this.component, this.componentType, this.lable, this.unit,
      {super.key});

  @override
  State<ComponentCard> createState() => _ComponentCardState();
}

class _ComponentCardState extends State<ComponentCard> {
  num sensor = 0;
  num control = 0;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    _extruderDataFetch();

    _focusNode.addListener(() {
      if(!_focusNode.hasFocus){
        _focusNode.unfocus();
        setState(() {
          textfield = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  DatabaseReference dBFetch() {
    final componentType = widget.componentType;
    final component = widget.component;

    DatabaseReference componentRef =
        FirebaseDatabase.instance.ref('$componentType/controller/$component');

    return componentRef;
  }

  void _extruderDataFetch() {
    final componentRef = dBFetch();

    componentRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map;

      setState(() {
        sensor = data['sensor'] as num;
        control = data['control'] as num;
      });

      _controller.text = '$control';
    });
  }

  void _updateDB(num value) async {
    await dBFetch().update({
      "control": value,
    });
  }

  bool textfield = false;

  @override
  Widget build(BuildContext context) {
    final lable = widget.lable;
    final unit = widget.unit;

    return Card(
      child: Column(
        children: [
          Text(lable),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '$sensor $unit',
                style: TextStyle(fontSize: 26, color: Colors.green[900]),
              ),
              textfield == true
                  ? SizedBox(
                      width: 60,
                      height: 30,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        autofocus: true,
                        focusNode: _focusNode,
                        controller: _controller,
                        style: TextStyle(
                            fontSize: 26, color: Colors.redAccent[700]),
                        textAlign: TextAlign.center,
                        onSubmitted: (value) {
                          num numValue = num.parse(value);
                          _updateDB(numValue);
                          setState(() {
                            textfield = false;
                          });
                        },
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        textfield = true;
                        setState(() {});
                      },
                      child: Text(
                        '$control $unit',
                        style: TextStyle(
                            fontSize: 26, color: Colors.redAccent[700]),
                      ),
                    ),
              IconButton(
                onPressed: () {
                  num value = ++control;
                  _updateDB(value);
                },
                icon: const Icon(Icons.arrow_circle_up_outlined),
                iconSize: 35,
              ),
              IconButton(
                onPressed: () {
                  num value = --control;
                  _updateDB(value);
                },
                icon: const Icon(Icons.arrow_circle_down_outlined),
                iconSize: 35,
              ),
            ],
          ),
          const Text('')
        ],
      ),
    );
  }
}
