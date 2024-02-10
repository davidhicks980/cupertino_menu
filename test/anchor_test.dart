// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:example/menu.dart';
import 'package:example/menu_item.dart';
import 'package:example/test_anchor.dart';
import 'package:flutter/cupertino.dart' show CupertinoApp, CupertinoColors, CupertinoDynamicColor, CupertinoIcons, CupertinoPageScaffold, CupertinoScrollbar, CupertinoTheme, CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide  CheckboxMenuButton, MenuAcceleratorLabel, MenuAnchor, MenuBar, MenuController, MenuItemButton, RadioMenuButton, SubmenuButton;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'semantics.dart';

// TODO(davidhicks980): Accelerators are not used on Apple platforms -- exclude
// them from the library?

typedef MenuParts = ({
  TextStyle? leadingIconStyle,
  TextStyle? leadingTextStyle,
  TextStyle? subtitleStyle,
  TextStyle? titleStyle,
  TextStyle? trailingIconStyle,
  TextStyle? trailingTextStyle
});
void main() {
  late CupertinoMenuController controller;
  String? focusedMenu;
  final List<TestMenu> selected = <TestMenu>[];
  final List<TestMenu> opened = <TestMenu>[];
  final List<TestMenu> closed = <TestMenu>[];
  Matcher rectEquals(Rect rect) {
    return rectMoreOrLessEquals(rect, epsilon: 0.1);
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

  Finder findMenuPanel() {
    return find.byWidgetPredicate(
        (Widget widget) => widget.runtimeType.toString() == '_MenuPanel');
  }

  Finder findMenuPanelDescendent<T>() {
    return find.descendant(
      of: findMenuPanel(),
      matching: find.byType(T),
    );
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
    MediaQueryData mediaQuery = const MediaQueryData(),
  }) {
    final FocusNode focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    return CupertinoApp(
      home: MediaQuery(
        data: mediaQuery,
        child: CupertinoTheme(
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
                    menuChildren: children ?? createTestMenus(onPressed: onPressed),
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
      ),
    );
  }


  T findMenuPanelWidget<T extends Widget>(WidgetTester tester) {
    return tester.firstWidget<T>(
      find.descendant(
        of: findMenuPanel(),
        matching: find.byType(T),
      ),
    );
  }

  CupertinoApp buildApp(Widget child, ) {
  return CupertinoApp(
    home: Stack(children: <Widget>[
      Align(
        alignment: AlignmentDirectional.topStart,
        child: child
      )
    ]),
  );
}



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
        Column(
          children: <Widget>[
            CupertinoMenuAnchor(
              builder: _buildAnchor,
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
      ),
    );

    await tester.pump();
    expect(FocusManager.instance.primaryFocus, equals(buttonFocus));
    await tester.tap(find.byType(CupertinoMenuAnchor));
    await tester.pumpAndSettle();

    await tester.tap(TestMenu.item1.findText);
    await tester.pump();

    expect(focusInOnPressed, equals(buttonFocus));
    expect(FocusManager.instance.primaryFocus, equals(buttonFocus));
  });

  group('Menu functions', () {
    group('Open and closing', () {
      testWidgets('controller open and close', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildApp(
              CupertinoMenuAnchor(
                builder: _buildAnchor,
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
          ),
        );

        // Create the menu. The menu is closed, so no menu items should be found in
        // the widget tree.
        await tester.pumpAndSettle();
        expect(controller.menuStatus, MenuStatus.closed);
        expect(TestMenu.item1.findText, findsNothing);
        expect(controller.isOpen, isFalse);

        // Open the menu.
        controller.open();
        await tester.pump();

        // The menu is opening => MenuStatus.opening.
        expect(controller.menuStatus, MenuStatus.opening);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // After 100 ms, the menu should still be animating open.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.menuStatus, MenuStatus.opening);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Interrupt the opening animation by closing the menu.
        controller.close();
        await tester.pump();

        // The menu is closing => MenuStatus.closing.
        expect(controller.menuStatus, MenuStatus.closing);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Open the menu again.
        controller.open();
        await tester.pump();

        // The menu is animating open => MenuStatus.opening.
        expect(controller.menuStatus, MenuStatus.opening);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has finished opening, so it should report it's animation
        // status as MenuStatus.open.
        expect(controller.menuStatus, MenuStatus.opened);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Close the menu.
        controller.close();
        await tester.pump();

        expect(controller.menuStatus, MenuStatus.closing);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // After 100 ms, the menu should still be closing.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.menuStatus, MenuStatus.closing);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Interrupt the closing animation by opening the menu.
        controller.open();
        await tester.pump();

        // The menu is animating open => MenuStatus.opening.
        expect(controller.menuStatus, MenuStatus.opening);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Close the menu again.
        controller.close();
        await tester.pump();

        // The menu is closing => MenuStatus.closing.
        expect(controller.menuStatus, MenuStatus.closing);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has closed => MenuStatus.closed.
        expect(controller.menuStatus, MenuStatus.closed);
        expect(controller.isOpen, isFalse);
        expect(TestMenu.item1.findText, findsNothing);
      });
      testWidgets('tap open and close', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildApp(
              CupertinoMenuAnchor(
                builder: _buildAnchor,
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
          ),
        );

        // Create the menu. The menu is closed, so no menu items should be found in
        // the widget tree.
        await tester.pumpAndSettle();
        expect(controller.menuStatus, MenuStatus.closed);
        expect(TestMenu.item1.findText, findsNothing);
        expect(controller.isOpen, isFalse);

        // Open the menu.
        await tester.tap(find.byType(CupertinoMenuAnchor));
        await tester.pump();

        // The menu is opening => MenuStatus.opening.
        expect(controller.menuStatus, MenuStatus.opening);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // After 100 ms, the menu should still be animating open.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.menuStatus, MenuStatus.opening);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Interrupt the opening animation by closing the menu.
        await tester.tap(find.byType(CupertinoMenuAnchor));
        await tester.pump();

        // The menu is closing => MenuStatus.closing.
        expect(controller.menuStatus, MenuStatus.closing);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Open the menu again.
        await tester.tap(find.byType(CupertinoMenuAnchor));
        await tester.pump();

        // The menu is animating open => MenuStatus.opening.
        expect(controller.menuStatus, MenuStatus.opening);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has finished opening, so it should report it's animation
        // status as MenuStatus.open.
        expect(controller.menuStatus, MenuStatus.opened);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Close the menu.
        await tester.tap(find.byType(CupertinoMenuAnchor));
        await tester.pump();

        expect(controller.menuStatus, MenuStatus.closing);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // After 100 ms, the menu should still be closing.
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.menuStatus, MenuStatus.closing);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Interrupt the closing animation by opening the menu.
        await tester.tap(find.byType(CupertinoMenuAnchor));
        await tester.pump();

        // The menu is animating open => MenuStatus.opening.
        expect(controller.menuStatus, MenuStatus.opening);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Close the menu again.
        await tester.tap(find.byType(CupertinoMenuAnchor));
        await tester.pump();

        // The menu is closing => MenuStatus.closing.
        expect(controller.menuStatus, MenuStatus.closing);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        await tester.pumpAndSettle();

        // The menu has closed => MenuStatus.closed.
        expect(controller.menuStatus, MenuStatus.closed);
        expect(controller.isOpen, isFalse);
        expect(TestMenu.item1.findText, findsNothing);
      });

      testWidgets('close when Navigator.pop() is called',
          (WidgetTester tester) async {
        final CupertinoMenuController controller = CupertinoMenuController();
        final GlobalKey<State<StatefulWidget>> menuItemGK = GlobalKey();
        await tester.pumpWidget(
          buildApp(
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

    testWidgets('geometry LTR', (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        CupertinoApp(
          home:Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoMenuAnchor(
                        builder: _buildAnchor,
                        menuChildren: createTestMenus(onPressed: onPressed),
                      ),
                    ),
                  ],
                ),
                const Expanded(child: Placeholder()),
              ],
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

      // The menu just started opening, therefore menu items should be Size.zero
      expect(tester.getRect(TestMenu.item5Disabled.findMenuItem),
      rectEquals(const Rect.fromLTRB(400.0, 28.0, 400.0, 28.0)));

      await tester.pumpAndSettle();

      expect(tester.getRect(menuAnchor),
      rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));

      expect(tester.getRect(TestMenu.item5Disabled.findMenuItem),
      rectEquals(const Rect.fromLTRB(275.0, 295.4, 525.0, 339.0)));

      // Decorative surface sizes should match
      const Rect surfaceSize = Rect.fromLTRB(275.0, 60.0, 525.0, 383.0);
      expect(
        tester.getRect(
          find.ancestor(
            of: TestMenu.item5Disabled.findMenuItem,
            matching: find.byType(DecoratedBoxTransition)).first),
        rectEquals(surfaceSize),
      );

      expect(
        tester.getRect(
          find.ancestor(
            of: TestMenu.item5Disabled.findMenuItem,
            matching: find.byType(FadeTransition)).first),
        rectEquals(surfaceSize),
      );

      // Test menu bar size when not expanded.
      await tester.pumpWidget(
        CupertinoApp(
          home:Column(
              children: <Widget>[
                CupertinoMenuAnchor(
                  builder: _buildAnchor,
                  menuChildren: createTestMenus(onPressed: onPressed),
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
        ),
      );
      await tester.pump();

      expect(
        tester.getRect(menuAnchor),
        rectEquals(const Rect.fromLTRB(372.0, 0.0, 428.0, 56.0)),
      );
    });

    testWidgets('geometry RTL', (WidgetTester tester) async {
      final UniqueKey menuKey = UniqueKey();
      await tester.pumpWidget(
        CupertinoApp(
          home:  Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoMenuAnchor(
                          key: menuKey,
                        builder: _buildAnchor,

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
      final Finder menuAnchor = find.byType(CupertinoMenuAnchor);
      expect(tester.getRect(menuAnchor),
      rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));

      // Open and make sure things are the right size.
      await tester.tap(menuAnchor);
      await tester.pump();

      expect(tester.getRect(menuAnchor),
      rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));

      // The menu just started opening, therefore menu items should be Size.zero
      expect(tester.getRect(TestMenu.item5Disabled.findMenuItem),
      rectEquals(const Rect.fromLTRB(400.0, 28.0, 400.0, 28.0)));

      await tester.pumpAndSettle();

      expect(tester.getRect(menuAnchor),
      rectEquals(const Rect.fromLTRB(0, 0, 800, 56)));

      expect(tester.getRect(TestMenu.item5Disabled.findMenuItem),
      rectEquals(const Rect.fromLTRB(275.0, 295.4, 525.0, 339.0)));

      // Decorative surface sizes should match
      const Rect surfaceSize = Rect.fromLTRB(275.0, 60.0, 525.0, 383.0);
      expect(
        tester.getRect(
          find.ancestor(
            of: TestMenu.item5Disabled.findMenuItem,
            matching: find.byType(DecoratedBoxTransition)).first),
        rectEquals(surfaceSize),
      );

      expect(
        tester.getRect(
          find.ancestor(
            of: TestMenu.item5Disabled.findMenuItem,
            matching: find.byType(FadeTransition)).first),
        rectEquals(surfaceSize),
      );

      // Test menu bar size when not expanded.
      await tester.pumpWidget(
        CupertinoApp(
          home:  Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: <Widget>[
                CupertinoMenuAnchor(
                  builder: _buildAnchor,
                  menuChildren: createTestMenus(onPressed: onPressed),
                ),
                const Expanded(child: Placeholder()),
              ],
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
      expect(tester.getRect(anchor),
        rectEquals(const Rect.fromLTRB(319.6, 17.0, 480.4, 65.0)));

      final Finder findMenuScope = find
          .ancestor(
            of: TestMenu.item1.findText,
            matching: find.byType(FocusScope),
          )
          .first;


      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(anchor);
      await tester.pumpAndSettle();

      Future<void> testPosition(Rect position, [AlignmentDirectional? alignment, AlignmentDirectional? menuAlignment])async {
        await tester.pumpWidget(buildTestApp(alignment: alignment, menuAlignment: menuAlignment));
        await tester.pump();
        expect(tester.getRect(findMenuScope), rectEquals(position));
      }

      await testPosition(const Rect.fromLTRB(275.0, 69.0, 525.0, 390.0));

      await testPosition(
       const Rect.fromLTRB(69.6, 17.0, 319.6, 338.0),
        AlignmentDirectional.topStart,
        AlignmentDirectional.topEnd,
      );

      await testPosition(
        const Rect.fromLTRB(275.0, 8.0, 525.0, 329.0),
        AlignmentDirectional.center,
        AlignmentDirectional.center,
      );
      await testPosition(
        const Rect.fromLTRB(480.4, 8.0, 730.4, 329.0),
        AlignmentDirectional.bottomEnd,
        AlignmentDirectional.bottomStart,
      );
      await testPosition(
        const Rect.fromLTRB(69.6, 17.0, 319.6, 338.0),
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
        rectEquals(const Rect.fromLTRB(319.6, 17.0, 480.4, 65.0)));

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

      await testPosition(const Rect.fromLTRB(275.0, 69.0, 525.0, 390.0));
      await testPosition(
        const Rect.fromLTRB(480.4, 17.0, 730.4, 338.0),
        AlignmentDirectional.topStart,
        AlignmentDirectional.topEnd,
      );
      await testPosition(
        const Rect.fromLTRB(275.0, 8.0, 525.0, 329.0),
        AlignmentDirectional.center,
        AlignmentDirectional.center,
      );
      await testPosition(
        const Rect.fromLTRB(69.6, 8.0, 319.6, 329.0),
        AlignmentDirectional.bottomEnd,
        AlignmentDirectional.bottomStart,
      );
      await testPosition(
        const Rect.fromLTRB(480.4, 17.0, 730.4, 338.0),
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
      expect(buttonRect, rectEquals(const Rect.fromLTRB(319.6, 17.0, 480.4, 65.0)));

      final Finder findMenuScope = find
          .ancestor(
              of: find.text(TestMenu.item1.label), matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();
      expect(tester.getRect(findMenuScope),
          rectEquals(const Rect.fromLTRB(375.0, 119.0, 625.0, 440.0)));

      // Now move the menu by calling open() again with a local position on the
      // anchor.
      controller.open(position: const Offset(200, 200));
      await tester.pumpAndSettle();
      expect(tester.getRect(findMenuScope),
          rectEquals(const Rect.fromLTRB(494.6, 271.0, 744.6, 592.0)));
    });

    testWidgets('menu position in RTL', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        alignmentOffset: const Offset(100, 50),
        textDirection: TextDirection.rtl,
      ));

      final Rect buttonRect = tester.getRect(find.byType(ElevatedButton));
      expect(buttonRect,
          rectEquals(const Rect.fromLTRB(319.6, 17.0, 480.4, 65.0)));

      final Finder findMenuScope = find
          .ancestor(
              of: find.text(TestMenu.item1.label), matching: find.byType(FocusScope))
          .first;

      // Open the menu and make sure things are the right size, in the right place.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(tester.getRect(findMenuScope),
          rectEquals(const Rect.fromLTRB(375.0, 119.0, 625.0, 440.0)));


      // Now move the menu by calling open() again with a local position on the
      // anchor.
      controller.open(position: const Offset(400, 200));
      await tester.pump();
      expect(tester.getRect(findMenuScope),
          rectEquals(const Rect.fromLTRB(719.6, 217.0, 719.6, 217.0)));
    });

    testWidgets('app and anchor padding LTR',
        (WidgetTester tester) async {

      // Out of MaterialApp:
      //    - overlay position affected
      //    - anchor position affected

      // In MaterialApp:
      //   - anchor position affected

      // Padding inside MaterialApp DOES NOT affect the overlay position but
      // DOES affect the anchor position
      await tester.pumpWidget(
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 10.0, bottom: 8.0),
          child: CupertinoApp(
            home:  Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 23, right: 13.0, top: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CupertinoMenuAnchor(
                            builder: _buildAnchor,
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
      );
      await tester.pump();
      final Finder anchor = find.byType(CupertinoMenuAnchor);

      /* DELETE */ print(tester.getRect(anchor));
      expect(tester.getRect(anchor),
      rectEquals(const Rect.fromLTRB(43.0, 8.0, 777.0, 64.0)));

      // Open and make sure things are the right size.
      await tester.tap(anchor);
      await tester.pumpAndSettle();

      /* DELETE */ print(tester.getRect(anchor));
      expect(tester.getRect(anchor),
      rectEquals(const Rect.fromLTRB(43.0, 8.0, 777.0, 64.0)));


      /* DELETE */ print(tester.getRect(TestMenu.item0.findText));
      expect(tester.getRect(TestMenu.item0.findText),
      rectEquals(const Rect.fromLTRB(317.0, 79.4, 416.5, 100.4)));

      expect(
        tester.getRect(
          find
              .ancestor(
                  of: TestMenu.item6.findText,
                  matching: find.byType(DecoratedBoxTransition))
              .first),

        rectEquals(const Rect.fromLTRB(285.0, 68.0, 535.0, 391.0)),
      );

      // Close and make sure it goes back where it was.
      await tester.tap(TestMenu.item6.findText);
      await tester.pump();

      /* DELETE */ print(find.byType(CupertinoMenuAnchor));
      expect(tester.getRect(find.byType(CupertinoMenuAnchor)),
          rectEquals(const Rect.fromLTRB(43.0, 8.0, 777.0, 64.0)));
    });

    testWidgets('app and anchor padding RTL',
        (WidgetTester tester) async {
      // Out of MaterialApp:
      //    - overlay position affected
      //    - anchor position affected

      // In MaterialApp:
      //   - anchor position affected
      await tester.pumpWidget(
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 10.0, bottom: 8.0),
          child: CupertinoApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 23, right: 13.0, top: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CupertinoMenuAnchor(
                            builder: _buildAnchor,
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
      const Rect anchorPosition = Rect.fromLTRB(43.0, 8.0, 777.0, 64.0);
      final Finder anchor = find.byType(CupertinoMenuAnchor);

      /* DELETE */ print(tester.getRect(anchor));
      expect(tester.getRect(anchor),
      rectEquals(anchorPosition));

      // Open and make sure things are the right size.
      await tester.tap(anchor);
      await tester.pumpAndSettle();

      /* DELETE */ print(tester.getRect(anchor));
      expect(tester.getRect(anchor),
      rectEquals(anchorPosition));


      /* DELETE */ print(tester.getRect(TestMenu.item6.findText));
      expect(tester.getRect(TestMenu.item6.findText),
      rectEquals(const Rect.fromLTRB(403.5, 358.7, 503.0, 379.7)));

      expect(
        tester.getRect(
          find.ancestor(
                of: TestMenu.item6.findText,
                matching: find.byType(DecoratedBoxTransition),
              )
              .first,
        ),
        rectEquals(const Rect.fromLTRB(285.0, 68.0, 535.0, 391.0)),
      );

      // Close and make sure it goes back where it was.
      await tester.tap(TestMenu.item1.findText);
      await tester.pumpAndSettle();

      expect(tester.getRect(anchor),
      rectEquals(anchorPosition));
    });
    testWidgets('menu screen insets LTR', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: CupertinoMenuAnchor(
              screenInsets:
                  const EdgeInsetsDirectional.fromSTEB(13, 12, 23, 14),
              controller: controller,
              menuChildren: createTestMenus(onPressed: onPressed),
            ),
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      expect(tester.getRect(findMenuPanelDescendent<CustomScrollView>().first),
          rectEquals(const Rect.fromLTRB(13.0, 12.0, 263.0, 335.0)));
    });
    testWidgets('menu screen insets RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.topLeft,
              child: CupertinoMenuAnchor(
                screenInsets:
                    const EdgeInsetsDirectional.fromSTEB(13, 12, 23, 14),
                controller: controller,
                menuChildren: createTestMenus(onPressed: onPressed),
              ),
            ),
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      expect(tester.getRect(findMenuPanelDescendent<CustomScrollView>().first),
          rectEquals(const Rect.fromLTRB(23.0, 12.0, 273.0, 335.0)));
    });
    testWidgets('textScaling over 1.25 increases menu width to 350',
        (WidgetTester tester) async {
      await tester.pumpWidget(
         CupertinoApp(
           home: MediaQuery(
             data: const MediaQueryData(textScaler: TextScaler.linear(1.25)),
             child: Center(
               child: CupertinoMenuAnchor(
                 builder: _buildAnchor,
                 menuChildren: <Widget>[
                   CupertinoMenuItem(child: TestMenu.item0.text,),
                 ],
               ),
             )
           ),
         ),
      );
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      // The default menu width is 250.
      expect(tester.getSize(find.byType(BackdropFilter)).width , 250.0);

      await tester.pumpWidget(
         CupertinoApp(
           home: MediaQuery(
             data: const MediaQueryData(textScaler: TextScaler.linear(1.26)),
             child: Center(
               child: CupertinoMenuAnchor(
                 builder: _buildAnchor,
                 menuChildren: <Widget>[
                   CupertinoMenuItem(child: TestMenu.item0.text,),
                 ],
               ),
             )
           ),
         ),
      );

      expect(tester.getSize(find.byType(BackdropFilter)).width , 350.0);
    });

    testWidgets('background color can be set', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: Center(
            child: CupertinoMenuAnchor(
              builder: _buildAnchor,
              backgroundColor:  CupertinoColors.activeGreen.darkColor,
              menuChildren: createTestMenus(onPressed: onPressed),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      // Private painter class is used to paint the background color.
      expect(
        '${findMenuPanelWidget<CustomPaint>(tester).painter}'.contains('Color(0xff30d158)'),
        isTrue,
      );
    });

    testWidgets('opaque background color removes backdrop filter', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: Center(
            child: CupertinoMenuAnchor(
              builder: _buildAnchor,
              backgroundColor:  CupertinoColors.activeGreen.darkColor,
              menuChildren: createTestMenus(onPressed: onPressed),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      // Private painter class is used to paint the background color.
      expect(
        findMenuPanelDescendent<BackdropFilter>(),
        findsNothing,
      );
    });

    testWidgets('surface builder can be changed', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: CupertinoMenuAnchor(
              builder: _buildAnchor,
              menuChildren: createTestMenus(onPressed: onPressed),
              backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
              surfaceBuilder: (
                BuildContext context,
                Widget child,
                Animation<double> animation,
                Color backgroundColor,
                Clip clip,
              ) {
                final DecorationTween decorationTween = DecorationTween(
                  begin: BoxDecoration(color: backgroundColor),
                  end: const BoxDecoration(color: Color.fromRGBO(0, 0, 255, 1)),
                );
                return DecoratedBoxTransition(
                  decoration: decorationTween.animate(animation),
                  child: child,
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pump();

      // Background color should be passed to the surface builder.
      expect(
        findMenuPanelWidget<DecoratedBoxTransition>(tester).decoration.value,
        equals(const BoxDecoration(color: Color.fromRGBO(255, 0, 0, 1))),
      );

      await tester.pumpAndSettle();

      // Animation should change the background color.
      expect(
        findMenuPanelWidget<DecoratedBoxTransition>(tester).decoration.value,
        equals(const BoxDecoration(color: Color.fromRGBO(0, 0, 255, 1))),
      );

      // A custom surface builder should not affect the layout of the menu.
      expect(
        tester.getRect(
          find.descendant(
                of: findMenuPanel(),
                matching: find.byType(DecoratedBoxTransition),
              )
              .first,
        ),
        rectEquals(const Rect.fromLTRB(8.0, 60.0, 258.0, 383.0)),
      );
    });

    testWidgets('default surface appearance', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CupertinoMenuAnchor(
                      builder: _buildAnchor,
                      menuChildren: createTestMenus(onPressed: onPressed),
                    ),
                  ),
                ],
              ),
              const Expanded(child: Placeholder()),
            ],
          ),
        ),
      );

      // Open and make sure things are the right size.
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      expect(tester.getRect(findMenuPanel()),
          equals(const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0)));
      final DecoratedBoxTransition decoratedBox =
          findMenuPanelWidget<DecoratedBoxTransition>(tester);
      final CustomPaint customPaint =
          findMenuPanelWidget<CustomPaint>(tester);
      final BackdropFilter backdropFilter =
          findMenuPanelWidget<BackdropFilter>(tester);
      expect(
        decoratedBox.decoration.value,
        equals(
          const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.12),
                spreadRadius: 30,
                blurRadius: 50,
              ),
            ],
          ),
        ),
      );
      expect(
        backdropFilter.filter,
        equals(
          ImageFilter.compose(
            inner: const ColorFilter.matrix(<double>[
               1.74, -0.4, -0.17, 0.0, 0.0, //
              -0.26,  1.6, -0.17, 0.0, 0.0, //
              -0.26, -0.4,  1.83, 0.0, 0.0, //
                0.0,  0.0,   0.0, 1.0, 0.0  //
            ]),
            outer: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          ),
        ),
      );

      expect(
        '${customPaint.painter}'.contains('Color(0xc5f3f3f3)'),
        isTrue,
      );


      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CupertinoMenuAnchor(
                      builder: _buildAnchor,
                      menuChildren: createTestMenus(onPressed: onPressed),
                    ),
                  ),
                ],
              ),
              const Expanded(child: Placeholder()),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      final DecoratedBoxTransition darkDecoratedBox =
          findMenuPanelWidget<DecoratedBoxTransition>(tester);
      final CustomPaint darkCustomPaint =
          findMenuPanelWidget<CustomPaint>(tester);
      final BackdropFilter darkBackdropFilter =
          findMenuPanelWidget<BackdropFilter>(tester);
      expect(
        darkDecoratedBox.decoration.value,
        equals(
          const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.12),
                spreadRadius: 30,
                blurRadius: 50,
              ),
            ],
          ),
        ),
      );
      expect(
        darkBackdropFilter.filter,
        equals(
          ImageFilter.compose(
            inner: const ColorFilter.matrix(<double>[
               1.385, -0.5599999999999999, -0.11199999999999999, 0.0, 0.3, //
              -0.315,  1.1400000000000001, -0.11199999999999999, 0.0, 0.3, //
              -0.315, -0.5599999999999999,  1.588              , 0.0, 0.3, //
               0.0  ,  0.0               ,  0.0                , 1.0, 0.0, //
            ]),
            outer: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          ),
        ),
      );

      expect(
        '${darkCustomPaint.painter}'.contains('Color(0xbb373737)'),
        isTrue,
      );
    });

    testWidgets('shrinkWrap affects menu layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: CupertinoMenuAnchor(
              builder: _buildAnchor,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  child: TestMenu.item0.text,
                  onPressed: (){},
                ),
              ]
            ),
          ),
        ),
      );


      // Open menu and make sure it's the right size.
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(
          find.descendant(
                of: findMenuPanel(),
                matching: find.byType(DecoratedBoxTransition),
              )
              .first,
        ),
        rectEquals(const Rect.fromLTRB(8.0, 56.5, 258.0, 100.2)),
      );

       await tester.pumpWidget(
        CupertinoApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: CupertinoMenuAnchor(
              shrinkWrap: false,
              builder: _buildAnchor,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  child: TestMenu.item0.text,
                  onPressed: (){},
                ),
              ]
            ),
          ),
        ),
      );
      expect(
        tester.getRect(
          find.descendant(
                of: findMenuPanel(),
                matching: find.byType(DecoratedBoxTransition),
              )
              .first,
        ),
        equals(const Rect.fromLTRB(8.0, 8.0, 258.0, 592.0)),
      );
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
                builder: (
                  BuildContext context,
                  CupertinoMenuController controller,
                  Widget? child,
                ) {
                  return FilledButton(
                    onPressed: controller.open,
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

     testWidgets('DismissMenuAction closes the menu',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
            consumesOutsideTap: true,
            onPressed: onPressed,
            onOpen: onOpen,
            onClose: onClose),
      );
      controller.open();
      await tester.pumpAndSettle();

      expect(controller.isOpen, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(controller.isOpen, isFalse);
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
        'Menus close and do not consume tap when consumesOutsideTap is false',
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

    testWidgets('CupertinoScrollBar is drawn on vertically constrained menus', (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Column(
          children: <Widget>[
            CupertinoMenuAnchor(
              constraints: const BoxConstraints.tightFor(height: 200),
              builder: _buildAnchor,
              menuChildren: createTestMenus()
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(CupertinoMenuAnchor));
    await tester.pumpAndSettle();

      expect(
        find.ancestor(
          of: find.byType(SliverList),
          matching: find.descendant(
            of: find.byType(DecoratedBoxTransition),
            matching: find.byType(CupertinoScrollbar),
          ),
        ),
        findsOneWidget,
      );
    }
  );

    testWidgets('onOpen and onClose work', (WidgetTester tester) async {
      bool opened = false;
      bool closed = true;
      CupertinoApp builder() {
        return CupertinoApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: CupertinoMenuAnchor(
                controller: controller,
                builder: _buildAnchor,
                onOpen: () {
                  opened = true;
                  closed = false;
                },
                onClose: () {
                  closed = true;
                  opened = false;
                },
                menuChildren: createTestMenus(onPressed: (TestMenu menu) {}),
              ),
            ),
          );
      }

      await tester.pumpWidget(builder());
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpFrames(builder(), const Duration(milliseconds: 50));
      expect(opened, isTrue);

      await tester.tap(find.text(TestMenu.item1.label));
      await tester.pump();
      expect(opened, isTrue);

      // Because a simulation is used, an exact number of frames is not guaranteed.
      await tester.pumpAndSettle();
      expect(closed, isTrue);
      expect(find.text(TestMenu.item1.label), findsNothing);


      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
    });
    testWidgets('forwardSpring can be set', (WidgetTester tester) async {
      CupertinoApp builder() {
        return CupertinoApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: CupertinoMenuAnchor(
                controller: controller,
                builder: _buildAnchor,
                forwardSpring: SpringDescription.withDampingRatio(mass: 0.0001, stiffness: 100),
                menuChildren: createTestMenus(onPressed: (TestMenu menu) {}),
              ),
            ),
          );
      }

      await tester.pumpWidget(builder());
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpFrames(builder(), const Duration(milliseconds: 50));

      expect(controller.menuStatus, MenuStatus.opened);

      await tester.pumpAndSettle();
      controller.close();
      await tester.pumpFrames(builder(), const Duration(milliseconds: 200));

      // Check that the reverse spring is not affected
      expect(controller.menuStatus, MenuStatus.closing);

    });
    testWidgets('reverseSpring can be set', (WidgetTester tester) async {
      CupertinoApp builder() {
        return CupertinoApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: CupertinoMenuAnchor(
                controller: controller,
                builder: _buildAnchor,
                reverseSpring: SpringDescription.withDampingRatio(mass: 0.0001, stiffness: 100),
                menuChildren: createTestMenus(onPressed: (TestMenu menu) {}),
              ),
            ),
          );
      }

      await tester.pumpWidget(builder());
      controller.open();
      await tester.pumpFrames(builder(), const Duration(milliseconds: 200));

      // Check that the forward spring is not affected
      expect(controller.menuStatus, MenuStatus.opening);

      await tester.pumpAndSettle();
      controller.close();
      await tester.pumpFrames(builder(), const Duration(milliseconds: 50));

      expect(controller.menuStatus, MenuStatus.closed);

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
        CupertinoApp(
          home: Column(
            children: <Widget>[
              CupertinoMenuAnchor(
                controller: controller,
                builder: _buildAnchor,
                menuChildren: createTestMenus(
                  onPressed: onPressed,
                ),
              ),
              const Expanded(child: Placeholder()),
            ],
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

    testWidgets('keyboard directional LTR traversal works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Align(
            alignment: AlignmentDirectional.topStart,
            child: CupertinoMenuAnchor(
              builder: _buildAnchor,
              menuChildren: createTestMenus(
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

      /* 5 is disabled */

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item6.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item6.debugFocusLabel));
    });
    testWidgets('keyboard directional RTL traversal works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: CupertinoApp(
            home: Align(
              alignment: AlignmentDirectional.topStart,
              child: CupertinoMenuAnchor(
                builder: _buildAnchor,
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

      /* 5 is disabled */

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item6.debugFocusLabel));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(focusedMenu, equals(TestMenu.item6.debugFocusLabel));
    });

    testWidgets('menu closes on ancestor scroll', (WidgetTester tester) async {
      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      bool opened = false;
      bool closed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                height: 1000,
                alignment: Alignment.center,
                child: CupertinoMenuAnchor(
                  builder: _buildAnchor,
                  onOpen: () {
                    opened = true;
                    closed = false;
                  },
                  onClose: () {
                    closed = true;
                    opened = false;
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

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pump();

      expect(opened, isTrue);
      expect(closed, isFalse);

      scrollController.jumpTo(1000);
      await tester.pumpAndSettle();

      expect(opened, isFalse);
      expect(closed, isTrue);
    });

    testWidgets('menu does not close on root menu internal scroll',
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


    testWidgets('menu closes on view size change', (WidgetTester tester) async {
      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      final MediaQueryData mediaQueryData =
          MediaQueryData.fromView(tester.view);

      bool opened = false;
      bool closed = false;

      Widget build(Size size) {
        return CupertinoApp(
          home: MediaQuery(
              data: mediaQueryData.copyWith(size: size),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  height: 1000,
                  alignment: Alignment.center,
                  child: CupertinoMenuAnchor(
                    builder: _buildAnchor,
                    onOpen: (){
                      opened = true;
                      closed = false;
                    },
                    onClose: (){
                      opened = false;
                      closed = true;
                    },
                    controller: controller,
                    menuChildren: createTestMenus(
                      onPressed: onPressed,
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

      expect(opened, isTrue);
      expect(closed, isFalse);

      const Size smallSize = Size(200, 200);
      await changeSurfaceSize(tester, smallSize);
      await tester.pumpWidget(build(smallSize));

      expect(opened, isFalse);
      expect(closed, isTrue);
    });

     testWidgets('panning scales the menu', (WidgetTester tester) async {
       final TestGesture gesture = await tester.createGesture(
        pointer: 1,
      );

      await gesture.addPointer(location: Offset.zero);
      addTearDown( gesture.removePointer);

      await changeSurfaceSize(tester, const Size(1000, 1000));

      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
                child: CupertinoMenuAnchor(
                  builder: _buildAnchor,
                  menuChildren: <Widget>[
                    const CupertinoLargeMenuDivider(),
                    CupertinoMenuItem(
                      onPressed: () {},
                      child: TestMenu.item0.text,
                    ),
                  ],
                ),
              ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      final Offset startPosition = tester.getCenter(find.byType(CupertinoLargeMenuDivider));
      await gesture.down(startPosition);
      await tester.pump();

      final Rect rect = tester
          .getRect(TestMenu.anchorButton.findAncestor<SizedBox>())
          .expandToInclude(
            tester.getRect(
              find.descendant(
                of: findMenuPanel(),
                matching: find.byType(CustomScrollView),
              ).first
            ),
          );

      double getScale()=> findMenuPanelWidget<ScaleTransition>(tester).scale.value;

      // Check that all corners of the menu are not scaled.
      await gesture.moveTo(rect.topLeft);
      await tester.pump();

      expect(getScale(), 1.0);

      await gesture.moveTo(rect.topRight);
      await tester.pump();

      expect(getScale(), 1.0);

      await gesture.moveTo(rect.bottomLeft);
      await tester.pump();

      expect(getScale(), 1.0);

      await gesture.moveTo(rect.bottomRight);
      await tester.pump();

      expect(getScale(), 1.0);

      await gesture.moveTo(rect.topLeft - const Offset(50, 50));
      await tester.pump();

      final double topLeftScale = getScale();

      expect(topLeftScale, lessThan(1.0));
      expect(topLeftScale, greaterThan(0.7));

      await gesture.moveTo(rect.bottomRight + const Offset(50, 50));
      await tester.pump();

      // Check that scale is roughly the same around the menu.
      expect(getScale(),
      moreOrLessEquals(topLeftScale, epsilon: 0.05));

      await gesture.moveTo(rect.topLeft - const Offset(200, 200));
      await tester.pump();

      // Check that the minimum scale is 0.7
      expect(getScale(), 0.7);

      await gesture.moveTo(rect.bottomRight + const Offset(200, 200));
      await tester.pump();

      expect(getScale(), 0.7);
    });
     testWidgets('pan can be disabled', (WidgetTester tester) async {
       final TestGesture gesture = await tester.createGesture(
        pointer: 1,
      );

      await gesture.addPointer(location: Offset.zero);

      addTearDown(gesture.removePointer);
      await changeSurfaceSize(tester, const Size(1000, 1000));

      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
                child: CupertinoMenuAnchor(
                  builder: _buildAnchor,
                  controller: controller,
                  enablePan: false,
                  menuChildren: <Widget>[
                    const CupertinoLargeMenuDivider(),
                    CupertinoMenuItem(
                      onPressed: () {},
                      pressedColor: const Color.fromRGBO(255, 0, 0, 1),
                      hoveredColor:  const Color.fromRGBO(0, 255, 0, 1),
                      panActivationDelay: const Duration(milliseconds: 50),
                      child: TestMenu.item0.text,
                    ),
                  ],
                ),
              ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      final Offset startPosition = tester.getCenter(find.byType(CupertinoLargeMenuDivider));
      await gesture.down(startPosition);
      await tester.pump();
      final Rect rect = tester.getRect(
              find.descendant(
                of: findMenuPanel(),
                matching: find.byType(CustomScrollView),
              ).first
            );

      double getScale() => findMenuPanelWidget<ScaleTransition>(tester).scale.value;
      await gesture.moveTo(rect.topLeft - const Offset(200, 200));
      await tester.pump();

      expect(getScale(), 1.0);

      await gesture.moveTo(rect.bottomRight + const Offset(200, 200));
      await tester.pump();

      expect(getScale(), 1.0);

      await gesture.moveTo(tester.getCenter(TestMenu.item0.findMenuItem));
      await tester.pump(const Duration(milliseconds: 500));

      // Pan is disabled, so panActivationDelay should not be triggered.
      expect(controller.menuStatus, MenuStatus.opened);
    });
  });


   testWidgets('MediaQuery changes do not throw', (WidgetTester tester) async {
    final AnimationController animationController = AnimationController(
      vsync: tester,
      duration: const Duration(
        milliseconds: 1000,
      ),
    );
    addTearDown(tester.view.reset);
    addTearDown(animationController.dispose);
    await tester.pumpWidget(CupertinoApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.all(8)  * animationController.value,
                textScaler: TextScaler.linear(1 + animationController.value),
                size: MediaQuery.of(context).size * (1+ animationController.value),

              ),
              child: CupertinoMenuAnchor(
                builder: _buildAnchor,
                onOpen: animationController.forward,
                onClose: animationController.reverse,
                menuChildren: createTestMenus(onPressed: (_){}),
              ),
            );
          },
        ),
      ),
    ));

    final Finder anchor = find.byType(CupertinoMenuAnchor).first;

    expect(anchor, findsOneWidget);

    await tester.tap(anchor);
    await tester.pump();

    expect(TestMenu.item0.findText, findsOneWidget);

    tester.view.physicalSize = const Size(700.0, 700.0);
    await tester.pump();
    tester.view.physicalSize = const Size(250.0, 500.0);
    await tester.pumpAndSettle();
    await tester.tap(anchor);
    await tester.pump();
    tester.view.physicalSize = const Size(500.0, 100.0);
    await tester.pump();
    tester.view.physicalSize = const Size(250.0, 500.0);
    await tester.pumpAndSettle();

    // Go without throw.
  });

   testWidgets('property changes do not throw', (WidgetTester tester) async {
    // /*DELETE*/ This test is probably too broad and can be removed.
    final AnimationController animationController = AnimationController(
      vsync: tester,
      duration: const Duration(
        milliseconds: 1000,
      ),
    );
    addTearDown(tester.view.reset);
    addTearDown(animationController.dispose);
    FocusNode? focusNode;
    addTearDown(()=>focusNode?.dispose());
    FocusNode? itemFocusNode;
    addTearDown(()=>itemFocusNode?.dispose());

    await tester.pumpWidget(CupertinoApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget? child) {
            focusNode?.dispose();
            focusNode = focusNode != null ? FocusNode() : null;

            itemFocusNode?.dispose();
            itemFocusNode = focusNode != null ? FocusNode() : null;

            final SpringDescription spring = SpringDescription(
                mass: 1 + animationController.value,
                stiffness: 10,
                damping: 10
              );
            final AlignmentDirectional itemAlignment = AlignmentDirectional(
                      animationController.value * 2 - 1,
                      animationController.value * 2 - 1,
                    );
            return CupertinoMenuAnchor(
              builder: _buildAnchor,
              onOpen: animationController.forward,
              onClose: animationController.reverse,
              scrollPhysics: animationController.value < 0.5
                  ? const BouncingScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              alignment: AlignmentGeometryTween(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ).evaluate(animationController),
              menuAlignment:AlignmentGeometryTween(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ).evaluate(animationController),
              alignmentOffset: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(100, 100),
              ).evaluate(animationController),
              forwardSpring: spring,
              reverseSpring: spring,
              constraints: BoxConstraints.tight(MediaQuery.of(context).size).deflate(
                const EdgeInsets.all(100) * animationController.value,
              ),
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  requestFocusOnHover: true,
                  leading: const Icon(CupertinoIcons.left_chevron),
                  trailing: const Icon(CupertinoIcons.right_chevron),
                  trailingWidth: (animationController.value + 1) * 40,
                  leadingWidth: (animationController.value + 1) * 40,
                  padding: const EdgeInsetsDirectional.all(12) * animationController.value,
                  leadingAlignment: itemAlignment,
                  trailingAlignment: itemAlignment,
                  focusNode: itemFocusNode,
                  child: TestMenu.item0.text,
                ),
              ]
            );
          },
        ),
      ),
    ));

    final Finder anchor = find.byType(CupertinoMenuAnchor).first;
    expect(anchor, findsOneWidget);
    await tester.tap(anchor);
    await tester.pump();

    expect(TestMenu.item0.findText, findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(anchor);
    await tester.pumpAndSettle();
    // Go without throw.
  });

  group('CupertinoMenuController', () {
    testWidgets('Moving a controller to a new instance works',
        (WidgetTester tester) async {

      final CupertinoMenuController controller = CupertinoMenuController();
      await tester.pumpWidget(
        CupertinoApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              menuChildren:  <CupertinoMenuItem>[
                CupertinoMenuItem(
                  child: TestMenu.item0.text,
                  onPressed: () {
                  },
                )
              ]
            ),
          ),
        ),
      );

      // Open a menu initially.
      controller.open();
      await tester.pumpAndSettle();

      // Now pump a new menu with a different UniqueKey to dispose of the opened
      // menu's node, but keep the existing controller.
      await tester.pumpWidget(
        CupertinoApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: CupertinoMenuAnchor(
              key: UniqueKey(),
              controller: controller,
              menuChildren: <CupertinoMenuItem>[
                CupertinoMenuItem(
                  child: TestMenu.item0.text,
                  onPressed: () {},
                )
              ]
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
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
        CupertinoApp(
         home:  Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoMenuAnchor(
                        builder: _buildAnchor,
                        constraints: const BoxConstraints(),
                        menuChildren: createTestMenus(onPressed: onPressed),
                      ),
                    ),
                  ],
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(7));
      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(8.0, 60.0, 792.0, 103.7),
        Rect.fromLTRB(8.0, 104.0, 792.0, 147.7),
        Rect.fromLTRB(8.0, 155.7, 792.0, 199.4),
        Rect.fromLTRB(8.0, 199.7, 792.0, 243.4),
        Rect.fromLTRB(8.0, 243.7, 792.0, 287.4),
        Rect.fromLTRB(8.0, 295.4, 792.0, 339.0),
        Rect.fromLTRB(8.0, 339.4, 792.0, 383.0),
      ];
      for (int i = 0; i < actual.length; i++) {
        /*DELETE*/ print('${actual[i]}');
        expect(actual[i], rectEquals(expected[i]));
      }
    });

    testWidgets('unconstrained menus show up in the right place in RTL',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        CupertinoApp(
         home: Directionality(
            textDirection: TextDirection.rtl,
            child:  Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoMenuAnchor(
                        builder: _buildAnchor,

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

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(7));

      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(275.0, 60.0, 525.0, 103.7),
        Rect.fromLTRB(275.0, 104.0, 525.0, 147.7),
        Rect.fromLTRB(275.0, 155.7, 525.0, 199.4),
        Rect.fromLTRB(275.0, 199.7, 525.0, 243.4),
        Rect.fromLTRB(275.0, 243.7, 525.0, 287.4),
        Rect.fromLTRB(275.0, 295.4, 525.0, 339.0),
        Rect.fromLTRB(275.0, 339.4, 525.0, 383.0),
      ];

      for (int i = 0; i < actual.length; i++) {
        /*DELETE*/ print('${actual[i]},');
        expect(actual[i], rectEquals(expected[i]));
      }

    });

    testWidgets('constrained menus show up in the right place in LTR',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(220, 200));
      await tester.pumpWidget(
        CupertinoApp(
          home:  Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                    children: <Widget>[
                      CupertinoMenuAnchor(
                        builder: _buildAnchor,
                        menuChildren: createTestMenus(onPressed: onPressed),
                      ),
                      const Expanded(child: Placeholder()),
                    ],
                  ),
          ),
        ),
      );
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      // Fewer items fit in the constrained menu.
      expect(find.byType(CupertinoMenuItem), findsNWidgets(5));
      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(8.0, 8.0, 212.0, 51.7),
        Rect.fromLTRB(8.0, 52.0, 212.0, 95.7),
        Rect.fromLTRB(8.0, 103.7, 212.0, 147.3),
        Rect.fromLTRB(8.0, 147.7, 212.0, 191.3),
        Rect.fromLTRB(8.0, 191.7, 212.0, 235.3),
      ];

      for (int i = 0; i < actual.length; i++) {
        /*DELETE*/ print('${actual[i]},');
        expect(actual[i], rectEquals(expected[i]));
      }
    });

    testWidgets('constrained menus show up in the right place in RTL',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(220, 200));
      await tester.pumpWidget(
        CupertinoApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: <Widget>[
                CupertinoMenuAnchor(
                  builder: _buildAnchor,

                  menuChildren: createTestMenus(onPressed: onPressed),
                ),
                const Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      // Fewer items fit in the constrained menu.
      expect(find.byType(CupertinoMenuItem), findsNWidgets(5));

      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(8.0, 8.0, 212.0, 51.7),
        Rect.fromLTRB(8.0, 52.0, 212.0, 95.7),
        Rect.fromLTRB(8.0, 103.7, 212.0, 147.3),
        Rect.fromLTRB(8.0, 147.7, 212.0, 191.3),
        Rect.fromLTRB(8.0, 191.7, 212.0, 235.3),
      ];

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
                builder: _buildAnchor,
                menuChildren: createTestMenus(onPressed: onPressed),
              ),
              const Expanded(child: Placeholder()),
            ],
          ),
        ),
      ));

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      // Fewer items fit in the constrained menu.
      expect(find.byType(CupertinoMenuItem), findsNWidgets(5));
      final List<Rect> actual = collectRects<CupertinoMenuItem>();

      /*DELETE*/ print('${actual[0]},');
      /*DELETE*/ print('${tester.getRect(find.byType(CustomScrollView))}');
      expect(
        actual[0],
        rectEquals(const Rect.fromLTRB(8.0, 8.0, 212.0, 51.7)),
      );

      expect(
        tester.getRect(find.byType(CustomScrollView)),
        rectEquals(const Rect.fromLTRB(8.0, 8.0, 212.0, 192.0)),
      );
    });

    testWidgets(
        'constrained menus show up in the right place with offset in LTR',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(220, 200));
      await tester.pumpWidget(
        CupertinoApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: CupertinoMenuAnchor(
                alignmentOffset: const Offset(30, 30),
                menuChildren: createTestMenus( onPressed: onPressed),
                builder: _buildAnchor,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(5));

      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(8.0, 8.0, 212.0, 51.7),
        Rect.fromLTRB(8.0, 52.0, 212.0, 95.7),
        Rect.fromLTRB(8.0, 103.7, 212.0, 147.3),
        Rect.fromLTRB(8.0, 147.7, 212.0, 191.3),
        Rect.fromLTRB(8.0, 191.7, 212.0, 235.3),
      ];

      for (int i = 0; i < actual.length; i++) {
        /*DELETE*/ print(actual[i]);
        expect(actual[i], rectEquals(expected[i]));
      }

    });

    testWidgets(
        'constrained menus show up in the right place with offset in RTL',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(220, 200));
      await tester.pumpWidget(
        CupertinoApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.topRight,
              child: CupertinoMenuAnchor(
                builder: _buildAnchor,
                alignmentOffset: const Offset(30, 30),
                menuChildren:  createTestMenus(onPressed: onPressed),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoMenuItem), findsNWidgets(5));
      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(8.0, 8.0, 212.0, 51.7),
        Rect.fromLTRB(8.0, 52.0, 212.0, 95.7),
        Rect.fromLTRB(8.0, 103.7, 212.0, 147.3),
        Rect.fromLTRB(8.0, 147.7, 212.0, 191.3),
        Rect.fromLTRB(8.0, 191.7, 212.0, 235.3),
      ];

      for (int i = 0; i < actual.length; i++) {
        /*DELETE*/ print(actual[i]);
        expect(actual[i], rectEquals(expected[i]));
      }

    });

    // TODO(davidhicks980): Should offset be applied before or after growth dir?

    testWidgets(
        'menus anchored below the halfway point of the screen grow upwards',
        (WidgetTester tester) async {
      await changeSurfaceSize(tester, const Size(800, 600));
      await tester.pumpWidget(
        CupertinoApp(
          home: Align(
                  alignment: const Alignment(0.5, 0.5),
                  child: CupertinoMenuAnchor(
                    builder: _buildAnchor,
                    menuChildren: <Widget>[
                      CupertinoMenuItem(child: TestMenu.item0.text),
                    ]
                  ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      /*DELETE*/ print(tester.getRect(find.byType(CupertinoMenuItem)));

      expect(find.byType(CupertinoMenuItem), findsOneWidget);
      expect(
        tester.getRect(find.byType(CupertinoMenuItem)),
        rectEquals(const Rect.fromLTRB(461.0, 363.8, 711.0, 407.5))
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
                    builder: _buildAnchor,
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

      /*DELETE*/ print(tester.getRect(TestMenu.item0.findText),
);

      expect(find.byType(CupertinoMenuItem), findsOneWidget);
      expect(
        tester.getRect(TestMenu.item0.findText),
        rectEquals(const Rect.fromLTRB(291.0, 559.7, 390.5, 580.7)),
      );
    });
  });




}

List<Widget> createTestMenus({
  void Function(TestMenu)? onPressed,
  Map<TestMenu, MenuSerializableShortcut> shortcuts = const <TestMenu, MenuSerializableShortcut>{},
  bool includeExtraGroups = false,
  bool accelerators = false,
  double? leadingWidth,
  double? trailingWidth,
  BoxConstraints? constraints,

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
  item5Disabled('Ite&m 5'),
  item6('Ite&m 6'),

  anchorButton('Press Me'),
  outsideButton('Outside');

  const TestMenu(this.acceleratorLabel);
  final String acceleratorLabel;
  // Strip the accelerator markers.
  String get label => MenuAcceleratorLabel.stripAcceleratorMarkers(acceleratorLabel);
  Finder get findText => find.text(label);
  Finder get findMenuItem => find.widgetWithText(CupertinoMenuItem, label);
  Finder findAncestor<T>() {
    return find.ancestor(
      of: findText,
      matching: find.byType(T),
    );
  }
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


Widget _buildAnchor(
  BuildContext context,
  CupertinoMenuController controller,
  Widget? child,
) {
  return Material(
    child: InkWell(
        onTap: () {
          if (controller.menuStatus case MenuStatus.opened || MenuStatus.opening) {
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
