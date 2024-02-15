import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide  MenuAcceleratorLabel, MenuAnchor, MenuBar, MenuController, MenuItemButton, SubmenuButton;
import 'cupertino_menu.0.dart';
import 'test_0.dart';
// import 'menu.dart';
// import 'test_anchor.dart';

/// Flutter code sample for [MenuAnchor].

void main() => runApp(const Main());

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> with SingleTickerProviderStateMixin {
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
    return const CupertinoApp(
      localizationsDelegates: <LocalizationsDelegate>[
        DefaultCupertinoLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: CupertinoMenuApp(),
    );

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


