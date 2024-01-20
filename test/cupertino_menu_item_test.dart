// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'package:cupertino_menu/menu.dart';
// import 'package:cupertino_menu/menu_item.dart';
import 'package:example/menu_item.dart';
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


class MenuItemDimensions {
  MenuItemDimensions({
    required this.tileRect,
    required this.titleRect,
    required this.scale,
    this.titleRectWithLeadingAndTrailing,
    this.subtitleRect,
    this.subtitleRectWithLeadingAndTrailing,
    this.titleRectWithLeading,
    this.titleRectWithTrailing,
    this.leadingRect,
    this.trailingRect,
    this.small = false,
  });

  final Rect tileRect;
  final Rect? titleRect;
  final Rect? titleRectWithLeading;
  final Rect? titleRectWithTrailing;
  final Rect? titleRectWithLeadingAndTrailing;
  final Rect? subtitleRect;
  final Rect? subtitleRectWithLeadingAndTrailing;
  final Rect? leadingRect;
  final Rect? trailingRect;
  final bool small;
  final int scale;

  @override
  String toString() {
    return '''
      MenuItemDimensions(
        tileRect: $tileRect,
        leadingRect: $leadingRect,
        trailingRect: $trailingRect,
        titleRect: $titleRect,
        titleRectWithLeading: $titleRectWithLeading,
        titleRectWithTrailing: $titleRectWithTrailing,
        titleRectWithLeadingAndTrailing: $titleRectWithLeadingAndTrailing
        subtitleRectWithLeadingAndTrailing: $subtitleRectWithLeadingAndTrailing,
        subtitleRect: $subtitleRect,
        scale: $scale,
      )
    ''';
  }
}

class MenuItemDimensionSet {
  MenuItemDimensionSet(
      {required this.regular,
      required this.truncatedText,
      required this.doubleTextSize,
      required this.builder});

  final MenuItemDimensions regular;
  final MenuItemDimensions truncatedText;
  final MenuItemDimensions doubleTextSize;

  final CupertinoMenuEntry<dynamic> Function(MenuItemWidgetSet variant,
      {required bool truncated}) builder;

  Map<MenuItemDisplaySet, MenuItemDimensions> get all =>
      <MenuItemDisplaySet, MenuItemDimensions>{
        MenuItemDisplaySet.regular: regular,
        MenuItemDisplaySet.truncated: truncatedText,
        MenuItemDisplaySet.doubleTextSize: doubleTextSize
      };

