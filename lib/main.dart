import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide  MenuAcceleratorLabel, MenuAnchor, MenuBar, MenuController, MenuItemButton, SubmenuButton;
import 'package:flutter/scheduler.dart';
import 'cupertino_menu.0.dart';
import 'menu.dart';
import 'test_anchor.dart';

/// Flutter code sample for [MenuAnchor].

void main() => runApp(const MenuApp());

class MenuApp extends StatefulWidget {
  const MenuApp({super.key});

  @override
  State<MenuApp> createState() => _MenuAppState();
}

class _MenuAppState extends State<MenuApp> with SingleTickerProviderStateMixin {
  bool hide = false;
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 1000,
    ),
  );

  final Alignment _alignment = Alignment.topLeft;



  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  CupertinoApp(
      home: Column(
        children: <Widget>[
          CupertinoMenuItem(
            onPressed: () {},
            leading: const Icon(Icons.add),
            trailing: const Icon(Icons.add),
            child: const Text('test'),
          ),
        ],
      ));

    // CupertinoApp(
    //           home:   Center(
    //             child: CupertinoMenuAnchor(
    //                   backgroundColor: CupertinoColors.activeGreen.withOpacity(0.5),
    //                   builder: _buildAnchor,
    //                   onClose: () {
    //                     print('closed');
    //                   },
    //                   menuChildren: createTestMenus2(
    //                     onPressed: (TestMenu p0) {
    //                       _alignment  = Alignment(Random().nextDouble(), Random().nextDouble());
    //                       setState(() {

    //                       });
    //                     }
    //                 ),
    //             ),
    //           ),
    // );
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




  Widget _buildAnchor(
  BuildContext context,
  MenuController controller,
  Widget? child,
) {
  return ConstrainedBox(
    constraints: const BoxConstraints.tightFor(width: 56, height: 56),
    child: Material(
      child: InkWell(
          onTap: () {
            if (controller.isOpen case true) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child:   const Icon(Icons.add),
          )
    ),
  );
}

List<Widget> createTestMenus2({
  void Function(TestMenu)? onPressed,
  Map<TestMenu, MenuSerializableShortcut> shortcuts = const <TestMenu, MenuSerializableShortcut>{},
  bool includeExtraGroups = false,
  bool accelerators = false,
  double? leadingWidth,
  double? trailingWidth,
  BoxConstraints? constraints,
  bool requestFocusOnHover = true,

}) {


  Widget cupertinoMenuItemButton(
    TestMenu menu, {
    bool enabled = true,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Key? key,
  }) {
    return CupertinoMenuItem(
      requestCloseOnActivate: false,
      requestFocusOnHover: requestFocusOnHover,
      key: key,
      onPressed: enabled && onPressed != null ? () => onPressed(menu) : null,
      leading: leadingIcon,
      trailing: trailingIcon,
      child:  menu.text,
    );
  }

  final List<Widget> result = <Widget>[
    cupertinoMenuItemButton(TestMenu.item0, leadingIcon: const Icon(Icons.add)),
    cupertinoMenuItemButton(TestMenu.item1),
    const CupertinoLargeMenuDivider(),
    cupertinoMenuItemButton(TestMenu.item2),
    cupertinoMenuItemButton(TestMenu.item3, leadingIcon: const Icon(Icons.add), trailingIcon: const Icon(Icons.add)),
    cupertinoMenuItemButton(TestMenu.item4),
    const CupertinoLargeMenuDivider(),
    cupertinoMenuItemButton(TestMenu.item5Disabled, enabled: false),
    cupertinoMenuItemButton(TestMenu.item6),
  ];
  return result;
}

enum TestMenu {
  item0('&Item 0'),
  item1('I&tem 1'),
  item2('It&em 2'),
  item3('Ite&m 3'),
  item4('I&tem 4'),
  item5Disabled('Ite&m 8'),
  item6('Ite&m 9'),
  anchorButton('Press Me'),
  outsideButton('Outside');
  const TestMenu(this.acceleratorLabel);
  final String acceleratorLabel;
  // Strip the accelerator markers.
  String get label => MenuAcceleratorLabel.stripAcceleratorMarkers(acceleratorLabel);
  Text get text => Text(label);
  Type get type => switch(label.split(' ').first){
     'Menu'=>  SubmenuButton,
     'Item'=>  CupertinoMenuItem,
     'MenuItem'=>  MenuItemButton,
      _ => CupertinoMenuItem,
  };

  String get debugFocusLabel => switch(label.split(' ').first){
     'Menu'=>  '$type($text)',
     'Item'=>  '$type($text)',
     'MenuItem'=>  '$type($text)',
    _ => '$type',
  };
}



class _DebugCupertinoMenuEntryMixin extends StatelessWidget with CupertinoMenuEntryMixin {

  const _DebugCupertinoMenuEntryMixin({
    super.key,
     this.hasLeading = false,
     this.allowTrailingSeparator = false,
     this.allowLeadingSeparator = false,
     this.child = const SizedBox.shrink(),
  });

  @override
  final bool hasLeading;

  @override
  final bool allowTrailingSeparator;

  @override
  final bool allowLeadingSeparator;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}



// List<Widget> createTestMenus({
//   void Function(TestMenu)? onPressed,
//   void Function(TestMenu)? onOpen,
//   void Function(TestMenu)? onClose,
//   Map<TestMenu, MenuSerializableShortcut> shortcuts = const <TestMenu, MenuSerializableShortcut>{},
//   bool includeExtraGroups = false,
//   bool accelerators = false,
// }) {

//     Widget cupertinoMenuItemButton(
//     TestMenu menu, {
//     bool enabled = true,
//     Widget? leadingIcon,
//     Widget? trailingIcon,
//     Key? key,
//   }) {
//     return CupertinoMenuItem(
//       key: key,
//       onPressed: enabled && onPressed != null ? () => onPressed(menu) : null,
//       leading: leadingIcon,
//       trailing: trailingIcon,
//       child:  const Text('test'),
//     );
//   }
//   Widget submenuButton(
//     TestMenu menu, {
//     required List<Widget> menuChildren,
//   }) {
//     return SubmenuButton(
//       onOpen: onOpen != null ? () => onOpen(menu) : null,
//       onClose: onClose != null ? () => onClose(menu) : null,
//       menuChildren: menuChildren,
//       child: accelerators ? MenuAcceleratorLabel(menu.acceleratorLabel) : Text(menu.label),
//     );
//   }

//   Widget menuItemButton(
//     TestMenu menu, {
//     bool enabled = true,
//     Widget? leadingIcon,
//     Widget? trailingIcon,
//     Key? key,
//   }) {
//     return MenuItemButton(
//       key: key,
//       onPressed: enabled && onPressed != null ? () => onPressed(menu) : null,
//       shortcut: shortcuts[menu],
//       leadingIcon: leadingIcon,
//       trailingIcon: trailingIcon,
//       child: accelerators ? MenuAcceleratorLabel(menu.acceleratorLabel) : Text(menu.label),
//     );
//   }

//   final List<Widget> result = <Widget>[
//     cupertinoMenuItemButton(TestMenu.mainMenu0, leadingIcon: const Icon(Icons.add)),
//       menuItemButton(TestMenu.subMenu00, leadingIcon: const Icon(Icons.add)),
//     submenuButton(
//       TestMenu.mainMenu1,
//       menuChildren: <Widget>[
//         menuItemButton(TestMenu.subMenu10),
//         submenuButton(
//           TestMenu.subMenu11,
//           menuChildren: <Widget>[
//             menuItemButton(TestMenu.subSubMenu110, key: UniqueKey()),
//             menuItemButton(TestMenu.subSubMenu111),
//             menuItemButton(TestMenu.subSubMenu112),
//             menuItemButton(TestMenu.subSubMenu113),
//           ],
//         ),
//         menuItemButton(TestMenu.subMenu12),
//       ],
//     ),
//     submenuButton(
//       TestMenu.mainMenu2,
//       menuChildren: <Widget>[
//         menuItemButton(
//           TestMenu.subMenu20,
//           leadingIcon: const Icon(Icons.ac_unit),
//           enabled: false,
//         ),
//       ],
//     ),
//     if (includeExtraGroups)
//       submenuButton(
//         TestMenu.mainMenu3,
//         menuChildren: <Widget>[
//           menuItemButton(TestMenu.subMenu30, enabled: false),
//         ],
//       ),
//     if (includeExtraGroups)
//       submenuButton(
//         TestMenu.mainMenu4,
//         menuChildren: <Widget>[
//           menuItemButton(TestMenu.subMenu40, enabled: false),
//           menuItemButton(TestMenu.subMenu41, enabled: false),
//           menuItemButton(TestMenu.subMenu42, enabled: false),
//         ],
//       ),
//     submenuButton(TestMenu.mainMenu5, menuChildren: const <Widget>[]),
//   ];
//   return result;
// }

// enum TestMenu {
//   mainMenu0('&Menu 0'),
//   mainMenu1('M&enu &1'),
//   mainMenu2('Me&nu 2'),
//   mainMenu3('Men&u 3'),
//   mainMenu4('Menu &4'),
//   mainMenu5('Menu &5 && &6 &'),
//   subMenu00('Sub &Menu 0&0'),
//   subMenu01('Sub Menu 0&1'),
//   subMenu02('Sub Menu 0&2'),
//   subMenu10('Sub Menu 1&0'),
//   subMenu11('Sub Menu 1&1'),
//   subMenu12('Sub Menu 1&2'),
//   subMenu20('Sub Menu 2&0'),
//   subMenu30('Sub Menu 3&0'),
//   subMenu40('Sub Menu 4&0'),
//   subMenu41('Sub Menu 4&1'),
//   subMenu42('Sub Menu 4&2'),
//   subSubMenu110('Sub Sub Menu 11&0'),
//   subSubMenu111('Sub Sub Menu 11&1'),
//   subSubMenu112('Sub Sub Menu 11&2'),
//   subSubMenu113('Sub Sub Menu 11&3');

//   const TestMenu(this.acceleratorLabel);
//   final String acceleratorLabel;
//   // Strip the accelerator markers.
//   String get label => MenuAcceleratorLabel.stripAcceleratorMarkers(acceleratorLabel);
// }