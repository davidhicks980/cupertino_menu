// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/cupertino_menu_anchor.dart';
import 'package:example/menu_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'semantics.dart';

void main() {
  late CupertinoMenuController controller;
  String? focusedMenu;
  final List<Label> selected = <Label>[];
  final List<Label> opened = <Label>[];
  final List<Label> closed = <Label>[];
  final GlobalKey menuItemKey = GlobalKey();
  const bool printOut = true;
  Matcher rectEquals(Rect rect) {
    return rectMoreOrLessEquals(rect, epsilon: 0.1);
  }
  void expectPrint(Rect rect1, Matcher rect2){
    if(printOut){
      print(rect1);
    } else {
      expect(rect1, rect2);
    }
  }

  void onPressed(Label item) {
    selected.add(item);
  }

  void onOpen() {
    opened.add(Label.anchor);
  }

  void onClose() {
    opened.remove(Label.anchor);
    closed.add(Label.anchor);
  }

  void handleFocusChange() {
    focusedMenu = (primaryFocus?.debugLabel ?? primaryFocus).toString();
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
    Offset alignmentOffset = Offset.zero,
    TextDirection textDirection = TextDirection.ltr,
    bool consumesOutsideTap = false,
    Map<Label, Key> keys = const <Label, Key>{},
    void Function(Label item)? onPressed,
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
                    onPressed?.call(Label.outsideButton);
                  },
                  child: Text(Label.outsideButton.label)),
              CupertinoMenuAnchor(
                childFocusNode: focusNode,
                controller: controller,
                alignmentOffset: alignmentOffset,
                alignment: alignment,
                consumeOutsideTap: consumesOutsideTap,
                onOpen: onOpen,
                onClose: onClose,
                menuChildren: createTestMenus(
                    onPressed: onPressed,
                    keys: keys,
                    shortcuts: <Label, MenuSerializableShortcut>{
                      Label._1: const SingleActivator(
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
                      onPressed?.call(Label.anchor);
                    },
                    child: child,
                  );
                },
                child: Label.anchor.text,
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
      print('called');
      focusInOnPressed = FocusManager.instance.primaryFocus;
    }

    final GlobalKey<State<StatefulWidget>> testKey = GlobalKey();

    await tester.pumpWidget(
      buildApp(
        <Widget>[
          CupertinoMenuAnchor(
            builder: Label.anchor.anchorBuilder,
            menuChildren: <Widget>[
              CupertinoMenuItem(
                key: Label._1.key,
                onPressed: onMenuSelected,
                child: Label._1.text,
              ),
            ],
          ),
          ElevatedButton(
            autofocus: true,
            onPressed: () {},
            focusNode: buttonFocus,
            child: Label.outsideButton.text,
          ),
        ],
      ),
    );

    await tester.pump();
    expect(FocusManager.instance.primaryFocus, equals(buttonFocus));

    await tester.tap(Label.anchor.finder);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Label._1.key));
    await tester.pump();

    expect(focusInOnPressed, equals(buttonFocus));
    expect(FocusManager.instance.primaryFocus, equals(buttonFocus));
  });

  group('Menu functions', () {
    group('Open and closing', () {
      Future<void> openCloseTester(
        WidgetTester tester,
        CupertinoMenuController controller, {
        required VoidCallback open,
        required VoidCallback close,
      }) async {
        await tester.pumpWidget(
          buildApp(
            <Widget>[
              CupertinoMenuAnchor(
                controller: controller,
                builder: Label.anchor.anchorBuilder,
                menuChildren: <Widget>[
                  CupertinoMenuItem(
                    child: Label._1.text,
                  ),
                  CupertinoMenuItem(
                    leading: const Icon(Icons.send),
                    trailing: const Icon(Icons.mail),
                    child: Label._2.text,
                  ),
                  CupertinoMenuItem(
                    child: Label._3.text,
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
        expect(Label._1, findsNothing);
        expect(controller.isOpen, isFalse);

        // Open the menu.
        open();
        await tester.pump();

        // The menu is opening => AnimationStatus.forward.
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(Label._1.finder, findsOneWidget);

        // After 100 ms, the menu should still be animating open.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(Label._1.finder, findsOneWidget);

        // Interrupt the opening animation by closing the menu.
        close();
        await tester.pump();

        // The menu is closing => AnimationStatus.reverse.
        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(Label._1.finder, findsOneWidget);

        // Open the menu again.
        open();
        await tester.pump();

        // The menu is animating open => AnimationStatus.forward.
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(Label._1.finder, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has finished opening, so it should report it's animation
        // status as AnimationStatus.completed.
        expect(controller.animationStatus, AnimationStatus.completed);
        expect(controller.isOpen, isTrue);
        expect(Label._1.finder, findsOneWidget);

        // Close the menu.
        close();
        await tester.pump();

        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(Label._1.finder, findsOneWidget);

        // After 100 ms, the menu should still be closing.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(Label._1.finder, findsOneWidget);

        // Interrupt the closing animation by opening the menu.
        open();
        await tester.pump();

        // The menu is animating open => AnimationStatus.forward.
        expect(controller.animationStatus, AnimationStatus.forward);
        expect(controller.isOpen, isTrue);
        expect(Label._1.finder, findsOneWidget);

        // Close the menu again.
        close();
        await tester.pump();

        // The menu is closing => AnimationStatus.reverse.
        expect(controller.animationStatus, AnimationStatus.reverse);
        expect(controller.isOpen, isTrue);
        expect(Label._1.finder, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has closed => AnimationStatus.dismissed.
        expect(controller.animationStatus, AnimationStatus.dismissed);
        expect(controller.isOpen, isFalse);
        expect(Label._1.finder, findsNothing);
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
          open: () => tester.tap(Label.anchor.finder),
          close: () => tester.tap(Label.anchor.finder),
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
                builder: Label.anchor.anchorBuilder,
                menuChildren: <Widget>[
                  CupertinoMenuItem(
                    key: menuItemGK,
                    child: Label._1.text,
                  ),
                  CupertinoMenuItem(
                    leading: const Icon(Icons.send),
                    trailing: const Icon(Icons.mail),
                    child: Label._2.text,
                  ),
                  CupertinoMenuItem(
                    child: Label._3.text,
                  ),
                ],
              ),
            ],
          ),
        );
        controller.open();
        await tester.pumpAndSettle();
        expect(Label._1.finder, findsOneWidget);
        expect(controller.isOpen, isTrue);
        Navigator.pop(menuItemGK.currentContext!);
        await tester.pumpAndSettle();
        expect(Label._1.finder, findsNothing);
      });
    });

    testWidgets('LTR geometry', (WidgetTester tester) async {
      final UniqueKey menuKey = UniqueKey();
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
                        key: menuKey,
                        menuChildren: createTestMenus(onPressed: onPressed),
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

      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          equals(const Rect.fromLTRB(0, 0, 800, 56)));

      // Open and make sure things are the right size.
      await tester.tap(find.byKey(menuKey));
      await tester.pump();

      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          equals(const Rect.fromLTRB(0, 0, 800, 56)));

      expect(tester.getRect(Label._7.finder),
          equals(const Rect.fromLTRB(400.0, 28.0, 400.0, 28.0)));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(Label._7.finder),
        equals(const Rect.fromLTRB(275.0, 375.0, 525.0, 419.0)),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          equals(const Rect.fromLTRB(0, 0, 800, 56)));
      expect(
        tester.getRect(Label._7.finder),
        equals(const Rect.fromLTRB(275.0, 375.0, 525.0, 419.0)),
      );

      // Decorative surface sizes should match
      const Rect surfaceSize = Rect.fromLTRB(275.0, 56.0, 525.0, 463.0);
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: Label._7.finder,
                  matching: find.byType(DecoratedBoxTransition))
              .first,
        ),
        equals(surfaceSize),
      );
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: Label._7.finder, matching: find.byType(FadeTransition))
              .first,
        ),
        equals(surfaceSize),
      );

      // Test menu bar size when not expanded.
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Column(
              children: <Widget>[
                CupertinoMenuAnchor(
                  menuChildren: createTestMenus(onPressed: onPressed),
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getRect(find.byType(CupertinoMenuAnchor)),
        equals(const Rect.fromLTRB(372.0, 0.0, 428.0, 56.0)),
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
                          menuChildren: createTestMenus(onPressed: onPressed),
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

      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          equals(const Rect.fromLTRB(0, 0, 800, 56)));

      // Open and make sure things are the right size.
      await tester.tap(find.byKey(menuKey));
      await tester.pump();

      // The menu just started opening, therefore menu items should be Size.zero
      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          equals(const Rect.fromLTRB(0, 0, 800, 56)));
      expect(tester.getRect(Label._8.finder),
          equals(const Rect.fromLTRB(400.0, 28.0, 400.0, 28.0)));

      // When the menu is fully open, the menu items should be the correct size.
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          equals(const Rect.fromLTRB(0, 0, 800, 56)));
      expect(
        tester.getRect(Label._7.finder),
        equals(const Rect.fromLTRB(275.0, 375.0, 525.0, 419.0)),
      );

      // Decorative surface sizes should match
      const Rect surfaceSize = Rect.fromLTRB(275.0, 56.0, 525.0, 463.0);
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: Label._7.finder,
                  matching: find.byType(DecoratedBoxTransition))
              .first,
        ),
        equals(surfaceSize),
      );
      expect(
        tester.getRect(
          find
              .ancestor(
                  of: Label._7.finder, matching: find.byType(FadeTransition))
              .first,
        ),
        equals(surfaceSize),
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
                  menuChildren: createTestMenus(onPressed: onPressed),
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
          )),
        ),
      );

      await tester.pump();
      expect(
        tester.getRect(find.byType(CupertinoMenuAnchor)),
        equals(const Rect.fromLTRB(372.0, 0.0, 428.0, 56.0)),
      );
    });

    testWidgets('menu alignment and offset in LTR',
        (WidgetTester tester) async {
      final Map<Label, Key> keys = <Label, Key>{
        Label._1: menuItemKey,
      };

      await tester.pumpWidget(buildTestApp(keys: keys));

      final Finder anchor = find.byType(ElevatedButton);
      expect('${tester.getRect(anchor)}',
      equals('${const Rect.fromLTRB(319.6, 20.0, 480.4, 68.0)}'));

      final Finder findMenuScope = find
          .ancestor(
              of: find.byKey(menuItemKey), matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(anchor);
      await tester.pumpAndSettle();

      Future<void> testPosition(AlignmentDirectional? alignment, Rect position)async {
        await tester.pumpWidget(buildTestApp(keys: keys, alignment: alignment));
        await tester.pump();
        expect('${tester.getRect(findMenuScope)}',
          equals('$position'));
      }

      await testPosition(null, const Rect.fromLTRB(275.0, 68.0, 525.0, 475.0),);
      await testPosition(AlignmentDirectional.topStart, const Rect.fromLTRB(194.6, 20.0, 444.6, 427.0),);
      await testPosition(AlignmentDirectional.center, const Rect.fromLTRB(275.0, 44.0, 525.0, 451.0),);
      await testPosition(AlignmentDirectional.bottomEnd, const Rect.fromLTRB(355.4, 68.0, 605.4, 475.0),);
      await testPosition(AlignmentDirectional.topStart, const Rect.fromLTRB(194.6, 20.0, 444.6, 427.0),);

      final Rect menuRect = tester.getRect(findMenuScope);
      await tester.pumpWidget(
        buildTestApp(
          keys: keys,
          alignment: AlignmentDirectional.topStart,
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
      final Map<Label, Key> keys = <Label, Key>{
        Label._1: menuItemKey,
      };

      await tester.pumpWidget(buildTestApp(keys: keys, textDirection: TextDirection.rtl));
      final Finder anchor = find.byType(ElevatedButton);
      expect('${tester.getRect(anchor)}',
      equals('${const Rect.fromLTRB(319.6, 20.0, 480.4, 68.0)}'));

      final Finder findMenuScope = find
          .ancestor(
              of: find.byKey(menuItemKey), matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(anchor);
      await tester.pumpAndSettle();

      Future<void> testPosition(AlignmentDirectional? alignment, Rect position)async {
        await tester.pumpWidget(buildTestApp(
          keys: keys,
          alignment: alignment,
          textDirection: TextDirection.rtl
        ));
        await tester.pump();
        expect('${tester.getRect(findMenuScope)}',
        equals('$position'));
      }

      await testPosition(null, const Rect.fromLTRB(275.0, 68.0, 525.0, 475.0));
      await testPosition(AlignmentDirectional.topStart, const Rect.fromLTRB(355.4, 20.0, 605.4, 427.0));
      await testPosition(AlignmentDirectional.center, const Rect.fromLTRB(275.0, 44.0, 525.0, 451.0));
      await testPosition(AlignmentDirectional.bottomEnd,const Rect.fromLTRB(194.6, 68.0, 444.6, 475.0));
      await testPosition(AlignmentDirectional.topStart, const Rect.fromLTRB(355.4, 20.0, 605.4, 427.0));

      final Rect menuRect = tester.getRect(findMenuScope);
      await tester.pumpWidget(
        buildTestApp(
          keys: keys,
          alignment: AlignmentDirectional.topStart,
          alignmentOffset: const Offset(10, 20),
          textDirection: TextDirection.rtl
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
              of: find.text(Label._1.label), matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();
      expect(tester.getRect(findMenuScope),
          equals(const Rect.fromLTRB(375.0, 118.0, 625.0, 525.0)));

      // Now move the menu by calling open() again with a local position on the
      // anchor.
      controller.open(position: const Offset(200, 200));
      await tester.pumpAndSettle();
      expect(tester.getRect(findMenuScope),
          equals(const Rect.fromLTRB(175.0, 185.0, 425.0, 592.0)));
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
              of: find.text(Label._1.label), matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();
      expect(tester.getRect(findMenuScope),
          rectEquals(const Rect.fromLTRB(375.0, 123.1, 625.0, 530.1)));


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
                            key: Label.anchor.key,
                            menuChildren: createTestMenus(onPressed: onPressed),
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
        tester.getRect(find.text(Label._7.label)),
        rectEquals(const Rect.fromLTRB(301.0, 399.6, 433.7, 420.6)),
      );

      expect(
        tester.getRect(
          find
              .ancestor(
                  of: Label._7.finder,
                  matching: find.byType(DecoratedBoxTransition))
              .first),

        rectEquals(const Rect.fromLTRB(285.0, 69.1, 535.0, 476.1)),
      );

      // Close and make sure it goes back where it was.
      await tester.tap(find.text(Label._1.label));
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
                              key: Label.anchor.key,
                              menuChildren:
                                  createTestMenus(onPressed: onPressed),
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

      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          rectEquals(anchorPosition));

      // Open and make sure things are the right size.
      await tester.tap(find.byKey(Label.anchor.key));
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          rectEquals(anchorPosition));
      expect(
        tester.getRect(find.text(Label._7.label)),
        rectEquals(const Rect.fromLTRB(386.3, 399.6, 519.0, 420.6)),
      );
      expect(
        tester.getRect(find
            .ancestor(
                of: find.text(Label._7.label), matching: find.byType(DecoratedBoxTransition))
            .first),
        rectEquals(const Rect.fromLTRB(285.0, 69.1, 535.0, 476.1)),
      );

      // Close and make sure it goes back where it was.
      await tester.tap(find.text(Label._1.label));
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
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
                        menuChildren: createTestMenus(onPressed: onPressed),
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

    testWidgets('MenuAnchor clip behavior', (WidgetTester tester) async {
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
      await tester.tap(find.text(Label.outsideButton.label));
      await tester.pump();
      expect(selected, equals(<Label>[Label.outsideButton]));
      selected.clear();

      await tester.tap(find.text(Label.anchor.label));
      await tester.pump();

      expect(opened, equals(<Label>[Label.anchor]));
      expect(closed, isEmpty);
      expect(selected, equals(<Label>[Label.anchor]));
      opened.clear();
      closed.clear();
      selected.clear();

      // The menu is open until it animates closed.
      await tester.tap(find.text(Label.outsideButton.label));
      await tester.pumpAndSettle();

      expect(opened, isEmpty);
      expect(closed, equals(<Label>[Label.anchor]));
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
      await tester.tap(find.text(Label.outsideButton.label));
      await tester.pump();
      expect(selected, equals(<Label>[Label.outsideButton]));
      selected.clear();

      await tester.tap(find.text(Label.anchor.label));
      await tester.pump();
      expect(opened, equals(<Label>[Label.anchor]));
      expect(closed, isEmpty);
      expect(selected, equals(<Label>[Label.anchor]));
      opened.clear();
      closed.clear();
      selected.clear();

      // The menu is open until it animates closed.
      await tester.tap(find.text(Label.outsideButton.label));
      await tester.pumpAndSettle();

      expect(opened, isEmpty);
      expect(closed, equals(<Label>[Label.anchor]));
      // Because consumesOutsideTap is false, this is expected to receive its
      // tap.
      expect(selected, equals(<Label>[Label.outsideButton]));
      selected.clear();
      opened.clear();
      closed.clear();
    });

    testWidgets('select works', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home:  CupertinoMenuAnchor(
              key: Label.anchor.key,
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus(
                onPressed: onPressed,
              ),
            ),
        ),
      );

      await tester.tap(find.byKey(Label.anchor.key));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Label._1.label));
      await tester.pump();
      expect(selected, equals(<Label>[Label._1]));
      await tester.pumpAndSettle();
      expect(opened, isEmpty);
      expect(find.text(Label._1.label), findsNothing);
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
        description.join('\n'),
        equalsIgnoringHashCodes(
            '''AUTO-CLOSE\nfocusNode: null\nclipBehavior: hardEdge\nalignmentOffset: Offset(10.0, 10.0)\nchild: Text("Sample Text")'''),
      );
    });

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
      controller.open();
      await tester.pumpAndSettle();

      expect(focusedMenu, equals('CupertinoMenuItemGestureHandler(Text("Menu 0"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItemGestureHandler(Text("Menu 1"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItemGestureHandler(Text("Menu 2"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItemGestureHandler(Text("Menu 0"))'));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItemGestureHandler(Text("Menu 2"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItemGestureHandler(Text("Menu 1"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItemGestureHandler(Text("Menu 0"))'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      opened.clear();
      closed.clear();

      // Test closing a menu with enter.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(opened, isEmpty);
      expect(closed, <Label>[Label._1]);
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
              menuChildren: createTestMenus(
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      );

      listenForFocusChanges();

      // Have to open a menu initially to start things going.
      controller.open();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 1"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 2"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 3"))'));


      // 4 is disabled
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 5"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // 6
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // 7
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // 8
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // 9
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 9"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // 9
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // 9
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 9"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 8"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 1"))'));


      // Should do nothing without a submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 1"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Menu 1"))'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

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
                menuChildren: createTestMenus(
                  onPressed: onPressed,
                ),
              ),
            ),
          ),
        ),
      );

      listenForFocusChanges();

      // Have to open a menu initially to start things going.
      await tester.tap(find.text(Label._1.label));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(focusedMenu, equals('SubmenuButton(Text("Menu 1"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals('SubmenuButton(Text("Menu 1"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Sub Menu 10"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals('SubmenuButton(Text("Sub Menu 11"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Sub Menu 12"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Sub Menu 12"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focusedMenu, equals('SubmenuButton(Text("Sub Menu 11"))'));

      // Open the next submenu
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(
          focusedMenu, equals('CupertinoMenuItem(Text("Sub Sub Menu 110"))'));

      // Go back, close the submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedMenu, equals('SubmenuButton(Text("Sub Menu 11"))'));

      // Move up, should close the submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Sub Menu 10"))'));

      // Move down, should reopen the submenu.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusedMenu, equals('SubmenuButton(Text("Sub Menu 11"))'));

      // Open the next submenu again.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(
          focusedMenu, equals('CupertinoMenuItem(Text("Sub Sub Menu 110"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(
          focusedMenu, equals('CupertinoMenuItem(Text("Sub Sub Menu 111"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(
          focusedMenu, equals('CupertinoMenuItem(Text("Sub Sub Menu 112"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(
          focusedMenu, equals('CupertinoMenuItem(Text("Sub Sub Menu 113"))'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(
          focusedMenu, equals('CupertinoMenuItem(Text("Sub Sub Menu 113"))'));
    });

    testWidgets('hover traversal works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus(
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      );

      listenForFocusChanges();

      // Hovering when the menu is not yet open does nothing.
      await hoverOver(tester, find.text(Label._1.label));
      await tester.pump();
      expect(focusedMenu, isNull);

      // Have to open a menu initially to start things going.
      await tester.tap(find.text(Label._1.label));
      await tester.pump();
      expect(focusedMenu, equals('SubmenuButton(Text("Menu 0"))'));

      // Hovering when the menu is already  open does nothing.
      await hoverOver(tester, find.text(Label._1.label));
      await tester.pump();
      expect(focusedMenu, equals('SubmenuButton(Text("Menu 0"))'));

      // Hovering over the other main menu items opens them now.
      await hoverOver(tester, find.text(Label._2.label));
      await tester.pump();
      expect(focusedMenu, equals('SubmenuButton(Text("Menu 2"))'));

      await hoverOver(tester, find.text(Label._1.label));
      await tester.pump();
      expect(focusedMenu, equals('SubmenuButton(Text("Menu 1"))'));

      // Hovering over the menu items focuses them.
      await hoverOver(tester, find.text(Label._7.label));
      await tester.pump();
      expect(focusedMenu, equals('CupertinoMenuItem(Text("Sub Menu 10"))'));

      await hoverOver(tester, find.text(Label._8.label));
      await tester.pump();
      expect(focusedMenu, equals('SubmenuButton(Text("Sub Menu 11"))'));

      // await hoverOver(tester, find.text(Label.item14.label));
      await tester.pump();
      expect(
          focusedMenu, equals('CupertinoMenuItem(Text("Sub Sub Menu 110"))'));
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
                  menuChildren: createTestMenus(
                    onPressed: onPressed,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text(Label._1.label));
      await tester.pump();

      expect(opened, isNotEmpty);
      expect(closed, isEmpty);
      opened.clear();

      scrollController.jumpTo(1000);
      await tester.pump();

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
                    rootOpened = true;
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
                  menuChildren: createTestMenus(
                    onPressed: onPressed,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show menu'));
      await tester.pump();
      expect(rootOpened, true);

      // Hover the first item.
      final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
          pointer.hover(tester.getCenter(find.text(Label._1.label))));
      await tester.pump();
      expect(opened, isNotEmpty);

      // Menus do not close on internal scroll.
      await tester.sendEventToBinding(pointer.scroll(const Offset(0.0, 30.0)));
      await tester.pump();
      expect(rootOpened, true);
      expect(closed, isEmpty);

      // Menus close on external scroll.
      scrollController.jumpTo(1000);
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
                    menuChildren: createTestMenus(
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

      await tester.tap(find.text(Label._1.label));
      await tester.pump();

      expect(opened, isNotEmpty);
      expect(closed, isEmpty);
      opened.clear();

      const Size smallSize = Size(200, 200);
      await changeSurfaceSize(tester, smallSize);

      await tester.pumpWidget(build(smallSize));
      await tester.pump();

      expect(opened, isEmpty);
      expect(closed, isNotEmpty);
    });
  });

  group('Accelerators', () {
    const Set<TargetPlatform> apple = <TargetPlatform>{
      TargetPlatform.macOS,
      TargetPlatform.iOS
    };
    final Set<TargetPlatform> nonApple =
        TargetPlatform.values.toSet().difference(apple);

    test('Accelerator markers are stripped properly', () {
      const Map<String, String> expected = <String, String>{
        'Plain String': 'Plain String',
        '&Simple Accelerator': 'Simple Accelerator',
        '&Multiple &Accelerators': 'Multiple Accelerators',
        'Whitespace & Accelerators': 'Whitespace  Accelerators',
        '&Quoted && Ampersand': 'Quoted & Ampersand',
        'Ampersand at End &': 'Ampersand at End ',
        '&&Multiple Ampersands &&& &&&A &&&&B &&&&':
            '&Multiple Ampersands & &A &&B &&',
        'Bohrium 𨨏 Code point U+28A0F': 'Bohrium 𨨏 Code point U+28A0F',
      };
      const List<int> expectedIndices = <int>[-1, 0, 0, -1, 0, -1, 24, -1];
      const List<bool> expectedHasAccelerator = <bool>[
        false,
        true,
        true,
        false,
        true,
        false,
        true,
        false
      ];
      int acceleratorIndex = -1;
      int count = 0;
      for (final String key in expected.keys) {
        expect(
          MenuAcceleratorLabel.stripAcceleratorMarkers(key,
              setIndex: (int index) {
            acceleratorIndex = index;
          }),
          equals(expected[key]),
          reason: "'$key' label doesn't match ${expected[key]}",
        );
        expect(
          acceleratorIndex,
          equals(expectedIndices[count]),
          reason: "'$key' index doesn't match ${expectedIndices[count]}",
        );
        expect(
          MenuAcceleratorLabel(key).hasAccelerator,
          equals(expectedHasAccelerator[count]),
          reason:
              "'$key' hasAccelerator isn't ${expectedHasAccelerator[count]}",
        );
        count += 1;
      }
    });

    testWidgets('can invoke menu items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus(
                onPressed: onPressed,
                accelerators: true,
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: 'm');
      await tester.pump();
      // Makes sure that identical accelerators in parent menu items don't
      // shadow the ones in the children.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: 'm');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();

      expect(opened, equals(<Label>[Label._1]));
      expect(closed, equals(<Label>[Label._1]));
      expect(selected, equals(<Label>[Label._1]));
      // Selecting a non-submenu item should close all the menus.
      expect(find.text(Label._1.label), findsNothing);
      opened.clear();
      closed.clear();
      selected.clear();

      // Invoking several levels deep.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: 'e');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: '1');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: '1');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altRight);
      await tester.pump();

      expect(opened, equals(<Label>[Label._1, Label._8]));
      expect(closed, equals(<Label>[Label._8, Label._1]));
      // expect(selected, equals(<Label>[Label.item14]));
      opened.clear();
      closed.clear();
      selected.clear();
    }, variant: TargetPlatformVariant(nonApple));

    testWidgets('can combine with regular keyboard navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus(
                onPressed: onPressed,
                accelerators: true,
              ),
            ),
          ),
        ),
      );

      // Combining accelerators and regular keyboard navigation works.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: 'e');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: '1');
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(opened, equals(<Label>[Label._1, Label._8]));
      expect(closed, equals(<Label>[Label._8, Label._1]));
      // expect(selected, equals(<Label>[Label.item14]));
    }, variant: TargetPlatformVariant(nonApple));

    testWidgets('can combine with mouse', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus(
                onPressed: onPressed,
                accelerators: true,
              ),
            ),
          ),
        ),
      );

      // Combining accelerators and regular keyboard navigation works.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: 'e');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: '1');
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      // await tester.tap(find.text(Label.item15.label));
      await tester.pump();

      expect(opened, equals(<Label>[Label._1, Label._8]));
      expect(closed, equals(<Label>[Label._8, Label._1]));
      // expect(selected, equals(<Label>[Label.item15]));
    }, variant: TargetPlatformVariant(nonApple));

    testWidgets("disabled items don't respond to accelerators",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus(
                onPressed: onPressed,
                accelerators: true,
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: '5');
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();

      expect(opened, isEmpty);
      expect(closed, isEmpty);
      expect(selected, isEmpty);
      // Selecting a non-submenu item should close all the menus.
      expect(find.text(Label._1.label), findsNothing);
    }, variant: TargetPlatformVariant(nonApple));

    testWidgets("Apple platforms don't react to accelerators",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus(
                onPressed: onPressed,
                accelerators: true,
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: 'm');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: 'm');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();

      expect(opened, isEmpty);
      expect(closed, isEmpty);
      expect(selected, isEmpty);

      // Or with the option key equivalents.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: 'µ');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM, character: 'µ');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();

      expect(opened, isEmpty);
      expect(closed, isEmpty);
      expect(selected, isEmpty);
    }, variant: const TargetPlatformVariant(apple));
  });

  group('CupertinoMenuController', () {
    testWidgets('Moving a controller to a new instance works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              menuChildren: createTestMenus(),
            ),
          ),
        ),
      );

      // Open a menu initially.
      await tester.tap(find.text(Label._1.label));
      await tester.pump();

      await tester.tap(find.text(Label._8.label));
      await tester.pump();

      // Now pump a new menu with a different UniqueKey to dispose of the opened
      // menu's node, but keep the existing controller.
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              menuChildren: createTestMenus(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('closing via controller works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              onOpen: onOpen,
              onClose: onClose,
              menuChildren: createTestMenus(
                onPressed: onPressed,
                shortcuts: <Label, MenuSerializableShortcut>{
                  // Label.item14: const SingleActivator(
                  //   LogicalKeyboardKey.keyA,
                  //   control: true,
                  // )
                },
              ),
            ),
          ),
        ),
      );

      // Open a menu initially.
      await tester.tap(find.text(Label._1.label));
      await tester.pump();

      await tester.tap(find.text(Label._8.label));
      await tester.pump();
      expect(opened, unorderedEquals(<Label>[Label._1, Label._8]));
      opened.clear();
      closed.clear();

      // Close menus using the controller
      controller.close();
      await tester.pump();

      // The menu should go away,
      expect(closed, unorderedEquals(<Label>[Label._1, Label._8]));
      expect(opened, isEmpty);
    });
  });

  group('CupertinoMenuItem', () {
    testWidgets('Shortcut mnemonics are displayed',
        (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   MaterialApp(
      //     home: Material(
      //       child: CupertinoMenuAnchor(
      //         controller: controller,
      //        menuChildren: createTestMenus(
      //           shortcuts: <Label, MenuSerializableShortcut>{
      //             Label.item14: const SingleActivator(LogicalKeyboardKey.keyA, control: true),
      //             Label.item14: const SingleActivator(LogicalKeyboardKey.keyB, shift: true),
      //             Label.item15: const SingleActivator(LogicalKeyboardKey.keyC, alt: true),
      //             Label.item16: const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
      //           },
      //         ),
      //       ),
      //     ),
      //   ),
      // );

      // // Open a menu initially.
      // await tester.tap(find.text(Label.one.label));
      // await tester.pump();

      // await tester.tap(find.text(Label.item8.label));
      // await tester.pump();

      // Text mnemonic0;
      // Text mnemonic1;
      // Text mnemonic2;
      // Text mnemonic3;

      // switch (defaultTargetPlatform) {
      //   case TargetPlatform.android:
      //   case TargetPlatform.fuchsia:
      //   case TargetPlatform.linux:
      //     mnemonic0 = tester.widget(findMnemonic(Label.item14.label));
      //     expect(mnemonic0.data, equals('Ctrl+A'));
      //     mnemonic1 = tester.widget(findMnemonic(Label.item14.label));
      //     expect(mnemonic1.data, equals('Shift+B'));
      //     mnemonic2 = tester.widget(findMnemonic(Label.item15.label));
      //     expect(mnemonic2.data, equals('Alt+C'));
      //     mnemonic3 = tester.widget(findMnemonic(Label.item16.label));
      //     expect(mnemonic3.data, equals('Meta+D'));
      //   case TargetPlatform.windows:
      //     mnemonic0 = tester.widget(findMnemonic(Label.item14.label));
      //     expect(mnemonic0.data, equals('Ctrl+A'));
      //     mnemonic1 = tester.widget(findMnemonic(Label.item14.label));
      //     expect(mnemonic1.data, equals('Shift+B'));
      //     mnemonic2 = tester.widget(findMnemonic(Label.item15.label));
      //     expect(mnemonic2.data, equals('Alt+C'));
      //     mnemonic3 = tester.widget(findMnemonic(Label.item16.label));
      //     expect(mnemonic3.data, equals('Win+D'));
      //   case TargetPlatform.iOS:
      //   case TargetPlatform.macOS:
      //     mnemonic0 = tester.widget(findMnemonic(Label.item14.label));
      //     expect(mnemonic0.data, equals('⌃ A'));
      //     mnemonic1 = tester.widget(findMnemonic(Label.item14.label));
      //     expect(mnemonic1.data, equals('⇧ B'));
      //     mnemonic2 = tester.widget(findMnemonic(Label.item15.label));
      //     expect(mnemonic2.data, equals('⌥ C'));
      //     mnemonic3 = tester.widget(findMnemonic(Label.item16.label));
      //     expect(mnemonic3.data, equals('⌘ D'));
      // }

      // await tester.pumpWidget(
      //   MaterialApp(
      //     home: Material(
      //       child: CupertinoMenuAnchor(
      //         controller: controller,
      //         menuChildren: createTestMenus(
      //           includeExtraGroups: true,
      //           shortcuts: <Label, MenuSerializableShortcut>{
      //             Label.item14: const SingleActivator(LogicalKeyboardKey.arrowRight),
      //             Label.item14: const SingleActivator(LogicalKeyboardKey.arrowLeft),
      //             Label.item15: const SingleActivator(LogicalKeyboardKey.arrowUp),
      //             Label.item16: const SingleActivator(LogicalKeyboardKey.arrowDown),
      //           },
      //         ),
      //       ),
      //     ),
      //   ),
      // );
      // await tester.pumpAndSettle();

      // mnemonic0 = tester.widget(findMnemonic(Label.item14.label));
      // expect(mnemonic0.data, equals('→'));
      // mnemonic1 = tester.widget(findMnemonic(Label.item14.label));
      // expect(mnemonic1.data, equals('←'));
      // mnemonic2 = tester.widget(findMnemonic(Label.item15.label));
      // expect(mnemonic2.data, equals('↑'));
      // mnemonic3 = tester.widget(findMnemonic(Label.item16.label));
      // expect(mnemonic3.data, equals('↓'));

      // // Try some weirder ones.
      // await tester.pumpWidget(
      //   MaterialApp(
      //     home: Material(
      //       child: CupertinoMenuAnchor(
      //         controller: controller,
      //        menuChildren: createTestMenus(
      //           shortcuts: <Label, MenuSerializableShortcut>{
      //             Label.item14: const SingleActivator(LogicalKeyboardKey.escape),
      //             Label.item14: const SingleActivator(LogicalKeyboardKey.fn),
      //             Label.item15: const SingleActivator(LogicalKeyboardKey.enter),
      //           },
      //         ),
      //       ),
      //     ),
      //   ),
      // );
      // await tester.pumpAndSettle();

      // mnemonic0 = tester.widget(findMnemonic(Label.item14.label));
      // expect(mnemonic0.data, equals('Esc'));
      // mnemonic1 = tester.widget(findMnemonic(Label.item14.label));
      // expect(mnemonic1.data, equals('Fn'));
      // mnemonic2 = tester.widget(findMnemonic(Label.item15.label));
      // expect(mnemonic2.data, equals('↵'));
    }, variant: TargetPlatformVariant.all());

    testWidgets('leading is used when set', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                SubmenuButton(
                  menuChildren: <Widget>[
                    CupertinoMenuItem(
                      leading: const Text('leading'),
                      child: Text(Label._1.label),
                    ),
                  ],
                  child: Text(Label._1.label),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text(Label._1.label));
      await tester.pump();

      expect(find.text('leading'), findsOneWidget);
    });

    testWidgets('trailing is used when set', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                SubmenuButton(
                  menuChildren: <Widget>[
                    CupertinoMenuItem(
                      trailing: const Text('trailing'),
                      child: Text(Label._1.label),
                    ),
                  ],
                  child: Text(Label._1.label),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text(Label._1.label));
      await tester.pump();

      expect(find.text('trailing'), findsOneWidget);
    });

    // testWidgets('SubmenuButton uses supplied controller', (WidgetTester tester) async {
    //   final CupertinoMenuController subCupertinoMenuController = CupertinoMenuController();
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Material(
    //         child: CupertinoMenuAnchor(
    //           controller: controller,
    //          menuChildren: <Widget>[
    //             SubmenuButton(
    //               controller: subCupertinoMenuController,
    //               menuChildren: <Widget>[
    //                 CupertinoMenuItem(
    //                   child: Text(TestMenu.mainMenu1.label),
    //                 ),
    //               ],
    //               child: Text(TestMenu.mainMenu0.label),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );

    //   subCupertinoMenuController.open();
    //   await tester.pump();
    //   expect(find.text(TestMenu.mainMenu1.label), findsOneWidget);

    //   subCupertinoMenuController.close();
    //   await tester.pump();
    //   expect(find.text(TestMenu.mainMenu1.label), findsNothing);

    //   // Now remove the controller and try to control it.
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Material(
    //         child: CupertinoMenuAnchor(
    //           controller: controller,
    //          menuChildren: <Widget>[
    //             SubmenuButton(
    //               menuChildren: <Widget>[
    //                 CupertinoMenuItem(
    //                   child: Text(TestMenu.mainMenu1.label),
    //                 ),
    //               ],
    //               child: Text(TestMenu.mainMenu0.label),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );

    //   await expectLater(() => subCupertinoMenuController.open(), throwsAssertionError);
    //   await tester.pump();
    //   expect(find.text(TestMenu.mainMenu1.label), findsNothing);
    // });

    testWidgets('diagnostics', (WidgetTester tester) async {
      final ButtonStyle style = ButtonStyle(
        shape:
            MaterialStateProperty.all<OutlinedBorder?>(const StadiumBorder()),
        elevation: MaterialStateProperty.all<double?>(10.0),
        backgroundColor: const MaterialStatePropertyAll<Color>(Colors.red),
      );
      final MenuStyle menuStyle = MenuStyle(
        shape: MaterialStateProperty.all<OutlinedBorder?>(
            const RoundedRectangleBorder()),
        elevation: MaterialStateProperty.all<double?>(20.0),
        backgroundColor: const MaterialStatePropertyAll<Color>(Colors.green),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                SubmenuButton(
                  style: style,
                  menuStyle: menuStyle,
                  menuChildren: <Widget>[
                    CupertinoMenuItem(
                      child: Text(Label._1.label),
                    ),
                  ],
                  child: Text(Label._1.label),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text(Label._1.label));
      await tester.pump();

      final SubmenuButton submenu = tester.widget(find.byType(SubmenuButton));
      final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
      submenu.debugFillProperties(builder);

      final List<String> description = builder.properties
          .where(
              (DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
          .map((DiagnosticsNode node) => node.toString())
          .toList();

      expect(
        description,
        equalsIgnoringHashCodes(
          <String>[
            'child: Text("Menu 0")',
            'focusNode: null',
            'menuStyle: MenuStyle#00000(backgroundColor: MaterialStatePropertyAll(MaterialColor(primary value: Color(0xff4caf50))), elevation: MaterialStatePropertyAll(20.0), shape: MaterialStatePropertyAll(RoundedRectangleBorder(BorderSide(width: 0.0, style: none), BorderRadius.zero)))',
            'alignmentOffset: null',
            'clipBehavior: hardEdge',
          ],
        ),
      );
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

      // Taps the CupertinoMenuItem which should close the menu
      await tester.tap(find.text('Button 1'));
      await tester.pump();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(0));

      await tester.pumpAndSettle();

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

      // Taps the CupertinoMenuItem which shouldn't close the menu
      await tester.tap(find.text('Button 1'));
      await tester.pump();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(1));
    });
  });

  group('Layout', () {
    List<Rect> collectMenuItemRects() {
      final List<Rect> menuRects = <Rect>[];
      final List<Element> candidates =
          find.byType(SubmenuButton).evaluate().toList();
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
                        menuChildren: createTestMenus(onPressed: onPressed),
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

      await tester.tap(find.text(Label._1.label));
      await tester.pump();
      // await tester.tap(find.text(Label.item8.label));
      await tester.pump();

      expect(find.byType(CupertinoMenuItem), findsNWidgets(6));
      expect(find.byType(SubmenuButton), findsNWidgets(5));
      expect(
        collectMenuItemRects(),
        equals(const <Rect>[
          Rect.fromLTRB(4.0, 0.0, 112.0, 48.0),
          Rect.fromLTRB(112.0, 0.0, 220.0, 48.0),
          Rect.fromLTRB(112.0, 104.0, 326.0, 152.0),
          Rect.fromLTRB(220.0, 0.0, 328.0, 48.0),
          Rect.fromLTRB(328.0, 0.0, 506.0, 48.0)
        ]),
      );
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
                          menuChildren: createTestMenus(onPressed: onPressed),
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

      await tester.tap(find.text(Label._1.label));
      await tester.pump();
      // await tester.tap(find.text(Label.item8.label));
      await tester.pump();

      expect(find.byType(CupertinoMenuItem), findsNWidgets(6));
      expect(find.byType(SubmenuButton), findsNWidgets(5));
      expect(
        collectMenuItemRects(),
        equals(const <Rect>[
          Rect.fromLTRB(688.0, 0.0, 796.0, 48.0),
          Rect.fromLTRB(580.0, 0.0, 688.0, 48.0),
          Rect.fromLTRB(474.0, 104.0, 688.0, 152.0),
          Rect.fromLTRB(472.0, 0.0, 580.0, 48.0),
          Rect.fromLTRB(294.0, 0.0, 472.0, 48.0)
        ]),
      );
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
                        menuChildren: createTestMenus(onPressed: onPressed),
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
      await tester.pump();

      await tester.tap(find.text(Label._1.label));
      await tester.pump();
      await tester.tap(find.text(Label._8.label));
      await tester.pump();

      expect(find.byType(CupertinoMenuItem), findsNWidgets(6));
      expect(find.byType(SubmenuButton), findsNWidgets(5));
      expect(
        collectMenuItemRects(),
        equals(const <Rect>[
          Rect.fromLTRB(4.0, 0.0, 112.0, 48.0),
          Rect.fromLTRB(112.0, 0.0, 220.0, 48.0),
          Rect.fromLTRB(86.0, 104.0, 300.0, 152.0),
          Rect.fromLTRB(220.0, 0.0, 328.0, 48.0),
          Rect.fromLTRB(328.0, 0.0, 506.0, 48.0)
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
                        menuChildren: createTestMenus(onPressed: onPressed),
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
      await tester.pump();

      await tester.tap(find.text(Label._1.label));
      await tester.pump();
      await tester.tap(find.text(Label._8.label));
      await tester.pump();

      expect(find.byType(CupertinoMenuItem), findsNWidgets(6));
      expect(find.byType(SubmenuButton), findsNWidgets(5));
      expect(
        collectMenuItemRects(),
        equals(const <Rect>[
          Rect.fromLTRB(188.0, 0.0, 296.0, 48.0),
          Rect.fromLTRB(80.0, 0.0, 188.0, 48.0),
          Rect.fromLTRB(0.0, 104.0, 214.0, 152.0),
          Rect.fromLTRB(-28.0, 0.0, 80.0, 48.0),
          Rect.fromLTRB(-206.0, 0.0, -28.0, 48.0)
        ]),
      );
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
          Rect.fromLTRB(0.0, 48.0, 256.0, 112.0),
          Rect.fromLTRB(266.0, 48.0, 522.0, 112.0),
          Rect.fromLTRB(522.0, 48.0, 778.0, 112.0),
          Rect.fromLTRB(256.0, 48.0, 512.0, 112.0),
        ]),
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

  group('LocalizedShortcutLabeler', () {
    testWidgets('getShortcutLabel returns the right labels',
        (WidgetTester tester) async {
      String expectedMeta;
      String expectedCtrl;
      String expectedAlt;
      String expectedSeparator;
      String expectedShift;
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          expectedCtrl = 'Ctrl';
          expectedMeta =
              defaultTargetPlatform == TargetPlatform.windows ? 'Win' : 'Meta';
          expectedAlt = 'Alt';
          expectedShift = 'Shift';
          expectedSeparator = '+';
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          expectedCtrl = '⌃';
          expectedMeta = '⌘';
          expectedAlt = '⌥';
          expectedShift = '⇧';
          expectedSeparator = ' ';
      }

      const SingleActivator allModifiers = SingleActivator(
        LogicalKeyboardKey.keyA,
        control: true,
        meta: true,
        shift: true,
        alt: true,
      );
      late String allExpected;
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          allExpected = <String>[
            expectedAlt,
            expectedCtrl,
            expectedMeta,
            expectedShift,
            'A'
          ].join(expectedSeparator);
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          allExpected = <String>[
            expectedCtrl,
            expectedAlt,
            expectedShift,
            expectedMeta,
            'A'
          ].join(expectedSeparator);
      }
      const CharacterActivator charShortcuts = CharacterActivator('ñ');
      const String charExpected = 'ñ';
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  shortcut: allModifiers,
                  child: Text(Label._7.label),
                ),
                CupertinoMenuItem(
                  shortcut: charShortcuts,
                  child: Text(Label._8.label),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text(Label._1.label));
      await tester.pump();

      expect(find.text(allExpected), findsOneWidget);
      expect(find.text(charExpected), findsOneWidget);
    }, variant: TargetPlatformVariant.all());
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
            menuChildren: createTestMenus(
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
    await tester.tap(find.text(Label._1.label));
    await tester.pump();

    // Test menu item text style uses the TextTheme.labelLarge.
    buttonMaterial = find
        .descendant(
          of: find.widgetWithText(TextButton, Label._7.label),
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

List<Widget> createTestMenus({
  void Function(Label)? onPressed,
  Map<Label, MenuSerializableShortcut> shortcuts =
      const <Label, MenuSerializableShortcut>{},
  Map<Label, Key> keys =
       const <Label, Key>{},
  bool accelerators = false,
}) {
  Widget menuItem(
    Label item, {
    bool enabled = true,
    Widget? leading,
    Widget? trailing,
    Widget? subtitle,
    Key? key,
  }) {
    return CupertinoMenuItem(
      key: key ??  keys[item],
      onPressed: enabled && onPressed != null ? () => onPressed(item) : null,
      shortcut: shortcuts[item],
      leading: leading,
      trailing: trailing,
      subtitle: subtitle,
      child: accelerators ? item.acceleratorText : item.text,
    );
  }

  final List<Widget> result = <Widget>[
    menuItem(Label._1, leading: const Icon(Icons.add)),
    menuItem(Label._2,
        leading: const Icon(Icons.add),
        trailing: const Icon(
          Icons.add,
          size: 48,
        )),
    CupertinoMenuLargeDivider(key: Label._3d.key),
    menuItem(Label._3,
        subtitle: const Text('subtitle'), leading: const Icon(Icons.add)),
    menuItem(Label._4, enabled: false),
    menuItem(Label._5),
    menuItem(Label._6),
    menuItem(Label._7),
    menuItem(Label._8),
  ];
  return result;
}

enum Label {
  _0('&Menu 0'),
  _1('&Menu 1'),
  _2('Me&nu 2'),
  _3('Men&u 3'),
  _4('Menu &4'),
  _5('Menu &5 &'),
  _6('Menu &&6'),
  _7('Me&nu 7'),
  _3d('Me&nu 8'),
  _8('Menu 9'),
  anchor('Press Me'),
  outsideButton('Outside');

  const Label(this.acceleratorLabel);
  final String acceleratorLabel;
  // Strip the accelerator markers.
  String get label =>
      MenuAcceleratorLabel.stripAcceleratorMarkers(acceleratorLabel);
  Text get text => Text(label);
  MenuAcceleratorLabel get acceleratorText =>
      MenuAcceleratorLabel(acceleratorLabel);
  Widget anchorBuilder(BuildContext context, CupertinoMenuController controller,
      [Widget? child, VoidCallback? onPressed]) {
    return TextButton(
      onPressed: onPressed ??
          () {
            if (controller.animationStatus == AnimationStatus.completed ||
                controller.animationStatus == AnimationStatus.forward) {
              controller.close();
            } else {
              controller.open();
            }
          },
      child: text,
    );
  }

  ValueKey<Label> get key => const ValueKey<Label>(Label._0);
  Finder get finder => find.widgetWithText(CupertinoMenuItem, label);
  Finder get acceleratedFinder => find.widgetWithText(CupertinoMenuItem, label);
}

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
      key: key,
      onPressed: enabled && onPressed != null ? () => onPressed(menu) : null,
      shortcut: shortcuts[menu],
      leading: leadingIcon,
      trailing: trailingIcon,
      child: accelerators ? MenuAcceleratorLabel(menu.acceleratorLabel) : Text(menu.label),
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
      child: accelerators ? MenuAcceleratorLabel(menu.acceleratorLabel) : Text(menu.label),
    );
  }

  final List<Widget> result = <Widget>[
    cupertinoMenuItemButton(TestMenu.item0, leadingIcon: const Icon(Icons.add)),
    cupertinoMenuItemButton(TestMenu.item1, enabled: false,),
    const CupertinoMenuLargeDivider(),
    submenuButton(
      TestMenu.mainMenu0,
      menuChildren: <Widget>[
        menuItemButton(TestMenu.subMenu00, leadingIcon: const Icon(Icons.add)),
        menuItemButton(TestMenu.subMenu01),
        menuItemButton(TestMenu.subMenu02),
      ],
    ),
    cupertinoMenuItemButton(TestMenu.item2),
    submenuButton(
      TestMenu.mainMenu1,
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
    submenuButton(
      TestMenu.mainMenu2,
      menuChildren: <Widget>[
        menuItemButton(
          TestMenu.subMenu20,
          leadingIcon: const Icon(Icons.ac_unit),
          enabled: false,
        ),
      ],
    ),
    if (includeExtraGroups)
      submenuButton(
        TestMenu.mainMenu3,
        menuChildren: <Widget>[
          menuItemButton(TestMenu.subMenu30, enabled: false),
        ],
      ),
    if (includeExtraGroups)
      submenuButton(
        TestMenu.mainMenu4,
        menuChildren: <Widget>[
          menuItemButton(TestMenu.subMenu40, enabled: false),
          menuItemButton(TestMenu.subMenu41, enabled: false),
          menuItemButton(TestMenu.subMenu42, enabled: false),
        ],
      ),
    submenuButton(TestMenu.mainMenu5, menuChildren: const <Widget>[]),
    const CupertinoMenuLargeDivider(),
    cupertinoMenuItemButton(TestMenu.item3),

  ];
  return result;
}

enum TestMenu {
  item0('&item 0'),
  item1('I&tem 1'),
  item2('It&em 2'),
  item3('Ite&m 3'),
  item4('Ite&m 4'),
  item5('Ite&m 5'),
  mainMenu0('&Menu 0'),
  mainMenu1('M&enu &1'),
  mainMenu2('Me&nu 2'),
  mainMenu3('Men&u 3'),
  mainMenu4('Menu &4'),
  mainMenu5('Menu &5 && &6 &'),
  subMenu00('Sub &Menu 0&0'),
  subMenu01('Sub Menu 0&1'),
  subMenu02('Sub Menu 0&2'),
  subMenu10('Sub Menu 1&0'),
  subMenu11('Sub Menu 1&1'),
  subMenu12('Sub Menu 1&2'),
  subMenu20('Sub Menu 2&0'),
  subMenu30('Sub Menu 3&0'),
  subMenu40('Sub Menu 4&0'),
  subMenu41('Sub Menu 4&1'),
  subMenu42('Sub Menu 4&2'),
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
  Finder get finder => find.widgetWithText(CupertinoMenuItem, label);
}