  @override
  String toString() {
    return all.toString();
  }
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
    required Widget item,
    bool pointerDown = false,
    List<Widget>? siblings,
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
        <Widget>[
          CupertinoMenuItem<T>(key: startKey, child: const Text('Start')),
          item,
          ...siblings ?? <Widget>[],
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

    for (final NestedControlDef menu in <NestedControlDef>[
      nestedMenu.sub_2,
      nestedMenu.sub_2_2
    ]) {
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

    for (final NestedControlDef menu in <NestedControlDef>[
      nestedMenu.sub_2_2,
      nestedMenu.sub_2
    ]) {
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

enum MenuItemWidgetSet {
  onlyTitle,
  showLeading,
  showTrailing,
  showSubtitle,
  showLeadingAndTrailingAndSubtitle,
}

enum MenuItemDisplaySet { regular, truncated, doubleTextSize }

void main() {
  Future<void> measureTest<T>(
    WidgetTester tester,
    MenuItemDimensionSet dimensionSet,
    SampleMenu menu, {
    required Finder titleFinder,
    Finder? leadingFinder,
    Finder? subtitleFinder,
    Finder? trailingFinder,
    List<Widget>? siblings,
  }) async {
    MenuItemDimensions? regular;
    MenuItemDimensions? truncatedText;
    MenuItemDimensions? doubleTextSize;
    for (final MapEntry<MenuItemDisplaySet, MenuItemDimensions> entry
        in dimensionSet.all.entries) {
      Rect? menuRect;
      Rect? tileRect;
      Rect? titleRect;
      Rect? trailingRect;
      Rect? leadingRect;
      Rect? subtitleRect;
      Rect? titleRectWithLeading;
      Rect? titleRectWithTrailing;
      Rect? titleRectWithLeadingAndTrailing;
      Rect? subtitleRectWithLeadingAndTrailing;
      for (final MenuItemWidgetSet variant in MenuItemWidgetSet.values) {
        final CupertinoMenuEntry<T> child = dimensionSet.builder(
          variant,
          truncated: entry.key == MenuItemDisplaySet.truncated,
        ) as CupertinoMenuEntry;
        await tester.pumpWidget(buildApp((BuildContext context) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                entry.key == MenuItemDisplaySet.doubleTextSize ? 2 : 1,
              ),
            ),
            child: menu.buildList(
<Widget>[child, ...?siblings],
            ),
          );
        }));
        menu.overlay.open();
        await tester.pumpAndSettle();

        menuRect = tester
            .getRect(find.byKey(const ValueKey<String>('_MenuContainer_0')));
        tileRect = tester.getRect(find.byWidget(child)).shift(-menuRect.topLeft);

        switch (variant) {
          case MenuItemWidgetSet.onlyTitle:
            titleRect = tester.getRect(titleFinder).shift(-menuRect.topLeft);
          case MenuItemWidgetSet.showLeading:
            if (leadingFinder != null) {
              titleRectWithLeading = tester.getRect(titleFinder).shift(-menuRect.topLeft);
              leadingRect = tester.getRect(leadingFinder).shift(-menuRect.topLeft);
            }
          case MenuItemWidgetSet.showTrailing:
            if (trailingFinder != null &&
                entry.key != MenuItemDisplaySet.doubleTextSize) {
              titleRectWithTrailing = tester.getRect(titleFinder).shift(-menuRect.topLeft);
              trailingRect = tester.getRect(trailingFinder).shift(-menuRect.topLeft);
            }

          case MenuItemWidgetSet.showSubtitle:
            if (subtitleFinder != null) {
              subtitleRect = tester.getRect(subtitleFinder).shift(-menuRect.topLeft);
            }
          case MenuItemWidgetSet.showLeadingAndTrailingAndSubtitle:
            if (leadingFinder != null &&
                trailingFinder != null &&
                subtitleFinder != null) {
              titleRectWithLeadingAndTrailing = tester.getRect(titleFinder).shift(-menuRect.topLeft);
              subtitleRectWithLeadingAndTrailing =
                  tester.getRect(subtitleFinder).shift(-menuRect.topLeft);
            }
        }

        expect(menuRect.size.width, tileRect.size.width);

        expect('$tileRect', '${entry.value.tileRect}');
        expect('$titleRect', '${entry.value.titleRect}');
        if (subtitleRect != null) {
          expect('$subtitleRect', '${entry.value.subtitleRect}');
        }
        if (leadingRect != null) {
          expect('$leadingRect', '${entry.value.leadingRect}');
        }
        if (trailingRect != null) {
          expect('$trailingRect', '${entry.value.trailingRect}');
        }
        if (titleRectWithLeading != null) {
          expect('$titleRectWithLeading', '${entry.value.titleRectWithLeading}');
        }
        if (titleRectWithTrailing != null) {
          expect('$titleRectWithTrailing','${entry.value.titleRectWithTrailing}');
        }
        if (titleRectWithLeadingAndTrailing != null) {
          expect('$titleRectWithLeadingAndTrailing',
              '${entry.value.titleRectWithLeadingAndTrailing}');
        }
        if (subtitleRectWithLeadingAndTrailing != null) {
          expect('$subtitleRectWithLeadingAndTrailing',
              '${entry.value.subtitleRectWithLeadingAndTrailing}');
        }

        menu.control.close();
        await tester.pumpAndSettle();
      }

      final MenuItemDimensions value = MenuItemDimensions(
        tileRect: tileRect!,
        titleRect: titleRect,
        subtitleRect: subtitleRect,
        trailingRect: trailingRect,
        leadingRect: leadingRect,
        titleRectWithLeading: titleRectWithLeading,
        titleRectWithTrailing: titleRectWithTrailing,
        titleRectWithLeadingAndTrailing:
            titleRectWithLeadingAndTrailing,
        subtitleRectWithLeadingAndTrailing:
            subtitleRectWithLeadingAndTrailing,
        scale: entry.value.scale,
      );

      switch (entry.key) {
        case MenuItemDisplaySet.regular:
          regular = value;
        case MenuItemDisplaySet.truncated:
          truncatedText = value;
        case MenuItemDisplaySet.doubleTextSize:
          doubleTextSize = value;
      }
    }
    tester.printToConsole('${MenuItemDimensionSet(
      regular: regular!,
      truncatedText: truncatedText!,
      doubleTextSize: doubleTextSize!,
      builder: dimensionSet.builder,
    )}, ');
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

  const Icon leading = Icon(CupertinoIcons.check_mark);
  const Icon trailing = Icon(CupertinoIcons.add);
  const String title = 'Title';
  const String subtitle = 'Subtitle';

  const String largeTitle = 'Title Title Title Title Title Title Title '
      'Title Title Title Title Title Title Title Title Title Title Title';
  const String largeSubtitle = 'Subtitle Subtitle Subtitle Subtitle Subtitle '
      'Subtitle Subtitle Subtitle Subtitle Subtitle Subtitle Subtitle';
  const ValueKey<String> titleKey = ValueKey<String>('title');
  const ValueKey<String> subtitleKey = ValueKey<String>('subtitle');

