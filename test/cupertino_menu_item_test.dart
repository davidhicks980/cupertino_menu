// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_menu/menu.dart';
import 'package:cupertino_menu/menu_item.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoApp,
        CupertinoDynamicColor,
        CupertinoIcons,
        CupertinoPageScaffold,
        CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

class MenuItemTestDescription {
  MenuItemTestDescription({
    required this.tileRect,
    required this.titleRect,
    this.subtitleRect,
    this.leadingRect,
    this.trailingRect,
  });

  final Rect tileRect;
  final Rect? titleRect;
  final Rect? subtitleRect;
  final Offset? leadingRect;
  final Rect? trailingRect;
}

class PointerHighlightTester<T> {
  PointerHighlightTester(
    this.tester,
    this.menu,
  );

  final SampleNestedMenu<T> menu;
  final WidgetTester tester;
  TestGesture? _gesture;

  Future<void> _runLayerTest({
    required Finder startFinder,
    required Finder endFinder,
    required Finder itemFinder,
    required Color highlightColor,
  }) async {
    final Offset startCenter = tester.getCenter(startFinder);
    final Offset endCenter = tester.getCenter(endFinder);
    final Rect itemRect = tester.getRect(itemFinder).deflate(1);
    final Finder finder = find.descendant(
      of: itemFinder,
      matching: find.byType(ColoredBox),
    );

    expect(finder, findsOneWidget);
    await _gesture!.moveTo(startCenter);
    await tester.pumpAndSettle();
    expect(tester.widget<ColoredBox>(finder).color, const Color(0x00000000));

    await _gesture!.moveTo(itemRect.topLeft);
    await tester.pumpAndSettle();
    expect(tester.widget<ColoredBox>(finder).color, highlightColor);

    await _gesture!.moveTo(itemRect.bottomRight);
    await tester.pumpAndSettle();
    expect(tester.widget<ColoredBox>(finder).color, highlightColor);

    await _gesture!.moveTo(endCenter);
    await tester.pumpAndSettle();
    expect(tester.widget<ColoredBox>(finder).color, const Color(0x00000000));
  }


  Future<void> testMoveOverItem({
    required Color highlightColor,
    required CupertinoMenuEntry<T> item,
    bool pointerDown = false,
    List<CupertinoMenuEntry<T>>? siblings,
    Color emptyColor = const Color(0x00000000),
  }) async {
    if (_gesture == null) {
      _gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );
      await _gesture!.addPointer(location: Offset.zero);
      addTearDown(() => _gesture!.removePointer());
    }

    const ValueKey<String> startKey = ValueKey<String>('Start');
    const ValueKey<String> endKey = ValueKey<String>('End');
    final SampleNestedMenu<T> nestedMenu = menu;
    await tester.pumpWidget(
       nestedMenu.buildListApp(
              <CupertinoMenuEntry<T>>[
            CupertinoMenuItem<T>(key: startKey, child: const Text('Start')),
            item,
            ...siblings ?? <CupertinoMenuEntry<T>>[],
            CupertinoMenuItem<T>(key: endKey, child: const Text('End')),
          ],
      ),
    );
    nestedMenu.root.control.open();
    await tester.pumpAndSettle();

    if (pointerDown) {
      await _gesture!.down(tester.getCenter(find.byKey(startKey)));
    }

    await _runLayerTest(
      startFinder: find.byKey(startKey),
      endFinder: find.byKey(endKey),
      itemFinder: find.byWidget(item),
      highlightColor: highlightColor,
    );


    for(final NestedControlDef menu in <NestedControlDef>[nestedMenu.sub_2, nestedMenu.sub_2_2]){
      await _gesture!.moveTo(tester.getCenter(find.byKey(menu.bottomAnchor)));
      if (!pointerDown) {
        // Pointer is not down. Tap to open the nested menu.
        await tester.tap(find.byKey(menu.bottomAnchor));
      }

      await tester.pumpAndSettle(
        CupertinoNestedMenuItemAnchor.panPressActivationDelay +
            const Duration(
              milliseconds: 50,
            ),
      );

      // Check to see if the nested menu is open
      expect(menu.control.isOpen, true);
      await _runLayerTest(
        startFinder: menu.findLayerMember(find.byKey(startKey)),
        endFinder: menu.findLayerMember(find.byKey(endKey)),
        itemFinder: menu.findLayerMember(find.byWidget(item)),
        highlightColor: highlightColor,
      );
    }

