import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide  MenuAcceleratorLabel, MenuAnchor, MenuController, MenuItemButton, SubmenuButton;

import 'cupertino_menu.0.dart';
import 'menu.dart';
import 'menu_item.dart';
import 'test_anchor.dart';

/// Flutter code sample for [MenuAnchor].

void main() => runApp(const MenuApp());

class MenuApp extends StatefulWidget {
  const MenuApp({super.key});

  @override
  State<MenuApp> createState() => _MenuAppState();
}

class _MenuAppState extends State<MenuApp> {
  final bool _darkMode = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(useMaterial3: false,  brightness: _darkMode ? Brightness.dark : Brightness.light,),
      home:  Scaffold(
        backgroundColor: _darkMode ? Colors.black : Colors.white,
        body:   const CupertinoMenuExample(),
      )
    );
  //  return  ConstrainedBox(
  //         constraints: const BoxConstraints.tightFor(width: 200, height: 200),
  //    child: MaterialApp(
  //           home: Directionality(
  //             textDirection: TextDirection.rtl,
  //             child:   CupertinoMenuAnchor(
  //                     menuChildren: createTestMenus2(
  //                       shortcuts: <TestMenu, MenuSerializableShortcut>{
  //                         TestMenu.item0:  const CharacterActivator('m', control: true),
  //                         TestMenu.item1:  const CharacterActivator('a', alt: true),
  //                         TestMenu.matMenu5:  const CharacterActivator('b', meta: true),
  //                       },
  //                       onPressed: (TestMenu menu){},
  //               ),
  //             ),
  //           ),
  //         ),
  //  );
  }
}
List<Widget> createTestMenus2({
  void Function(TestMenu)? onPressed,
  void Function(TestMenu)? onOpen,
  void Function(TestMenu)? onClose,
  Map<TestMenu, MenuSerializableShortcut> shortcuts = const <TestMenu, MenuSerializableShortcut>{},
  bool includeExtraGroups = false,
  bool accelerators = false,
  Map<TestMenu, Key> keys =
       const <TestMenu, Key>{},
}) {
  Widget submenuButton(
    TestMenu menu, {
    required List<Widget> menuChildren,
  }) {
    return SubmenuButton(

      onOpen: onOpen != null ? () => onOpen(menu) : null,
      onClose: onClose != null ? () => onClose(menu) : null,
      menuChildren: menuChildren,
      child: accelerators ? MenuAcceleratorLabel(menu.acceleratorLabel) : Text(menu.label),
    );
  }

  Widget cupertinoMenuItemButton(
    TestMenu menu, {
    bool enabled = true,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Widget? subtitle,
    Key? key,
  }) {
    return CupertinoMenuItem(
      requestFocusOnHover: true,
      key: key,
      onPressed: enabled && onPressed != null ? () => onPressed(menu) : null,
      leading: leadingIcon,
      trailing: trailingIcon,
      subtitle: subtitle,
      child: accelerators ? MenuAcceleratorLabel(menu.acceleratorLabel) : menu.text,
    );
  }
  Widget menuItemButton(
    TestMenu menu, {
    bool enabled = true,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Key? key,
  }) {
    return MenuItemButton(
      key: key,
      onPressed: enabled && onPressed != null ? () => onPressed(menu) : null,
      shortcut: shortcuts[menu],
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      child: accelerators ? MenuAcceleratorLabel(menu.acceleratorLabel) : menu.text,
    );
  }

  final List<Widget> result = <Widget>[
    cupertinoMenuItemButton(TestMenu.item0, leadingIcon: const Icon(Icons.add)),
    cupertinoMenuItemButton(TestMenu.item1),
    const CupertinoMenuLargeDivider(),
    cupertinoMenuItemButton(TestMenu.item2),
    menuItemButton(TestMenu.matItem3, leadingIcon: const Icon(Icons.add)),
    cupertinoMenuItemButton(TestMenu.item4),
    submenuButton(
      TestMenu.matMenu5,
      menuChildren: <Widget>[
    cupertinoMenuItemButton(TestMenu.item4, leadingIcon: const Text('Leading'), trailingIcon: const Text('Trailing'), subtitle: const Text('Subtitle')),
    cupertinoMenuItemButton(TestMenu.item4),

      ],
    ),
    submenuButton(
      TestMenu.matMenu5,
      menuChildren: <Widget>[
        menuItemButton(TestMenu.subMenu00, leadingIcon: const Icon(Icons.add)),
        menuItemButton(TestMenu.subMenu01),
        menuItemButton(TestMenu.subMenu02),
      ],
    ),
    submenuButton(
      TestMenu.matMenu6,
      menuChildren: <Widget>[
        menuItemButton(TestMenu.subMenu10),
        submenuButton(
          TestMenu.subMenu11,
          menuChildren: <Widget>[
            menuItemButton(TestMenu.subSubMenu110, key: UniqueKey()),
            menuItemButton(TestMenu.subSubMenu111),
            menuItemButton(TestMenu.subSubMenu112),
            menuItemButton(TestMenu.subSubMenu113),
          ],
        ),
        menuItemButton(TestMenu.subMenu12),
      ],
    ),
    if (includeExtraGroups)
      submenuButton(
        TestMenu.matMenu6a,
        menuChildren: <Widget>[
          menuItemButton(TestMenu.subMenu20, enabled: false),
        ],
      ),
    if (includeExtraGroups)
      submenuButton(
        TestMenu.matMenu6b,
        menuChildren: <Widget>[
          menuItemButton(TestMenu.subMenu30, enabled: false),
          menuItemButton(TestMenu.subMenu31, enabled: false),
          menuItemButton(TestMenu.subMenu32, enabled: false),
        ],
      ),
    submenuButton(TestMenu.matMenu7Empty, menuChildren: const <Widget>[]),
    const CupertinoMenuLargeDivider(),
    cupertinoMenuItemButton(TestMenu.item8Disabled, enabled: false),
    cupertinoMenuItemButton(TestMenu.item9),
  ];
  return result;
}