  final MenuItemDimensionSet baseMenuItem = MenuItemDimensionSet(
        regular: MenuItemDimensions(
          tileRect: const Rect.fromLTRB(0.0, 0.0, 250.0, 58.0),
          leadingRect: const Rect.fromLTRB(6.4, 18.5, 27.4, 39.5),
          trailingRect: const Rect.fromLTRB(220.6, 18.5, 241.6, 39.5),
          titleRect: const Rect.fromLTRB(32.0, 12.0, 115.9, 29.0),
          titleRectWithLeading: const Rect.fromLTRB(32.0, 12.0, 115.9, 29.0),
          titleRectWithTrailing: const Rect.fromLTRB(32.0, 12.0, 115.9, 29.0),
          titleRectWithLeadingAndTrailing:
              const Rect.fromLTRB(32.0, 12.0, 115.9, 29.0),
          subtitleRectWithLeadingAndTrailing:
              const Rect.fromLTRB(32.0, 29.0, 166.3, 46.0),
          subtitleRect: const Rect.fromLTRB(32.0, 29.0, 166.3, 46.0),
          scale: 1,
        ),
        truncatedText: MenuItemDimensions(
          tileRect: const Rect.fromLTRB(0.0, 0.0, 250.0, 92.0),
          leadingRect: const Rect.fromLTRB(6.4, 35.5, 27.4, 56.5),
          trailingRect: const Rect.fromLTRB(220.6, 35.5, 241.6, 56.5),
          titleRect: const Rect.fromLTRB(32.0, 12.0, 206.0, 46.0),
          titleRectWithLeading: const Rect.fromLTRB(32.0, 12.0, 206.0, 46.0),
          titleRectWithTrailing: const Rect.fromLTRB(32.0, 12.0, 206.0, 46.0),
          titleRectWithLeadingAndTrailing:
              const Rect.fromLTRB(32.0, 12.0, 206.0, 46.0),
          subtitleRectWithLeadingAndTrailing:
              const Rect.fromLTRB(32.0, 46.0, 206.0, 80.0),
          subtitleRect: const Rect.fromLTRB(32.0, 46.0, 206.0, 80.0),
          scale: 1,
        ),
        doubleTextSize: MenuItemDimensions(
          tileRect: const Rect.fromLTRB(0.0, 0.0, 350.0, 101.9),
          leadingRect: const Rect.fromLTRB(1.9, 30.0, 43.9, 72.0),
          titleRect: const Rect.fromLTRB(45.3, 17.0, 214.2, 51.0),
          titleRectWithLeading: const Rect.fromLTRB(45.3, 17.0, 214.2, 51.0),
          titleRectWithLeadingAndTrailing:
              const Rect.fromLTRB(45.3, 17.0, 214.2, 51.0),
          subtitleRectWithLeadingAndTrailing:
              const Rect.fromLTRB(45.3, 51.0, 315.6, 85.0),
          subtitleRect: const Rect.fromLTRB(45.3, 51.0, 315.6, 85.0),
          scale: 2,
        ),
        builder: (MenuItemWidgetSet variant, {bool truncated = false}) {
          return CupertinoMenuItem<String>(
              trailing: trailing,
              leading: leading,
              subtitle: Text(
                truncated ? largeSubtitle : subtitle,
                key: const ValueKey<String>('subtitle'),
              ),
              child: Text(
                truncated ? largeTitle : title,
                key: const ValueKey<String>('title'),
              ));
        },
      );
  // Test the CupertinoMenuItem widget.
  testWidgets(
    'Dimension test',
    (WidgetTester tester) async {
      final SampleMenu<String> menu = SampleMenu<String>(withController: true);



      await measureTest(
        tester,
        baseMenuItem,
        menu,
        titleFinder: find.byKey(titleKey),
        subtitleFinder: find.byKey(subtitleKey),
        leadingFinder: find.byIcon(leading.icon!),
        trailingFinder: find.byIcon(trailing.icon!),
      );
    },
  );

  testWidgets(
      'CupertinoCheckedMenuItem -> pan -> makes cursor clickable on Web',
      (WidgetTester tester) async {
    final SampleNestedMenu<String> menu =
        SampleNestedMenu<String>(withController: true);
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
      final SampleNestedMenu<String> menu =
          SampleNestedMenu<String>(withController: true);

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
      final SampleNestedMenu<String> menu =
          SampleNestedMenu<String>(withController: true);
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
      final SampleNestedMenu<String> menu =
          SampleNestedMenu<String>(withController: true);
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
      final SampleNestedMenu<String> menu =
          SampleNestedMenu<String>(withController: true);
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
      final SampleNestedMenu<String> menu =
          SampleNestedMenu<String>(withController: true);
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
      final SampleNestedMenu<String> menu =
          SampleNestedMenu<String>(withController: true);

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
      final SampleNestedMenu<String> menu =
          SampleNestedMenu<String>(withController: true);
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
      final SampleNestedMenu<String> menu =
          SampleNestedMenu<String>(withController: true);
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
      final SampleNestedMenu<String> menu =
          SampleNestedMenu<String>(withController: true);
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


  });
}
