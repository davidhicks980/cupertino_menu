import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide  MenuAcceleratorLabel, MenuAnchor, MenuBar, MenuController, MenuItemButton, SubmenuButton;

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

class _MenuAppState extends State<MenuApp> with SingleTickerProviderStateMixin {
  final bool _darkMode = true;
  bool hide = false;
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  FocusNode? itemFocusNode = FocusNode();
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 1000,
    ),
  );
   List<CupertinoMenuItem> get items => <CupertinoMenuItem>[
        CupertinoMenuItem(
          closeOnActivate: false,
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),

          focusNode: focusNode1,
           onPressed: () {
            setState(() {
              hide = !hide;
            });
          },
          subtitle: const Text('Item 0'),
          child: const Text('Item 0'),
        ),
        CupertinoMenuItem(
          closeOnActivate: false,
          leading: const Icon(Icons.add),
          trailing: const Icon(Icons.add),
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
          focusNode: focusNode2,
          onPressed: () {
            setState(() {
              hide = !hide;
            });
          },
          child: const Text('Item 1'),
        ),
        CupertinoMenuItem(
          closeOnActivate: false,
           onPressed: () {
            setState(() {
              hide = !hide;
            });
          },
          child: const Text('Item 2'),
        ),
      ];

  @override
  void dispose() {
    focusNode1.dispose();
    focusNode2.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const CupertinoThemeData themeData = CupertinoThemeData();
    return const CupertinoApp(
          home: CupertinoMenuAnchor(
            builder: _buildAnchor,
            menuChildren: <Widget>[
              _DebugCupertinoMenuEntryMixin(child: Text('Menu 0')),
              _DebugCupertinoMenuEntryMixin(child: Text('Menu 0')),
              _DebugCupertinoMenuEntryMixin(child: Text('Menu 0')),
            ],
          ),
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

  Widget _buildAnchor(
  BuildContext context,
  MenuController controller,
  Widget? child,
) {
  return Material(
    child: InkWell(
        onTap: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        child:  SizedBox(
          height: 56,
          width: 56,
          child: TestMenu.anchorButton.text,
        )),
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