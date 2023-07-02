import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

// ignore: must_be_immutable
class ComponentIconButton extends StatefulWidget {
  bool commandState;
  String commandType;
  String component;
  String componentType;
  IconData icon;

  ComponentIconButton(
      this.component, this.componentType, this.commandType, this.commandState, this.icon,
      {super.key});

  @override
  State<ComponentIconButton> createState() => _ComponentIconButtonState();
}

class _ComponentIconButtonState extends State<ComponentIconButton> {
  
  DatabaseReference dBFetch (){

    DatabaseReference dBRef =
      FirebaseDatabase.instance.ref('${widget.componentType}/controller/');

      return dBRef;

  }

  void _setDB(String key, value) async {
    await dBFetch().child(widget.component).update({
      key: value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          var commandState = widget.commandState;
          final commandType = widget.commandType;

          commandState = true;
          _setDB(commandType, commandState);
          Timer(const Duration(milliseconds: 500), () {
            setState(() {
              commandState = false;
              _setDB(commandType, commandState);
            });
          });
        });
      },
      icon: Icon(widget.icon),
      iconSize: 35,
    );
  }
}
