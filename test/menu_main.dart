// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:example/menu.dart';
import 'package:example/menu_item.dart';
import 'package:example/test_anchor.dart';
import 'package:flutter/cupertino.dart' show CupertinoApp, CupertinoColors, CupertinoDynamicColor, CupertinoIcons, CupertinoPageScaffold, CupertinoTheme, CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide  CheckboxMenuButton, MenuAcceleratorLabel, MenuAnchor, MenuBar, MenuController, MenuItemButton, RadioMenuButton, SubmenuButton;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'semantics.dart';

 // TODO(davidhicks980): Accelerators are not used on Apple platforms -- exclude
  // them from the library?

typedef MenuParts = ({TextStyle? leadingIconStyle, TextStyle? leadingTextStyle, TextStyle? subtitleStyle, TextStyle? titleStyle, TextStyle? trailingIconStyle, TextStyle? trailingTextStyle});
void main() {
  late CupertinoMenuController controller;
  String? focusedMenu;
  final List<TestMenu> selected = <TestMenu>[];
  final List<TestMenu> opened = <TestMenu>[];
  final List<TestMenu> closed = <TestMenu>[];
  const bool printOut = true;
  Matcher rectEquals(Rect rect) {
    return rectMoreOrLessEquals(rect, epsilon: 0.1);
  }
  double edgeInsetsDistance(EdgeInsets a, EdgeInsets b) {
    double delta = math.max<double>(
      (a.left - b.left).abs(),
      (a.top - b.top).abs(),
    );
    delta = math.max<double>(delta, (a.right - b.right).abs());
    delta = math.max<double>(delta, (a.bottom - b.bottom).abs());
    return delta;
  }

  double edgeInsetsDirectionalDistance(EdgeInsetsDirectional a, EdgeInsetsDirectional b) {
    double delta = math.max<double>(
      (a.start - b.start).abs(),
      (a.top - b.top).abs(),
    );
    delta = math.max<double>(delta, (a.end - b.end).abs());
    delta = math.max<double>(delta, (a.bottom - b.bottom).abs());
    return delta;
  }

  Matcher edgeInsetsWithin(EdgeInsets edgeInsets, {double distance = 0.1}) {
    return within(
      distance: distance,
      from: edgeInsets,
      distanceFunction: edgeInsetsDistance,
    );
  }

  Matcher edgeInsetsDirectionalMoreOrLess(EdgeInsetsDirectional edgeInsets,
      {double distance = 0.1}) {
    return within(
      distance: distance,
      from: edgeInsets,
      distanceFunction: edgeInsetsDirectionalDistance,
    );
  }


  Finder findDecoration(Finder finder) =>
          find.descendant(of: finder, matching: find.byType(DecoratedBox));

  Color? findDecoratedBoxColor( WidgetTester tester, Finder finder,) {
    return (tester
            .widget<DecoratedBox>(findDecoration(finder).first)
            .decoration as BoxDecoration)
        .color;
  }
  RichText? findRichText( WidgetTester tester, Finder finder,) {
    return tester.firstWidget<RichText>(find.descendant(
              of: finder,
            matching: find.byType(RichText)));
  }
  TextStyle? findTextStyle( WidgetTester tester, Finder finder,) {
    return findRichText(tester, finder)?.text.style;
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
                    onOpened: onOpen,
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
                builder: _buildAnchor,
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
        expect(controller.menuStatus, MenuStatus.closed);
        expect(TestMenu.item1.findText, findsNothing);
        expect(controller.isOpen, isFalse);

        // Open the menu.
        await open();
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
        await close();
        await tester.pump();

        // The menu is closing => MenuStatus.closing.
        expect(controller.menuStatus, MenuStatus.closing);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Open the menu again.
        await open();
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
        await close();
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
        await open();
        await tester.pump();

        // The menu is animating open => MenuStatus.opening.
        expect(controller.menuStatus, MenuStatus.opening);
        expect(controller.isOpen, isTrue);
        expect(TestMenu.item1.findText, findsOneWidget);

        // Close the menu again.
        await close();
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
        CupertinoApp(
          home:Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoMenuAnchor(
                        builder: _buildAnchor,
                        menuChildren: createTestMenus2(onPressed: onPressed),
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
          find.ancestor(
            of: TestMenu.item5Disabled.findText,
            matching: find.byType(DecoratedBoxTransition),
          ).first,
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
                        builder: _buildAnchor,

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
                        builder: _buildAnchor,

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
      expect(tester.getRect(anchor),
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
              onOpened: onOpen,
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
                  onOpened: onOpen,
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
              onOpened: onOpen,
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
                onOpened: onOpen,
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
              onOpened: onOpen,
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
                  onOpened: onOpen,
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
                  onOpened: () {
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
                    onOpened: onOpen,
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
      home: Scaffold(
        body: AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.all(8)  * animationController.value,
                textScaler: TextScaler.linear(1 + animationController.value),
                size: MediaQuery.of(context).size * (1+ animationController.value),

              ),
              child: CupertinoMenuAnchor(
                onOpened: animationController.forward,
                onClose: animationController.reverse,
                menuChildren: createTestMenus2(onPressed: (_){}),
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
    // /*DELETE*/ This test is properly too broad and can be removed.
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
      home: Scaffold(
        body: AnimatedBuilder(
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
              onOpened: animationController.forward,
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
  group('CupertinoMenuEntryMixin', () {
    Widget buildApp(List<Widget> children) {
        return CupertinoApp(
          home: CupertinoMenuAnchor(
            controller: controller,
            menuChildren: children,
          ),
        );
      }
    testWidgets('allowLeadingSeparator and allowTrailingSeparator',
        (WidgetTester tester) async {
      Widget buildDebug({required bool lead, required bool trail, Widget? child}) {
        return _DebugCupertinoMenuEntryMixin(
          allowLeadingSeparator: lead,
          allowTrailingSeparator: trail,
          child: child ?? const SizedBox(),
        );
      }

      Finder findAncestorDivider(Finder finder) => find.ancestor(
            of: finder,
            matching: find.byType(_CupertinoMenuDivider),
      );

      await tester.pumpWidget(buildApp(<Widget>[
        buildDebug(lead: true, trail: true, child: TestMenu.item0.text),
        buildDebug(lead: true, trail: true, child: TestMenu.item1.text),
        buildDebug(lead: true, trail: true, child: TestMenu.item2.text),
      ]));

      controller.open();
      await tester.pumpAndSettle();

      // Borders are drawn below menu items.
      expect(findAncestorDivider(TestMenu.item0.findText), findsOneWidget);
      expect(findAncestorDivider(TestMenu.item1.findText), findsOneWidget);
      expect(findAncestorDivider(TestMenu.item2.findText), findsNothing);

      // First item should never have a leading separator and bottom item should
      // never have a trailing separator.
      await tester.pumpWidget(buildApp(<Widget>[
        buildDebug(lead: false, trail: true,  child: TestMenu.item0.text),
        buildDebug(lead: true,  trail: true,  child: TestMenu.item1.text),
        buildDebug(lead: true,  trail: false, child: TestMenu.item2.text),
      ]));

      await tester.pump();

      expect(findAncestorDivider(TestMenu.item0.findText), findsOneWidget);
      expect(findAncestorDivider(TestMenu.item1.findText), findsOneWidget);
      expect(findAncestorDivider(TestMenu.item2.findText), findsNothing);

      await tester.pumpWidget(buildApp(<Widget>[
        buildDebug(lead: true,  trail: false, child: TestMenu.item0.text),
        buildDebug(lead: true,  trail: true,  child: TestMenu.item1.text),
        buildDebug(lead: true,  trail: true,  child: TestMenu.item2.text),
      ]));

      await tester.pump();

      // item 0: trailing == false so no separator is drawn after
      expect(findAncestorDivider(TestMenu.item0.findText), findsNothing);
      expect(findAncestorDivider(TestMenu.item1.findText), findsOneWidget);
      expect(findAncestorDivider(TestMenu.item2.findText), findsNothing);

      await tester.pumpWidget(buildApp(<Widget>[
        buildDebug(lead: true,  trail: true,  child: TestMenu.item0.text),
        buildDebug(lead: false, trail: true,  child: TestMenu.item1.text),
        buildDebug(lead: true,  trail: true,  child: TestMenu.item2.text),
      ]));

      await tester.pump();

      // item 1: leading == false so no separator is drawn before
      expect(findAncestorDivider(TestMenu.item0.findText), findsNothing);
      expect(findAncestorDivider(TestMenu.item1.findText), findsOneWidget);
      expect(findAncestorDivider(TestMenu.item2.findText), findsNothing);

      await tester.pumpWidget(buildApp(<Widget>[
        buildDebug(lead: true,  trail: true,  child: TestMenu.item0.text),
        buildDebug(lead: true, trail: false,  child: TestMenu.item1.text),
        buildDebug(lead: true,  trail: true,  child: TestMenu.item2.text),
      ]));

      await tester.pump();

      // item 1: trailing == false so no separator is drawn after
      expect(findAncestorDivider(TestMenu.item0.findText), findsOneWidget);
      expect(findAncestorDivider(TestMenu.item1.findText), findsNothing);
      expect(findAncestorDivider(TestMenu.item2.findText), findsNothing);
    });
     testWidgets('hasLeading',
        (WidgetTester tester) async {
      final GlobalKey<_DebugCupertinoMenuEntryMixinState> firstKey =
          GlobalKey<_DebugCupertinoMenuEntryMixinState>();
      final GlobalKey<_DebugCupertinoMenuEntryMixinState> secondKey =
          GlobalKey<_DebugCupertinoMenuEntryMixinState>();

      await tester.pumpWidget(buildApp(<Widget>[
         _DebugCupertinoMenuEntryMixin(key: firstKey),
         _DebugCupertinoMenuEntryMixin(key: secondKey, hasLeading: true),
      ]));

      controller.open();
      await tester.pumpAndSettle();

      expect(firstKey.currentState?.widget.hasLeading, isFalse);
      expect(secondKey.currentState?.widget.hasLeading, isTrue);
      expect(firstKey.currentState?.shouldApplyLeading(), isTrue);
      expect(secondKey.currentState?.shouldApplyLeading(), isTrue);
    });
     testWidgets('closeMenu',
        (WidgetTester tester) async {
      final GlobalKey<_DebugCupertinoMenuEntryMixinState> firstKey =
          GlobalKey<_DebugCupertinoMenuEntryMixinState>();
      await tester.pumpWidget(buildApp(<Widget>[
         _DebugCupertinoMenuEntryMixin(key: firstKey, child: TestMenu.item0.text),
      ]));

      controller.open();
      await tester.pumpAndSettle();
      expect(TestMenu.item0.findText, findsOneWidget);
      firstKey.currentState?.closeMenu();
      await tester.pump();
      expect(firstKey.currentState?.getMenuStatus(), MenuStatus.closing);
      await tester.pumpAndSettle();
      // Menu item is no longer attached
      expect(firstKey.currentState?.getMenuStatus(), null);
    });

     testWidgets('getMenuStatus',
        (WidgetTester tester) async {
      final GlobalKey<_DebugCupertinoMenuEntryMixinState> firstKey =
          GlobalKey<_DebugCupertinoMenuEntryMixinState>();
      await tester.pumpWidget(buildApp(<Widget>[
         _DebugCupertinoMenuEntryMixin(key: firstKey, child: TestMenu.item0.text),
      ]));


      // When menu is closed, item is not mounted
      expect(firstKey.currentState?.getMenuStatus(), null);
      controller.open();
      await tester.pump();
      expect(firstKey.currentState?.getMenuStatus(), MenuStatus.opening);
      await tester.pumpAndSettle();
      expect(firstKey.currentState?.getMenuStatus(), MenuStatus.opened);
      firstKey.currentState?.closeMenu();
      await tester.pump();
      expect(firstKey.currentState?.getMenuStatus(), MenuStatus.closing);
      await tester.pumpAndSettle();
      expect(firstKey.currentState?.getMenuStatus(), null);

    });
  });

  group('CupertinoMenuLargeDivider', () {
    testWidgets('dimensions', (WidgetTester tester) async {
      final CupertinoMenuController controller = CupertinoMenuController();
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoLargeMenuDivider(),
        ),
      );

      /*DELETE*/  print(tester.getRect(find.byType(CupertinoLargeMenuDivider)));
      expect(tester.getRect(find.byType(CupertinoLargeMenuDivider)),
          rectEquals(
            const Rect.fromLTRB(275.0, 584.0, 525.0, 592.0)
            ));

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoMenuAnchor(
            controller: controller,
            menuChildren: <Widget>[
              // Default padding
              CupertinoMenuItem(
                child: TestMenu.item0.text,
                onPressed: () {},
              ),
              const CupertinoLargeMenuDivider(),
            ],
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      // /*DELETE*/  print(tester.getRect(find.byType(CupertinoMenuLargeDivider)));
      // /*DELETE*/  print(tester.getRect(find.text(superLongText)));
      expect(tester.getRect(find.byType(CupertinoLargeMenuDivider)),
          rectEquals(
            const Rect.fromLTRB(275.0, 584.0, 525.0, 592.0)
            ));
    });
    testWidgets('color', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(
            brightness: Brightness.light,
          ),
          home: CupertinoMenuAnchor(
            controller: controller,
            menuChildren: <Widget>[
              // Default padding
              CupertinoMenuItem(
                child: TestMenu.item0.text,
                onPressed: () {},
              ),
              const CupertinoLargeMenuDivider(),
            ],
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      /*DELETE*/ print(tester.getRect(find.byType(CupertinoLargeMenuDivider)));
      // /*DELETE*/  print(tester.getRect(find.text(superLongText)));
      final FinderResult<Element> containerFinder = find
          .descendant(
            of: find.byType(CupertinoLargeMenuDivider),
            matching: find.byType(Container),
          )
          .evaluate();
      expect(
        (containerFinder.first.widget as Container).color,
        isSameColorAs(const Color.fromRGBO(0, 0, 0, 0.08)),
      );

      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(
            brightness: Brightness.dark,
          ),
          home: CupertinoMenuAnchor(
            controller: controller,
            menuChildren: <Widget>[
              // Default padding
              CupertinoMenuItem(
                child: TestMenu.item0.text,
                onPressed: () {},
              ),
              const CupertinoLargeMenuDivider(),
            ],
          ),
        ),
      );
      expect(
        (containerFinder.first.widget as Container).color,
        isSameColorAs(const Color.fromRGBO(0, 0, 0, 0.16)),
      );
    });
    testWidgets('no adjacent borders are drawn', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(
            brightness: Brightness.light,
          ),
          home: CupertinoMenuAnchor(
            controller: controller,
            menuChildren: <Widget>[
              CupertinoMenuItem(
                child: TestMenu.item0.text,
                onPressed: () {},
              ),
              const CupertinoLargeMenuDivider(),
              CupertinoMenuItem(
                child: TestMenu.item1.text,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();
      expect( find.byType(CupertinoLargeMenuDivider), findsOneWidget);
      expect( find.byType(_CupertinoMenuDivider), findsNothing);
    });
  });

  group('CupertinoMenuItem', () {
    testWidgets('child layout LTR', (WidgetTester tester) async {
      final String superLongText = 'super long text' * 1000;

      // Maxlines should be 2 when the TextScaler < 1.25.
       await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              child:  Text(superLongText),
            ),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      /*DELETE*/  print(tester.getRect(TestMenu.item0.findText));
      /*DELETE*/  print(tester.getRect(find.text(superLongText)));
      expect(
        tester.getRect(TestMenu.item0.findText),
        rectEquals(
         const Rect.fromLTRB(307.0, 77.6, 406.5, 98.6)
       ),
      );

      expect(
        tester.getRect(find.text(superLongText)),
        rectEquals(
         const Rect.fromLTRB(307.0, 141.6, 509.0, 183.6)
       ),
      );

      // MaxLines should be 100 when the TextScaler > 1.25.
      await tester.pumpWidget(
        buildTestApp(
          mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          children: <Widget>[
            CupertinoMenuItem(
              applyInsetScaling: false,
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              child:  Text(superLongText),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();
     /*DELETE*/ print(tester.getRect(TestMenu.item0.findText));
     /*DELETE*/ print(tester.getRect(find.text(superLongText)));
      expect(tester.getRect(TestMenu.item0.findText),
          rectEquals(
      const Rect.fromLTRB(257.0, 19.0, 387.1, 47.0)
      ));

      expect(tester.getRect(find.text(superLongText)),
          rectEquals(
        const Rect.fromLTRB(261.5, 96.5, 556.8, 2896.5)

      ));


    });

    testWidgets('child layout RTL', (WidgetTester tester) async {
      final String superLongText = 'super long text' * 1000;

      // Maxlines should be 2 when the TextScaler < 1.25.
       await tester.pumpWidget(
        buildTestApp(
          textDirection: TextDirection.rtl,
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              child:  Text(superLongText),
            ),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();
    /*DELETE*/  print(tester.getRect(TestMenu.item0.findText));
    /*DELETE*/  print(tester.getRect(find.text(superLongText)));
      expect(
        tester.getRect(TestMenu.item0.findText),
        rectEquals(
        const Rect.fromLTRB(393.5, 77.6, 493.0, 98.6)
      ),
      );

      expect(
        tester.getRect(find.text(superLongText)),
        rectEquals(
         const Rect.fromLTRB(291.0, 141.6, 493.0, 183.6)
      ),
      );

      // MaxLines should be 100 when the TextScaler > 1.25.
      await tester.pumpWidget(
        buildTestApp(
          mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          textDirection: TextDirection.rtl,
          children: <Widget>[
            CupertinoMenuItem(
              applyInsetScaling: false,
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              child:  Text(superLongText),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();
      /*DELETE*/ print(tester.getRect(TestMenu.item0.findText));
      /*DELETE*/ print(tester.getRect(find.text(superLongText)));
      expect(
        tester.getRect(TestMenu.item0.findText),
        rectEquals(
         const Rect.fromLTRB(412.9, 19.0, 543.0, 47.0)
      ),
      );

      expect(
        tester.getRect(find.text(superLongText)),
        rectEquals(
           const Rect.fromLTRB(243.2, 96.5, 538.5, 2896.5)
      ),
      );
    });
    testWidgets('leading layout LTR', (WidgetTester tester) async {
       await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leadingWidth: 20,
              leadingAlignment: AlignmentDirectional.bottomEnd,
              leading: const Text('leading'),
              child:  TestMenu.item1.text,
            ),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();
     /*DELETE*/ print(tester.getRect(find.text('leading')));
     /*DELETE*/ print(tester.getRect(find.byIcon(CupertinoIcons.left_chevron)));
      expect(
        tester.getRect(find.text('leading')),
        rectEquals(const Rect.fromLTRB(275.0, 141.6, 295.0, 183.6)),
      );

      expect(
        tester.getRect(find.byIcon(CupertinoIcons.left_chevron)),
        rectEquals(const Rect.fromLTRB(281.4, 87.6, 302.4, 108.6)),
      );

      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leadingWidth: 50,
              leadingAlignment: AlignmentDirectional.topStart,
              leading: const Text('leading'),
              child:  TestMenu.item1.text,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();
     /*DELETE*/ print(tester.getRect(find.text('leading')));
     /*DELETE*/ print(tester.getRect(find.byIcon(CupertinoIcons.left_chevron)));
      expect(
        tester.getRect(find.text('leading')),
        rectEquals(const Rect.fromLTRB(275.0, 141.6, 325.0, 183.6)),
      );

      expect(
        tester.getRect(find.byIcon(CupertinoIcons.left_chevron)),
        rectEquals(const Rect.fromLTRB(281.4, 87.6, 302.4, 108.6)),
      );
    });
    testWidgets('leading layout RTL', (WidgetTester tester) async {
       await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leadingWidth: 20,
              leadingAlignment: AlignmentDirectional.bottomEnd,
              leading: const Text('leading'),
              child:  TestMenu.item1.text,
            ),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();
     /*DELETE*/ print(tester.getRect(find.text('leading')));
     /*DELETE*/ print(tester.getRect(find.byIcon(CupertinoIcons.left_chevron)));
      // expect(
      //   tester.getRect(find.text('leading')),
      //   rectEquals(const Rect.fromLTRB(275.0, 142.1, 295.0, 184.1)),
      // );

      // expect(
      //   tester.getRect(find.byIcon(CupertinoIcons.left_chevron)),
      //   rectEquals(const Rect.fromLTRB(281.4, 88.1, 302.4, 109.1)),
      // );

      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leadingWidth: 50,
              leadingAlignment: AlignmentDirectional.topStart,
              leading: const Text('leading'),
              child:  TestMenu.item1.text,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();
     /*DELETE*/ print(tester.getRect(find.text('leading')));
     /*DELETE*/ print(tester.getRect(find.byIcon(CupertinoIcons.left_chevron)));
      // expect(
      //   tester.getRect(find.text('leading')),
      //   rectEquals(const Rect.fromLTRB(275.0, 142.1, 325.0, 184.1)),
      // );

      // expect(
      //   tester.getRect(find.byIcon(CupertinoIcons.left_chevron)),
      //   rectEquals(const Rect.fromLTRB(281.4, 88.1, 302.4, 109.1)),
      // );
    });
    testWidgets('hasLeading shift LTR', (WidgetTester tester) async {
       await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              onPressed: (){},
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              child:  TestMenu.item1.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leadingWidth: 3,
              child:  TestMenu.item2.text,
            ),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      /*DELETE*/ print(tester.getRect(TestMenu.item0.findText));
      /*DELETE*/ print(tester.getRect(TestMenu.item1.findText));
      /*DELETE*/ print(tester.getRect(TestMenu.item2.findText));
      final Rect a1 = tester.getRect(TestMenu.item0.findText);
      final Rect a2 = tester.getRect(TestMenu.item1.findText);
      final Rect a3 = tester.getRect(TestMenu.item2.findText);
      expect(a1.left, a2.left);
      expect(a1.left - a3.left, 16 - 3);
      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              onPressed: (){},
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leading: const Icon(CupertinoIcons.left_chevron),
              child:  TestMenu.item1.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leadingWidth: 3,
              child:  TestMenu.item2.text,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      /*DELETE*/ print(tester.getRect(TestMenu.item0.findText));
      /*DELETE*/ print(tester.getRect(TestMenu.item1.findText));
      /*DELETE*/ print(tester.getRect(TestMenu.item2.findText));
      final Rect b1 = tester.getRect(TestMenu.item0.findText);
      final Rect b2 = tester.getRect(TestMenu.item1.findText);
      final Rect b3 = tester.getRect(TestMenu.item2.findText);
      expect(b1.left, b2.left);
      expect(b1.left - b3.left, 32 - 3);
      expect(b1.left - a1.left, 32 - 16);
    });
    testWidgets('hasLeading shift RTL', (WidgetTester tester) async {
      // When no menu item has a leading widget, leadingWidth defaults to 16.
      // If leadingWidth is set, the default is ignored.
       await tester.pumpWidget(
        buildTestApp(
          textDirection: TextDirection.rtl,
          children: <Widget>[
            CupertinoMenuItem(
              onPressed: (){},
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              child:  TestMenu.item1.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leadingWidth: 3,
              child:  TestMenu.item2.text,
            ),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      /*DELETE*/ print(tester.getRect(TestMenu.item0.findText));
      /*DELETE*/ print(tester.getRect(TestMenu.item1.findText));
      /*DELETE*/ print(tester.getRect(TestMenu.item2.findText));
      final Rect a1 = tester.getRect(TestMenu.item0.findText);
      final Rect a2 = tester.getRect(TestMenu.item1.findText);
      final Rect a3 = tester.getRect(TestMenu.item2.findText);
      expect(a1.right, a2.right);
      expect(a1.right - a3.right, -16 + 3);

      // When any menu item has a leading widget, leadingWidth defaults to 32
      // for all menu items on this menu layer. If leadingWidth is set on an
      // item, that item ignores the default leading width.
      await tester.pumpWidget(
        buildTestApp(
          textDirection: TextDirection.rtl,
          children: <Widget>[
            CupertinoMenuItem(
              onPressed: (){},
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leading: const Icon(CupertinoIcons.left_chevron),
              child:  TestMenu.item1.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              leadingWidth: 3,
              child:  TestMenu.item2.text,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      /*DELETE*/ print(tester.getRect(TestMenu.item0.findText));
      /*DELETE*/ print(tester.getRect(TestMenu.item1.findText));
      /*DELETE*/ print(tester.getRect(TestMenu.item2.findText));
      final Rect b1 = tester.getRect(TestMenu.item0.findText);
      final Rect b2 = tester.getRect(TestMenu.item1.findText);
      final Rect b3 = tester.getRect(TestMenu.item2.findText);
      expect(b1.right, b2.right);
      expect(b1.right - b3.right, -32 + 3);
      expect(b1.right - a1.right, -32 + 16);
    });

    testWidgets('trailing layout LTR', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              trailingWidth: 20,
              trailingAlignment: AlignmentDirectional.bottomEnd,
              trailing: const Text('trailing'),
              child:  TestMenu.item1.text,
            ),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

     /*DELETE*/ print(tester.getRect(find.text('trailing')));
     /*DELETE*/ print(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)));
      // expect(tester.getRect(find.text('trailing')),
      //     rectEquals(
      //      const Rect.fromLTRB(505.0, 142.1, 525.0, 184.1)
      // ));

      // expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
      //     rectEquals(
      //      const Rect.fromLTRB(489.4, 88.1, 510.4, 109.1)
      // ));

      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              applyInsetScaling: false,
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              trailingWidth: 50,
              trailingAlignment: AlignmentDirectional.topStart,
              trailing: const Text('trailing'),
              child:  TestMenu.item1.text,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

     /*DELETE*/ print(tester.getRect(find.text('trailing')));
     /*DELETE*/ print(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)));
      // expect(tester.getRect(find.text('trailing')),
      //     rectEquals(
      //      const Rect.fromLTRB(475.0, 142.1, 525.0, 184.1)
      // ));

      // expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
      //     rectEquals(
      //      const Rect.fromLTRB(489.4, 88.1, 510.4, 109.1)
      // ));
    });
    testWidgets('trailing layout RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          textDirection: TextDirection.rtl,
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              trailingWidth: 20,
              trailingAlignment: AlignmentDirectional.bottomEnd,
              trailing: const Text('trailing'),
              child:  TestMenu.item1.text,
            ),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

     /*DELETE*/ print(tester.getRect(find.text('trailing')));
     /*DELETE*/ print(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)));

      // expect(tester.getRect(find.text('trailing')),
      //     rectEquals(
      //      const Rect.fromLTRB(275.0, 142.1, 295.0, 184.1)
      // ));

      // expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
      //     rectEquals(
      //     const Rect.fromLTRB(289.6, 88.1, 310.6, 109.1)
      // ));

      await tester.pumpWidget(
        buildTestApp(
          textDirection: TextDirection.rtl,
          children: <Widget>[
            CupertinoMenuItem(
              applyInsetScaling: false,
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: (){},
              trailingWidth: 50,
              trailingAlignment: AlignmentDirectional.topStart,
              trailing: const Text('trailing'),
              child:  TestMenu.item1.text,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

     /*DELETE*/ print(tester.getRect(find.text('trailing')));
     /*DELETE*/ print(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)));
      // expect(
      //   tester.getRect(find.text('trailing')),
      // rectEquals( const Rect.fromLTRB(275.0, 142.1, 325.0, 184.1) ));

      // expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
      //     rectEquals(
      //      const Rect.fromLTRB(289.6, 88.1, 310.6, 109.1)
      // ));
    });

    testWidgets('subtitle layout LTR', (WidgetTester tester) async {
      final String longSubtitle = 'subtitle' * 1000;

      // When TextScaler <= 1.25, maxLines == 2
      await tester.pumpWidget(buildTestApp(
        children: <Widget>[
          CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
          CupertinoMenuItem(
            onPressed: (){},
            subtitle: Text(longSubtitle),
            child: TestMenu.item1.text,
          ),
        ],
      ));
      controller.open();
      await tester.pumpAndSettle();

     /*DELETE*/ print(tester.getRect(find.text('subtitle')));
     /*DELETE*/ print(tester.getRect(find.text(longSubtitle)));
      // expect(tester.getRect(find.text('subtitle')),
      //     rectEquals(
      //       const Rect.fromLTRB(307.0, 100.3, 425.3, 119.3)
      //     ));
      // expect(tester.getRect(find.text(longSubtitle)),
      //     rectEquals(
      //       const Rect.fromLTRB(307.0, 164.3, 509.0, 202.3)
      //       ));

      // When TextScaler > 1.25, maxLines == 100
      await tester.pumpWidget(buildTestApp(
        mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        children: <Widget>[
            CupertinoMenuItem(
              applyInsetScaling: false,
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
          CupertinoMenuItem(
            onPressed: (){},
            subtitle: Text(longSubtitle),
            child: TestMenu.item1.text,
          ),
        ],
      ));
      await tester.pumpAndSettle();

    /*DELETE*/ print(tester.getRect(find.text('subtitle')));
     /*DELETE*/ print(tester.getRect(find.text(longSubtitle)));
      // expect(tester.getRect(find.text('subtitle')),
      //     rectEquals(
      //       const Rect.fromLTRB(257.0, 48.5, 411.3, 72.5)
      //       ));
      // expect(tester.getRect(find.text(longSubtitle)),
      //     rectEquals(
      //      const Rect.fromLTRB(261.5, 126.1, 556.8, 2526.1)
      //       ));
    });
    testWidgets('subtitle layout RTL', (WidgetTester tester) async {
      final String longSubtitle = 'subtitle' * 1000;

      // When TextScaler <= 1.25, maxLines == 2
      await tester.pumpWidget(buildTestApp(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
          CupertinoMenuItem(
            onPressed: (){},
            subtitle: Text(longSubtitle),
            child: TestMenu.item1.text,
          ),
        ],
      ));
      controller.open();
      await tester.pumpAndSettle();

     /*DELETE*/ print(tester.getRect(find.text('subtitle')));
     /*DELETE*/ print(tester.getRect(find.text(longSubtitle)));
      // expect(tester.getRect(find.text('subtitle')),
      //     rectEquals(
      //       const Rect.fromLTRB(374.7, 100.3, 493.0, 119.3)
      //     ));
      // expect(tester.getRect(find.text(longSubtitle)),
      //     rectEquals(
      //       const Rect.fromLTRB(291.0, 164.3, 493.0, 202.3)
      //       ));

      // When TextScaler > 1.25, maxLines == 100
      await tester.pumpWidget(buildTestApp(
        textDirection: TextDirection.rtl,
        mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        children: <Widget>[
            CupertinoMenuItem(
              applyInsetScaling: false,
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
          CupertinoMenuItem(
            onPressed: (){},
            subtitle: Text(longSubtitle),
            child: TestMenu.item1.text,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      /*DELETE*/ print(tester.getRect(find.text('subtitle')));
      /*DELETE*/ print(tester.getRect(find.text(longSubtitle)));
      // expect(tester.getRect(find.text('subtitle')),
      //     rectEquals(
      //       const Rect.fromLTRB(388.7, 48.5, 543.0, 72.5)
      //       ));
      // expect(tester.getRect(find.text(longSubtitle)),
      //     rectEquals(
      //      const Rect.fromLTRB(243.2, 126.1, 538.5, 2526.1)
      //       ));
    });

    testWidgets('default layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Column(
            children: <Widget>[
              CupertinoMenuAnchor(
                menuChildren: <Widget>[
                  CupertinoMenuItem(
                    leading: const Icon(CupertinoIcons.left_chevron),
                    trailing: const Icon(CupertinoIcons.right_chevron),
                    subtitle: const Text('subtitle'),
                    child: TestMenu.item1.text,
                    onPressed: () {},
                  ),
                ],
              ),
              const Spacer(),
              CupertinoMenuItem(
                onPressed: () {},
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                subtitle: const Text('subtitle'),
                child: TestMenu.item0.text,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoMenuAnchor));
      await tester.pumpAndSettle();

      BoxConstraints getConstraints(Finder finder) {
        return (find.descendant(
                  of: finder,
                  matching: find.byType(ConstrainedBox),
                ).evaluate().first.widget as ConstrainedBox).constraints;
      }
      /*DELETE*/ print(tester.getRect(TestMenu.item0.findWidget));
      /*DELETE*/ print(getConstraints(TestMenu.item0.findWidget));
      /*DELETE*/ print(tester.getRect(TestMenu.item1.findWidget));
      /*DELETE*/ print(getConstraints(TestMenu.item1.findWidget));
      // Standalone menu item has loose constraints with a minimum
      // height of 44.
      // expect(
      //   getConstraints(TestMenu.item0.findWidget),
      //   const BoxConstraints(minHeight: 44.0),
      // );
      // expect(
      //   tester.getRect(TestMenu.item0.findWidget),
      //   rectEquals(const Rect.fromLTRB(0.0, 536.0, 800.0, 600.0) )
      // );
      // expect(
      //   getConstraints(TestMenu.item1.findWidget),
      //   const BoxConstraints(minHeight: 44.0),
      // );
      // expect(
      //   tester.getRect(TestMenu.item1.findWidget),
      //   rectEquals(const Rect.fromLTRB(275.0, 56.8, 525.0, 120.8))
      // );


    });
     testWidgets('custom constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Column(
            children: <Widget>[
              CupertinoMenuAnchor(
                controller: controller,
                menuChildren: <Widget>[
                  CupertinoMenuItem(
                    constraints: const BoxConstraints(
                      minWidth: 50,
                      minHeight: 150,
                      maxWidth: 150,
                      maxHeight: 200,
                    ),
                    leading: const Icon(CupertinoIcons.left_chevron),
                    trailing: const Icon(CupertinoIcons.right_chevron),
                    subtitle: const Text('subtitle'),
                    child: TestMenu.item1.text,
                    onPressed: () {},
                  ),
                ],
              ),
              CupertinoMenuItem(
                constraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 150,
                  maxWidth: 150,
                  maxHeight: 200,
                ),
                onPressed: () {},
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                subtitle: const Text('subtitle'),
                child: TestMenu.item0.text,
              ),
            ],
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      BoxConstraints getConstraints(Finder finder) {
        return (find.descendant(
                  of: finder,
                  matching: find.byType(ConstrainedBox),
                ).evaluate().first.widget as ConstrainedBox).constraints;
      }
      /*DELETE*/ print(tester.getRect(TestMenu.item0.findWidget));
      /*DELETE*/ print(getConstraints(TestMenu.item0.findWidget));
      /*DELETE*/ print(tester.getRect(TestMenu.item1.findWidget));
      /*DELETE*/ print(getConstraints(TestMenu.item1.findWidget));

      // expect(
      //   getConstraints(TestMenu.item0.findWidget),
      //   const BoxConstraints(minHeight: 150.0, maxHeight: 200, minWidth: 50, maxWidth: 150),
      // );
      // expect(
      //   tester.getRect(TestMenu.item0.findWidget),
      //   rectEquals(const Rect.fromLTRB(325.0, 56.0, 475.0, 256.0))
      // );
      // expect(
      //   getConstraints(TestMenu.item1.findWidget),
      //   const BoxConstraints(minHeight: 150.0, maxHeight: 200, minWidth: 50, maxWidth: 150),
      // );
      // expect(
      //   tester.getRect(TestMenu.item1.findWidget),
      //   rectEquals(const Rect.fromLTRB(275.0, 58.5, 525.0, 258.5))
      // );
    });
     testWidgets('Vertical padding', (WidgetTester tester) async {
      EdgeInsetsGeometry getEdgeInsets(Finder finder) {
        return (find.descendant(
                  of: finder,
                  matching: find.byType(Padding),
                ).evaluate().first.widget as Padding).padding;
      }
      // Default padding
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoMenuAnchor(
            controller: controller,
            menuChildren: <Widget>[
              // Default padding
              CupertinoMenuItem(
                child: TestMenu.item0.text,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      // Because one physical pixel is subtracted from the total vertical
      // padding, the vertical padding is 11.3 per side instead of 11.5.
      expect(
        getEdgeInsets(TestMenu.item0.findWidget),
        edgeInsetsDirectionalMoreOrLess(const EdgeInsetsDirectional.fromSTEB(0.0, 11.3, 0.0, 11.3))
      );
      expect(
        tester.getSize(TestMenu.item0.findWidget),
        within(distance: 0.1, from: const Size(250, 43.7)),
      );


     await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoMenuAnchor(
            controller: controller,
            menuChildren: <Widget>[
              // Padding + height is below minHeight constraint of 44, so
              // vertical padding does not affect layout
              CupertinoMenuItem(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
                child: TestMenu.item0.text,
                onPressed: () {},
              ),

              // Padding + height is above minHeight constraint of 44, so
              // padding does affect vertical layout
              CupertinoMenuItem(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 5),
                subtitle: const Text('subtitle'),
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                onPressed: () {},
                child: TestMenu.item1.text,
              ),
            ],
          ),
        ),
      );

      /*DELETE*/ print(tester.getSize(TestMenu.item0.findWidget));
      /*DELETE*/ print(getEdgeInsets(TestMenu.item0.findWidget));
      /*DELETE*/ print(tester.getSize(TestMenu.item1.findWidget));
      /*DELETE*/ print(getEdgeInsets(TestMenu.item1.findWidget));

      // User-defined padding does not subtract 1 physical pixel from the total
      // vertical padding.

      // Padding + height is below minHeight constraint of 44, so padding does not
      // affect vertical layout
      expect(
        getEdgeInsets(TestMenu.item0.findWidget),
        edgeInsetsDirectionalMoreOrLess(
          const EdgeInsetsDirectional.fromSTEB(0.0, 5, 0.0, 5),
        ),
      );
      expect(
        tester.getSize(TestMenu.item0.findWidget),
        within(distance: 0.05, from: const Size(250, 44)),
      );

      // Padding + height is above min height of 44, so padding does
      // affect vertical layout
      expect(
        getEdgeInsets(TestMenu.item1.findWidget),
        edgeInsetsDirectionalMoreOrLess(const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 5))
      );
      expect(
        tester.getSize(TestMenu.item1.findWidget),
        within(distance: 0.05, from: const Size(250, 53)),
      );
    });
     testWidgets('horizontal padding LTR', (WidgetTester tester) async {
      T findEdgeInsets<T extends EdgeInsetsGeometry>(Finder finder) {
        return (find.descendant(
                  of: finder,
                  matching: find.byType(Padding),
                ).evaluate().first.widget as Padding).padding as T;
      }
      // Default position
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoMenuAnchor(
            controller: controller,
            menuChildren: <Widget>[
              CupertinoMenuItem(
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                subtitle: const Text('subtitle'),
                child: TestMenu.item0.text,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();
      final Rect leading = tester.getRect(find.byIcon(CupertinoIcons.left_chevron));
      final Rect trailing = tester.getRect(find.byIcon(CupertinoIcons.right_chevron));
      final Rect subtitle = tester.getRect(find.text('subtitle'));
      final Rect child = tester.getRect(TestMenu.item0.findText);
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoMenuAnchor(
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  padding: const EdgeInsetsDirectional.only(start: 7, end: 13),
                  leading: const Icon(CupertinoIcons.left_chevron),
                  trailing: const Icon(CupertinoIcons.right_chevron),
                  subtitle: const Text('subtitle'),
                  child: TestMenu.item0.text,
                  onPressed: () {},
                ),
              ],
          ),
        ),
      );
      final Rect leading2 = tester.getRect(find.byIcon(CupertinoIcons.left_chevron));
      final Rect trailing2 = tester.getRect(find.byIcon(CupertinoIcons.right_chevron));
      final Rect subtitle2 = tester.getRect(find.text('subtitle'));
      final Rect child2 = tester.getRect(TestMenu.item0.findText);
      // Default padding subtracts 1 physical pixel from the total vertical
      // padding. Otherwise, the padding vertical padding would be 11.5 per side.
      expect(
        findEdgeInsets(TestMenu.item0.findWidget),
        edgeInsetsDirectionalMoreOrLess(const EdgeInsetsDirectional.only(start: 7, end: 13))
      );
      expect(
        tester.getSize(TestMenu.item0.findWidget),
        within(distance: 0.05, from: const Size(250, 44)),
      );

      expect(leading2.left - leading.left, 7);
      expect(trailing2.right - trailing.right, -13);
      expect(subtitle2.left - subtitle.left, 7);
      expect(child2.left - child.left, 7);
    });

     testWidgets('horizontal padding RTL', (WidgetTester tester) async {
      T findEdgeInsets<T extends EdgeInsetsGeometry>(Finder finder) {
        return (find.descendant(
                  of: finder,
                  matching: find.byType(Padding),
                ).evaluate().first.widget as Padding).padding as T;
      }
      // Default position
      await tester.pumpWidget(
        CupertinoApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  leading: const Icon(CupertinoIcons.left_chevron),
                  trailing: const Icon(CupertinoIcons.right_chevron),
                  subtitle: const Text('subtitle'),
                  child: TestMenu.item0.text,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();
      final Rect leading = tester.getRect(find.byIcon(CupertinoIcons.left_chevron));
      final Rect trailing = tester.getRect(find.byIcon(CupertinoIcons.right_chevron));
      final Rect subtitle = tester.getRect(find.text('subtitle'));
      final Rect child = tester.getRect(TestMenu.item0.findText);

      await tester.pumpWidget(
        CupertinoApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: CupertinoMenuAnchor(
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  padding: const EdgeInsetsDirectional.only(start: 7, end: 13),
                  leading: const Icon(CupertinoIcons.left_chevron),
                  trailing: const Icon(CupertinoIcons.right_chevron),
                  subtitle: const Text('subtitle'),
                  child: TestMenu.item0.text,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      final Rect leading2 = tester.getRect(find.byIcon(CupertinoIcons.left_chevron));
      final Rect trailing2 = tester.getRect(find.byIcon(CupertinoIcons.right_chevron));
      final Rect subtitle2 = tester.getRect(find.text('subtitle'));
      final Rect child2 = tester.getRect(TestMenu.item0.findText);

      expect(
        findEdgeInsets(TestMenu.item0.findWidget),
        edgeInsetsDirectionalMoreOrLess(const EdgeInsetsDirectional.only(start: 7, end: 13))
      );
      expect(
        tester.getSize(TestMenu.item0.findWidget),
        within(distance: 0.05, from: const Size(250, 44)),
      );

      expect(leading2.right - leading.right, moreOrLessEquals(-7));
      expect(trailing2.left - trailing.left, moreOrLessEquals(13));
      expect(subtitle2.right - subtitle.right, moreOrLessEquals(-7));
      expect(child2.right - child.right, moreOrLessEquals(-7));
    });

     testWidgets('hide trailing with TextScaler greater than 1.25', (WidgetTester tester) async {
       // Trailing is not shown when the TextScaler > 1.25.
      await tester.pumpWidget(
        buildTestApp(
          mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,

            ),

          ],
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      expect(find.text('subtitle'), findsOne);
      expect(TestMenu.item0.findWidget, findsOne);
      expect(find.byIcon(CupertinoIcons.left_chevron), findsOne);
      expect(find.byIcon(CupertinoIcons.right_chevron), findsNothing);

      await tester.pumpWidget(
        buildTestApp(
          textDirection: TextDirection.rtl,
          mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestMenu.item0.text,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('subtitle'), findsOne);
      expect(TestMenu.item0.findWidget, findsOne);
      expect(find.byIcon(CupertinoIcons.left_chevron), findsOne);
      expect(find.byIcon(CupertinoIcons.right_chevron), findsNothing);
    });

    testWidgets('default style', (WidgetTester tester) async {
      const CupertinoDynamicColor titleColor =
          CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(0, 0, 0, 0.96),
        darkColor: Color.fromRGBO(255, 255, 255, 0.96),
      );

      const CupertinoDynamicColor subtitleColor =
          CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(0, 0, 0, 0.4),
        darkColor: Color.fromRGBO(255, 255, 255, 0.4),
      );


      /* TEST 1: DARK THEME */
      await tester.pumpWidget(buildTestApp(
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        children: <Widget>[
          CupertinoMenuItem(
            subtitle: const Text('subtitle'),
            leading: const Stack(children: <Widget>[
              Icon(CupertinoIcons.left_chevron),
              Text('leading')
            ]),
            trailing: const Stack(children: <Widget>[
              Icon(CupertinoIcons.right_chevron),
              Text('trailing')
            ]),
            child: TestMenu.item0.text,
            onPressed: () {},
          ),
        ],
      ));

      controller.open();
      await tester.pumpAndSettle();

       MenuParts findParts({bool hideTrailing = false}) {
        return (
          leadingIconStyle:
              findTextStyle(tester, find.byIcon(CupertinoIcons.left_chevron)),
          trailingIconStyle:
              findTextStyle(tester, find.byIcon(CupertinoIcons.right_chevron)),
          leadingTextStyle: findTextStyle(tester, find.text('leading')),
          trailingTextStyle: findTextStyle(tester, find.text('trailing')),
          titleStyle: findTextStyle(tester, TestMenu.item0.findText),
          subtitleStyle: findTextStyle(tester, find.text('subtitle')),
        );
      }

      MenuParts parts = findParts();
      void matchDefaultStyle(TextStyle style, Finder finder) {
        expect(style.fontSize, 17);
        expect(style.fontFamily, 'SF Pro Text');
        expect(style.fontFamilyFallback, <String>['.AppleSystemUIFont']);
        expect(style.decoration, TextDecoration.none);
        expect(style.overflow, TextOverflow.ellipsis);
        expect(style.letterSpacing, -0.41);
        expect(style.fontWeight, FontWeight.normal);
        expect(style.color, isSameColorAs(titleColor.darkColor));
        expect(style.textBaseline, TextBaseline.ideographic);
        expect(style.height, 1.25);
        expect(findRichText(tester, finder)?.maxLines, 2);
      }

      expect(parts.leadingIconStyle?.fontSize, 21);
      expect(parts.leadingIconStyle?.height, 1);
      expect(
        parts.leadingIconStyle?.color,
        isSameColorAs(titleColor.darkColor),
      );
      expect(parts.trailingIconStyle?.fontSize, 21);
      expect(parts.trailingIconStyle?.height, 1);
      expect(
        parts.trailingIconStyle?.color,
        isSameColorAs(titleColor.darkColor),
      );
      matchDefaultStyle(parts.leadingTextStyle!,  find.text('leading'));
      matchDefaultStyle(parts.trailingTextStyle!, find.text('trailing'));
      matchDefaultStyle(parts.titleStyle!, TestMenu.item0.findText);
      expect(parts.subtitleStyle?.fontSize, 15);
      expect(parts.subtitleStyle?.fontFamily, 'SF Pro Text');
      expect(parts.subtitleStyle?.fontFamilyFallback,  <String>['.AppleSystemUIFont']);
      expect(parts.subtitleStyle?.decoration, TextDecoration.none);
      expect(parts.subtitleStyle?.overflow,  TextOverflow.ellipsis);
      expect(parts.subtitleStyle?.letterSpacing,  -0.21);
      expect(parts.subtitleStyle?.fontWeight,  FontWeight.normal);
      expect(parts.subtitleStyle?.foreground!.color, isSameColorAs(subtitleColor.darkColor));
      expect(parts.subtitleStyle?.textBaseline, TextBaseline.ideographic);
      expect(findRichText(tester, find.text('subtitle'))?.maxLines, 2);


      /* LIGHT THEME */
       await tester.pumpWidget(buildTestApp(
        theme: const CupertinoThemeData(brightness: Brightness.light),
        children: <Widget>[
          CupertinoMenuItem(
            subtitle: const Text('subtitle'),
            leading: const Stack(children: <Widget>[
              Icon(CupertinoIcons.left_chevron),
              Text('leading')
            ]),
            trailing: const Stack(children: <Widget>[
              Icon(CupertinoIcons.right_chevron),
              Text('trailing')
            ]),
            child: TestMenu.item0.text,
            onPressed: () {},
          ),
        ],
      ));
      await tester.pumpAndSettle();
      parts = findParts();
      expect(parts.leadingIconStyle?.color, isSameColorAs(titleColor.color));
      expect(parts.leadingTextStyle?.color, isSameColorAs(titleColor.color));
      expect(parts.trailingIconStyle?.color, isSameColorAs(titleColor.color));
      expect(parts.trailingTextStyle?.color, isSameColorAs(titleColor.color));
      expect(parts.subtitleStyle?.foreground!.color, isSameColorAs(subtitleColor.color));

      /* THEME OVERRIDE AND MEDIA QUERY */
       await tester.pumpWidget(buildTestApp(
        mediaQuery: const MediaQueryData(boldText: true, textScaler: TextScaler.linear(1.1)),
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        children: <Widget>[
          CupertinoMenuItem(
            isDefaultAction: true,
            subtitle: const Text('subtitle',
                style: TextStyle(inherit: false, color: CupertinoColors.black)),
            leading: const Stack(children: <Widget>[
              Icon(CupertinoIcons.left_chevron, color: CupertinoColors.black),
              Text(
                'leading',
                style: TextStyle(color: CupertinoColors.black),
              )
            ]),
            trailing: const Stack(children: <Widget>[
              Icon(CupertinoIcons.right_chevron, color: CupertinoColors.black),
              Text(
                'trailing',
                style: TextStyle(color: CupertinoColors.black)
              )
            ]),
            child: Text(
              TestMenu.item0.label,
              style:
                  const TextStyle(color: CupertinoColors.lightBackgroundGray),
            ),
            onPressed: () {},
          ),
        ],
      ));

      await tester.pumpAndSettle();
      parts = findParts();

      expect(parts.leadingIconStyle!.color, isSameColorAs(CupertinoColors.black));
      expect(parts.leadingIconStyle!.fontSize, 21 * math.sqrt(1.1));

      expect(parts.trailingIconStyle!.color, isSameColorAs(CupertinoColors.black));
      expect(parts.trailingIconStyle!.fontSize, 21 * math.sqrt(1.1));

      expect(parts.leadingTextStyle!.color, isSameColorAs(CupertinoColors.black));
      expect(parts.trailingTextStyle!.color, isSameColorAs(CupertinoColors.black));

      expect(parts.subtitleStyle!.color, isSameColorAs(CupertinoColors.black));
      expect(parts.subtitleStyle!.fontWeight, FontWeight.bold);

      expect(parts.titleStyle!.color, isSameColorAs(CupertinoColors.lightBackgroundGray));
      expect(parts.titleStyle!.fontWeight, FontWeight.bold);

       /* FONT SCALING > 1.25 */
      await tester.pumpWidget(buildTestApp(
        mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        children: <Widget>[
          CupertinoMenuItem(
            subtitle: const Text('subtitle'),
            leading: const Stack(children: <Widget>[
              Icon(CupertinoIcons.left_chevron),
              Text('leading')
            ]),
            trailing: const Stack(children: <Widget>[
              Icon(CupertinoIcons.right_chevron),
              Text('trailing')
            ]),
            child: TestMenu.item0.text,
            onPressed: () {},
          ),
        ],
      ));

      expect(findRichText(tester, TestMenu.item0.findText)?.maxLines, 100);
      expect(findRichText(tester, find.text('subtitle'))?.maxLines, 100);

      expect(find.text('leading'), findsOne);
      expect(find.byIcon(CupertinoIcons.left_chevron), findsOne);

      expect(find.text('trailing'), findsNothing);
      expect(find.byIcon(CupertinoIcons.right_chevron), findsNothing);
    });

    testWidgets('isDestructiveAction style', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        children: <Widget>[
          CupertinoMenuItem(
            isDestructiveAction: true,
            subtitle: const Text('subtitle'),
            leading: const Icon(
              CupertinoIcons.left_chevron,
            ),
            trailing: const Icon(
              CupertinoIcons.right_chevron,
            ),
            child: TestMenu.item0.text,
            onPressed: () {

            },
          ),
        ],
      ));

      controller.open();
      await tester.pumpAndSettle();
      expect(
        findTextStyle(tester, find.byIcon(CupertinoIcons.left_chevron))?.color,
        isSameColorAs(CupertinoColors.systemRed.darkColor),
      );
      expect(
        findTextStyle(tester, find.byIcon(CupertinoIcons.right_chevron))?.color,
        isSameColorAs(CupertinoColors.systemRed.darkColor),
      );
      expect(
        findTextStyle(tester, TestMenu.item0.findText)?.color,
        isSameColorAs(CupertinoColors.systemRed.darkColor),
      );
      expect(
        findTextStyle(tester, find.text('subtitle'))?.foreground?.color,
        isSameColorAs((CupertinoMenuItem.defaultSubtitleStyle.color! as CupertinoDynamicColor).darkColor),
      );

      // Check that destructive theming can be overidden
      await tester.pumpWidget(buildTestApp(
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        children: <Widget>[
          CupertinoMenuItem(
            isDestructiveAction: true,
            subtitle: const Text('subtitle',
              style: TextStyle(inherit: false,color: CupertinoColors.systemPurple),
            ),
            leading: const Icon(
              CupertinoIcons.left_chevron,
              color: CupertinoColors.activeBlue,
            ),
            trailing: const Icon(
              CupertinoIcons.right_chevron,
              color: CupertinoColors.activeGreen,
            ),
            child: Text(TestMenu.item0.label,
              style: const TextStyle(
                color: CupertinoColors.activeOrange,
              ),
            ),
          ),
        ],
      ));

      await tester.pumpAndSettle();
      expect(
        findTextStyle(tester, find.byIcon(CupertinoIcons.left_chevron))?.color,
        isSameColorAs(CupertinoColors.activeBlue.color),
      );
      expect(
        findTextStyle(tester, find.byIcon(CupertinoIcons.right_chevron))?.color,
        isSameColorAs(CupertinoColors.activeGreen.color),
      );
      expect(
        findTextStyle(tester, TestMenu.item0.findText)?.color,
        isSameColorAs(CupertinoColors.activeOrange.color),
      );
      expect(
        findTextStyle(tester, find.text('subtitle'))?.color,
        isSameColorAs(CupertinoColors.systemPurple.color),
      );
    });

    testWidgets('isDefaultAction style', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        children: <Widget>[
          CupertinoMenuItem(
            isDefaultAction: true,
            subtitle: const Text('subtitle'),
            leading: const Icon(
              CupertinoIcons.left_chevron,
            ),
            trailing: const Icon(
              CupertinoIcons.right_chevron,
            ),
            child: TestMenu.item0.text,
            onPressed: () {

            },
          ),
        ],
      ));

      controller.open();
      await tester.pumpAndSettle();
      expect(
        findTextStyle(tester, TestMenu.item0.findText)?.fontWeight,
        FontWeight.bold,
      );

    });

    testWidgets('close on activate', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          onClose: onClose,
          onOpen: onOpen,
          children: <Widget>[
            CupertinoMenuItem(
              onPressed: () {},
              requestCloseOnActivate: false,
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

    testWidgets('disabled items should not interact', (WidgetTester tester) async {

      // Test various interactions to ensure that disabled items do not
      // respond.
      int interactions = 0;
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
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

      // Test focus
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      // Test hover
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();

      // Test press
      await gesture.down(tester.getCenter(TestMenu.item0.findWidget));
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);

      expect(
        findTextStyle(tester, find.text(TestMenu.item0.label))?.color,
        isSameColorAs(CupertinoColors.systemGrey),
      );

      // Test pan
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();

      expect(controller.isOpen, isTrue);
      expect(TestMenu.item0.findWidget, findsOneWidget);
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(interactions, 0);
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
        findDecoratedBoxColor( tester, TestMenu.item0.findWidget),
        isSameColorAs(
          CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.05),
        ),
      );

      // Hovered button with custom hoverColor and pressedColor
      // Specified hovered color takes priority over pressed color
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pumpAndSettle();
      expect(
        findDecoratedBoxColor(tester, TestMenu.item1.findWidget),
        isSameColorAs(customHoveredColor.darkColor),
      );

      // Hovered button with custom pressedColor
      // Pressed color @ 5% opacity is used when hovered color is not specified
      await gesture.moveTo(tester.getCenter(TestMenu.item2.findWidget));
      await tester.pumpAndSettle();
      expect(
        findDecoratedBoxColor(tester, TestMenu.item2.findWidget),
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
      final FocusNode focusNode = FocusNode(debugLabel: 'TestNode ${TestMenu.item1}');
      addTearDown(focusNode.dispose);
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
                focusNode: focusNode,
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
        findDecoratedBoxColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(
          CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.075),
        ),
      );

      // Hovered button with custom hoverColor and pressedColor
      // Specified hovered color takes priority over pressed color
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pumpAndSettle();
      expect(
        findDecoratedBoxColor(tester, TestMenu.item1.findWidget),
        isSameColorAs(customFocusColor.darkColor),
      );

      // Hovered button with custom pressedColor
      // Pressed color @ 5% opacity is used when hovered color is not specified
      await gesture.moveTo(tester.getCenter(TestMenu.item2.findWidget));
      await tester.pumpAndSettle();
      expect(
        findDecoratedBoxColor(tester, TestMenu.item2.findWidget),
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
        findDecoratedBoxColor(tester, TestMenu.item2.findWidget),
        isSameColorAs(
          customPressedColor.darkColor.withOpacity(0.075),
        ),
      );
      expect(findDecoration(TestMenu.item3.findWidget), findsNothing);
      focusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(findDecoration(TestMenu.item0.findWidget), findsNothing);
      expect(
        findDecoratedBoxColor(tester, TestMenu.item1.findWidget),
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
            const CupertinoLargeMenuDivider(),
            CupertinoMenuItem(
              requestCloseOnActivate: false,
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
        find.byType(CupertinoLargeMenuDivider),
        warnIfMissed: true,
      ));
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();

      expect(
        findDecoratedBoxColor(tester , TestMenu.item0.findWidget),
        isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor),
      );
      // Pressed button with custom pressedColor
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pumpAndSettle();

      expect(
        findDecoratedBoxColor(tester , TestMenu.item1.findWidget),
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
        findDecoratedBoxColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor),
      );

      await gesture.up();
      await tester.pumpAndSettle();

      // On mouse up, should be hovered but not pressed
      expect(
        findDecoratedBoxColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(
            CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.05)),
      );
      expect(pressedCount, 1);

      await gesture
          .down(tester.getCenter(find.byType(CupertinoLargeMenuDivider)));
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();
      expect(
        findDecoratedBoxColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor),
      );

      // Wait for panActivationDelay to pass
      await tester.pump(const Duration(seconds: 1));

      expect(pressedCount, 2);
      expect(
        findDecoratedBoxColor(tester, TestMenu.item0.findWidget),
        isSameColorAs(
            CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.05)),
      );

      // Moving back over item1 should cause it to fill again
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pumpAndSettle();
      expect(
        findDecoratedBoxColor(tester, TestMenu.item1.findWidget),
        isSameColorAs(customPressedColor.darkColor),
      );
    });
    testWidgets('onPressed is called when set', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        CupertinoApp(
          home:  CupertinoMenuAnchor(
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
      );

      controller.open();
      await tester.pumpAndSettle();

      await tester.tap(TestMenu.item1.findText);
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
    testWidgets('onFocusChange is called on enabled items',
        (WidgetTester tester) async {
      final List<bool> focusChanges = <bool>[];
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              focusNode: focusNode,
              onFocusChange: focusChanges.add,
              onPressed: () {},
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              child: TestMenu.item1.text,
              onPressed: () {},
            ),
          ],
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      // true
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // false
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // true
      focusNode.requestFocus();
      await tester.pump();

      // false -- focus is excluded if the item is disabled
      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              onFocusChange: focusChanges.add,
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              child: TestMenu.item1.text,
              onPressed: () {},
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              onFocusChange: focusChanges.add,
              onPressed: () {},
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              child: TestMenu.item1.text,
              onPressed: () {},
            ),
          ],
        ),
      );
      // true
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      // Shouldn't be called -- focus is excluded once closing begins
      controller.close();
      await tester.pumpAndSettle();

      expect(focusChanges, <bool>[true, false, true, false, true,]);
    });

    testWidgets('onHover is called on enabled items', (WidgetTester tester) async {
       final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );

      await gesture.addPointer(location: Offset.zero);
      addTearDown(() => gesture.removePointer());
      final List<(TestMenu, bool)> hoverChanges = <(TestMenu, bool)>[];
      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
            CupertinoMenuItem(
              onHover: (bool value) {
                hoverChanges.add((TestMenu.item0, value));
              },
              onPressed: () {},
              child: TestMenu.item0.text,
            ),
            CupertinoMenuItem(
              child: TestMenu.item1.text,
              onHover: (bool value) {
                hoverChanges.add((TestMenu.item1, value));
              },
            ),
            CupertinoMenuItem(
              child: TestMenu.item2.text,
              onHover: (bool value) {
                hoverChanges.add((TestMenu.item2, value));
              },
              onPressed: () {},
            ),
          ],
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      // (item0, true)
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pumpAndSettle();

      // (item0, false)
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pumpAndSettle();

      // (item2, true)
      await gesture.moveTo(tester.getCenter(TestMenu.item2.findWidget));
      await tester.pumpAndSettle();

      // (item2, false)
      await gesture.moveTo(tester.getBottomRight(TestMenu.item2.findWidget) + const Offset(0, 10));
      await tester.pumpAndSettle();

      expect(hoverChanges, <(TestMenu, bool)>[
        (TestMenu.item0, true),
        (TestMenu.item0, false),
        (TestMenu.item2, true),
        (TestMenu.item2, false),
      ]);
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

      controller.open();
      await tester.pumpAndSettle();

      await tester.tap(TestMenu.item1.findText);
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
    testWidgets('HitTestBehavior can be set', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(children: <Widget>[
        CupertinoMenuItem(
          onPressed: () {},
          child: TestMenu.item0.text,
        ),
        CupertinoMenuItem(
          onPressed: () {},
          behavior: HitTestBehavior.translucent,
          child: TestMenu.item1.text,
        ),
      ]));
      controller.open();
      await tester.pumpAndSettle();

      final  GestureDetector first = find
          .descendant(
            of: TestMenu.item0.findWidget,
            matching: find.byType(GestureDetector),
          )
          .evaluate().first.widget as GestureDetector;

      // Test default
      expect(first.behavior, HitTestBehavior.opaque);

      final  GestureDetector second = find
          .descendant(
            of: TestMenu.item1.findWidget,
            matching: find.byType(GestureDetector),
          )
          .evaluate().first.widget as GestureDetector;
      // Test custom
      expect(second.behavior, HitTestBehavior.translucent);
    });
    testWidgets('HitTestBehavior can be set', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(children: <Widget>[
        CupertinoMenuItem(
          onPressed: () {},
          child: TestMenu.item0.text,
        ),
        CupertinoMenuItem(
          onPressed: () {},
          behavior: HitTestBehavior.translucent,
          child: TestMenu.item1.text,
        ),
      ]));
      controller.open();
      await tester.pumpAndSettle();

      final  GestureDetector first = find
          .descendant(
            of: TestMenu.item0.findWidget,
            matching: find.byType(GestureDetector),
          )
          .evaluate().first.widget as GestureDetector;

      // Test default
      expect(first.behavior, HitTestBehavior.opaque);

      final  GestureDetector second = find
          .descendant(
            of: TestMenu.item1.findWidget,
            matching: find.byType(GestureDetector),
          )
          .evaluate().first.widget as GestureDetector;
      // Test custom
      expect(second.behavior, HitTestBehavior.translucent);
    });
    testWidgets('panPressActivationDelay works when set', (WidgetTester tester) async {
      TestMenu? pressed;
       final TestGesture gesture = await tester.createGesture(
        pointer: 1,
      );

      await gesture.addPointer(location: Offset.zero);
      addTearDown( gesture.removePointer);
      await tester.pumpWidget(
        buildTestApp(
          children: <Widget>[
                const CupertinoLargeMenuDivider(),
                CupertinoMenuItem(
                  onPressed: () {
                    pressed ??= TestMenu.item0;
                  },
                  child: TestMenu.item0.text,
                ),
                CupertinoMenuItem(
                  panActivationDelay: const Duration(milliseconds: 300),
                  child: TestMenu.item1.text,
                ),
                CupertinoMenuItem(
                  onPressed: () {
                    pressed ??= TestMenu.item2;
                  },
                  panActivationDelay: const Duration(milliseconds: 300),
                  child: TestMenu.item2.text,
                ),
              ],
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      final Offset startPosition = tester.getCenter(find.byType(CupertinoLargeMenuDivider));
      await gesture.down(startPosition);
      await tester.pumpAndSettle();

      // Item0 does not specify panPressActivationDelay => should not activate
      await gesture.moveTo(tester.getCenter(TestMenu.item0.findWidget));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(controller.isOpen, isTrue);

      // Item1 is disabled => should not activate
      await gesture.moveTo(tester.getCenter(TestMenu.item1.findWidget));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(controller.isOpen, isTrue);

      // Item2 is enabled and has a non-zero panPressActivationDelay, so it
      // should activate
      await gesture.moveTo(tester.getCenter(TestMenu.item2.findWidget));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(controller.isOpen, isFalse);
      expect(pressed, TestMenu.item2);
    });

    testWidgets('respects closeOnActivate property',
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
                  requestCloseOnActivate: false,
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
                        builder: _buildAnchor,
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
                        builder: _buildAnchor,

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
                        builder: _buildAnchor,
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
                        builder: _buildAnchor,

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
      expect(find.byType(CupertinoMenuItem), findsNWidgets(5));

      final List<Rect> actual = collectRects<CupertinoMenuItem>();
      const List<Rect> expected = <Rect>[
        Rect.fromLTRB(8.0, 8.0, 212.0, 52.0),
        Rect.fromLTRB(8.0, 52.0, 212.0, 96.0),
        Rect.fromLTRB(8.0, 104.0, 212.0, 148.0),
        Rect.fromLTRB(8.0, 148.0, 212.0, 192.0)
      ];

      for (int i = 0; i < actual.length; i++) {
        /*DELETE*/ print('${actual[i]},');
        // expect(actual[i], rectEquals(expected[i]));
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
                menuChildren: createTestMenus2(onPressed: onPressed),
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
                    builder: _buildAnchor,
                  ),
                ),
              );
            },
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
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Align(
                  alignment: Alignment.topRight,
                  child: CupertinoMenuAnchor(
                    builder: _buildAnchor,
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
        MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              return  Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: const Alignment(0.5, 0.5),
                  child: CupertinoMenuAnchor(
                    builder: _buildAnchor,

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


class _DebugCupertinoMenuEntryMixin extends StatefulWidget with CupertinoMenuEntryMixin {
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

  bool _shouldApplyLeading(BuildContext context){
    return super.shouldApplyLeading(context);
  }

  void _closeMenu(BuildContext context){
     super.closeMenu(context);
  }
  MenuStatus? _getMenuStatus(BuildContext context){
    return super.getMenuStatus(context);
  }

  @override
  State<_DebugCupertinoMenuEntryMixin> createState() => _DebugCupertinoMenuEntryMixinState();
}

class _DebugCupertinoMenuEntryMixinState extends State<_DebugCupertinoMenuEntryMixin> {
  bool shouldApplyLeading(){
    return widget._shouldApplyLeading(context);
  }

  void closeMenu(){
    return widget._closeMenu(context);
  }

  MenuStatus? getMenuStatus(){
    return widget._getMenuStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}