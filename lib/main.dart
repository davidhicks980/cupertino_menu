import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cupertino_menu.0.dart';
import 'test_anchor.dart' as test;

/// Flutter code sample for [MenuAnchor].

void main() => runApp(const MenuApp());

class MyCascadingMenu extends StatefulWidget {
  const MyCascadingMenu({super.key});

  @override
  State<MyCascadingMenu> createState() => _MyCascadingMenuState();
}

class _MyCascadingMenuState extends State<MyCascadingMenu> {
  final FocusNode _buttonFocusNode = FocusNode();

  bool _value = false;

  bool _hide = false;

  Widget buildMenu(int i) {
    return test.SubmenuButton(
      key: UniqueKey(),
        menuChildren: <Widget>[
          test.MenuItemButton(onPressed: () {}, child: Text('$i-1 ${" " * 30}')),
          test.SubmenuButton(
            menuChildren: <Widget>[
              test.MenuItemButton(onPressed: () {}, child: Text('$i-2-1')),
              test.SubmenuButton(
                menuChildren: <Widget>[
                  test.MenuItemButton(onPressed: () {}, child: Text('$i-2-2-1')),
                  test.MenuItemButton(onPressed: () {}, child: Text('$i-2-2-2')),
                ],
                child: Text('$i-2-2'),
              ),
              test.SubmenuButton(
                menuChildren: <Widget>[
                  test.MenuItemButton(onPressed: () {}, child: Text('$i-2-3-1')),
                  test.MenuItemButton(onPressed: () {}, child: Text('$i-2-3-2')),
                ],
                child: Text('$i-2-3'),
              ),
              test.MenuItemButton(onPressed: () {}, child: Text('$i-2-4')),
              test.SubmenuButton(
                menuChildren: <Widget>[
                  test.MenuItemButton(onPressed: () {}, child: Text('$i-2-5-1')),
                  test.MenuItemButton(onPressed: () {}, child: Text('$i-2-5-2')),
                ],
                child: Text('$i-2-5'),
              ),
            ],
            child: Text('$i-2'),
          ),
          test.MenuItemButton(onPressed: () {}, child: Text('$i-3')),
        ],
        child: Text('$i                       '),
      );
  }
  Widget buildOriginalMenu(int i) {
    return SubmenuButton(
      key: UniqueKey(),
        menuChildren: <Widget>[
          MenuItemButton(onPressed: () {}, child: Text('$i-1 ${" " * 30}')),
          SubmenuButton(
            menuChildren: <Widget>[
              MenuItemButton(onPressed: () {}, child: Text('$i-2-1')),
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(onPressed: () {}, child: Text('$i-2-2-1')),
                  MenuItemButton(onPressed: () {}, child: Text('$i-2-2-2')),
                ],
                child: Text('$i-2-2'),
              ),
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(onPressed: () {}, child: Text('$i-2-3-1')),
                  MenuItemButton(onPressed: () {}, child: Text('$i-2-3-2')),
                ],
                child: Text('$i-2-3'),
              ),
              MenuItemButton(onPressed: () {}, child: Text('$i-2-4')),
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(onPressed: () {}, child: Text('$i-2-5-1')),
                  MenuItemButton(onPressed: () {}, child: Text('$i-2-5-2')),
                ],
                child: Text('$i-2-5'),
              ),
            ],
            child: Text('$i-2'),
          ),
          MenuItemButton(onPressed: () {}, child: Text('$i-3')),
        ],
        child: Text('$i                       '),
      );
  }

  @override
  Widget build(BuildContext context) {
    return  Directionality(
      textDirection: _value ? TextDirection.rtl: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Switch(value: _value, onChanged: (bool value){
             setState(() {
               _value = value;
             });
          }),
          Switch(value: _hide, onChanged: (bool value){
             setState(() {
               _hide = value;
             });
          }),
          buildMenu(0),
          // buildOriginalMenu(0),
          if(!_hide)
          Expanded(
            child: test.MenuBar(
                children: <Widget>[
                  buildMenu(1),
                  buildMenu(2),
                  buildMenu(3),
                  buildMenu(4),
                  buildMenu(5),

                ]
            ),
          ),
          Expanded(
            child: MenuBar(
                children: <Widget>[
                  buildOriginalMenu(1),
                  buildOriginalMenu(2),
                  buildOriginalMenu(3),
                  buildOriginalMenu(4),
                  buildOriginalMenu(5),

                ]
            ),
          ),


        ],
      ),
    );
  }
}

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: MyCascadingMenu(),
      ),
    );
  }
}
