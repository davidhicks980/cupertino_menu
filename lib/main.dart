import 'package:flutter/material.dart';

import 'cupertino_menu.0.dart';

/// Flutter code sample for [MenuAnchor].

void main() => runApp(const MenuApp());

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      home: const Scaffold(body:  CupertinoMenuExample())
    );
  }
}

class MyCascadingMenu extends StatefulWidget {
  const MyCascadingMenu({super.key});

  @override
  State<MyCascadingMenu> createState() => _MyCascadingMenuState();
}

class _MyCascadingMenuState extends State<MyCascadingMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MenuAnchor(
          menuChildren: <Widget>[
            MenuItemButton(
              onPressed: () {},
              child: const Text('Item'),
            ),
            SubmenuButton(
              onFocusChange: (bool focused) {
                print('It worked');
              },
              menuChildren: <Widget>[
                MenuItemButton(
                  onPressed: () {},
                  child: const Text('Red'),
                ),
                MenuItemButton(
                  onPressed: () {},
                  child: const Text('Green'),
                ),
                MenuItemButton(
                  onPressed: () {},
                  child: const Text('Blue'),
                ),
              ],
              child: const Text('Color'),
            ),
          ],
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
            return TextButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: const Text('OPEN MENU'),
            );
          },
        ),
      ],
    );
  }
}