enum TestMenu {
  item0('&Item 0'),
  item1('I&tem 1'),
  item2('It&em 2'),
  matItem3('&MenuItem 3'),
  item4('I&tem 4'),
  matMenu5('&Menu 5'),
  matMenu6('M&enu &6'),
  matMenu6a('Men&u 6a'),
  matMenu6b('Menu &6b'),
  matMenu7Empty('Menu &6 &&'),
  item8Disabled('Ite&m 8'),
  item9('Ite&m 9'),
  subMenu00('Sub &Menu 0&0'),
  subMenu01('Sub Menu 0&1'),
  subMenu02('Sub Menu 0&2'),
  subMenu10('Sub Menu 1&0'),
  subMenu11('Sub Menu 1&1'),
  subMenu12('Sub Menu 1&2'),
  subMenu20('Sub Menu 2&0'),
  subMenu30('Sub Menu 3&0'),
  subMenu31('Sub Menu 3&1'),
  subMenu32('Sub Menu 3&2'),
  subSubMenu110('Sub Sub Menu 11&0'),
  subSubMenu111('Sub Sub Menu 11&1'),
  subSubMenu112('Sub Sub Menu 11&2'),
  subSubMenu113('Sub Sub Menu 11&3'),
  anchorButton('Press Me'),
  outsideButton('Outside');

  const TestMenu(this.acceleratorLabel);
  final String acceleratorLabel;
  // Strip the accelerator markers.
  String get label => MenuAcceleratorLabel.stripAcceleratorMarkers(acceleratorLabel);
  // Finder get findItem => find.widgetWithText(CupertinoMenuItem, label);
  Text get text => Text(label);
  String get debugFocusLabel => switch(label.split(' ').first){
     'Menu'=>  '$SubmenuButton($text)',
     'Item'=>  '$CupertinoMenuItem($text)',
     'MenuItem'=>  '$MenuItemButton($text)',
    _ => '$CupertinoMenuItem',
  };
}

const double _kBorderWidth = 4.0;
const double _kBorderRadius = 8.0;
const double _kClipRadius = 12.0;

const int _kBlueStartingIndex = 0;
const int _kYellowStartingIndex = 3;



Widget buildTestApp({
    AlignmentGeometry? alignment,
    AlignmentGeometry? menuAlignment,
    Offset alignmentOffset = Offset.zero,
    TextDirection textDirection = TextDirection.ltr,
    bool consumesOutsideTap = false,
     List<Widget>? children,
    void Function(TestMenu item)? onPressed,
    void Function()? onOpen,
    void Function()? onClose,
    CupertinoThemeData theme = const CupertinoThemeData(),
  }) {
    final FocusNode focusNode = FocusNode();
    return CupertinoApp(
      home: CupertinoTheme(
        data: theme,
        child: Directionality(
            textDirection: textDirection,
            child: Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      onPressed?.call(TestMenu.outsideButton);
                    },
                    child: Text(TestMenu.outsideButton.label)),
                CupertinoMenuAnchor(
                  childFocusNode: focusNode,
                  alignmentOffset: alignmentOffset,
                  alignment: alignment,
                  menuAlignment: menuAlignment,
                  consumeOutsideTap: consumesOutsideTap,
                  onOpen: onOpen,
                  onClose: onClose,
                  menuChildren: children ?? createTestMenus2(
                      onPressed: onPressed,
                  ),
                  builder: (BuildContext context,
                      CupertinoMenuController controller, Widget? child) {
                    return ElevatedButton(
                      focusNode: focusNode,
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                        onPressed?.call(TestMenu.anchorButton);
                      },
                      child: TestMenu.anchorButton.text,
                    );
                  },
                ),
              ],
            ),
        ),
      ),
    );
  }