    for(final NestedControlDef menu in <NestedControlDef>[nestedMenu.sub_2_2, nestedMenu.sub_2]){
      await _gesture!.moveTo(tester.getCenter(find.byKey(menu.topAnchor)));
      if (!pointerDown) {
       // Pointer is not down. Tap to open the nested menu.
        await tester.tap(find.byKey(menu.topAnchor));
      }

      await tester.pumpAndSettle(
        CupertinoNestedMenuItemAnchor.panPressActivationDelay +
            const Duration(milliseconds: 50),
      );

      // Check to see if the nested menu is open
      expect(menu.control.isOpen, false);
    }

    await _runLayerTest(
      startFinder: find.byKey(startKey),
      endFinder: find.byKey(endKey),
      itemFinder: find.byWidget(item),
      highlightColor: highlightColor,
    );


    if (pointerDown) {
      await _gesture!.up();
    }

    nestedMenu.control.close();
    await tester.pumpAndSettle();
    menu.next();
  }
}

void main() {
  Future<void> measureTest(
    WidgetTester tester,
    MenuItemTestDescription description,
    Finder itemFinder,
    Finder titleFinder,
    Widget child,
    VoidCallback open, {
    Finder? subtitleFinder,
    Finder? leadingFinder,
    Finder? trailingFinder,
  }) async {
    final ValueNotifier<MediaQueryData?> mediaQuery =
        ValueNotifier<MediaQueryData?>(null);
    await tester.pumpWidget(
      buildApp(
        (BuildContext context) => ValueListenableBuilder<MediaQueryData?>(
          valueListenable: mediaQuery,
          builder:
              (BuildContext context, MediaQueryData? snapshot, Widget? child) {
            return MediaQuery(
              data: snapshot ?? MediaQuery.of(context),
              child: child!,
            );
          },
          child: Builder(
            builder: (BuildContext context) {
              return child;
            },
          ),
        ),
      ),
    );
    open();
    await tester.pumpAndSettle();
    Rect? menuRect;
    Rect? tileRect;
    Rect? titleRect;
    Rect? trailingRect;
    Rect? leadingRect;
    Rect? subtitleRect;

    menuRect = tester.getRect(
        find.byKey(const ValueKey<String>('CupertinoRootMenuContainer')));
    tileRect = tester.getRect(itemFinder).shift(-menuRect.topLeft);
    titleRect = tester.getRect(titleFinder).shift(-menuRect.topLeft);
    if (description.trailingRect != null) {
      trailingRect = tester.getRect(trailingFinder!).shift(-menuRect.topLeft);
    }

    if (description.leadingRect != null) {
      leadingRect = tester.getRect(leadingFinder!).shift(-menuRect.topLeft);
    }

    if (description.subtitleRect != null) {
      subtitleRect = tester.getRect(subtitleFinder!).shift(-menuRect.topLeft);
    }

    expect(menuRect.size, tileRect.size);
    expect(tileRect.toString(), description.tileRect.toString());
    expect(titleRect.toString(), description.titleRect.toString());
    if (subtitleRect != null) {
      expect(subtitleRect.toString(), description.subtitleRect.toString());
    }
    if (leadingRect != null) {
      expect(leadingRect.toString(), description.leadingRect.toString());
    }
    if (trailingRect != null) {
      expect(trailingRect.toString(), description.trailingRect.toString());
    }
    final TestGesture testGesture = await tester.startGesture(
        tileRect.topLeft + const Offset(1.0, 1.0),
        kind: PointerDeviceKind.mouse);
  }

  Icon leadingStyleTest(WidgetTester tester) {
    final Finder finder = find.descendant(
      of: find.byType(CupertinoMenuItem),
      matching: find.byIcon(CupertinoIcons.check_mark),
    );
    expect(finder, findsOneWidget);
    final Icon icon = tester.widget(finder);
    return icon;
  }

  Icon trailingStyleTest(WidgetTester tester) {
    final Finder finder = find.descendant(
      of: find.byType(CupertinoMenuItem),
      matching: find.byType(Icon),
    );
    expect(finder, findsOneWidget);
    final Icon icon = tester.widget(finder);
    return icon;
  }

  T getDescendent<T extends Type>(
      WidgetTester tester, Type parent, Type child) {
    final Finder finder = find.descendant(
      of: find.byType(parent),
      matching: find.byType(child),
    );
    expect(finder, findsOneWidget);
    return tester.widget(finder) as T;
  }

  // Test the CupertinoMenuItem widget.
  testWidgets('CupertinoMenuItem control test', (WidgetTester tester) async {
    final SampleMenu<String> menu = SampleMenu<String>(withController: true);

    final MenuItemTestDescription description = MenuItemTestDescription(
      tileRect: const Rect.fromLTRB(0.0, 0.0, 250.0, 45.0),
      titleRect: const Rect.fromLTRB(16.0, 14.0, 206.0, 31.0),
      trailingRect: const Rect.fromLTRB(220.6, 12.0, 241.6, 33.0),
    );
    final ValueNotifier<MediaQueryData?> mediaQuery =
        ValueNotifier<MediaQueryData?>(null);

    await tester.pumpWidget(
      buildApp(
        (BuildContext context) => ValueListenableBuilder<MediaQueryData?>(
          valueListenable: mediaQuery,
          builder:
              (BuildContext context, MediaQueryData? snapshot, Widget? child) {
            return MediaQuery(
              data: snapshot ?? MediaQuery.of(context),
              child: child!,
            );
          },
          child: Builder(
            builder: (BuildContext context) {
              return menu.buildSimple(
                context,
                <CupertinoMenuEntry<void>>[
                  CupertinoMenuItem<String>(
                    trailing: const Icon(CupertinoIcons.add),
                    child: Text(menu.root.itemText),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    menu.root.control.open();
    await tester.pumpAndSettle();
    measureTest(
      tester,
      description,
      find.byType(CupertinoMenuItem<String>),
      find.text(menu.root.itemText),
      CupertinoMenuItem(
        trailing: const Icon(CupertinoIcons.add),
        child: Text(menu.root.itemText),
      ),
      menu.root.control.open,
      trailingFinder: find.byIcon(
        CupertinoIcons.add,
      ),
    );
  });
}

// void main() {
//   // Constants taken from _ContextMenuActionState.
//   const CupertinoDynamicColor kBackgroundColor =
//       CupertinoDynamicColor.withBrightness(
//     color: Color(0xFFF1F1F1),
//     darkColor: Color(0xFF212122),
//   );
//   const CupertinoDynamicColor kBackgroundColorPressed =
//       CupertinoDynamicColor.withBrightness(
//     color: Color(0xFFDDDDDD),
//     darkColor: Color(0xFF3F3F40),
//   );
//   const Color kDestructiveActionColor = CupertinoColors.destructiveRed;
//   const FontWeight kDefaultActionWeight = FontWeight.w600;

//   // Widget getApp({
//   //   Brightness? brightness,
//   // }) {
//   //   final UniqueKey actionKey = UniqueKey();
//   //   final CupertinoContextMenuAction action = CupertinoContextMenuAction(
//   //     key: actionKey,
//   //     onPressed: onPressed,
//   //     trailingIcon: CupertinoIcons.home,
//   //     isDestructiveAction: isDestructiveAction,
//   //     isDefaultAction: isDefaultAction,
//   //     child: const Text('I am a CupertinoContextMenuAction'),
//   //   );

//   //   return CupertinoApp(
//   //     theme: CupertinoThemeData(
//   //       brightness: brightness ?? Brightness.light,
//   //     ),
//   //     home: CupertinoPageScaffold(
//   //       child: Center(
//   //         child: action,
//   //       ),
//   //     ),
//   //   );
//   // }

//   TextStyle getTextStyle(WidgetTester tester) {
//     final Finder finder = find.descendant(
//       of: find.byType(CupertinoMenuItem),
//       matching: find.byType(DefaultTextStyle),
//     );
//     expect(finder, findsOneWidget);
//     final DefaultTextStyle defaultStyle = tester.widget(finder);
//     return defaultStyle.style;
//   }

//   testWidgets('responds to taps', (WidgetTester tester) async {
//     bool wasPressed = false;
//     await tester.pumpWidget(getApp(onPressed: () {
//       wasPressed = true;
//     }));

//     expect(wasPressed, false);
//     await tester.tap(find.byType(CupertinoMenuItem));
//     expect(wasPressed, true);
//   });

//   testWidgets('turns grey when pressed and held', (WidgetTester tester) async {
//     await tester.pumpWidget(getApp());
//     expect(find.byType(CupertinoMenuItem),
//         paints..rect(color: kBackgroundColor.color));

//     final Offset actionCenterLight =
//         tester.getCenter(find.byType(CupertinoMenuItem));
//     final TestGesture gestureLight =
//         await tester.startGesture(actionCenterLight);
//     await tester.pump();
//     expect(find.byType(CupertinoMenuItem),
//         paints..rect(color: kBackgroundColorPressed.color));

//     await gestureLight.up();
//     await tester.pump();
//     expect(find.byType(CupertinoMenuItem),
//         paints..rect(color: kBackgroundColor.color));

//     await tester.pumpWidget(getApp(brightness: Brightness.dark));
//     expect(find.byType(CupertinoMenuItem),
//         paints..rect(color: kBackgroundColor.darkColor));

//     final Offset actionCenterDark =
//         tester.getCenter(find.byType(CupertinoMenuItem));
//     final TestGesture gestureDark = await tester.startGesture(actionCenterDark);
//     await tester.pump();
//     expect(find.byType(CupertinoMenuItem),
//         paints..rect(color: kBackgroundColorPressed.darkColor));

//     await gestureDark.up();
//     await tester.pump();
//     expect(find.byType(CupertinoMenuItem),
//         paints..rect(color: kBackgroundColor.darkColor));
//   });

//   testWidgets('icon and textStyle colors have correct defaults',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(getApp());
//     expect(getTextStyle(tester), CupertinoInteractiveMenuItem.defaultTextStyle);
//     expect(getLeading(tester).color, CupertinoInteractiveMenuItem.defaultTextColor);
//   });

//   testWidgets('icon and textStyle colors are correct for destructive actions',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(getApp(isDestructiveAction: true));
//     expect(getTextStyle(tester).color, kDestructiveActionColor);
//     expect(getLeading(tester).color, kDestructiveActionColor);
//   });

//   testWidgets('textStyle is correct for defaultAction',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(getApp(isDefaultAction: true));
//     expect(getTextStyle(tester).fontWeight, kDefaultActionWeight);
//   });

  testWidgets(
      'CupertinoCheckedMenuItem -> pan -> makes cursor clickable on Web',
      (WidgetTester tester) async {
    final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);
    await tester.pumpWidget(
      menu.buildItemApp(
        CupertinoCheckedMenuItem<String>(
          enabled: false,
          child: Text(menu.root.itemText),
        ),
      ),
    );

    menu.control.open();
    await tester.pumpAndSettle();

    final Offset menuItemCenter =
        tester.getCenter(find.text(menu.root.itemText));
    final TestGesture gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse, pointer: 1);
    await gesture.addPointer(location: menuItemCenter);
    await tester.pumpAndSettle();
    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.basic,
    );

    // / Cupertino context menu action with "onPressed" callback.
    await tester.pumpWidget(
      menu.buildItemApp(
        CupertinoCheckedMenuItem<String>(
          child: Text(menu.root.itemText),
        ),
      ),
    );
    menu.control.open();
    await gesture.moveTo(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.basic);

    await gesture.moveTo(menuItemCenter);
    await tester.pumpAndSettle();
    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      kIsWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
    );
  });

  group('Hover items =>', () {
    const Color testColor = Color(0xffff0000);
    testWidgets('When enabled, CupertinoCheckedMenuItem highlights on hover',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);

      final PointerHighlightTester<String> highlightTester =
          PointerHighlightTester<String>(tester, menu);

      await highlightTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoCheckedMenuItem<String>(
          enabled: false,
          child: Text(menu.root.itemText),
        ),
      );

      await highlightTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress.withOpacity(0.05),
        item: CupertinoCheckedMenuItem<String>(
          child: Text(menu.root.itemText),
        ),
      );

      await highlightTester.testMoveOverItem(
        highlightColor: testColor.withOpacity(0.05),
        item: CupertinoCheckedMenuItem<String>(
          pressedColor: testColor,
          child: Text(menu.root.itemText),
        ),
      );
    });

    testWidgets('When enabled, CupertinoMenuItem highlights on hover',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);
      final PointerHighlightTester<String> pointerTester =
          PointerHighlightTester<String>(tester, menu);

      await pointerTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoMenuItem<String>(
          enabled: false,
          child: Text(menu.root.itemText),
        ),
      );
      await pointerTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress.withOpacity(0.05),
        item: CupertinoMenuItem<String>(
          child: Text(menu.root.itemText),
        ),
      );
      await pointerTester.testMoveOverItem(
        highlightColor: testColor.withOpacity(0.05),
        item: CupertinoMenuItem<String>(
          pressedColor: testColor,
          child: Text(menu.root.itemText),
        ),
      );
    });
    testWidgets('When enabled, CupertinoMenuActionItem highlights on hover',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);
      final PointerHighlightTester<String> pointerTester =
          PointerHighlightTester<String>(tester, menu);

      final List<CupertinoMenuEntry<String>> siblings =
          <CupertinoMenuEntry<String>>[
        CupertinoMenuActionItem<String>(
          enabled: false,
          icon: const Icon(CupertinoIcons.multiply),
          child: Text('${menu.root.itemText}_2'),
        ),
        CupertinoMenuActionItem<String>(
          icon: const Icon(CupertinoIcons.minus),
          child: Text('${menu.root.itemText}_3'),
        ),
      ];
      await pointerTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoMenuActionItem<String>(
          enabled: false,
          icon: const Icon(CupertinoIcons.add),
          child: Text(menu.root.itemText),
        ),
        siblings: siblings,
      );

      await pointerTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress.withOpacity(0.05),
        item: CupertinoMenuActionItem<String>(
          icon: const Icon(CupertinoIcons.add),
          child: Text(menu.root.itemText),
        ),
        siblings: siblings,
      );
      await pointerTester.testMoveOverItem(
        highlightColor: testColor.withOpacity(0.05),
        item: CupertinoMenuActionItem<String>(
          pressedColor: testColor,
          icon: const Icon(CupertinoIcons.add),
          child: Text(menu.root.itemText),
        ),
        siblings: siblings,
      );
    });
    testWidgets('When enabled, CupertinoBaseMenuItem highlights on hover',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);
      final PointerHighlightTester<String> pointerTester =
          PointerHighlightTester<String>(tester, menu);

      await pointerTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoMenuItem<String>(
          enabled: false,
          child: Text(menu.root.itemText),
        ),
      );
      await pointerTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress.withOpacity(0.05),
        item: CupertinoMenuItem<String>(
          child: Text(menu.root.itemText),
        ),
      );
      await pointerTester.testMoveOverItem(
        highlightColor: testColor.withOpacity(0.05),
        item: CupertinoMenuItem<String>(
          pressedColor: testColor,
          child: Text(menu.root.itemText),
        ),
      );
    });
    testWidgets(
        'When enabled, CupertinoNestedMenuItemAnchor highlights on hover',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);
      final PointerHighlightTester<String> pointerTester =
          PointerHighlightTester<String>(tester, menu);

      await pointerTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoNestedMenu<String>(
            enabled: false,
            title: TextSpan(text: menu.root.itemText),
            itemBuilder: (BuildContext context) {
              return <CupertinoMenuEntry<String>>[];
            }),
      );
      await pointerTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress.withOpacity(0.05),
        item: CupertinoNestedMenu<String>(
            title: TextSpan(text: menu.root.itemText),
            itemBuilder: (BuildContext context) {
              return <CupertinoMenuEntry<String>>[];
            }),
      );
      await pointerTester.testMoveOverItem(
        highlightColor: testColor.withOpacity(0.05),
        item: CupertinoNestedMenu<String>(
            pressedColor: testColor,
            title: TextSpan(text: menu.root.itemText),
            itemBuilder: (BuildContext context) {
              return <CupertinoMenuEntry<String>>[];
            }),
      );
    });
  });

  /* PAN ITEMS */
  group('Pan items => ', () {
    const Color testColor = Color(0xffff0000);
    testWidgets('Pan highlight: CupertinoCheckedMenuItem highlights on pan',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);

      final PointerHighlightTester<String> highlightTester =
          PointerHighlightTester<String>(tester, menu);

      await highlightTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoCheckedMenuItem<String>(
          enabled: false,
          child: Text(menu.root.itemText),
        ),
        pointerDown: true,
      );

      await highlightTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress,
        item: CupertinoCheckedMenuItem<String>(
          child: Text(menu.root.itemText),
        ),
        pointerDown: true,
      );

      await highlightTester.testMoveOverItem(
        highlightColor: testColor,
        item: CupertinoCheckedMenuItem<String>(
          pressedColor: testColor,
          child: Text(menu.root.itemText),
        ),
        pointerDown: true,
      );
    });

    testWidgets('Pan highlight: CupertinoMenuItem',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);
      final PointerHighlightTester<String> pointerTester =
          PointerHighlightTester<String>(tester, menu);

      await pointerTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoMenuItem<String>(
          enabled: false,
          child: Text(menu.root.itemText),
        ),
        pointerDown: true,
      );
      await pointerTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress,
        item: CupertinoMenuItem<String>(
          child: Text(menu.root.itemText),
        ),
        pointerDown: true,
      );
      await pointerTester.testMoveOverItem(
        highlightColor: testColor,
        item: CupertinoMenuItem<String>(
          pressedColor: testColor,
          child: Text(menu.root.itemText),
        ),
        pointerDown: true,
      );
    });
    testWidgets('Pan highlight: CupertinoMenuActionItem',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);
      final PointerHighlightTester<String> pointerTester =
          PointerHighlightTester<String>(tester, menu);

      final List<CupertinoMenuEntry<String>> siblings =
          <CupertinoMenuEntry<String>>[
        CupertinoMenuActionItem<String>(
          enabled: false,
          icon: const Icon(CupertinoIcons.multiply),
          child: Text('${menu.root.itemText}_2'),
        ),
        CupertinoMenuActionItem<String>(
          icon: const Icon(CupertinoIcons.minus),
          child: Text('${menu.root.itemText}_3'),
        ),
      ];
      await pointerTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoMenuActionItem<String>(
          enabled: false,
          icon: const Icon(CupertinoIcons.add),
          child: Text(menu.root.itemText),
        ),
        siblings: siblings,
        pointerDown: true,
      );

      await pointerTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress,
        item: CupertinoMenuActionItem<String>(
          icon: const Icon(CupertinoIcons.add),
          child: Text(menu.root.itemText),
        ),
        siblings: siblings,
        pointerDown: true,
      );
      await pointerTester.testMoveOverItem(
        highlightColor: testColor,
        item: CupertinoMenuActionItem<String>(
          pressedColor: testColor,
          icon: const Icon(CupertinoIcons.add),
          child: Text(menu.root.itemText),
        ),
        siblings: siblings,
        pointerDown: true,
      );
    });
    testWidgets('Pan highlight: CupertinoBaseMenuItem',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);
      final PointerHighlightTester<String> pointerTester =
          PointerHighlightTester<String>(tester, menu);

      await pointerTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoMenuItem<String>(
          enabled: false,
          child: Text(menu.root.itemText),
        ),
        pointerDown: true,
      );
      await pointerTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress,
        item: CupertinoMenuItem<String>(
          child: Text(menu.root.itemText),
        ),
        pointerDown: true,
      );
      await pointerTester.testMoveOverItem(
        highlightColor: testColor,
        item: CupertinoMenuItem<String>(
          pressedColor: testColor,
          child: Text(menu.root.itemText),
        ),
        pointerDown: true,
      );
    });

    testWidgets(
        'Pan highlight: CupertinoNestedMenuItemAnchor',
        (WidgetTester tester) async {
      final SampleNestedMenu<String> menu = SampleNestedMenu<String>(withController: true);
      final PointerHighlightTester<String> pointerTester =
          PointerHighlightTester<String>(tester, menu);

      await pointerTester.testMoveOverItem(
        highlightColor: const Color(0x00000000),
        item: CupertinoNestedMenu<String>(
            enabled: false,
            title: TextSpan(text: menu.root.itemText),
            itemBuilder: (BuildContext context) {
              return <CupertinoMenuEntry<String>>[];
            }),
        pointerDown: true,
      );

      await pointerTester.testMoveOverItem(
        highlightColor: CupertinoMenuEntry.backgroundOnPress,
        item: CupertinoNestedMenu<String>(
            title: TextSpan(text: menu.root.itemText),
            itemBuilder: (BuildContext context) {
              return <CupertinoMenuEntry<String>>[];
            }),
        pointerDown: true,
      );

      await pointerTester.testMoveOverItem(
        highlightColor: testColor,
        item: CupertinoNestedMenu<String>(
            pressedColor: testColor,
            title: TextSpan(text: menu.root.itemText),
            itemBuilder: (BuildContext context) {
              return <CupertinoMenuEntry<String>>[];
            }),
        pointerDown: true,
      );
    });
  });

