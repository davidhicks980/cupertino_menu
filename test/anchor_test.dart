// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:example/menu.dart';
import 'package:example/menu_item.dart';
import 'package:example/test_anchor.dart';
import 'package:flutter/cupertino.dart' show CupertinoApp, CupertinoColors, CupertinoDynamicColor, CupertinoPageScaffold, CupertinoTheme, CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide  CheckboxMenuButton, MenuAcceleratorLabel, MenuAnchor, MenuBar, MenuController, MenuItemButton, RadioMenuButton, SubmenuButton;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'semantics.dart';

void main() {
  late CupertinoMenuController controller;
  String? focusedMenu;
  final List<TestMenu> selected = <TestMenu>[];
  final List<TestMenu> opened = <TestMenu>[];
  final List<TestMenu> closed = <TestMenu>[];
  final GlobalKey menuItemKey = GlobalKey();
  const bool printOut = true;
  Matcher rectEquals(Rect rect) {
    return rectMoreOrLessEquals(rect, epsilon: 0.1);
  }

  Future<void> rectsEqual(List<Rect> rects1, List<Rect> rects2) async {
    print(rects1);
    // for (int i = 0; i < math.max(rects1.length, rects2.length); i++) {
    //   expect(rects1[i], rectEquals(rects2[i]));
    // }
  }
  Finder findDecoration(Finder finder) =>
          find.descendant(of: finder, matching: find.byType(DecoratedBox));

  Color? findBoxDecorationColor( WidgetTester tester, Finder finder,) {
    return (tester
            .widget<DecoratedBox>(findDecoration(finder).first)
            .decoration as BoxDecoration)
        .color;
  }
  TextStyle? findTextStyle( WidgetTester tester, TestMenu menu,) {
    return tester.firstWidget<RichText>(find.descendant(
              of: menu.findText,
            matching: find.byType(RichText))).text.style;
  }



  void expectPrint(Rect rect1, Matcher rect2){
    if(printOut){
      print(rect1);
    } else {
      expect(rect1, rect2);
    }
  }

  void onPressed(TestMenu item) {
    selected.add(item);
  }

  void onOpen() {
    opened.add(TestMenu.anchorButton);
  }

  void onClose() {
    opened.remove(TestMenu.anchorButton);
    closed.add(TestMenu.anchorButton);
  }

  void handleFocusChange() {
    focusedMenu = (primaryFocus?.debugLabel ?? primaryFocus).toString();
    print(focusedMenu);
  }

  setUp(() {
    focusedMenu = null;
    selected.clear();
    opened.clear();
    closed.clear();
    controller = CupertinoMenuController();
    focusedMenu = null;
  });

  Future<void> changeSurfaceSize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  void listenForFocusChanges() {
    FocusManager.instance.addListener(handleFocusChange);
    addTearDown(() => FocusManager.instance.removeListener(handleFocusChange));
  }

  Finder findMenuPanels() {
    return find.byWidgetPredicate(
        (Widget widget) => widget.runtimeType.toString() == '_MenuPanel');
  }

  Finder findCupertinoMenuAnchorItemLabels() {
    return find.byWidgetPredicate(
        (Widget widget) => widget.runtimeType.toString() == '_MenuItemLabel');
  }

  // Finds the mnemonic associated with the menu item that has the given label.
  Finder findMnemonic(String label) {
    return find
        .descendant(
          of: find.ancestor(
              of: find.text(label),
              matching: findCupertinoMenuAnchorItemLabels()),
          matching: find.byType(Text),
        )
        .last;
  }

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
    addTearDown(focusNode.dispose);
    addTearDown(opened.clear);
    addTearDown(closed.clear);
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
                  controller: controller,
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

  Future<TestGesture> hoverOver(WidgetTester tester, Finder finder) async {
    final TestGesture gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.moveTo(tester.getCenter(finder));
    await tester.pumpAndSettle();
    return gesture;
  }

  T findMenuPanelWidget<T extends Widget>(WidgetTester tester) {
    return tester.widget<T>(
      find
          .descendant(of: findMenuPanels(), matching: find.byType(T))
          .first,
    );
  }

  // testWidgets('Menu defaults', (WidgetTester tester) async {
  //   final ThemeData themeData = ThemeData();
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       theme: themeData,
  //       home: Material(
  //         child: CupertinoMenuAnchor(
  //           controller: controller,
  //           menuChildren: createTestMenus(
  //             onPressed: onPressed,
  //             onOpen: onOpen,
  //             onClose: onClose,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   // menu bar(horizontal menu)
  //   Finder menuMaterial = find
  //       .ancestor(
  //         of: find.byType(TextButton),
  //         matching: find.byType(Material),
  //       )
  //       .first;

  //   Material material = tester.widget<Material>(menuMaterial);
  //   expect(opened, isEmpty);
  //   expect(material.color, themeData.colorScheme.surface);
  //   expect(material.shadowColor, themeData.colorScheme.shadow);
  //   expect(material.surfaceTintColor, themeData.colorScheme.surfaceTint);
  //   expect(material.elevation, 3.0);
  //   expect(material.shape, const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))));

  //   Finder buttonMaterial = find
  //       .descendant(
  //         of: find.byType(TextButton),
  //         matching: find.byType(Material),
  //       )
  //       .first;
  //   material = tester.widget<Material>(buttonMaterial);
  //   expect(material.color, Colors.transparent);
  //   expect(material.elevation, 0.0);
  //   expect(material.shape, const RoundedRectangleBorder());
  //   expect(material.textStyle?.color, themeData.colorScheme.onSurface);
  //   expect(material.textStyle?.fontSize, 14.0);
  //   expect(material.textStyle?.height, 1.43);

  //   // vertical menu
  //   await tester.tap(find.text(TestMenu.item0.label));
  //   await tester.pump();

  //   menuMaterial = find
  //       .ancestor(
  //         of: find.widgetWithText(TextButton, TestMenu.item6.label),
  //         matching: find.byType(Material),
  //       )
  //       .first;

  //   material = tester.widget<Material>(menuMaterial);
  //   expect(opened.last, equals(TestMenu.item0));
  //   expect(material.color, themeData.colorScheme.surface);
  //   expect(material.shadowColor, themeData.colorScheme.shadow);
  //   expect(material.surfaceTintColor, themeData.colorScheme.surfaceTint);
  //   expect(material.elevation, 3.0);
  //   expect(material.shape, const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))));

  //   buttonMaterial = find
  //       .descendant(
  //         of: find.widgetWithText(TextButton, TestMenu.item6.label),
  //         matching: find.byType(Material),
  //       )
  //       .first;
  //   material = tester.widget<Material>(buttonMaterial);
  //   expect(material.color, Colors.transparent);
  //   expect(material.elevation, 0.0);
  //   expect(material.shape, const RoundedRectangleBorder());
  //   expect(material.textStyle?.color, themeData.colorScheme.onSurface);
  //   expect(material.textStyle?.fontSize, 14.0);
  //   expect(material.textStyle?.height, 1.43);

  //   await tester.tap(find.text(TestMenu.item0.label));
  //   await tester.pump();
  //   expect(find.byIcon(Icons.add), findsOneWidget);
  //   final RichText iconRichText = tester.widget<RichText>(
  //     find.descendant(of: find.byIcon(Icons.add), matching: find.byType(RichText)),
  //   );
  //   expect(iconRichText.text.style?.color, themeData.colorScheme.onSurfaceVariant);
  // });

  // testWidgets('Menu defaults - disabled', (WidgetTester tester) async {
  //   final ThemeData themeData = ThemeData();
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       theme: themeData,
  //       home: Material(
  //         child: CupertinoMenuAnchor(
  //           controller: controller,
  //          menuChildren: createTestMenus(
  //             onPressed: onPressed,
  //             onOpen: onOpen,
  //             onClose: onClose,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   // menu bar(horizontal menu)
  //   Finder menuMaterial = find
  //       .ancestor(
  //         of: find.widgetWithText(TextButton, TestMenu.item5.label),
  //         matching: find.byType(Material),
  //       )
  //       .first;

  //   Material material = tester.widget<Material>(menuMaterial);
  //   expect(opened, isEmpty);
  //   expect(material.color, themeData.colorScheme.surface);
  //   expect(material.shadowColor, themeData.colorScheme.shadow);
  //   expect(material.surfaceTintColor, themeData.colorScheme.surfaceTint);
  //   expect(material.elevation, 3.0);
  //   expect(material.shape, const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))));

  //   Finder buttonMaterial = find
  //       .descendant(
  //         of: find.widgetWithText(TextButton, TestMenu.item5.label),
  //         matching: find.byType(Material),
  //       )
  //       .first;
  //   material = tester.widget<Material>(buttonMaterial);
  //   expect(material.color, Colors.transparent);
  //   expect(material.elevation, 0.0);
  //   expect(material.shape, const RoundedRectangleBorder());
  //   expect(material.textStyle?.color, themeData.colorScheme.onSurface.withOpacity(0.38));

  //   // vertical menu
  //   await tester.tap(find.text(TestMenu.item2.label));
  //   await tester.pump();

  //   menuMaterial = find
  //       .ancestor(
  //         of: find.widgetWithText(TextButton, TestMenu.item9.label),
  //         matching: find.byType(Material),
  //       )
  //       .first;

  //   material = tester.widget<Material>(menuMaterial);
  //   expect(material.color, themeData.colorScheme.surface);
  //   expect(material.shadowColor, themeData.colorScheme.shadow);
  //   expect(material.surfaceTintColor, themeData.colorScheme.surfaceTint);
  //   expect(material.elevation, 3.0);
  //   expect(material.shape, const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))));

  //   buttonMaterial = find
  //       .descendant(
  //         of: find.widgetWithText(TextButton, TestMenu.item9.label),
  //         matching: find.byType(Material),
  //       )
  //       .first;
  //   material = tester.widget<Material>(buttonMaterial);
  //   expect(material.color, Colors.transparent);
  //   expect(material.elevation, 0.0);
  //   expect(material.shape, const RoundedRectangleBorder());
  //   expect(material.textStyle?.color, themeData.colorScheme.onSurface.withOpacity(0.38));

  //   expect(find.byIcon(Icons.ac_unit), findsOneWidget);
  //   final RichText iconRichText = tester.widget<RichText>(
  //     find.descendant(of: find.byIcon(Icons.ac_unit), matching: find.byType(RichText)),
  //   );
  //   expect(iconRichText.text.style?.color, themeData.colorScheme.onSurface.withOpacity(0.38));
  // });

  testWidgets('focus is returned to previous focus before invoking onPressed',
      (WidgetTester tester) async {
    final FocusNode buttonFocus = FocusNode(debugLabel: 'Button Focus');
    addTearDown(buttonFocus.dispose);
    FocusNode? focusInOnPressed;
    void onMenuSelected() {

      focusInOnPressed = FocusManager.instance.primaryFocus;
    }

    await tester.pumpWidget(
      buildApp(
        <Widget>[
          CupertinoMenuAnchor(
           menuChildren: <Widget>[
              CupertinoMenuItem(
                onPressed: onMenuSelected,
                child: TestMenu.item1.text,
              ),
            ],
          ),
          ElevatedButton(
            autofocus: true,
            onPressed: () {},
            focusNode: buttonFocus,
            child: TestMenu.outsideButton.text,
          ),
        ],
      ),
    );

    await tester.pump();
    expect(FocusManager.instance.primaryFocus, equals(buttonFocus));

    await tester.tap(find.byType(CupertinoMenuAnchor));
    await tester.pumpAndSettle();

    await tester.tap(TestMenu.item1.findText);
    await tester.pump();
    await tester.pump();

    expect(focusInOnPressed, equals(buttonFocus));
    expect(FocusManager.instance.primaryFocus, equals(buttonFocus));
  });

  group('Menu functions', () {
    group('Open and closing', () {
      Future<void> openCloseTester(
        WidgetTester tester,
        CupertinoMenuController controller, {
        required FutureOr<void> Function() open,
        required FutureOr<void> Function() close,
      }) async {
        await tester.pumpWidget(
          buildApp(
            <Widget>[
              CupertinoMenuAnchor(
                controller: controller,
                menuChildren: <Widget>[
                  CupertinoMenuItem(
                    child: TestMenu.item1.text,
                  ),
                  CupertinoMenuItem(
                    leading: const Icon(Icons.send),
                    trailing: const Icon(Icons.mail),
                    child: TestMenu.item2.text,
                  ),
                  CupertinoMenuItem(
                    child: TestMenu.item4.text,
                  ),
                ],

              ),
            ],
          ),
        );


        // Create the menu. The menu is closed, so no menu items should be found in
        // the widget tree.
        await tester.pumpAndSettle();
        expect(controller.animationStatus, AnimationStatus.dismissed);
        expect(TestMenu.item1.findText, findsNothing);
        expect(controller.isOpen, isFalse);

        // Open the menu.
        await open();
        await tester.pump();

        // The menu is opening => AnimationStatus.forward.
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // After 100 ms, the menu should still be animating open.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Interrupt the opening animation by closing the menu.
        await close();
        await tester.pump();

        // The menu is closing => AnimationStatus.reverse.
        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Open the menu again.
        await open();
        await tester.pump();

        // The menu is animating open => AnimationStatus.forward.
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has finished opening, so it should report it's animation
        // status as AnimationStatus.completed.
        expect(controller.animationStatus, AnimationStatus.completed);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Close the menu.
        await close();
        await tester.pump();

        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // After 100 ms, the menu should still be closing.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Interrupt the closing animation by opening the menu.
        await open();
        await tester.pump();

        // The menu is animating open => AnimationStatus.forward.
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Close the menu again.
        await close();
        await tester.pump();

        // The menu is closing => AnimationStatus.reverse.
        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has closed => AnimationStatus.dismissed.
        expect(controller.animationStatus, AnimationStatus.dismissed);
        expect(controller.isOpen, isFalse);
        expect(TestMenu.item1.findText, findsNothing);
      }

      testWidgets('controller open and close', (WidgetTester tester) async {
        final CupertinoMenuController controller = CupertinoMenuController();
        await openCloseTester(
          tester,
          controller,
          open: controller.open,
          close: controller.close,
        );
      });
      testWidgets('tap open and close', (WidgetTester tester) async {
        final CupertinoMenuController controller = CupertinoMenuController();
        await openCloseTester(
          tester,
          controller,
          open: () async {
             await  tester.tap(find.byType(CupertinoMenuAnchor));
          },
          close: () async {
              await tester.tap(find.byType(CupertinoMenuAnchor));
          },
        );
      });
      testWidgets('close when Navigator.pop() is called',
          (WidgetTester tester) async {
        final CupertinoMenuController controller = CupertinoMenuController();
        final GlobalKey<State<StatefulWidget>> menuItemGK = GlobalKey();
        await tester.pumpWidget(
          buildApp(
            <Widget>[
              CupertinoMenuAnchor(
                controller: controller,
                menuChildren: <Widget>[
                  CupertinoMenuItem(
                    key: menuItemGK,
                    child: TestMenu.item1.text,
                  ),
                  CupertinoMenuItem(
                    leading: const Icon(Icons.send),
                    trailing: const Icon(Icons.mail),
                    child: TestMenu.item2.text,
                  ),
                  CupertinoMenuItem(
                    child: TestMenu.item4.text,
                  ),
                ],
                child: TestMenu.anchorButton.text,
              ),
            ],
          ),
        );
        controller.open();
        await tester.pumpAndSettle();
        expect(TestMenu.item1.findText, findsOneWidget);
        expect(controller.isOpen, isTrue);
        Navigator.pop(menuItemGK.currentContext!);
        await tester.pumpAndSettle();
        expect(TestMenu.item1.findText, findsNothing);
      });
    });

    testWidgets('LTR geometry', (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Material(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoMenuAnchor(

                        menuChildren: createTestMenus2(onPressed: onPressed),
                      ),
                    ),
                  ],
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      final Finder menuAnchor = find.byType(CupertinoMenuAnchor);
      expect(tester.getRect(menuAnchor),
          rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));

      // Open and make sure things are the right size.
      await tester.tap(menuAnchor);
      await tester.pump();

      expect(tester.getRect(menuAnchor),
          rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));

      expect(tester.getRect(TestMenu.item5Disabled.findText),
          rectEquals(const Rect.fromLTRB(400.0, 28.0, 400.0, 28.0)));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(TestMenu.item5Disabled.findText),
        rectEquals(const Rect.fromLTRB(275.0, 445.9, 525.0, 489.9)),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(menuAnchor),
          rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));
      expect(
        tester.getRect(TestMenu.item5Disabled.findText),
        rectEquals(const Rect.fromLTRB(275.0, 445.9, 525.0, 489.9)),
      );

      // Decorative surface sizes should match
      const Rect surfaceSize = Rect.fromLTRB(275.0, 61.9, 525.0, 533.9);
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item5Disabled.findText,
                  matching: find.byType(DecoratedBoxTransition))
              .first,
        ),
        rectEquals(surfaceSize),
      );
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item5Disabled.findText, matching: find.byType(FadeTransition))
              .first,
        ),
        rectEquals(surfaceSize),
      );

      // Test menu bar size when not expanded.
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Column(
              children: <Widget>[
                CupertinoMenuAnchor(
                  menuChildren: createTestMenus2(onPressed: onPressed),
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getRect(menuAnchor),
        rectEquals(const Rect.fromLTRB(372.0, 0.0, 428.0, 56.0)),
      );
    });

    testWidgets('RTL geometry', (WidgetTester tester) async {
      final UniqueKey menuKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Material(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoMenuAnchor(
                          key: menuKey,
                          menuChildren: createTestMenus2(onPressed: onPressed),
                        ),
                      ),
                    ],
                  ),
                  const Expanded(child: Placeholder()),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final Finder menuAnchor = find.byType(CupertinoMenuAnchor);
      expect(tester.getRect(menuAnchor),
          rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));

      // Open and make sure things are the right size.
      await tester.tap(find.byKey(menuKey));
      await tester.pump();

      // The menu just started opening, therefore menu items should be Size.zero
      expect(tester.getRect(menuAnchor),
          rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));
      expect(tester.getRect(TestMenu.item6.findText),
          rectEquals(const Rect.fromLTRB(400.0, 28.0, 400.0, 28.0)));

      // When the menu is fully open, the menu items should be the correct size.
      await tester.pumpAndSettle();
      expect(tester.getRect(menuAnchor),
          rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));
      expect(
        tester.getRect(TestMenu.item5Disabled.findText),
        rectEquals(const Rect.fromLTRB(275.0, 445.9, 525.0, 489.9)),
      );

      // Decorative surface sizes should match
      const Rect surfaceSize = Rect.fromLTRB(275.0, 61.9, 525.0, 533.9);
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item5Disabled.findText,
                  matching: find.byType(DecoratedBoxTransition))
              .first,
        ),
        rectEquals(surfaceSize),
      );
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item5Disabled.findText, matching: find.byType(FadeTransition))
              .first,
        ),
        rectEquals(surfaceSize),
      );

      // Test menu bar size when not expanded.
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
              child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: <Widget>[
                CupertinoMenuAnchor(
                  menuChildren: createTestMenus2(onPressed: onPressed),
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
          )),
        ),
      );

      await tester.pump();
      expect(
        tester.getRect(menuAnchor),
        rectEquals(const Rect.fromLTRB(372.0, 0.0, 428.0, 56.0)),
      );
    });

    testWidgets('menu alignment and offset in LTR',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(),
      );

      final Finder anchor = find.byType(ElevatedButton);
      expectPrint(tester.getRect(anchor),
        rectEquals(const Rect.fromLTRB(319.6, 20.0, 480.4, 68.0)));

      final Finder findMenuScope = find
          .ancestor(
              of: TestMenu.item1.findText, matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(anchor);
      await tester.pumpAndSettle();

      Future<void> testPosition(Rect position, [AlignmentDirectional? alignment, AlignmentDirectional? menuAlignment])async {
        await tester.pumpWidget(buildTestApp(alignment: alignment, menuAlignment: menuAlignment));
        await tester.pump();
        expect(tester.getRect(findMenuScope),
          rectEquals(position));
      }

      await testPosition(const Rect.fromLTRB(275.0, 73.9, 525.0, 545.9));
      await testPosition(
        const Rect.fromLTRB(69.6, 20.0, 319.6, 492.0),
        AlignmentDirectional.topStart,
        AlignmentDirectional.topEnd,
      );
      await testPosition(
        const Rect.fromLTRB(275.0, 8.0, 525.0, 480.0),
        AlignmentDirectional.center,
        AlignmentDirectional.center,
      );
      await testPosition(
        const Rect.fromLTRB(480.4, 8.0, 730.4, 480.0),
        AlignmentDirectional.bottomEnd,
        AlignmentDirectional.bottomStart,
      );
      await testPosition(
        const Rect.fromLTRB(69.6, 20.0, 319.6, 492.0),
        AlignmentDirectional.topStart,
        AlignmentDirectional.topEnd,
      );

      final Rect menuRect = tester.getRect(findMenuScope);
      await tester.pumpWidget(
        buildTestApp(
          alignment: AlignmentDirectional.topStart,
          menuAlignment: AlignmentDirectional.topEnd,
          alignmentOffset: const Offset(10, 20),
        ),
      );
      await tester.pump();
      final Rect offsetMenuRect = tester.getRect(findMenuScope);
      expect(
        offsetMenuRect.topLeft - menuRect.topLeft,
        equals(const Offset(10, 20)),
      );
    });

    testWidgets('menu alignment and offset in RTL',
        (WidgetTester tester) async {
       await tester.pumpWidget(
        buildTestApp(
          textDirection: TextDirection.rtl,
        ),
      );

      final Finder anchor = find.byType(ElevatedButton);
      expect(tester.getRect(anchor),
        rectEquals(const Rect.fromLTRB(319.6, 20.0, 480.4, 68.0)));

      final Finder findMenuScope = find
          .ancestor(of: TestMenu.item1.findText, matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(anchor);
      await tester.pumpAndSettle();

      Future<void> testPosition(Rect position, [AlignmentDirectional? alignment, AlignmentDirectional? menuAlignment])async {
        await tester.pumpWidget(buildTestApp(
          textDirection: TextDirection.rtl,
          alignment: alignment,
          menuAlignment: menuAlignment,
        ));
        await tester.pump();
        expect(tester.getRect(findMenuScope),
          rectEquals(position));
      }

      await testPosition(const Rect.fromLTRB(275.0, 73.9, 525.0, 545.9));
      await testPosition(
        const Rect.fromLTRB(69.6, 20.0, 319.6, 492.0),
        AlignmentDirectional.topStart,
        AlignmentDirectional.topEnd,
      );
      await testPosition(
        const Rect.fromLTRB(275.0, 8.0, 525.0, 480.0),
        AlignmentDirectional.center,
        AlignmentDirectional.center,
      );
      await testPosition(
        const Rect.fromLTRB(480.4, 8.0, 730.4, 480.0),
        AlignmentDirectional.bottomEnd,
        AlignmentDirectional.bottomStart,
      );
      await testPosition(
        const Rect.fromLTRB(69.6, 20.0, 319.6, 492.0),
        AlignmentDirectional.topStart,
        AlignmentDirectional.topEnd,
      );

      final Rect menuRect = tester.getRect(findMenuScope);
      await tester.pumpWidget(
        buildTestApp(
          textDirection: TextDirection.rtl,
          alignment: AlignmentDirectional.topStart,
          menuAlignment: AlignmentDirectional.topEnd,
          alignmentOffset: const Offset(10, 20),
        ),
      );
      await tester.pump();
      final Rect offsetMenuRect = tester.getRect(findMenuScope);
      expect(
        offsetMenuRect.topLeft - menuRect.topLeft,
        equals(const Offset(-10, 20)),
      );
    });

    testWidgets('menu position in LTR', (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestApp(alignmentOffset: const Offset(100, 50)));

      final Rect buttonRect = tester.getRect(find.byType(ElevatedButton));
      expect(buttonRect, rectEquals(const Rect.fromLTRB(319.6, 20.0, 480.4, 68.0)));

      final Finder findMenuScope = find
          .ancestor(
              of: find.text(TestMenu.item1.label), matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();
      expect(tester.getRect(findMenuScope),
          rectEquals(const Rect.fromLTRB(375.0, 120.0, 625.0, 592.0)));

      // Now move the menu by calling open() again with a local position on the
      // anchor.
      controller.open(position: const Offset(200, 200));
      await tester.pumpAndSettle();
      expect(tester.getRect(findMenuScope),
          rectEquals(const Rect.fromLTRB(494.6, 120.0, 744.6, 592.0)));
    });

    testWidgets('menu position in RTL', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        alignmentOffset: const Offset(100, 50),
        textDirection: TextDirection.rtl,
      ));

      final Rect buttonRect = tester.getRect(find.byType(ElevatedButton));
      expect(buttonRect,
          rectEquals(const Rect.fromLTRB(319.6, 20.0, 480.4, 68.0)));

      final Finder findMenuScope = find
          .ancestor(
              of: find.text(TestMenu.item1.label), matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(tester.getRect(findMenuScope),
          rectEquals(const Rect.fromLTRB(375.0, 120.0, 625.0, 592.0)));


      // Now move the menu by calling open() again with a local position on the
      // anchor.
      controller.open(position: const Offset(400, 200));
      await tester.pump();
      expect(tester.getRect(findMenuScope),
          rectEquals(const Rect.fromLTRB(819.6, 270.0, 819.6, 270.0)));
    });

    testWidgets('LTR app and anchor padding',
        (WidgetTester tester) async {

      // Out of MaterialApp:
      //    - overlay position affected
      //    - anchor position affected

      // In MaterialApp:
      //   - anchor position affected

      // Padding inside MaterialApp DOES NOT affect the overlay position BUT
      // DOES affect the anchor position
      await tester.pumpWidget(
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 10.0, bottom: 8.0),
          child: MaterialApp(
            theme: ThemeData(useMaterial3: false),
            home: Material(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 23, right: 13.0, top: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CupertinoMenuAnchor(
                            menuChildren: createTestMenus2(onPressed: onPressed),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: Placeholder()),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final Finder anchor = find.byType(CupertinoMenuAnchor);
      expect(
        tester.getRect(anchor),
        rectEquals(const Rect.fromLTRB(43.0, 8.0, 777.0, 64.0)));

      // Open and make sure things are the right size.
      await tester.tap(anchor);
      await tester.pumpAndSettle();

      expect(tester.getRect(anchor),
      rectEquals(const Rect.fromLTRB(43.0, 8.0, 777.0, 64.0)));

      expect(
        tester.getRect(TestMenu.item0.findText),
        rectEquals(const Rect.fromLTRB(285.0, 69.9, 535.0, 113.9)),
      );

      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item6.findText,
                  matching: find.byType(DecoratedBoxTransition))
              .first),

        rectEquals(const Rect.fromLTRB(285.0, 69.9, 535.0, 541.9)),
      );

      // Close and make sure it goes back where it was.
      await tester.tap(TestMenu.item6.findText);
      await tester.pump();

      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          rectEquals(const Rect.fromLTRB(43.0, 8.0, 777.0, 64.0)));
    });

    testWidgets('RTL app and anchor padding',
        (WidgetTester tester) async {
      // Out of MaterialApp:
      //    - overlay position affected
      //    - anchor position affected

      // In MaterialApp:
      //   - anchor position affected
      await tester.pumpWidget(
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 10.0, bottom: 8.0),
          child: MaterialApp(
            theme: ThemeData(useMaterial3: false),
            home: Material(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 23, right: 13.0, top: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: CupertinoMenuAnchor(
                                                         menuChildren:
                                  createTestMenus2(onPressed: onPressed),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(child: Placeholder()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      const Rect anchorPosition = Rect.fromLTRB(43.0, 8.0, 777.0, 64.0);
      final Finder anchor = find.byType(CupertinoMenuAnchor);
      expect(tester.getRect(anchor),
          rectEquals(anchorPosition));

      // Open and make sure things are the right size.
      await tester.tap(anchor);
      await tester.pumpAndSettle();

      expect(tester.getRect(anchor),
          rectEquals(anchorPosition));
      expect(
        tester.getRect(TestMenu.item6.findText),
        rectEquals(const Rect.fromLTRB(285.0, 497.9, 535.0, 541.9)),
      );
      expect(
        tester.getRect(find
            .ancestor(
                of: TestMenu.item6.findText, matching: find.byType(DecoratedBoxTransition))
            .first),
        rectEquals(const Rect.fromLTRB(285.0, 69.9, 535.0, 541.9)),
      );

      // Close and make sure it goes back where it was.
      await tester.tap(TestMenu.item1.findText);
      await tester.pumpAndSettle();

      expect(tester.getRect(anchor),
          rectEquals(anchorPosition));
    });

    testWidgets('visual attributes can be set', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoMenuAnchor(
                        menuChildren: createTestMenus2(onPressed: onPressed),
                      ),
                    ),
                  ],
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );

      // Open and make sure things are the right size.
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      expect(tester.getRect(findMenuPanels()),
          equals(const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0)));
      final DecoratedBoxTransition material = findMenuPanelWidget<DecoratedBoxTransition>(tester);
      expect(material.decoration.value, equals(const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.12),
            spreadRadius: 30,
            blurRadius: 50,
          ),
        ])));
    });

    testWidgets('panel clip behavior', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Center(
              child: CupertinoMenuAnchor(
                menuChildren: const <Widget>[
                  CupertinoMenuItem(
                    child: Text('Button 1'),
                  ),
                ],
                builder: (BuildContext context,
                    CupertinoMenuController controller, Widget? child) {
                  return FilledButton(
                    onPressed: () {
                      controller.open();
                    },
                    child: const Text('Tap me'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      // Test default clip behavior.
      expect(findMenuPanelWidget<ClipRRect>(tester).clipBehavior,
          equals(Clip.hardEdge));
      // Close the menu.
      await tester.tapAt(const Offset(10.0, 10.0));
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Center(
              child: CupertinoMenuAnchor(
                clipBehavior: Clip.antiAlias,
                menuChildren: const <Widget>[
                  CupertinoMenuItem(
                    child: Text('Button 1'),
                  ),
                ],
                builder: (BuildContext context,
                    CupertinoMenuController controller, Widget? child) {
                  return FilledButton(
                    onPressed: () {
                      controller.open();
                    },
                    child: const Text('Tap me'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap me'));
      await tester.pump();
      // Test custom clip behavior.
       expect(findMenuPanelWidget<ClipRRect>(tester).clipBehavior,
          equals(Clip.antiAlias));
    });

    testWidgets('Menus close and consume tap when consumesOutsideTap is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
            consumesOutsideTap: true,
            onPressed: onPressed,
            onOpen: onOpen,
            onClose: onClose),
      );

      expect(opened, isEmpty);
      expect(closed, isEmpty);

      // Doesn't consume tap when the menu is closed.
      await tester.tap(find.text(TestMenu.outsideButton.label));
      await tester.pump();
      expect(selected, equals(<TestMenu>[TestMenu.outsideButton]));
      selected.clear();

      await tester.tap(find.text(TestMenu.anchorButton.label));
      await tester.pump();

      expect(opened, equals(<TestMenu>[TestMenu.anchorButton]));
      expect(closed, isEmpty);
      expect(selected, equals(<TestMenu>[TestMenu.anchorButton]));
      opened.clear();
      closed.clear();
      selected.clear();

      // The menu is open until it animates closed.
      await tester.tap(find.text(TestMenu.outsideButton.label));
      await tester.pumpAndSettle();

      expect(opened, isEmpty);
      expect(closed, equals(<TestMenu>[TestMenu.anchorButton]));
      // When the menu is open, don't expect the outside button to be selected:
      // it's supposed to consume the key down.
      expect(selected, isEmpty);
      selected.clear();
      opened.clear();
      closed.clear();
    });

    testWidgets(
        'Menus close and DO NOT consume tap when consumesOutsideTap is FALSE',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(onPressed: onPressed, onOpen: onOpen, onClose: onClose),
      );

      expect(opened, isEmpty);
      expect(closed, isEmpty);

      // Doesn't consume tap when the menu is closed.
      await tester.tap(find.text(TestMenu.outsideButton.label));
      await tester.pump();
      expect(selected, equals(<TestMenu>[TestMenu.outsideButton]));
      selected.clear();

      await tester.tap(find.text(TestMenu.anchorButton.label));
      await tester.pump();
      expect(opened, equals(<TestMenu>[TestMenu.anchorButton]));
      expect(closed, isEmpty);
      expect(selected, equals(<TestMenu>[TestMenu.anchorButton]));
      opened.clear();
      closed.clear();
      selected.clear();

      // The menu is open until it animates closed.
      await tester.tap(find.text(TestMenu.outsideButton.label));
      await tester.pumpAndSettle();

      expect(opened, isEmpty);
      expect(closed, equals(<TestMenu>[TestMenu.anchorButton]));
      // Because consumesOutsideTap is false, this is expected to receive its
      // tap.
      expect(selected, equals(<TestMenu>[TestMenu.outsideButton]));
      selected.clear();
      opened.clear();
      closed.clear();
    });

    testWidgets('select works', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home:  CupertinoMenuAnchor(
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus2(
                onPressed: onPressed,
              ),
            ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TestMenu.item1.label));
      await tester.pump();
      expect(selected, equals(<TestMenu>[TestMenu.item1]));
      await tester.pumpAndSettle();
      expect(opened, isEmpty);
      expect(find.text(TestMenu.item1.label), findsNothing);
      selected.clear();
    });

    testWidgets('diagnostics', (WidgetTester tester) async {
      const CupertinoMenuItem item = CupertinoMenuItem(
        child: Text('Child'),
      );
      final CupertinoMenuAnchor menuAnchor = CupertinoMenuAnchor(
        controller: controller,
        menuChildren: const <Widget>[item],
        consumeOutsideTap: true,
        alignmentOffset: const Offset(10, 10),
        child: const Text('Sample Text'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: menuAnchor,
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
      menuAnchor.debugFillProperties(builder);

      final List<String> description = builder.properties
          .where(
              (DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
          .map((DiagnosticsNode node) => node.toString())
          .toList();

      expect(
        description,
        equalsIgnoringHashCodes(
          <String>['AUTO-CLOSE',
          'focusNode: null',
          'clipBehavior: hardEdge',
          'alignmentOffset: Offset(10.0, 10.0)',
          'child: Text("Sample Text")',
          ]
      ));
    });



    // TODO(davidhicks980): Tab traversal is broken when encountering material
    // submenus. This is found in master material menu as well
    testWidgets('keyboard tab traversal works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Column(
              children: <Widget>[
                CupertinoMenuAnchor(
                  controller: controller,
                  onOpen: onOpen,
                  onClose: onClose,
                  menuChildren: createTestMenus2(
                    onPressed: onPressed,
                  ),
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );

      listenForFocusChanges();
      // Have to open a menu initially to start things going.
      // pumpAndSettle is not used here because we should be able to
      // traverse the menu before it is fully open.
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pump();

      // First focus is set when the menu is opened.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item1.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item3.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item4.debugFocusLabel));

      /* 5 is disabled */

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item6.debugFocusLabel));

      // Should cycle back to the beginning.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);

      expect(focusedMenu, equals(TestMenu.item6.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item4.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item3.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item1.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(focusedMenu, equals(TestMenu.item6.debugFocusLabel));

    });

    testWidgets('keyboard directional traversal works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus2(
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      );

      listenForFocusChanges();

      // Have to open a menu initially to start things going.
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item1.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item3.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item4.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item4.debugFocusLabel));




    });

    testWidgets('keyboard directional traversal works in RTL mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Material(
              child: CupertinoMenuAnchor(
                controller: controller,
                onOpen: onOpen,
                onClose: onClose,
                menuChildren: createTestMenus2(
                  onPressed: onPressed,
                ),
              ),
            ),
          ),
        ),
      );
      listenForFocusChanges();

       // Have to open a menu initially to start things going.
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.item1.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.matItem3.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.item4.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.matMenu5.debugFocusLabel));

      // // Focusing on the submenu anchor should open the submenu.
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6.debugFocusLabel));
      // expect(find.text(TestMenu.matMenu6_0.label), findsOne);

      // // Enter submenu (6)
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      // expect(focusedMenu, equals(TestMenu.matMenu6_0.debugFocusLabel));

      // // Focus next submenu (6.1), should open
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // await tester.pump();
      // expect(focusedMenu, equals( TestMenu.matMenu6_1.debugFocusLabel));
      // expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // // Press space, should close
      // await tester.sendKeyEvent(LogicalKeyboardKey.space);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      // expect(find.text(TestMenu.matMenu6_1_0.label), findsNothing);

      // // ArrowRight should open the submenu again.
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      // expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // // Arrow down, should close the submenu
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // await tester.pump();
      // expect(focusedMenu, equals( TestMenu.matMenu6_2.debugFocusLabel));
      // expect(find.text(TestMenu.matMenu6_1_0.label), findsNothing);

      // // At end, focus should not loop
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // await tester.pump();
      // expect(focusedMenu, equals( TestMenu.matMenu6_2.debugFocusLabel));

      // // Return to submenu (6.1), should open
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      // expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // // Enter submenu
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6_1_0.debugFocusLabel));

      // // Leave submenu without closing it.
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      // expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // // Move up, should close the submenu.
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6_0.debugFocusLabel));
      // expect(find.text(TestMenu.matMenu6_1_0.label), findsNothing);

      // // Move down, should reopen the submenu.
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      // expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // // Enter submenu (6.1)
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      // expect(focusedMenu, equals(TestMenu.matMenu6_1_0.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.matMenu6_1_1.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.matMenu6_1_2.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.matMenu6_1_3.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      // expect(focusedMenu, equals(TestMenu.matMenu6_1_3.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1.2
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1.1
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1.0
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.0
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6_0.debugFocusLabel));

      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 5
      // await tester.pump();
      // expect(find.text(TestMenu.matMenu6_0.label), findsNothing);
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 4
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 3
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 2
      // expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 1
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 0
      // await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 0
      // expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));
    });

    // TODO(davidhicks980): Moving focus away from 6.1 does not cause focus to
    // move, despite it working on simulator
    testWidgets('hover traversal works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus2(
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      );

      listenForFocusChanges();

      await tester.pump();
      expect(focusedMenu, isNull);

      // Have to open a menu initially to start things going.
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      // Hovering when the menu is already open focuses the item.
      await hoverOver(tester, TestMenu.item1.findText);
      expect(focusedMenu, equals(TestMenu.item1.debugFocusLabel));

      // // Hovering over the menu items opens and focuses them.
      // await hoverOver(tester, TestMenu.matMenu6.findItem);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6.debugFocusLabel));
      // expect(TestMenu.matMenu6_0.findItem, findsOne);

      // await hoverOver(tester, TestMenu.matMenu6_1.findItem);
      // await tester.pump();
      // expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      // expect(TestMenu.matMenu6_1_0.findItem, findsOne);

    });

    testWidgets('menus close on ancestor scroll', (WidgetTester tester) async {
      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                height: 1000,
                alignment: Alignment.center,
                child: CupertinoMenuAnchor(
                  controller: controller,
                  onOpen: onOpen,
                  onClose: onClose,
                  menuChildren: createTestMenus2(
                    onPressed: onPressed,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pump();

      expect(opened, isNotEmpty);
      expect(closed, isEmpty);
      opened.clear();

      scrollController.jumpTo(1000);
      await tester.pumpAndSettle();

      expect(opened, isEmpty);
      expect(closed, isNotEmpty);
    });

    testWidgets('menus do not close on root menu internal scroll',
        (WidgetTester tester) async {
      // Regression test for https://github.com/flutter/flutter/issues/122168.
      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      bool rootOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            menuButtonTheme: MenuButtonThemeData(
              // Increase menu items height to make root menu scrollable.
              style:
                  TextButton.styleFrom(minimumSize: const Size.fromHeight(200)),
            ),
          ),
          home: Material(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                height: 1000,
                alignment: Alignment.topLeft,
                child: CupertinoMenuAnchor(
                  onOpen: () {
                    onOpen();
                    rootOpened = true;
                  },
                  onClose: () {
                    onClose();
                    rootOpened = false;
                    print('root closed');
                  },
                  controller: controller,
                  alignmentOffset: const Offset(0, 10),
                  builder: (BuildContext context,
                      CupertinoMenuController controller, Widget? child) {
                    return FilledButton.tonal(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      child: const Text('Show menu'),
                    );
                  },
                  menuChildren: createTestMenus2(
                    onPressed: onPressed,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show menu'));
      await tester.pumpAndSettle();
      expect(rootOpened, true);

      // Hover the first item.
      final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
          pointer.hover(tester.getCenter(find.text(TestMenu.item0.label))));
      await tester.pump();
      expect(opened, isNotEmpty);

      // Menus do not close on internal scroll.
      await tester.sendEventToBinding(pointer.scroll(const Offset(0.0, 30.0)));
      await tester.pump();
      expect(rootOpened, true);
      expect(closed, isEmpty);

      // Menus close on external scroll.
      scrollController.jumpTo(1000);
      await tester.pumpAndSettle();
      await tester.pump();
      expect(rootOpened, false);
      expect(closed, isNotEmpty);
    });

    testWidgets('menus close on view size change', (WidgetTester tester) async {
      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      final MediaQueryData mediaQueryData =
          MediaQueryData.fromView(tester.view);

      Widget build(Size size) {
        return MaterialApp(
          home: Material(
            child: MediaQuery(
              data: mediaQueryData.copyWith(size: size),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  height: 1000,
                  alignment: Alignment.center,
                  child: CupertinoMenuAnchor(
                    onOpen: onOpen,
                    onClose: onClose,
                    controller: controller,
                    menuChildren: createTestMenus2(
                      onPressed: onPressed,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(build(mediaQueryData.size));

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pump();

      expect(opened, isNotEmpty);
      expect(closed, isEmpty);
      opened.clear();

      const Size smallSize = Size(200, 200);
      await changeSurfaceSize(tester, smallSize);

      await tester.pumpWidget(build(smallSize));

      expect(opened, isEmpty);
      expect(closed, isNotEmpty);
    });
  });
  // TODO(davidhicks980): Accelerators are not used on Apple platforms -- exclude
  // them from the library?


  group('CupertinoMenuController', () {
    testWidgets('Moving a controller to a new instance works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              menuChildren: createTestMenus2(),
            ),
          ),
        ),
      );

      // Open a menu initially.
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      await tester.tap(TestMenu.item6.findText);
      await tester.pump();

      // Now pump a new menu with a different UniqueKey to dispose of the opened
      // menu's node, but keep the existing controller.
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              menuChildren: createTestMenus2(),
            ),
          ),
        ),
      );
      await tester.pump();
    });

  });

  group('CupertinoMenuItem', () {
    testWidgets('leading is used when set', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  leading: const Text('lead'),
                  child: Text(TestMenu.item1.label),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      expect(find.text('lead'), findsOneWidget);
    });

    testWidgets('trailing is used when set', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  trailing: const Text('trailing'),
                  child: Text(TestMenu.item1.label),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      expect(find.text('trailing'), findsOneWidget);
    });

    testWidgets('subtitle is used when set', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  subtitle: const Text('subtitle'),
                  child: Text(TestMenu.item1.label),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      expect(find.text('subtitle'), findsOneWidget);
    });
    testWidgets('disabled items do not interact', (WidgetTester tester) async {
      int interactions = 0;
      final FocusNode focusNode = FocusNode();
      addTearDown(() => focusNode.dispose());
      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );

      focusNode.addListener(() {
        interactions++;
      });

      await gesture.addPointer(location: Offset.zero);
      addTearDown(() => gesture.removePointer());
      await tester.pumpWidget(
        buildTestApp(
          onPressed: onPressed,
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          children: <Widget>[
            CupertinoMenuItem(
              panActivationDelay: const Duration(milliseconds: 10),
              requestFocusOnHover: true,
              focusNode: focusNode,

              onFocusChange: (bool value) {
                interactions++;
              },
              onHover: (bool value) {
                interactions++;
              },
              child: TestMenu.item0.text,
            ),
          ]),
      );
      controller.open();
      await tester.pumpAndSettle();

      focusNode.requestFocus();
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();
      await gesture.down(tester.getCenter(TestMenu.item0.findWidget));
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);

      expect(
        findTextStyle(tester, TestMenu.item0)?.color,
        isSameColorAs(CupertinoColors.systemGrey),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      expect(controller.isOpen, isTrue);
      expect(TestMenu.item0.findWidget, findsOneWidget);
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(interactions, 0);
    });
    testWidgets('close on activate', (WidgetTester tester) async {

      await tester.pumpWidget(
        buildTestApp(
          onClose: onClose,
          onOpen: onOpen,
          children: <Widget>[
            CupertinoMenuItem(
              onPressed: () {},
              closeOnActivate: false,
              child: TestMenu.item0.text,
            ),

          ]),
      );

      controller.open();
      await tester.pumpAndSettle();
      expect(TestMenu.item0.findWidget, findsOneWidget);
      await tester.tap(TestMenu.item0.findWidget);
      await tester.pumpAndSettle();
      expect(opened, isNotEmpty);
      expect(closed, isEmpty);
      expect(TestMenu.item0.findWidget, findsOneWidget);
      await tester.pumpWidget(
        buildTestApp(
          onClose: onClose,
          onOpen: onOpen,
          children: <Widget>[
            CupertinoMenuItem(
              onPressed: () {},
              child: TestMenu.item0.text,
            ),
          ]),
      );
      // Transitions between widgets are animated
      await tester.pumpAndSettle();
      await tester.tap(TestMenu.item0.findWidget);
      await tester.pumpAndSettle();
      expect(opened, isEmpty);
      expect(closed, isNotEmpty);
      expect(TestMenu.item0.findWidget, findsNothing);
    });

    testWidgets('hover color', (WidgetTester tester) async {
      const CupertinoDynamicColor customPressedColor =
          CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(0, 255, 0, 1),
        darkColor: Color.fromRGBO(0, 0, 255, 1),
      );
      const CupertinoDynamicColor customHoveredColor =
          CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(75, 0, 0, 1),
        darkColor: Color.fromRGBO(150, 0, 0, 1),
      );
      await tester.pumpWidget(buildTestApp(
          onPressed: onPressed,
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          children: <Widget>[
            CupertinoMenuItem(
              child: TestMenu.item0.text,
              onPressed: () {},
            ),
            CupertinoMenuItem(
                onPressed: () {},
                pressedColor: customPressedColor,
                hoveredColor: customHoveredColor,
                child: TestMenu.item1.text),
            CupertinoMenuItem(
                onPressed: () {},
                pressedColor: customPressedColor,
                child: TestMenu.item2.text),
            CupertinoMenuItem(child: TestMenu.item3.text),
          ]));
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );

      await gesture.addPointer(location: Offset.zero);
      addTearDown(() => gesture.removePointer());

      // None hovered
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item1.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item2.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item3.findWidget), findsNothing);

      // Enabled button
      // Pressed color @ 5% opacity is used when hovered color is not specified
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();
      expect(
        findBoxDecorationColor( tester, TestMenu.item0.findWidget),
        isSameColorAs(
          CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.05),
        ),
      );

      // Hovered button with custom hoverColor and pressedColor
      // Specified hovered color takes priority over pressed color
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pumpAndSettle();
      expect(
        findBoxDecorationColor(tester, TestMenu.item1.findWidget),
        isSameColorAs(customHoveredColor.darkColor),
      );

      // Hovered button with custom pressedColor
      // Pressed color @ 5% opacity is used when hovered color is not specified
      await gesture.moveTo(tester.getCenter(TestMenu.item2.findWidget));
      await tester.pumpAndSettle();
      expect(
        findBoxDecorationColor(tester, TestMenu.item2.findWidget),
        isSameColorAs(
          customPressedColor.darkColor.withOpacity(0.05),
        ),
      );

      // Disabled button
      await gesture.moveTo(tester.getCenter(TestMenu.item3.findWidget));
      await tester.pumpAndSettle();
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item1.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item2.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item3.findWidget), findsNothing);
    });

    testWidgets('focus color', (WidgetTester tester) async {
      const CupertinoDynamicColor customPressedColor =
          CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(0, 255, 0, 1),
        darkColor: Color.fromRGBO(0, 0, 255, 1),
      );
      const CupertinoDynamicColor customFocusColor =
          CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(75, 0, 0, 1),
        darkColor: Color.fromRGBO(150, 0, 0, 1),
      );
      final FocusNode focusNode1 = FocusNode(debugLabel: 'TestNode ${TestMenu.item1}');
      addTearDown(() => focusNode1.dispose());
      await tester.pumpWidget(buildTestApp(
          onPressed: onPressed,
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          children: <Widget>[
            CupertinoMenuItem(
              requestFocusOnHover: true,
              child: TestMenu.item0.text,
              onPressed: () {},
            ),
            CupertinoMenuItem(
                requestFocusOnHover: true,
                focusNode: focusNode1,
                onPressed: () {},
                pressedColor: customPressedColor,
                focusedColor: customFocusColor,
              child: TestMenu.item1.text,
            ),
            CupertinoMenuItem(
                requestFocusOnHover: true,
                onPressed: () {},
                pressedColor: customPressedColor,
                child: TestMenu.item2.text,),
            CupertinoMenuItem(
              requestFocusOnHover: true,
              child: TestMenu.item3.text),
          ]));


      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );

      await gesture.addPointer(location: Offset.zero);
      addTearDown(() => gesture.removePointer());



      // None hovered
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item1.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item2.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item3.findWidget), findsNothing);

      // Enabled button
      // Pressed color @ 5% opacity is used when hovered color is not specified
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();
      expect(
        findBoxDecorationColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(
          CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.075),
        ),
      );

      // Hovered button with custom hoverColor and pressedColor
      // Specified hovered color takes priority over pressed color
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pumpAndSettle();
      expect(
        findBoxDecorationColor(tester, TestMenu.item1.findWidget),
        isSameColorAs(customFocusColor.darkColor),
      );

      // Hovered button with custom pressedColor
      // Pressed color @ 5% opacity is used when hovered color is not specified
      await gesture.moveTo(tester.getCenter(TestMenu.item2.findWidget));
      await tester.pumpAndSettle();
      expect(
        findBoxDecorationColor(tester, TestMenu.item2.findWidget),
        isSameColorAs(
          customPressedColor.darkColor.withOpacity(0.075),
        ),
      );

      // Disabled button
      await gesture.moveTo(tester.getCenter(TestMenu.item3.findWidget));
      await tester.pumpAndSettle();
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item1.findWidget), findsNothing);
      expect(
        findBoxDecorationColor(tester, TestMenu.item2.findWidget),
        isSameColorAs(
          customPressedColor.darkColor.withOpacity(0.075),
        ),
      );
      expect(findDecoration(TestMenu.item3.findWidget), findsNothing);
      focusNode1.requestFocus();
      await tester.pumpAndSettle();
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(
        findBoxDecorationColor(tester, TestMenu.item1.findWidget),
        isSameColorAs(customFocusColor.darkColor),
      );
      expect(findDecoration(TestMenu.item2.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item3.findWidget), findsNothing);

    });

    testWidgets('pressed color', (WidgetTester tester) async {
    const CupertinoDynamicColor customPressedColor =
          CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(0, 255, 0, 1),
        darkColor: Color.fromRGBO(0, 0, 255, 1),
      );

      // ignore: prefer_final_locals
      int pressedCount = 0;
      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );

      await gesture.addPointer(location: Offset.zero);
      addTearDown(() => gesture.removePointer());

      // TODO(davidhicks980): Because the app defaults to light mode, I only test
      // dark mode here. Should light mode be tested as well?
      await tester.pumpWidget(buildTestApp(
          onPressed: onPressed,
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          children: <Widget>[
            const CupertinoMenuLargeDivider(),
            CupertinoMenuItem(
              closeOnActivate: false,
              panActivationDelay: const Duration(milliseconds: 200),
              onPressed: () {
                pressedCount++;
              },
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
                onPressed: () {},
                pressedColor: customPressedColor,
                child: TestMenu.item1.text),
            CupertinoMenuItem(
                pressedColor: customPressedColor, child: TestMenu.item2.text),
            CupertinoMenuItem(child: TestMenu.item3.text),
          ]));

      controller.open();
      await tester.pumpAndSettle();

      // None hovered
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item1.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item2.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item3.findWidget), findsNothing);

      // Pressed button with default color
      // TODO(davidhicks980): This test fails if the pan is not started over an
      // inert widget, but works outside of the test. I could not identify the cause.
      await gesture.down(tester.getCenter(
        find.byType(CupertinoMenuLargeDivider),
        warnIfMissed: true,
      ));
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();

      expect(
        findBoxDecorationColor(tester , TestMenu.item0.findWidget),
        isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor),
      );
      // Pressed button with custom pressedColor
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pumpAndSettle();

      expect(
        findBoxDecorationColor(tester , TestMenu.item1.findWidget),
        isSameColorAs(customPressedColor.darkColor),
      );

      // Item0 should not be pressed
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);

      // Disabled with custom pressedColor -- no effect
      await gesture.moveTo(tester.getCenter(TestMenu.item2.findWidget));
      await tester.pumpAndSettle();
      expect(findDecoration(TestMenu.item2.findWidget), findsNothing);

      // Disabled button
      await gesture.moveTo(tester.getCenter(TestMenu.item3.findWidget));
      await tester.pumpAndSettle();

      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item1.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item2.findWidget), findsNothing);
      expect(findDecoration(TestMenu.item3.findWidget), findsNothing);

      // Moving back over item0 should cause item0 to fill again
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();
      expect(
        findBoxDecorationColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor),
      );

      await gesture.up();
      await tester.pumpAndSettle();

      // On mouse up, should be hovered but not pressed
      expect(
        findBoxDecorationColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(
            CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.05)),
      );
      expect(pressedCount, 1);

      await gesture
          .down(tester.getCenter(find.byType(CupertinoMenuLargeDivider)));
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();
      expect(
        findBoxDecorationColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor),
      );

      // Wait for panActivationDelay to pass
      await tester.pump(const Duration(seconds: 1));

      expect(pressedCount, 2);
      expect(
        findBoxDecorationColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(
            CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.05)),
      );

      // Moving back over item1 should cause it to fill again
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pumpAndSettle();
      expect(
        findBoxDecorationColor(tester, TestMenu.item1.findWidget),
        isSameColorAs(customPressedColor.darkColor),
      );
    });
    testWidgets('onPressed is called when set', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  onPressed: () {
                    pressed = true;
                  },
                  child: TestMenu.item1.text,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      await tester.tap(TestMenu.item1.findText);
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('CupertinoMenuItem respects closeOnActivate property',
        (WidgetTester tester) async {
      final CupertinoMenuController controller = CupertinoMenuController();
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: Center(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  onPressed: () {},
                  child: const Text('Button 1'),
                ),
              ],
              builder: (BuildContext context,
                  CupertinoMenuController controller, Widget? child) {
                return FilledButton(
                  onPressed: () {
                    controller.open();
                  },
                  child: const Text('Tap me'),
                );
              },
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(1));
      await tester.pumpAndSettle();


      // Taps the CupertinoMenuItem which should close the menu
      await tester.tap(find.text('Button 1'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(0));


      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: Center(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  closeOnActivate: false,
                  onPressed: () {},
                  child: const Text('Button 1'),
                ),
              ],
              builder: (BuildContext context,
                  CupertinoMenuController controller, Widget? child) {
                return FilledButton(
                  onPressed: () {
                    controller.open();
                  },
                  child: const Text('Tap me'),
                );
              },
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(1));
      await tester.pumpAndSettle();

      // Taps the CupertinoMenuItem which shouldn't close the menu
      await tester.tap(find.text('Button 1'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(1));
    });
  });

  group('Layout', () {
    List<Rect> collectRects<T>() {
      final List<Rect> menuRects = <Rect>[];
      final List<Element> candidates =
          find.byType(T).evaluate().toList();
      for (final Element candidate in candidates) {
        final RenderBox box = candidate.renderObject! as RenderBox;
        final Offset topLeft = box.localToGlobal(box.size.topLeft(Offset.zero));
        final Offset bottomRight =
            box.localToGlobal(box.size.bottomRight(Offset.zero));
        menuRects.add(Rect.fromPoints(topLeft, bottomRight));
      }
      return menuRects;
    }



    testWidgets('unconstrained menus show up in the right place in LTR',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Material(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoMenuAnchor(
                        constraints: const BoxConstraints(),
                        menuChildren: createTestMenus2(onPressed: onPressed),
                      ),
                    ),
                  ],
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(7));
      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(8.0, 60.0, 792.0, 104.0),
        Rect.fromLTRB(8.0, 104.0, 792.0, 148.0),
        Rect.fromLTRB(8.0, 156.0, 792.0, 200.0),
        Rect.fromLTRB(8.0, 200.0, 792.0, 244.0),
        Rect.fromLTRB(8.0, 244.0, 792.0, 288.0),
        Rect.fromLTRB(8.0, 296.0, 792.0, 340.0),
        Rect.fromLTRB(8.0, 340.0, 792.0, 384.0)
      ];
      for (int i = 0; i < actual.length; i++) {
        expect(actual[i], rectEquals(expected[i]));
      }
    });

    testWidgets('unconstrained menus show up in the right place in RTL',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Material(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoMenuAnchor(
                          menuChildren: createTestMenus2(onPressed: onPressed),
                        ),
                      ),
                    ],
                  ),
                  const Expanded(child: Placeholder()),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(7));

      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(275.0, 60.0, 525.0, 104.0),
        Rect.fromLTRB(275.0, 104.0, 525.0, 148.0),
        Rect.fromLTRB(275.0, 156.0, 525.0, 200.0),
        Rect.fromLTRB(275.0, 200.0, 525.0, 244.0),
        Rect.fromLTRB(275.0, 244.0, 525.0, 288.0),
        Rect.fromLTRB(275.0, 296.0, 525.0, 340.0),
        Rect.fromLTRB(275.0, 340.0, 525.0, 384.0)
      ];

      for (int i = 0; i < actual.length; i++) {
        expect(actual[i], rectEquals(expected[i]));
      }

    });

    testWidgets('constrained menus show up in the right place in LTR',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(220, 200));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Material(
                  child: Column(
                    children: <Widget>[
                      CupertinoMenuAnchor(
                        menuChildren: createTestMenus2(onPressed: onPressed),
                      ),
                      const Expanded(child: Placeholder()),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      // Fewer items fit in the constrained menu.
      expect(find.byType(CupertinoMenuItem), findsNWidgets(4));
      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[Rect.fromLTRB(8.0, 8.0, 212.0, 52.0), Rect.fromLTRB(8.0, 52.0, 212.0, 96.0), Rect.fromLTRB(8.0, 104.0, 212.0, 148.0), Rect.fromLTRB(8.0, 148.0, 212.0, 192.0)];
      print(actual);

      for (int i = 0; i < actual.length; i++) {
        expect(actual[i], rectEquals(expected[i]));
      }
    });

    testWidgets('constrained menus show up in the right place in RTL',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(220, 200));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Material(
                  child: Column(
                    children: <Widget>[
                      CupertinoMenuAnchor(
                        menuChildren: createTestMenus2(onPressed: onPressed),
                      ),
                      const Expanded(child: Placeholder()),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      // Fewer items fit in the constrained menu.
      expect(find.byType(CupertinoMenuItem), findsNWidgets(4));

      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(8.0, 8.0, 212.0, 52.0),
        Rect.fromLTRB(8.0, 52.0, 212.0, 96.0),
        Rect.fromLTRB(8.0, 104.0, 212.0, 148.0),
        Rect.fromLTRB(8.0, 148.0, 212.0, 192.0)
      ];
      print(actual);

      for (int i = 0; i < actual.length; i++) {
        expect(actual[i], rectEquals(expected[i]));
      }
    });

    testWidgets('parent constraints do not affect menu size',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(220, 200));
      const ValueKey<TestMenu> anchorKey =
          ValueKey<TestMenu>(TestMenu.anchorButton);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 5, height: 5),
          child: Column(
            children: <Widget>[
              CupertinoMenuAnchor(
                menuChildren: createTestMenus2(onPressed: onPressed),
                builder: (BuildContext context,
                    CupertinoMenuController controller, Widget? child) {
                  return FilledButton(
                    key: anchorKey,
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: TestMenu.item0.text,
                  );
                },
              ),
              const Expanded(child: Placeholder()),
            ],
          ),
        ),
      ));

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      // Fewer items fit in the constrained menu.
      expect(find.byType(CupertinoMenuItem), findsNWidgets(4));

      final List<Rect> actual = collectRects<CupertinoMenuItem>();

      expect(actual[0], rectEquals(const Rect.fromLTRB(8.0, 8.0, 212.0, 52.0)));

      expect(tester.getRect(find.byKey(anchorKey)),
          rectEquals(const Rect.fromLTRB(52.0, 0.0, 168.0, 48.0)));
    });

    testWidgets(
        'constrained menus show up in the right place with offset in LTR',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(220, 200));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CupertinoMenuAnchor(
                    alignmentOffset: const Offset(30, 30),
                    menuChildren: createTestMenus2( onPressed: onPressed),
                    builder: (BuildContext context,
                        CupertinoMenuController controller, Widget? child) {
                      return FilledButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        child: const Text('Tap me'),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(4));

      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[Rect.fromLTRB(8.0, 8.0, 212.0, 52.0), Rect.fromLTRB(8.0, 52.0, 212.0, 96.0), Rect.fromLTRB(8.0, 104.0, 212.0, 148.0), Rect.fromLTRB(8.0, 148.0, 212.0, 192.0)];

      for (int i = 0; i < actual.length; i++) {
        expect(actual[i], rectEquals(expected[i]));
      }

    });

    testWidgets(
        'constrained menus show up in the right place with offset in RTL',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(220, 200));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Align(
                  alignment: Alignment.topRight,
                  child: CupertinoMenuAnchor(
                    alignmentOffset: const Offset(30, 30),
                    menuChildren:  createTestMenus2(onPressed: onPressed),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(4));
      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[Rect.fromLTRB(8.0, 8.0, 212.0, 52.0), Rect.fromLTRB(8.0, 52.0, 212.0, 96.0), Rect.fromLTRB(8.0, 104.0, 212.0, 148.0), Rect.fromLTRB(8.0, 148.0, 212.0, 192.0)];

      for (int i = 0; i < actual.length; i++) {
        expect(actual[i], rectEquals(expected[i]));
      }

    });

    // TODO(davidhicks980): Should offset be applied before or after growth dir?

    testWidgets(
        'menus anchored below the halfway point of the screen grow upwards',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return  Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: const Alignment(0.5, 0.5),
                  child: CupertinoMenuAnchor(
                    menuChildren: <Widget>[
                      CupertinoMenuItem(child: TestMenu.item0.text),
                    ]
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoMenuItem), findsNWidgets(1));
      expect(
        tester.getRect(find.byType(CupertinoMenuItem)),
        rectEquals(const Rect.fromLTRB(461.0, 363.4, 711.0, 407.4))
      );
    });

    testWidgets(
        'offset does not affect the growth direction of the menu',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child:  CupertinoMenuAnchor(
                    alignmentOffset: const Offset(0, 450),
                    menuChildren:  <Widget>[
                      CupertinoMenuItem(child: TestMenu.item0.text, onPressed: (){}),
                    ],
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoMenuItem), findsNWidgets(1));
      expect(
        tester.getRect(TestMenu.item0.findText),
        rectEquals(const Rect.fromLTRB(291.0, 559.5, 390.5, 580.5)),
      );
    });
  });


  group('Semantics', () {
    testWidgets('CupertinoMenuItem is not a semantic button',
        (WidgetTester tester) async {
      final SemanticsTester semantics = SemanticsTester(tester);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: CupertinoMenuItem(
              onPressed: () {},
              constraints: BoxConstraints.tight(const Size(88.0, 48.0)),
              child: const Text('ABC'),
            ),
          ),
        ),
      );

      // The flags should not have SemanticsFlag.isButton
      expect(
        semantics,
        hasSemantics(
          TestSemantics.root(
            children: <TestSemantics>[
              TestSemantics.rootChild(
                actions: <SemanticsAction>[
                  SemanticsAction.tap,
                ],
                label: 'ABC',
                rect: const Rect.fromLTRB(0.0, 0.0, 88.0, 48.0),
                transform: Matrix4.translationValues(356.0, 276.0, 0.0),
                flags: <SemanticsFlag>[
                  SemanticsFlag.hasEnabledState,
                  SemanticsFlag.isEnabled,
                  SemanticsFlag.isFocusable,
                ],
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
          ignoreId: true,
        ),
      );

      semantics.dispose();
    });
  });

  // This is a regression test for https://github.com/flutter/flutter/issues/131676.
  testWidgets('Material3 - Menu uses correct text styles',
      (WidgetTester tester) async {
    const TextStyle menuTextStyle = TextStyle(
      fontSize: 18.5,
      fontStyle: FontStyle.italic,
      wordSpacing: 1.2,
      decoration: TextDecoration.lineThrough,
    );
    final ThemeData themeData = ThemeData(
      textTheme: const TextTheme(
        labelLarge: menuTextStyle,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: themeData,
        home: Material(
          child: CupertinoMenuAnchor(
            controller: controller,
            onOpen: onOpen,
            onClose: onClose,
            menuChildren: createTestMenus2(
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );

    // Test menu button text style uses the TextTheme.labelLarge.
    Finder buttonMaterial = find
        .descendant(
          of: find.byType(TextButton),
          matching: find.byType(Material),
        )
        .first;
    Material material = tester.widget<Material>(buttonMaterial);
    expect(material.textStyle?.fontSize, menuTextStyle.fontSize);
    expect(material.textStyle?.fontStyle, menuTextStyle.fontStyle);
    expect(material.textStyle?.wordSpacing, menuTextStyle.wordSpacing);
    expect(material.textStyle?.decoration, menuTextStyle.decoration);

    // Open the menu.
    await tester.tap(find.text(TestMenu.item1.label));
    await tester.pump();

    // Test menu item text style uses the TextTheme.labelLarge.
    buttonMaterial = find
        .descendant(
          of: find.widgetWithText(TextButton, TestMenu.item5Disabled.label),
          matching: find.byType(Material),
        )
        .first;
    material = tester.widget<Material>(buttonMaterial);
    expect(material.textStyle?.fontSize, menuTextStyle.fontSize);
    expect(material.textStyle?.fontStyle, menuTextStyle.fontStyle);
    expect(material.textStyle?.wordSpacing, menuTextStyle.wordSpacing);
    expect(material.textStyle?.decoration, menuTextStyle.decoration);
  });
}

// List<Widget> createTestMenus2({
//   void Function(Label)? onPressed,
//   Map<Label, MenuSerializableShortcut> shortcuts =
//       const <Label, MenuSerializableShortcut>{},
//   Map<Label, Key> keys =
//        const <Label, Key>{},
//   bool accelerators = false,
// }) {
//   Widget menuItem(
//     Label item, {
//     bool enabled = true,
//     Widget? leading,
//     Widget? trailing,
//     Widget? subtitle,
//     Key? key,
//   }) {
//     return CupertinoMenuItem(
//       key: key ??  keys[item],
//       onPressed: enabled && onPressed != null ? () => onPressed(item) : null,
//       shortcut: shortcuts[item],
//       leading: leading,
//       trailing: trailing,
//       subtitle: subtitle,
//       child: accelerators ? item.acceleratorText : item.text,
//     );
//   }

//   final List<Widget> result = <Widget>[
//     menuItem(Label._1, leading: const Icon(Icons.add)),
//     menuItem(Label._2,
//         leading: const Icon(Icons.add),
//         trailing: const Icon(
//           Icons.add,
//           size: 48,
//         )),
//     CupertinoMenuLargeDivider(key: Label._3d.key),
//     menuItem(Label._3,
//         subtitle: const Text('subtitle'), leading: const Icon(Icons.add)),
//     menuItem(Label._4, enabled: false),
//     menuItem(Label._5),
//     menuItem(Label._6),
//     menuItem(Label._7),
//     menuItem(Label._8),
//   ];
//   return result;
// }



CupertinoApp buildApp(List<Widget> children) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children),
    ),
  );
}



List<Widget> createTestMenus2({
  void Function(TestMenu)? onPressed,
  Map<TestMenu, MenuSerializableShortcut> shortcuts = const <TestMenu, MenuSerializableShortcut>{},
  bool includeExtraGroups = false,
  bool accelerators = false,
  Map<TestMenu, Key> keys =
       const <TestMenu, Key>{},
}) {


  Widget cupertinoMenuItemButton(
    TestMenu menu, {
    bool enabled = true,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Key? key,
  }) {
    return CupertinoMenuItem(
      requestFocusOnHover: true,
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
    const CupertinoMenuLargeDivider(),
    cupertinoMenuItemButton(TestMenu.item2),
    cupertinoMenuItemButton(TestMenu.item3, leadingIcon: const Icon(Icons.add), trailingIcon: const Icon(Icons.add)),
    cupertinoMenuItemButton(TestMenu.item4),
    const CupertinoMenuLargeDivider(),
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
  Finder get findText => find.text(label);
  Finder  get findWidget => find.widgetWithText(CupertinoMenuItem, label);
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