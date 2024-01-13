import 'package:flutter/material.dart';

import 'cupertino_menu.0.dart';

/// Flutter code sample for [MenuAnchor].

void main() => runApp(const MenuApp());

class MenuApp extends StatefulWidget {
  const MenuApp({super.key});

  @override
  State<MenuApp> createState() => _MenuAppState();
}

class _MenuAppState extends State<MenuApp> {
  bool _darkMode = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(useMaterial3: false,  brightness: _darkMode ? Brightness.dark : Brightness.light,),
      home:  Scaffold(
        backgroundColor: _darkMode ? Colors.black : Colors.white,
        body:  CupertinoMenuExample(
        onDarkModeChanged: (){
          setState(() {
            _darkMode = !_darkMode;
          });
        },
      ))
    );
  }
}

