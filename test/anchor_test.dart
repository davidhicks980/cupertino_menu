// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as  math;

import 'package:example/menu.dart';
import 'package:example/menu_item.dart';
import 'package:example/test_anchor.dart';
import 'package:flutter/cupertino.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      for (int i = 0; i < math.max(rects1.length, rects2.length); i++) {
      expect(rects1[i], rectEquals(rects2[i]));
    }
    });

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
    Map<TestMenu, Key> keys = const <TestMenu, Key>{},
    void Function(TestMenu item)? onPressed,
    void Function()? onOpen,
    void Function()? onClose,
  }) {
    final FocusNode focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    return CupertinoApp(
      home: Material(
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
                menuChildren: createTestMenus2(
                    onPressed: onPressed,
                    keys: keys,
                    shortcuts: <TestMenu, MenuSerializableShortcut>{
                      TestMenu.item1: const SingleActivator(
                        LogicalKeyboardKey.keyB,
                        control: true,
                      ),
                    }),
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
                    child: child,
                  );
                },
                child: TestMenu.anchorButton.text,
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

    await tester.tap(TestMenu.item1.findItem);
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
        expect(TestMenu.item1.findItem, findsNothing);
        expect(controller.isOpen, isFalse);

        // Open the menu.
        await open();
        await tester.pump();

        // The menu is opening => AnimationStatus.forward.
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findItem, findsOneWidget);

        // After 100 ms, the menu should still be animating open.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findItem, findsOneWidget);

        // Interrupt the opening animation by closing the menu.
        await close();
        await tester.pump();

        // The menu is closing => AnimationStatus.reverse.
        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findItem, findsOneWidget);

        // Open the menu again.
        await open();
        await tester.pump();

        // The menu is animating open => AnimationStatus.forward.
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findItem, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has finished opening, so it should report it's animation
        // status as AnimationStatus.completed.
        expect(controller.animationStatus, AnimationStatus.completed);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findItem, findsOneWidget);

        // Close the menu.
        await close();
        await tester.pump();

        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findItem, findsOneWidget);

        // After 100 ms, the menu should still be closing.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findItem, findsOneWidget);

        // Interrupt the closing animation by opening the menu.
        await open();
        await tester.pump();

        // The menu is animating open => AnimationStatus.forward.
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findItem, findsOneWidget);

        // Close the menu again.
        await close();
        await tester.pump();

        // The menu is closing => AnimationStatus.reverse.
        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findItem, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has closed => AnimationStatus.dismissed.
        expect(controller.animationStatus, AnimationStatus.dismissed);
        expect(controller.isOpen, isFalse);
        expect(TestMenu.item1.findItem, findsNothing);
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
        expect(TestMenu.item1.findItem, findsOneWidget);
        expect(controller.isOpen, isTrue);
        Navigator.pop(menuItemGK.currentContext!);
        await tester.pumpAndSettle();
        expect(TestMenu.item1.findItem, findsNothing);
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

      expect(tester.getRect(TestMenu.item8Disabled.findItem),
          rectEquals(const Rect.fromLTRB(400.0, 28.0, 400.0, 28.0)));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(TestMenu.item8Disabled.findItem),
        rectEquals(const Rect.fromLTRB(275.0, 445.9, 525.0, 489.9)),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(menuAnchor),
          rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));
      expect(
        tester.getRect(TestMenu.item8Disabled.findItem),
        rectEquals(const Rect.fromLTRB(275.0, 445.9, 525.0, 489.9)),
      );

      // Decorative surface sizes should match
      const Rect surfaceSize = Rect.fromLTRB(275.0, 61.9, 525.0, 533.9);
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item8Disabled.findItem,
                  matching: find.byType(DecoratedBoxTransition))
              .first,
        ),
        rectEquals(surfaceSize),
      );
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item8Disabled.findItem, matching: find.byType(FadeTransition))
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
      expect(tester.getRect(TestMenu.item9.findItem),
          rectEquals(const Rect.fromLTRB(400.0, 28.0, 400.0, 28.0)));

      // When the menu is fully open, the menu items should be the correct size.
      await tester.pumpAndSettle();
      expect(tester.getRect(menuAnchor),
          rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));
      expect(
        tester.getRect(TestMenu.item8Disabled.findItem),
        rectEquals(const Rect.fromLTRB(275.0, 445.9, 525.0, 489.9)),
      );

      // Decorative surface sizes should match
      const Rect surfaceSize = Rect.fromLTRB(275.0, 61.9, 525.0, 533.9);
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item8Disabled.findItem,
                  matching: find.byType(DecoratedBoxTransition))
              .first,
        ),
        rectEquals(surfaceSize),
      );
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item8Disabled.findItem, matching: find.byType(FadeTransition))
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
              of: TestMenu.item1.findItem, matching: find.byType(FocusScope))
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
          .ancestor(of: TestMenu.item1.findItem, matching: find.byType(FocusScope))
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
        tester.getRect(TestMenu.item0.findItem),
        rectEquals(const Rect.fromLTRB(285.0, 69.9, 535.0, 113.9)),
      );

      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item9.findItem,
                  matching: find.byType(DecoratedBoxTransition))
              .first),

        rectEquals(const Rect.fromLTRB(285.0, 69.9, 535.0, 541.9)),
      );

      // Close and make sure it goes back where it was.
      await tester.tap(TestMenu.item9.findItem);
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
        tester.getRect(TestMenu.item9.findItem),
        rectEquals(const Rect.fromLTRB(285.0, 497.9, 535.0, 541.9)),
      );
      expect(
        tester.getRect(find
            .ancestor(
                of: TestMenu.item9.findItem, matching: find.byType(DecoratedBoxTransition))
            .first),
        rectEquals(const Rect.fromLTRB(285.0, 69.9, 535.0, 541.9)),
      );

      // Close and make sure it goes back where it was.
      await tester.tap(TestMenu.item1.findItem);
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
        shortcut: SingleActivator(LogicalKeyboardKey.keyA),
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
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.item1.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matItem3.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.item4.debugFocusLabel));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matItem3.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.item1.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // At the end of the list
      expect(focusedMenu, equals(TestMenu.item9.debugFocusLabel));

      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));
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
      expect(focusedMenu, equals(TestMenu.matItem3.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item4.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu5.debugFocusLabel));

      // Focusing on the submenu anchor should open the submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_0.label), findsOne);

      // Enter submenu (6)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(focusedMenu, equals(TestMenu.matMenu6_0.debugFocusLabel));

      // Focus next submenu (6.1), should open
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals( TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Press space, should close
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsNothing);

      // ArrowRight should open the submenu again.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Arrow down, should close the submenu
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals( TestMenu.matMenu6_2.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsNothing);

      // At end, focus should not loop
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals( TestMenu.matMenu6_2.debugFocusLabel));

      // Return to submenu (6.1), should open
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Enter submenu
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1_0.debugFocusLabel));

      // Leave submenu without closing it.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Move up, should close the submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_0.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsNothing);

      // Move down, should reopen the submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Enter submenu (6.1)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_0.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_1.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_2.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_3.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_3.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1.2
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1.1
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1.0
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.0
      expect(focusedMenu, equals(TestMenu.matMenu6_0.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 5
      await tester.pump();

      expect(find.text(TestMenu.matMenu6_0.label), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 4
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 3
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 2
      expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 1
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 0
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 0
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));
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

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item1.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matItem3.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item4.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu5.debugFocusLabel));

      // Focusing on the submenu anchor should open the submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_0.label), findsOne);

      // Enter submenu (6)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(focusedMenu, equals(TestMenu.matMenu6_0.debugFocusLabel));

      // Focus next submenu (6.1), should open
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals( TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Press space, should close
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsNothing);

      // ArrowRight should open the submenu again.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Arrow down, should close the submenu
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals( TestMenu.matMenu6_2.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsNothing);

      // At end, focus should not loop
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals( TestMenu.matMenu6_2.debugFocusLabel));

      // Return to submenu (6.1), should open
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Enter submenu
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1_0.debugFocusLabel));

      // Leave submenu without closing it.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Move up, should close the submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_0.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsNothing);

      // Move down, should reopen the submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(find.text(TestMenu.matMenu6_1_0.label), findsOne);

      // Enter submenu (6.1)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_0.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_1.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_2.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_3.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.matMenu6_1_3.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1.2
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1.1
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1.0
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.1
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6.0
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_0.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 6
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 5
      await tester.pump();
      expect(find.text(TestMenu.matMenu6_0.label), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 4
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 3
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 2
      expect(focusedMenu, equals(TestMenu.item2.debugFocusLabel));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 1
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 0
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // 0
      expect(focusedMenu, equals(TestMenu.item0.debugFocusLabel));
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
      await hoverOver(tester, TestMenu.item1.findItem);
      expect(focusedMenu, equals(TestMenu.item1.debugFocusLabel));

      // Hovering over the menu items opens and focuses them.
      await hoverOver(tester, TestMenu.matMenu6.findItem);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6.debugFocusLabel));
      expect(TestMenu.matMenu6_0.findItem, findsOne);

      await hoverOver(tester, TestMenu.matMenu6_1.findItem);
      await tester.pump();
      expect(focusedMenu, equals(TestMenu.matMenu6_1.debugFocusLabel));
      expect(TestMenu.matMenu6_1_0.findItem, findsOne);

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

      await tester.tap(TestMenu.item9.findItem);
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

      await tester.tap(TestMenu.item1.findItem);
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
    List<Rect> collectMenuItemRects() {
      final List<Rect> menuRects = <Rect>[];
      final List<Element> candidates =
          find.byType(CupertinoMenuItem).evaluate().toList();
      for (final Element candidate in candidates) {
        final RenderBox box = candidate.renderObject! as RenderBox;
        final Offset topLeft = box.localToGlobal(box.size.topLeft(Offset.zero));
        final Offset bottomRight =
            box.localToGlobal(box.size.bottomRight(Offset.zero));
        menuRects.add(Rect.fromPoints(topLeft, bottomRight));
      }
      return menuRects;
    }

    List<Rect> collectSubmenuRects() {
      final List<Rect> menuRects = <Rect>[];
      final List<Element> candidates = findMenuPanels().evaluate().toList();
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
      await tester.tap(TestMenu.matMenu6.findItem);
      await tester.pump();


      expect(find.byType(CupertinoMenuItem), findsNWidgets(6));
      expect(find.byType(SubmenuButton), findsNWidgets(4));
      rectsEqual(collectMenuItemRects(), <Rect>[
            const Rect.fromLTRB(8.0, 61.9, 792.0, 105.9),
            const Rect.fromLTRB(8.0, 105.9, 792.0, 149.9),
            const Rect.fromLTRB(8.0, 157.9, 792.0, 201.9),
            const Rect.fromLTRB(8.0, 249.9, 792.0, 293.9),
            const Rect.fromLTRB(8.0, 445.9, 792.0, 489.9),
            const Rect.fromLTRB(8.0, 489.9, 792.0, 533.9)
          ]);
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
      await tester.tap(TestMenu.matMenu6.findItem);
      await tester.pump();


      expect(find.byType(CupertinoMenuItem), findsNWidgets(6));
      expect(find.byType(SubmenuButton), findsNWidgets(4));
      rectsEqual(collectMenuItemRects(), <Rect>[
        const Rect.fromLTRB(275.0, 61.9, 525.0, 105.9),
        const Rect.fromLTRB(275.0, 105.9, 525.0, 149.9),
        const Rect.fromLTRB(275.0, 157.9, 525.0, 201.9),
        const Rect.fromLTRB(275.0, 249.9, 525.0, 293.9),
        const Rect.fromLTRB(275.0, 445.9, 525.0, 489.9),
        const Rect.fromLTRB(275.0, 489.9, 525.0, 533.9)
      ]);
    });

    testWidgets('constrained menus show up in the right place in LTR',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(300, 300));
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
      await tester.tap(TestMenu.matMenu6.findItem);
      await tester.pump();

      // Fewer items fit in the constrained menu.
      expect(find.byType(CupertinoMenuItem), findsNWidgets(4));
      expect(find.byType(SubmenuButton), findsNWidgets(2));
      expect(
        collectMenuItemRects(),
        equals(const <Rect>[
            Rect.fromLTRB(25.0, 8.0, 275.0, 52.0),
            Rect.fromLTRB(25.0, 52.0, 275.0, 96.0),
            Rect.fromLTRB(25.0, 104.0, 275.0, 148.0),
            Rect.fromLTRB(25.0, 196.0, 275.0, 240.0)
          ]),
      );
    });

    testWidgets('constrained menus show up in the right place in RTL',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(300, 300));
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
      await tester.tap(TestMenu.matMenu6.findItem);
      await tester.pump();

      // Fewer items fit in the constrained menu.
      expect(find.byType(CupertinoMenuItem), findsNWidgets(4));
      expect(find.byType(SubmenuButton), findsNWidgets(2));
      rectsEqual(
        collectMenuItemRects(),
        const <Rect>[
            Rect.fromLTRB(25.0, 8.0, 275.0, 52.0),
            Rect.fromLTRB(25.0, 52.0, 275.0, 96.0),
            Rect.fromLTRB(25.0, 104.0, 275.0, 148.0),
            Rect.fromLTRB(25.0, 196.0, 275.0, 240.0)
          ]);
    });

    testWidgets(
        'constrained menus show up in the right place with offset in LTR',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
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
                    alignmentOffset: const Offset(10, 10),
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
      expect(find.byType(CupertinoMenuItem), findsNWidgets(6));
      rectsEqual(
        collectSubmenuRects(),
        const <Rect>[
          Rect.fromLTRB(0.0, 48.0, 256.0, 112.0),
          Rect.fromLTRB(266.0, 48.0, 522.0, 112.0),
          Rect.fromLTRB(522.0, 48.0, 778.0, 112.0),
          Rect.fromLTRB(256.0, 48.0, 512.0, 112.0),
        ]
      );
    });

    testWidgets(
        'constrained menus show up in the right place with offset in RTL',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
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
                    menuChildren: const <Widget>[
                      // SubmenuButton(
                      //   alignmentOffset: Offset(10, 0),
                      //   menuChildren: <Widget>[
                      //     SubmenuButton(
                      //       menuChildren: <Widget>[
                      //         SubmenuButton(
                      //           alignmentOffset: Offset(10, 0),
                      //           menuChildren: <Widget>[
                      //             SubmenuButton(
                      //               menuChildren: <Widget>[],
                      //               child: Text('SubMenuButton4'),
                      //             ),
                      //           ],
                      //           child: Text('SubMenuButton3'),
                      //         ),
                      //       ],
                      //       child: Text('SubMenuButton2'),
                      //     ),
                      //   ],
                      //   child: Text('SubMenuButton1'),
                      // ),
                    ],
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
      await tester.pump();

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      await tester.tap(find.text('SubMenuButton1'));
      await tester.pump();
      await tester.tap(find.text('SubMenuButton2'));
      await tester.pump();
      await tester.tap(find.text('SubMenuButton3'));
      await tester.pump();

      expect(find.byType(SubmenuButton), findsNWidgets(4));
      expect(
        collectSubmenuRects(),
        equals(const <Rect>[
          Rect.fromLTRB(544.0, 48.0, 800.0, 112.0),
          Rect.fromLTRB(278.0, 48.0, 534.0, 112.0),
          Rect.fromLTRB(22.0, 48.0, 278.0, 112.0),
          Rect.fromLTRB(288.0, 48.0, 544.0, 112.0),
        ]),
      );
    });

    testWidgets(
        'vertically constrained menus are positioned above the anchor by default',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: CupertinoMenuAnchor(
                    menuChildren: const <Widget>[
                      CupertinoMenuItem(
                        child: Text('Button1'),
                      ),
                    ],
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

      await tester.pump();
      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(find.byType(CupertinoMenuItem), findsNWidgets(1));
      // Test the default offset (0, 0) vertical position.
      expect(
        collectSubmenuRects(),
        equals(const <Rect>[
          Rect.fromLTRB(0.0, 488.0, 122.0, 552.0),
        ]),
      );
    });

    testWidgets(
        'vertically constrained menus are positioned above the anchor with the provided offset',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: CupertinoMenuAnchor(
                    alignmentOffset: const Offset(0, 50),
                    menuChildren: const <Widget>[
                      CupertinoMenuItem(
                        child: Text('Button1'),
                      ),
                    ],
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

      await tester.pump();
      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(find.byType(CupertinoMenuItem), findsNWidgets(1));
      // Test the offset (0, 50) vertical position.
      expect(
        collectSubmenuRects(),
        equals(const <Rect>[
          Rect.fromLTRB(0.0, 438.0, 122.0, 502.0),
        ]),
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
          of: find.widgetWithText(TextButton, TestMenu.item8Disabled.label),
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
    Key? key,
  }) {
    return CupertinoMenuItem(
      requestFocusOnHover: true,
      key: key,
      onPressed: enabled && onPressed != null ? () => onPressed(menu) : null,
      shortcut: shortcuts[menu],
      leading: leadingIcon,
      trailing: trailingIcon,
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
        menuItemButton(TestMenu.matMenu5_0, leadingIcon: const Icon(Icons.add)),
        menuItemButton(TestMenu.matMenu5_1),
        menuItemButton(TestMenu.matMenu5_2),
      ],
    ),
    submenuButton(
      TestMenu.matMenu6,
      menuChildren: <Widget>[
        menuItemButton(TestMenu.matMenu6_0),
        submenuButton(
          TestMenu.matMenu6_1,
          menuChildren: <Widget>[
            menuItemButton(TestMenu.matMenu6_1_0, key: UniqueKey()),
            menuItemButton(TestMenu.matMenu6_1_1),
            menuItemButton(TestMenu.matMenu6_1_2),
            menuItemButton(TestMenu.matMenu6_1_3),
          ],
        ),
        menuItemButton(TestMenu.matMenu6_2),
      ],
    ),
    if (includeExtraGroups)
      submenuButton(
        TestMenu.matMenu6a,
        menuChildren: <Widget>[
          menuItemButton(TestMenu.matMenu6a_0, enabled: false),
        ],
      ),
    if (includeExtraGroups)
      submenuButton(
        TestMenu.matMenu6b,
        menuChildren: <Widget>[
          menuItemButton(TestMenu.matMenu6b_0, enabled: false),
          menuItemButton(TestMenu.matMenu6b_1, enabled: false),
          menuItemButton(TestMenu.matMenu6b_2, enabled: false),
        ],
      ),
    submenuButton(TestMenu.matMenu7Empty, menuChildren: const <Widget>[]),
    const CupertinoMenuLargeDivider(),
    cupertinoMenuItemButton(TestMenu.item8Disabled, enabled: false),
    cupertinoMenuItemButton(TestMenu.item9),
  ];
  return result;
}

class Fo {
  const Fo( [this.node, this.children]);
  final TestMenu? node;
  final List<Fo>? children;
  List<TestMenu>? get childMenus => children?.map((Fo fo) => fo.node!).toList();
  Fo findChild(TestMenu menu) => children!.firstWhere((Fo fo) => fo.node == menu);
}

const Fo focusOrder = Fo(null,<Fo>[
  Fo(TestMenu.item0),
  Fo(TestMenu.item1),
  Fo(TestMenu.item2),
  Fo(TestMenu.matItem3),
  Fo(TestMenu.item4),
  Fo(TestMenu.matMenu5, <Fo>[
    Fo(TestMenu.matMenu5_0),
    Fo(TestMenu.matMenu5_1),
    Fo(TestMenu.matMenu5_2),
  ]),
  Fo(TestMenu.matMenu6, <Fo>[
    Fo(TestMenu.matMenu6_0),
    Fo(TestMenu.matMenu6_1, <Fo>[
      Fo(TestMenu.matMenu6_1_0),
      Fo(TestMenu.matMenu6_1_1),
      Fo(TestMenu.matMenu6_1_2),
      Fo(TestMenu.matMenu6_1_3),
    ]),
    Fo(TestMenu.matMenu6_2),
  ]),
  // TestMenu.matMen)u7Empty, // Should not focus
  // TestMenu.item8D)isabled, // Should not focus
  Fo(TestMenu.item9),
]);



enum TestMenu {
  item0('&Item 0'),
  item1('I&tem 1'),
  item2('It&em 2'),
  matItem3('&MenuItem 3'),
  item4('I&tem 4'),
  matMenu5('&Menu 5'),
  matMenu5_0('&MenuItem 5&_0'),
  matMenu5_1('MenuItem 5_&1'),
  matMenu5_2('MenuItem 5&_2'),
  matMenu6('M&enu &6'),
  matMenu6_0('MenuItem 6&_&0'),
  matMenu6_1('Menu 6&_1'),
  matMenu6_2('MenuItem 6&_2'),
  matMenu6a('Men&u 6a'),
  matMenu6a_0('MenuItem 6a&_0'),
  matMenu6b('Menu &6b'),
  matMenu6b_0('MenuItem 6b&_0'),
  matMenu6b_1('MenuItem 6b&_1'),
  matMenu6b_2('MenuItem 6b&_2'),
  matMenu7Empty('Menu &7 &&'),
  item8Disabled('Ite&m 8'),
  item9('Ite&m 9'),



  matMenu6_1_0('MenuItem 6_1&_0'),
  matMenu6_1_1('MenuItem 6_1&_1'),
  matMenu6_1_2('MenuItem 6_1&_2'),
  matMenu6_1_3('MenuItem 6_1&_3'),
  anchorButton('Press Me'),
  outsideButton('Outside');

  const TestMenu(this.acceleratorLabel);
  final String acceleratorLabel;
  // Strip the accelerator markers.
  String get label => MenuAcceleratorLabel.stripAcceleratorMarkers(acceleratorLabel);
  Finder get findItem => find.text(label);
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