// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:example/menu.dart';
import 'package:example/menu_item.dart';
import 'package:example/test_anchor.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoApp,
        CupertinoColors,
        CupertinoDynamicColor,
        CupertinoIcons,
        CupertinoPageScaffold,
        CupertinoTheme,
        CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'
    hide
        CheckboxMenuButton,
        MenuAcceleratorLabel,
        MenuAnchor,
        MenuBar,
        MenuController,
        MenuItemButton,
        RadioMenuButton,
        SubmenuButton;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

import 'semantics.dart';

// TODO(davidhicks980): Accelerators are not used on Apple platforms -- exclude
// them from the library?


/// Record that groups together the styles of various parts of a menu item.
typedef MenuPartsStyle = ({
  TextStyle? leadingIconStyle,
  TextStyle? leadingTextStyle,
  TextStyle? subtitleStyle,
  TextStyle? titleStyle,
  TextStyle? trailingIconStyle,
  TextStyle? trailingTextStyle
});

void main() {
  late CupertinoMenuController controller;
  final List<TestItem> selected = <TestItem>[];
  final List<TestItem> opened = <TestItem>[];
  final List<TestItem> closed = <TestItem>[];
  Matcher rectEquals(Rect rect) => rectMoreOrLessEquals(rect, epsilon: 0.1);
  Matcher edgeInsetsDirectionalMoreOrLess(
    EdgeInsetsDirectional edgeInsets, {
    double distance = 0.1,
  }) {
    return within(
      distance: distance,
      from: edgeInsets,
      distanceFunction: (EdgeInsetsDirectional a, EdgeInsetsDirectional b) {
        double delta = math.max<double>(
          (a.start - b.start).abs(),
          (a.top - b.top).abs(),
        );
        delta = math.max<double>(delta, (a.end - b.end).abs());
        delta = math.max<double>(delta, (a.bottom - b.bottom).abs());
        return delta;
      },
    );
  }

  Matcher constraintsMoreOrLess(
    BoxConstraints constraints, {
    double distance = 0.1,
  }) {
    return within(
      distance: distance,
      from: constraints,
      distanceFunction: (BoxConstraints a, BoxConstraints b) {
        double delta = 0;
        if (a.minWidth != b.minWidth) {
          delta = a.minWidth - b.minWidth;
        }
        if (a.maxWidth != b.maxWidth) {
          delta = math.max<double>(delta, (a.maxWidth - b.maxWidth).abs());
        }

        if (a.minHeight != b.minHeight) {
          delta = math.max<double>(delta, (a.minHeight - b.minHeight).abs());
        }

        if (a.maxHeight != b.maxHeight) {
          delta = math.max<double>(delta, (a.maxHeight - b.maxHeight).abs());
        }

        return delta;
      },
    );
  }

  Finder findDescendentDecoration(Finder finder) =>
      find.descendant(of: finder, matching: find.byType(DecoratedBox));

  Color? findDescendentDecoratedBoxColor(
    WidgetTester tester,
    Finder finder,
  ) {
    return (tester
            .firstWidget<DecoratedBox>(findDescendentDecoration(finder))
            .decoration as BoxDecoration)
        .color;
  }

  RichText? findDescendentRichText(
    WidgetTester tester,
    Finder finder,
  ) {
    return tester.firstWidget<RichText>(
      find.descendant(
        of: finder,
        matching: find.byType(RichText),
      ),
    );
  }

  TextStyle? findDescendentTextStyle(
    WidgetTester tester,
    Finder finder,
  ) {
    return findDescendentRichText(tester, finder)?.text.style;
  }

  BoxConstraints findConstraints(Finder finder, [Type owner = ConstrainedBox]) {
    return (find
            .descendant(
              of: finder,
              matching: find.byType(owner),
            )
            .evaluate()
            .first
            .widget as ConstrainedBox)
        .constraints;
  }


  setUp(() {
    controller = CupertinoMenuController();
  });

  Finder findCupertinoMenuAnchorItemLabels() {
    return find.byWidgetPredicate((Widget widget) =>
        widget.runtimeType.toString() == '_CupertinoMenuItemLabel');
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
    void Function(TestItem item)? onPressed,
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
                      onPressed?.call(TestItem.outsideButton);
                    },
                    child: Text(TestItem.outsideButton.label)),
                CupertinoMenuAnchor(
                  childFocusNode: focusNode,
                  controller: controller,
                  alignmentOffset: alignmentOffset,
                  alignment: alignment,
                  menuAlignment: menuAlignment,
                  consumeOutsideTap: consumesOutsideTap,
                  onOpen: onOpen,
                  onClose: onClose,
                  menuChildren: children ??
                      createTestItems(
                        onPressed: onPressed,
                      ),
                  builder: _buildAnchor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  group('CupertinoMenuEntryMixin', () {
    CupertinoApp buildApp(List<Widget> children) {
      return CupertinoApp(
        home: Stack(children: <Widget>[
          Align(
            alignment: AlignmentDirectional.topStart,
            child: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: children,
              builder: _buildAnchor,
            ),
          )
        ]),
      );
    }

    testWidgets(
        'dividers respect allowLeadingSeparator and allowTrailingSeparator',
        (WidgetTester tester) async {
      Widget buildDebugEntry(
          {required bool lead, required bool trail, Widget? child}) {
        return _DebugCupertinoMenuEntryMixin(
          allowLeadingSeparator: lead,
          allowTrailingSeparator: trail,
          child: child ?? const SizedBox(),
        );
      }

      Finder findAncestorDivider(Finder finder) => find.ancestor(
            of: finder,
            matching: find.byType(CupertinoMenuDivider),
          );

      await tester.pumpWidget(buildApp(<Widget>[
        buildDebugEntry(lead: true, trail: true, child: TestItem.item0.text),
        buildDebugEntry(lead: true, trail: true, child: TestItem.item1.text),
        buildDebugEntry(lead: true, trail: true, child: TestItem.item2.text),
      ]));

      controller.open();
      await tester.pumpAndSettle();

      // Borders are drawn below menu items.
      expect(findAncestorDivider(TestItem.item0.findText), findsOneWidget);
      expect(findAncestorDivider(TestItem.item1.findText), findsOneWidget);
      expect(findAncestorDivider(TestItem.item2.findText), findsNothing);

      // First item should never have a leading separator and bottom item should
      // never have a trailing separator.
      await tester.pumpWidget(buildApp(<Widget>[
        buildDebugEntry(lead: false, trail: true, child: TestItem.item0.text),
        buildDebugEntry(lead: true, trail: true, child: TestItem.item1.text),
        buildDebugEntry(lead: true, trail: false, child: TestItem.item2.text),
      ]));

      await tester.pump();

      expect(findAncestorDivider(TestItem.item0.findText), findsOneWidget);
      expect(findAncestorDivider(TestItem.item1.findText), findsOneWidget);
      expect(findAncestorDivider(TestItem.item2.findText), findsNothing);

      await tester.pumpWidget(buildApp(<Widget>[
        buildDebugEntry(lead: true, trail: false, child: TestItem.item0.text),
        buildDebugEntry(lead: true, trail: true, child: TestItem.item1.text),
        buildDebugEntry(lead: true, trail: true, child: TestItem.item2.text),
      ]));

      await tester.pump();

      // item 0: trailing == false so no separator is drawn after
      expect(findAncestorDivider(TestItem.item0.findText), findsNothing);
      expect(findAncestorDivider(TestItem.item1.findText), findsOneWidget);
      expect(findAncestorDivider(TestItem.item2.findText), findsNothing);

      await tester.pumpWidget(buildApp(<Widget>[
        buildDebugEntry(lead: true, trail: true, child: TestItem.item0.text),
        buildDebugEntry(lead: false, trail: true, child: TestItem.item1.text),
        buildDebugEntry(lead: true, trail: true, child: TestItem.item2.text),
      ]));

      await tester.pump();

      // item 1: leading == false so no separator is drawn before
      expect(findAncestorDivider(TestItem.item0.findText), findsNothing);
      expect(findAncestorDivider(TestItem.item1.findText), findsOneWidget);
      expect(findAncestorDivider(TestItem.item2.findText), findsNothing);

      await tester.pumpWidget(buildApp(<Widget>[
        buildDebugEntry(lead: true, trail: true, child: TestItem.item0.text),
        buildDebugEntry(lead: true, trail: false, child: TestItem.item1.text),
        buildDebugEntry(lead: true, trail: true, child: TestItem.item2.text),
      ]));

      await tester.pump();

      // item 1: trailing == false so no separator is drawn after
      expect(findAncestorDivider(TestItem.item0.findText), findsOneWidget);
      expect(findAncestorDivider(TestItem.item1.findText), findsNothing);
      expect(findAncestorDivider(TestItem.item2.findText), findsNothing);
    });

    testWidgets('hasLeading aligns sibling CupertinoMenuItems',
        (WidgetTester tester) async {
      final GlobalKey itemKey = GlobalKey();
      await tester.pumpWidget(buildApp(<Widget>[
        CupertinoMenuItem(key: itemKey, child: TestItem.item0.text),
        const _DebugCupertinoMenuEntryMixin(),
      ]));

      await tester.tap(TestItem.anchorButton.findText);
      await tester.pumpAndSettle();

      expect(
        tester.widget<CupertinoMenuItem>(TestItem.item0.findWidget).hasLeading,
        isFalse,
      );

      final Offset offsetWithoutLeading = tester.getTopLeft(TestItem.item0.findText);

      await tester.pumpWidget(buildApp(<Widget>[
        CupertinoMenuItem(key: itemKey, child: TestItem.item0.text),
        const _DebugCupertinoMenuEntryMixin(hasLeading: true),
      ]));

      expect(
        tester.widget<CupertinoMenuItem>(TestItem.item0.findWidget).hasLeading,
        isFalse,
      );

      // By default, the leading width is 16.0.
      expect(
        tester.getTopLeft(TestItem.item0.findText) - offsetWithoutLeading,
        const Offset(16, 0.0),
      );
    });
  });

  group('CupertinoMenuLargeDivider', () {
    testWidgets('dimensions', (WidgetTester tester) async {
      final CupertinoMenuController controller = CupertinoMenuController();
      await tester.pumpWidget(
        const CupertinoApp(
          home: Align(
            alignment: AlignmentDirectional.topStart,
            child: CupertinoLargeMenuDivider(),
          ),
        ),
      );

      expect(
          tester.getRect(find.byType(CupertinoLargeMenuDivider)),
          rectEquals(
            const Rect.fromLTRB(0.0, 0.0, 800.0, 8.0),
          ));

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoMenuAnchor(
            controller: controller,
            menuChildren: <Widget>[
              // Default padding
              CupertinoMenuItem(
                child: TestItem.item0.text,
                onPressed: () {},
              ),
              const CupertinoLargeMenuDivider(),
            ],
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byType(CupertinoLargeMenuDivider)),
          rectEquals(const Rect.fromLTRB(275.0, 584.0, 525.0, 592.0)));
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
                child: TestItem.item0.text,
                onPressed: () {},
              ),
              const CupertinoLargeMenuDivider(),
            ],
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

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
                child: TestItem.item0.text,
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
            menuChildren: const <Widget>[
              _DebugCupertinoMenuEntryMixin(allowTrailingSeparator: true),
              CupertinoLargeMenuDivider(),
              _DebugCupertinoMenuEntryMixin(allowLeadingSeparator: true),
            ],
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoLargeMenuDivider), findsOneWidget);
      expect(find.byType(CupertinoMenuDivider), findsNothing);
    });
  });

  group('CupertinoMenuItem', () {
    group('Appearance', () {
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
              child: TestItem.item0.text,
              onPressed: () {},
            ),
          ],
        ));

        controller.open();
        await tester.pumpAndSettle();

        MenuPartsStyle findParts({bool hideTrailing = false}) {
          return (
            leadingIconStyle:
              findDescendentTextStyle(
                tester,
                find.byIcon(CupertinoIcons.left_chevron)
              ),
            trailingIconStyle:
              findDescendentTextStyle(
                tester,
                find.byIcon(CupertinoIcons.right_chevron)
              ),
            leadingTextStyle: findDescendentTextStyle(tester, find.text('leading')),
            trailingTextStyle: findDescendentTextStyle(tester, find.text('trailing')),
            titleStyle: findDescendentTextStyle(tester, TestItem.item0.findText),
            subtitleStyle: findDescendentTextStyle(tester, find.text('subtitle')),
          );
        }

        MenuPartsStyle parts = findParts();

        // Helper function to match the default style of the text.
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
          expect(findDescendentRichText(tester, finder)?.maxLines, 2);
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
        matchDefaultStyle(parts.leadingTextStyle!, find.text('leading'));
        matchDefaultStyle(parts.trailingTextStyle!, find.text('trailing'));
        matchDefaultStyle(parts.titleStyle!, TestItem.item0.findText);
        expect(parts.subtitleStyle?.fontSize, 15);
        expect(parts.subtitleStyle?.fontFamily, 'SF Pro Text');
        expect(parts.subtitleStyle?.fontFamilyFallback,
            <String>['.AppleSystemUIFont']);
        expect(parts.subtitleStyle?.decoration, TextDecoration.none);
        expect(parts.subtitleStyle?.overflow, TextOverflow.ellipsis);
        expect(parts.subtitleStyle?.letterSpacing, -0.21);
        expect(parts.subtitleStyle?.fontWeight, FontWeight.normal);
        expect(parts.subtitleStyle?.foreground!.color,
            isSameColorAs(subtitleColor.darkColor));
        expect(parts.subtitleStyle?.textBaseline, TextBaseline.ideographic);
        expect(
            findDescendentRichText(tester, find.text('subtitle'))?.maxLines, 2);

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
              child: TestItem.item0.text,
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
        expect(parts.subtitleStyle?.foreground!.color,
            isSameColorAs(subtitleColor.color));

        /* THEME OVERRIDE AND MEDIA QUERY */
        await tester.pumpWidget(
          buildTestApp(
            mediaQuery: const MediaQueryData(
              boldText: true,
              textScaler: TextScaler.linear(1.1),
            ),
            theme: const CupertinoThemeData(brightness: Brightness.dark),
            children: <Widget>[
              CupertinoMenuItem(
                isDefaultAction: true,
                subtitle: const Text(
                  'subtitle',
                  style: TextStyle(
                    inherit: false,
                    color: CupertinoColors.black,
                  ),
                ),
                leading: const Stack(children: <Widget>[
                  Icon(
                    CupertinoIcons.left_chevron,
                    color: CupertinoColors.black,
                  ),
                  Text(
                    'leading',
                    style: TextStyle(color: CupertinoColors.black),
                  )
                ]),
                trailing: const Stack(children: <Widget>[
                  Icon(
                    CupertinoIcons.right_chevron,
                    color: CupertinoColors.black,
                  ),
                  Text(
                    'trailing',
                    style: TextStyle(color: CupertinoColors.black),
                  )
                ]),
                child: Text(
                  TestItem.item0.label,
                  style: const TextStyle(
                    color: CupertinoColors.lightBackgroundGray,
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();
        parts = findParts();

        expect(parts.leadingIconStyle!.color,
            isSameColorAs(CupertinoColors.black));
        expect(parts.leadingIconStyle!.fontSize, 21 * math.sqrt(1.1));

        expect(parts.trailingIconStyle!.color,
            isSameColorAs(CupertinoColors.black));
        expect(parts.trailingIconStyle!.fontSize, 21 * math.sqrt(1.1));

        expect(parts.leadingTextStyle!.color,
            isSameColorAs(CupertinoColors.black));
        expect(parts.trailingTextStyle!.color,
            isSameColorAs(CupertinoColors.black));

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
              child: TestItem.item0.text,
              onPressed: () {},
            ),
          ],
        ));

        expect(findDescendentRichText(tester, TestItem.item0.findText)?.maxLines, 100);
        expect(findDescendentRichText(tester, find.text('subtitle'))?.maxLines, 100);

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
              child: TestItem.item0.text,
              onPressed: () {},
            ),
          ],
        ));

        controller.open();
        await tester.pumpAndSettle();

        expect(
          findDescendentTextStyle(
            tester,
            find.byIcon(CupertinoIcons.left_chevron),
          )?.color,
          isSameColorAs(CupertinoColors.systemRed.darkColor),
        );
        expect(
          findDescendentTextStyle(
            tester,
            find.byIcon(CupertinoIcons.right_chevron),
          )?.color,
          isSameColorAs(CupertinoColors.systemRed.darkColor),
        );
        expect(
          findDescendentTextStyle(tester, TestItem.item0.findText)?.color,
          isSameColorAs(CupertinoColors.systemRed.darkColor),
        );
        expect(
          findDescendentTextStyle(tester, find.text('subtitle'))
              ?.foreground
              ?.color,
          isSameColorAs(
            (CupertinoMenuItem.defaultSubtitleStyle.color! as CupertinoDynamicColor).darkColor,
          ),
        );

        // Check that destructive theming can be overidden
        await tester.pumpWidget(buildTestApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          children: <Widget>[
            CupertinoMenuItem(
              isDestructiveAction: true,
              subtitle: const Text(
                'subtitle',
                style: TextStyle(
                    inherit: false, color: CupertinoColors.systemPurple),
              ),
              leading: const Icon(
                CupertinoIcons.left_chevron,
                color: CupertinoColors.activeBlue,
              ),
              trailing: const Icon(
                CupertinoIcons.right_chevron,
                color: CupertinoColors.activeGreen,
              ),
              child: Text(
                TestItem.item0.label,
                style: const TextStyle(
                  color: CupertinoColors.activeOrange,
                ),
              ),
            ),
          ],
        ));

        await tester.pumpAndSettle();

        expect(
          findDescendentTextStyle(
            tester,
            find.byIcon(CupertinoIcons.left_chevron),
          )?.color,
          isSameColorAs(CupertinoColors.activeBlue.color),
        );
        expect(
          findDescendentTextStyle(
            tester,
            find.byIcon(CupertinoIcons.right_chevron),
          )?.color,
          isSameColorAs(CupertinoColors.activeGreen.color),
        );
        expect(
          findDescendentTextStyle(tester, TestItem.item0.findText)?.color,
          isSameColorAs(CupertinoColors.activeOrange.color),
        );
        expect(
          findDescendentTextStyle(tester, find.text('subtitle'))?.color,
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
              child: TestItem.item0.text,
              onPressed: () {},
            ),
          ],
        ));

        controller.open();
        await tester.pumpAndSettle();

        expect(
          findDescendentTextStyle(tester, TestItem.item0.findText)?.fontWeight,
          FontWeight.bold,
        );
      });

      testWidgets('allows adjacent borders', (WidgetTester tester) async {
        /* TEST 1: DARK THEME */
        await tester.pumpWidget(buildTestApp(
          children: <Widget>[
            const _DebugCupertinoMenuEntryMixin(
              allowTrailingSeparator: true,
            ),
            CupertinoMenuItem(
              child: TestItem.item0.text,
            ),
            const _DebugCupertinoMenuEntryMixin(
              allowLeadingSeparator: true,
            ),
          ],
        ));

        controller.open();
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoMenuDivider), findsNWidgets(2));
      });

      testWidgets('disabled items should not interact',
          (WidgetTester tester) async {
        // Test various interactions to ensure that disabled items do not
        // respond.
        int interactions = 0;
        final FocusNode focusNode = FocusNode();
        final TestGesture gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          pointer: 1,
        );

        focusNode.addListener(() {
          interactions++;
        });

        await gesture.addPointer(location: Offset.zero);

        addTearDown(gesture.removePointer);
        addTearDown(focusNode.dispose);

        await tester.pumpWidget(
          buildTestApp(
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
                  child: TestItem.item0.text,
                ),
              ]),
        );

        controller.open();
        await tester.pumpAndSettle();

        // Test focus
        focusNode.requestFocus();
        await tester.pumpAndSettle();

        // Test hover
        await gesture.moveTo(tester.getCenter(TestItem.item0.findWidget));
        await tester.pumpAndSettle();

        // Test press
        await gesture.down(tester.getCenter(TestItem.item0.findWidget));

        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);
        expect(
          findDescendentTextStyle(tester, find.text(TestItem.item0.label))
              ?.color,
          isSameColorAs(CupertinoColors.systemGrey),
        );

        // Test pan
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.up();

        expect(controller.isOpen, isTrue);
        expect(TestItem.item0.findWidget, findsOneWidget);
        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);
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
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          children: <Widget>[
            CupertinoMenuItem(
              child: TestItem.item0.text,
              onPressed: () {},
            ),
            CupertinoMenuItem(
              onPressed: () {},
              pressedColor: customPressedColor,
              hoveredColor: customHoveredColor,
              child: TestItem.item1.text,
            ),
            CupertinoMenuItem(
              onPressed: () {},
              pressedColor: customPressedColor,
              child: TestItem.item2.text,
            ),
            CupertinoMenuItem(child: TestItem.item3.text),
          ],
        ));
        await tester.tap(find.byType(CupertinoMenuAnchor));
        await tester.pumpAndSettle();
        final TestGesture gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          pointer: 1,
        );
        await gesture.addPointer(location: Offset.zero);

        addTearDown(() => gesture.removePointer());

        // None hovered
        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item1.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item2.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item3.findWidget), findsNothing);

        // Enabled button
        // Pressed color @ 5% opacity is used when hovered color is not specified
        await gesture.moveTo(tester.getCenter(TestItem.item0.findWidget));
        await tester.pumpAndSettle();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item0.findWidget),
          isSameColorAs(
            CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.05),
          ),
        );

        // Hovered button with custom hoverColor and pressedColor
        // Specified hovered color takes priority over pressed color
        await gesture.moveTo(tester.getCenter(TestItem.item1.findWidget));
        await tester.pumpAndSettle();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item1.findWidget),
          isSameColorAs(customHoveredColor.darkColor),
        );

        // Hovered button with custom pressedColor
        // Pressed color @ 5% opacity is used when hovered color is not specified
        await gesture.moveTo(tester.getCenter(TestItem.item2.findWidget));
        await tester.pumpAndSettle();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item2.findWidget),
          isSameColorAs(customPressedColor.darkColor.withOpacity(0.05)),
        );

        // Disabled button
        await gesture.moveTo(tester.getCenter(TestItem.item3.findWidget));
        await tester.pumpAndSettle();

        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item1.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item2.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item3.findWidget), findsNothing);
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
        final FocusNode focusNode = FocusNode(debugLabel: 'TestNode ${TestItem.item1}');
        addTearDown(focusNode.dispose);
        await tester.pumpWidget(buildTestApp(
            theme: const CupertinoThemeData(brightness: Brightness.dark),
            children: <Widget>[
              CupertinoMenuItem(
                requestFocusOnHover: true,
                child: TestItem.item0.text,
                onPressed: () {},
              ),
              CupertinoMenuItem(
                requestFocusOnHover: true,
                focusNode: focusNode,
                onPressed: () {},
                pressedColor: customPressedColor,
                focusedColor: customFocusColor,
                child: TestItem.item1.text,
              ),
              CupertinoMenuItem(
                requestFocusOnHover: true,
                onPressed: () {},
                pressedColor: customPressedColor,
                child: TestItem.item2.text,
              ),
              CupertinoMenuItem(
                  requestFocusOnHover: true, child: TestItem.item3.text),
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
        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item1.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item2.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item3.findWidget), findsNothing);

        // Enabled button
        // Pressed color @ 5% opacity is used when hovered color is not specified
        await gesture.moveTo(tester.getCenter(TestItem.item0.findWidget));
        await tester.pumpAndSettle();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item0.findWidget),
          isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.075),
          ),
        );

        // Hovered button with custom hoverColor and pressedColor
        // Specified hovered color takes priority over pressed color
        await gesture.moveTo(tester.getCenter(TestItem.item1.findWidget));
        await tester.pumpAndSettle();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item1.findWidget),
          isSameColorAs(customFocusColor.darkColor),
        );

        // Hovered button with custom pressedColor
        // Pressed color @ 5% opacity is used when hovered color is not specified
        await gesture.moveTo(tester.getCenter(TestItem.item2.findWidget));
        await tester.pumpAndSettle();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item2.findWidget),
          isSameColorAs(customPressedColor.darkColor.withOpacity(0.075),
          ),
        );

        // Disabled button
        await gesture.moveTo(tester.getCenter(TestItem.item3.findWidget));
        await tester.pumpAndSettle();

        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item1.findWidget), findsNothing);
        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item2.findWidget),
          isSameColorAs(customPressedColor.darkColor.withOpacity(0.075),
          ),
        );
        expect(findDescendentDecoration(TestItem.item3.findWidget), findsNothing);

        // Programmatic focus
        focusNode.requestFocus();
        await tester.pumpAndSettle();

        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);
        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item1.findWidget),
          isSameColorAs(customFocusColor.darkColor),
        );
        expect(findDescendentDecoration(TestItem.item2.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item3.findWidget), findsNothing);
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

        // Because the app defaults to light mode, I only test
        // dark mode here. Should light mode be tested as well?
        await tester.pumpWidget(buildTestApp(
            theme: const CupertinoThemeData(brightness: Brightness.dark),
            children: <Widget>[
              const CupertinoLargeMenuDivider(),
              CupertinoMenuItem(
                requestCloseOnActivate: false,
                panActivationDelay: const Duration(milliseconds: 200),
                onPressed: () {
                  pressedCount++;
                },
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                pressedColor: customPressedColor,
                child: TestItem.item1.text,
              ),
              CupertinoMenuItem(
                pressedColor: customPressedColor,
                child: TestItem.item2.text,
              ),
              CupertinoMenuItem(child: TestItem.item3.text),
            ]));

        controller.open();
        await tester.pumpAndSettle();

        // None hovered
        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item1.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item2.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item3.findWidget), findsNothing);

        await gesture.down(tester.getCenter(
          find.byType(CupertinoLargeMenuDivider),
          warnIfMissed: true,
        ));
        await tester.pump();
        await gesture.moveTo(tester.getCenter(TestItem.item0.findWidget));
        await tester.pump();

        // Pressed button with default color
        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item0.findWidget),
          isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor),
        );

        // Pressed button with custom pressedColor
        await gesture.moveTo(tester.getCenter(TestItem.item1.findWidget));
        await tester.pump();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item1.findWidget),
          isSameColorAs(customPressedColor.darkColor),
        );

        // Item0 should not be pressed
        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);

        // Disabled with custom pressedColor -- no effect
        await gesture.moveTo(tester.getCenter(TestItem.item2.findWidget));
        await tester.pump();
        expect(findDescendentDecoration(TestItem.item2.findWidget), findsNothing);

        // Disabled button
        await gesture.moveTo(tester.getCenter(TestItem.item3.findWidget));
        await tester.pump();

        expect(findDescendentDecoration(TestItem.item0.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item1.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item2.findWidget), findsNothing);
        expect(findDescendentDecoration(TestItem.item3.findWidget), findsNothing);

        // Moving back over item0 should cause item0 to fill again
        await gesture.moveTo(tester.getCenter(TestItem.item0.findWidget));
        await tester.pump();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item0.findWidget),
          isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor),
        );

        await gesture.up();
        await tester.pump();

        // On mouse up, should be hovered but not pressed
        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item0.findWidget),
          isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.05)),
        );
        expect(pressedCount, 1);

        await gesture.down(tester.getCenter(find.byType(CupertinoLargeMenuDivider)));
        await tester.pump();
        await gesture.moveTo(tester.getCenter(TestItem.item0.findWidget));
        await tester.pump();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item0.findWidget),
          isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor),
        );

        // Wait for panActivationDelay to pass
        await tester.pump(const Duration(seconds: 1));

        expect(pressedCount, 2);
        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item0.findWidget),
          isSameColorAs(CupertinoMenuItem.defaultPressedColor.darkColor.withOpacity(0.05)),
        );

        // Moving back over item1 should cause it to fill again
        await gesture.moveTo(tester.getCenter(TestItem.item1.findWidget));
        await tester.pump();

        expect(
          findDescendentDecoratedBoxColor(tester, TestItem.item1.findWidget),
          isSameColorAs(customPressedColor.darkColor),
        );
      });

      testWidgets('mouse cursor can be set and is inherited',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          CupertinoApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: MouseRegion(
                cursor: SystemMouseCursors.forbidden,
                child: CupertinoMenuItem(
                  mouseCursor: SystemMouseCursors.text,
                  child: TestItem.item0.text,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final TestGesture gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          pointer: 1,
        );
        await gesture.addPointer(location: tester.getCenter(TestItem.item0.findWidget));
        addTearDown(gesture.removePointer);

        await tester.pump();

        expect(
          RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
          SystemMouseCursors.text,
        );

        // Test default cursor
        await tester.pumpWidget(
          CupertinoApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: MouseRegion(
                cursor: SystemMouseCursors.forbidden,
                child: CupertinoMenuItem(
                  child: TestItem.item0.text,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        expect(
          RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
          SystemMouseCursors.click,
        );

        // Test default cursor when disabled
        await tester.pumpWidget(
          CupertinoApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: MouseRegion(
                cursor: SystemMouseCursors.forbidden,
                child: CupertinoMenuItem(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.basic,
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
        );

        // The cursor should defer to it's child.
        expect(
          RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
          SystemMouseCursors.basic,
        );
      });
    });
    group('Layout', () {
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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                child: Text(superLongText),
              ),
            ],
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

        expect(
          tester.getRect(TestItem.item0.findText),
          rectEquals(const Rect.fromLTRB(307.0, 77.6, 406.5, 98.6)),
        );
        expect(
          tester.getRect(find.text(superLongText)),
          rectEquals(const Rect.fromLTRB(307.0, 141.6, 509.0, 183.6)),
        );

        // MaxLines should be 100 when the TextScaler > 1.25.
        await tester.pumpWidget(
          buildTestApp(
            mediaQuery:
                const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            children: <Widget>[
              CupertinoMenuItem(
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                subtitle: const Text('subtitle'),
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                child: Text(superLongText),
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.getRect(TestItem.item0.findText),
            rectEquals(const Rect.fromLTRB(261.5, 20.5, 391.6, 48.5)));
        expect(tester.getRect(find.text(superLongText)),
            rectEquals(const Rect.fromLTRB(261.5, 99.6, 556.8, 2899.6)));
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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                child: Text(superLongText),
              ),
            ],
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

        expect(
          tester.getRect(TestItem.item0.findText),
          rectEquals(const Rect.fromLTRB(393.5, 77.6, 493.0, 98.6)),
        );
        expect(
          tester.getRect(find.text(superLongText)),
          rectEquals(const Rect.fromLTRB(291.0, 141.6, 493.0, 183.6)),
        );

        // MaxLines should be 100 when the TextScaler > 1.25.
        await tester.pumpWidget(
          buildTestApp(
            mediaQuery:
                const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            textDirection: TextDirection.rtl,
            children: <Widget>[
              CupertinoMenuItem(
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                subtitle: const Text('subtitle'),
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                child: Text(superLongText),
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        expect(
          tester.getRect(TestItem.item0.findText),
          rectEquals(const Rect.fromLTRB(408.4, 20.5, 538.5, 48.5)),
        );
        expect(
          tester.getRect(find.text(superLongText)),
          rectEquals(const Rect.fromLTRB(243.2, 99.6, 538.5, 2899.6)),
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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leadingWidth: 20,
                leadingAlignment: AlignmentDirectional.bottomEnd,
                leading: const Text('leading'),
                child: TestItem.item1.text,
              ),
            ],
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leadingWidth: 50,
                leadingAlignment: AlignmentDirectional.topStart,
                leading: const Text('leading'),
                child: TestItem.item1.text,
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leadingWidth: 20,
                leadingAlignment: AlignmentDirectional.bottomEnd,
                leading: const Text('leading'),
                child: TestItem.item1.text,
              ),
            ],
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leadingWidth: 50,
                leadingAlignment: AlignmentDirectional.topStart,
                leading: const Text('leading'),
                child: TestItem.item1.text,
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        expect(
          tester.getRect(find.text('leading')),
          rectEquals(const Rect.fromLTRB(275.0, 141.6, 325.0, 183.6)),
        );
        expect(
          tester.getRect(find.byIcon(CupertinoIcons.left_chevron)),
          rectEquals(const Rect.fromLTRB(281.4, 87.6, 302.4, 108.6)),
        );
      });
      testWidgets('hasLeading shift LTR', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            children: <Widget>[
              CupertinoMenuItem(
                onPressed: () {},
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                child: TestItem.item1.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leadingWidth: 3,
                child: TestItem.item2.text,
              ),
            ],
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

        final Rect a1 = tester.getRect(TestItem.item0.findText);
        final Rect a2 = tester.getRect(TestItem.item1.findText);
        final Rect a3 = tester.getRect(TestItem.item2.findText);

        expect(a1.left, a2.left);
        expect(a1.left - a3.left, 16 - 3);

        await tester.pumpWidget(
          buildTestApp(
            children: <Widget>[
              CupertinoMenuItem(
                onPressed: () {},
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leading: const Icon(CupertinoIcons.left_chevron),
                child: TestItem.item1.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leadingWidth: 3,
                child: TestItem.item2.text,
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        final Rect b1 = tester.getRect(TestItem.item0.findText);
        final Rect b2 = tester.getRect(TestItem.item1.findText);
        final Rect b3 = tester.getRect(TestItem.item2.findText);

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
                onPressed: () {},
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                child: TestItem.item1.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leadingWidth: 3,
                child: TestItem.item2.text,
              ),
            ],
          ),
        );

        controller.open();
        await tester.pumpAndSettle();
        final Rect a1 = tester.getRect(TestItem.item0.findText);
        final Rect a2 = tester.getRect(TestItem.item1.findText);
        final Rect a3 = tester.getRect(TestItem.item2.findText);

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
                onPressed: () {},
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leading: const Icon(CupertinoIcons.left_chevron),
                child: TestItem.item1.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                leadingWidth: 3,
                child: TestItem.item2.text,
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        final Rect b1 = tester.getRect(TestItem.item0.findText);
        final Rect b2 = tester.getRect(TestItem.item1.findText);
        final Rect b3 = tester.getRect(TestItem.item2.findText);

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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                trailingWidth: 20,
                trailingAlignment: AlignmentDirectional.bottomEnd,
                trailing: const Text('trailing'),
                child: TestItem.item1.text,
              ),
            ],
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('trailing')),
            rectEquals(const Rect.fromLTRB(505.0, 141.6, 525.0, 183.6)));

        expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
            rectEquals(const Rect.fromLTRB(489.4, 87.6, 510.4, 108.6)));

        await tester.pumpWidget(
          buildTestApp(
            children: <Widget>[
              CupertinoMenuItem(
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                subtitle: const Text('subtitle'),
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                trailingWidth: 50,
                trailingAlignment: AlignmentDirectional.topStart,
                trailing: const Text('trailing'),
                child: TestItem.item1.text,
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('trailing')),
            rectEquals(const Rect.fromLTRB(475.0, 141.6, 525.0, 183.6)));
        expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
            rectEquals(const Rect.fromLTRB(489.4, 87.6, 510.4, 108.6)));
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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                trailingWidth: 20,
                trailingAlignment: AlignmentDirectional.bottomEnd,
                trailing: const Text('trailing'),
                child: TestItem.item1.text,
              ),
            ],
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('trailing')),
            rectEquals(const Rect.fromLTRB(275.0, 141.6, 295.0, 183.6)));
        expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
            rectEquals(const Rect.fromLTRB(289.6, 87.6, 310.6, 108.6)));

        await tester.pumpWidget(
          buildTestApp(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              CupertinoMenuItem(
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                subtitle: const Text('subtitle'),
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                onPressed: () {},
                trailingWidth: 50,
                trailingAlignment: AlignmentDirectional.topStart,
                trailing: const Text('trailing'),
                child: TestItem.item1.text,
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('trailing')),
            rectEquals(const Rect.fromLTRB(275.0, 141.6, 325.0, 183.6)));
        expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
            rectEquals(const Rect.fromLTRB(289.6, 87.6, 310.6, 108.6)));
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
              child: TestItem.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: () {},
              subtitle: Text(longSubtitle),
              child: TestItem.item1.text,
            ),
          ],
        ));
        controller.open();
        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('subtitle')),
            rectEquals(const Rect.fromLTRB(307.0, 99.8, 425.3, 118.8)));
        expect(tester.getRect(find.text(longSubtitle)),
            rectEquals(const Rect.fromLTRB(307.0, 163.8, 509.0, 201.8)));

        // When TextScaler > 1.25, maxLines == 100
        await tester.pumpWidget(buildTestApp(
          mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestItem.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: () {},
              subtitle: Text(longSubtitle),
              child: TestItem.item1.text,
            ),
          ],
        ));
        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('subtitle')),
            rectEquals(const Rect.fromLTRB(261.5, 49.5, 415.8, 73.5)));
        expect(tester.getRect(find.text(longSubtitle)),
            rectEquals(const Rect.fromLTRB(261.5, 128.6, 556.8, 2528.6)));
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
              child: TestItem.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: () {},
              subtitle: Text(longSubtitle),
              child: TestItem.item1.text,
            ),
          ],
        ));
        controller.open();
        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('subtitle')),
            rectEquals(const Rect.fromLTRB(374.7, 99.8, 493.0, 118.8)));
        expect(tester.getRect(find.text(longSubtitle)),
            rectEquals(const Rect.fromLTRB(291.0, 163.8, 493.0, 201.8)));

        // When TextScaler > 1.25, maxLines == 100
        await tester.pumpWidget(buildTestApp(
          textDirection: TextDirection.rtl,
          mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          children: <Widget>[
            CupertinoMenuItem(
              leading: const Icon(CupertinoIcons.left_chevron),
              trailing: const Icon(CupertinoIcons.right_chevron),
              subtitle: const Text('subtitle'),
              child: TestItem.item0.text,
            ),
            CupertinoMenuItem(
              onPressed: () {},
              subtitle: Text(longSubtitle),
              child: TestItem.item1.text,
            ),
          ],
        ));
        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('subtitle')),
            rectEquals(const Rect.fromLTRB(384.2, 49.5, 538.5, 73.5)));
        expect(tester.getRect(find.text(longSubtitle)),
            rectEquals(const Rect.fromLTRB(243.2, 128.6, 538.5, 2528.6)));
      });
      testWidgets('default layout', (WidgetTester tester) async {
        await tester.pumpWidget(
          CupertinoApp(
            home: Column(
              children: <Widget>[
                CupertinoMenuAnchor(
                  controller: controller,
                  menuChildren: <Widget>[
                    CupertinoMenuItem(
                      leading: const Icon(CupertinoIcons.left_chevron),
                      trailing: const Icon(CupertinoIcons.right_chevron),
                      subtitle: const Text('subtitle'),
                      child: TestItem.item1.text,
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
                  child: TestItem.item0.text,
                ),
              ],
            ),
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

        // Standalone menu item has loose constraints with a minimum
        // height of 44.
        expect(
          findConstraints(TestItem.item0.findWidget),
          constraintsMoreOrLess(const BoxConstraints(minHeight: 43.7)),
        );
        expect(tester.getRect(TestItem.item0.findWidget),
            rectEquals(const Rect.fromLTRB(0.0, 536.3, 800.0, 600.0)));
        expect(
          findConstraints(TestItem.item1.findWidget),
          constraintsMoreOrLess(const BoxConstraints(minHeight: 43.7)),
        );
        expect(tester.getRect(TestItem.item1.findWidget),
            rectEquals(const Rect.fromLTRB(275.0, 8.0, 525.0, 71.7)));
      });
      testWidgets('applyInsetScaling can be set', (WidgetTester tester) async {
        // applyInsetScaling, when true, increases the size of the padding,
        // leading and trailing width, and the constraints by a factor of the
        // square root of the textScaler. This behavior was observed on the iOS
        // simulator.
        await tester.pumpWidget(
          CupertinoApp(
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(1.15),
              ),
              child: CupertinoMenuAnchor(
                controller: controller,
                menuChildren: <Widget>[
                  CupertinoMenuItem(
                    leading: const Icon(CupertinoIcons.left_chevron),
                    trailing: const Icon(CupertinoIcons.right_chevron),
                    subtitle: const Text('subtitle'),
                    child: TestItem.item0.text,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        controller.open();
        await tester.pumpAndSettle();

        // First, test with applyInsetScaling set to true.
        expect(tester.getRect(TestItem.item0.findWidget),
            rectEquals(const Rect.fromLTRB(275.0, 521.4, 525.0, 592.0)));
        expect(tester.getRect(find.byIcon(CupertinoIcons.left_chevron)),
            rectEquals(const Rect.fromLTRB(281.9, 545.4, 304.4, 568.0)));
        expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
            rectEquals(const Rect.fromLTRB(486.8, 545.4, 509.3, 568.0)));

        await tester.pumpWidget(
          CupertinoApp(
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(1.15),
              ),
              child: CupertinoMenuAnchor(
                controller: controller,
                menuChildren: <Widget>[
                  CupertinoMenuItem(
                    applyInsetScaling: false,
                    leading: const Icon(CupertinoIcons.left_chevron),
                    trailing: const Icon(CupertinoIcons.right_chevron),
                    subtitle: const Text('subtitle'),
                    child: TestItem.item0.text,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        // Then, test with applyInsetScaling set to false.
        expect(tester.getRect(TestItem.item0.findWidget),
            rectEquals(const Rect.fromLTRB(275.0, 523.0, 525.0, 592.0)));
        expect(tester.getRect(find.byIcon(CupertinoIcons.left_chevron)),
            rectEquals(const Rect.fromLTRB(280.5, 546.2, 303.0, 568.8)));
        expect(tester.getRect(find.byIcon(CupertinoIcons.right_chevron)),
            rectEquals(const Rect.fromLTRB(488.8, 546.2, 511.3, 568.8)));
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
                      child: TestItem.item1.text,
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
                  child: TestItem.item0.text,
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
                  )
                  .evaluate()
                  .first
                  .widget as ConstrainedBox)
              .constraints;
        }

        expect(
          getConstraints(TestItem.item0.findWidget),
          const BoxConstraints(
              minHeight: 150.0, maxHeight: 200, minWidth: 50, maxWidth: 150),
        );
        expect(tester.getRect(TestItem.item0.findWidget),
            rectEquals(const Rect.fromLTRB(325.0, 0.0, 475.0, 200.0)));
        expect(
          getConstraints(TestItem.item1.findWidget),
          const BoxConstraints(
              minHeight: 150.0, maxHeight: 200, minWidth: 50, maxWidth: 150),
        );
        expect(tester.getRect(TestItem.item1.findWidget),
            rectEquals(const Rect.fromLTRB(275.0, 8.0, 525.0, 208.0)));
      });

      testWidgets('vertical padding', (WidgetTester tester) async {
        EdgeInsetsGeometry getEdgeInsets(Finder finder) {
          return (find
                  .descendant(
                    of: finder,
                    matching: find.byType(Padding),
                  )
                  .evaluate()
                  .first
                  .widget as Padding)
              .padding;
        }

        // Default padding
        await tester.pumpWidget(
          CupertinoApp(
            home: CupertinoMenuAnchor(
              controller: controller,
              menuChildren: <Widget>[
                // Default padding
                CupertinoMenuItem(
                  child: TestItem.item0.text,
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
          getEdgeInsets(TestItem.item0.findWidget),
          edgeInsetsDirectionalMoreOrLess(
            const EdgeInsetsDirectional.fromSTEB(0.0, 11.3, 0.0, 11.3),
          ),
        );
        expect(
          tester.getSize(TestItem.item0.findWidget),
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
                  child: TestItem.item0.text,
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
                  child: TestItem.item1.text,
                ),
              ],
            ),
          ),
        );

        // User-defined padding does not subtract 1 physical pixel from the total
        // vertical padding.

        // Padding + height is below minHeight constraint of 44, so padding does not
        // affect vertical layout
        expect(
          getEdgeInsets(TestItem.item0.findWidget),
          edgeInsetsDirectionalMoreOrLess(
            const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 5.0),
          ),
        );
        expect(
          tester.getSize(TestItem.item0.findWidget),
          within(distance: 0.05, from: const Size(250, 43.7)),
        );

        // Padding + height is above min height of 44, so padding does
        // affect vertical layout
        expect(
            getEdgeInsets(TestItem.item1.findWidget),
            edgeInsetsDirectionalMoreOrLess(
                const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 5)));
        expect(
          tester.getSize(TestItem.item1.findWidget),
          within(distance: 0.05, from: const Size(250, 53)),
        );
      });
      testWidgets('horizontal padding LTR', (WidgetTester tester) async {
        T findEdgeInsets<T extends EdgeInsetsGeometry>(Finder finder) {
          return (find
                  .descendant(
                    of: finder,
                    matching: find.byType(Padding),
                  )
                  .evaluate()
                  .first
                  .widget as Padding)
              .padding as T;
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
                  child: TestItem.item0.text,
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
        final Rect child = tester.getRect(TestItem.item0.findText);
        await tester.pumpWidget(
          CupertinoApp(
            home: CupertinoMenuAnchor(
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  padding: const EdgeInsetsDirectional.only(start: 7, end: 13),
                  leading: const Icon(CupertinoIcons.left_chevron),
                  trailing: const Icon(CupertinoIcons.right_chevron),
                  subtitle: const Text('subtitle'),
                  child: TestItem.item0.text,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
        final Rect leading2 = tester.getRect(find.byIcon(CupertinoIcons.left_chevron));
        final Rect trailing2 = tester.getRect(find.byIcon(CupertinoIcons.right_chevron));
        final Rect subtitle2 = tester.getRect(find.text('subtitle'));
        final Rect child2 = tester.getRect(TestItem.item0.findText);

        // Default padding subtracts 1 physical pixel from the total vertical
        // padding. Otherwise, the padding vertical padding would be 11.5 per side.
        expect(
            findEdgeInsets(TestItem.item0.findWidget),
            edgeInsetsDirectionalMoreOrLess(
                const EdgeInsetsDirectional.only(start: 7, end: 13)));
        expect(
          tester.getSize(TestItem.item0.findWidget),
          within(distance: 0.05, from: const Size(250, 43.7)),
        );
        expect(leading2.left - leading.left, 7);
        expect(trailing2.right - trailing.right, -13);
        expect(subtitle2.left - subtitle.left, 7);
        expect(child2.left - child.left, 7);
      });

      testWidgets('horizontal padding RTL', (WidgetTester tester) async {
        T findEdgeInsets<T extends EdgeInsetsGeometry>(Finder finder) {
          return (find
                  .descendant(
                    of: finder,
                    matching: find.byType(Padding),
                  )
                  .evaluate()
                  .first
                  .widget as Padding)
              .padding as T;
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
                    child: TestItem.item0.text,
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
        final Rect child = tester.getRect(TestItem.item0.findText);

        await tester.pumpWidget(
          CupertinoApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: CupertinoMenuAnchor(
                menuChildren: <Widget>[
                  CupertinoMenuItem(
                    padding:
                        const EdgeInsetsDirectional.only(start: 7, end: 13),
                    leading: const Icon(CupertinoIcons.left_chevron),
                    trailing: const Icon(CupertinoIcons.right_chevron),
                    subtitle: const Text('subtitle'),
                    child: TestItem.item0.text,
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
        final Rect child2 = tester.getRect(TestItem.item0.findText);

        expect(
          findEdgeInsets(TestItem.item0.findWidget),
          edgeInsetsDirectionalMoreOrLess(
            const EdgeInsetsDirectional.only(
              start: 7,
              end: 13,
            ),
          ),
        );

        expect(
          tester.getSize(TestItem.item0.findWidget),
          within(distance: 0.05, from: const Size(250, 43.7)),
        );
        expect(leading2.right - leading.right, moreOrLessEquals(-7));
        expect(trailing2.left - trailing.left, moreOrLessEquals(13));
        expect(subtitle2.right - subtitle.right, moreOrLessEquals(-7));
        expect(child2.right - child.right, moreOrLessEquals(-7));
      });

      testWidgets('hide trailing with TextScaler greater than 1.25',
          (WidgetTester tester) async {
        // Trailing is not shown when the TextScaler > 1.25.
        await tester.pumpWidget(
          buildTestApp(
            mediaQuery:
                const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            children: <Widget>[
              CupertinoMenuItem(
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                subtitle: const Text('subtitle'),
                child: TestItem.item0.text,
              ),
            ],
          ),
        );
        controller.open();
        await tester.pumpAndSettle();

        expect(find.text('subtitle'), findsOne);
        expect(TestItem.item0.findWidget, findsOne);
        expect(find.byIcon(CupertinoIcons.left_chevron), findsOne);
        expect(find.byIcon(CupertinoIcons.right_chevron), findsNothing);

        await tester.pumpWidget(
          buildTestApp(
            textDirection: TextDirection.rtl,
            mediaQuery:
                const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            children: <Widget>[
              CupertinoMenuItem(
                leading: const Icon(CupertinoIcons.left_chevron),
                trailing: const Icon(CupertinoIcons.right_chevron),
                subtitle: const Text('subtitle'),
                child: TestItem.item0.text,
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('subtitle'), findsOne);
        expect(TestItem.item0.findWidget, findsOne);
        expect(find.byIcon(CupertinoIcons.left_chevron), findsOne);
        expect(find.byIcon(CupertinoIcons.right_chevron), findsNothing);
      });
    });

    group('Interaction', () {
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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                child: TestItem.item1.text,
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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                child: TestItem.item1.text,
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
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                child: TestItem.item1.text,
                onPressed: () {},
              ),
            ],
          ),
        );

        // true -- move focus to the first item
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();

        // false -- focus is excluded if the menu starts closing
        controller.close();
        await tester.pumpAndSettle();

        expect(focusChanges, <bool>[true, false, true, false, true, false]);
      });

      testWidgets('onHover is called on enabled items',
          (WidgetTester tester) async {
        final TestGesture gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          pointer: 1,
        );

        await gesture.addPointer(location: Offset.zero);
        addTearDown(() => gesture.removePointer());
        final List<(TestItem, bool)> hoverChanges = <(TestItem, bool)>[];
        await tester.pumpWidget(
          buildTestApp(
            children: <Widget>[
              CupertinoMenuItem(
                onHover: (bool value) {
                  hoverChanges.add((TestItem.item0, value));
                },
                onPressed: () {},
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                child: TestItem.item1.text,
                onHover: (bool value) {
                  hoverChanges.add((TestItem.item1, value));
                },
              ),
              CupertinoMenuItem(
                child: TestItem.item2.text,
                onHover: (bool value) {
                  hoverChanges.add((TestItem.item2, value));
                },
                onPressed: () {},
              ),
            ],
          ),
        );
        controller.open();
        await tester.pumpAndSettle();

        // (item0, true)
        await gesture.moveTo(tester.getCenter(TestItem.item0.findWidget));
        await tester.pumpAndSettle();

        // (item0, false) -- hover is ignored if the item is disabled
        await gesture.moveTo(tester.getCenter(TestItem.item1.findWidget));
        await tester.pumpAndSettle();

        // (item2, true)
        await gesture.moveTo(tester.getCenter(TestItem.item2.findWidget));
        await tester.pumpAndSettle();

        // (item2, false)
        await gesture.moveTo(tester.getBottomRight(TestItem.item2.findWidget) +
            const Offset(0, 10));
        await tester.pumpAndSettle();

        expect(hoverChanges, <(TestItem, bool)>[
          (TestItem.item0, true),
          (TestItem.item0, false),
          (TestItem.item2, true),
          (TestItem.item2, false),
        ]);
      });
      testWidgets('onPressed is called when set', (WidgetTester tester) async {
        int pressed = 0;
        final CupertinoApp widget = CupertinoApp(
          home: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: CupertinoMenuAnchor(
                  controller: controller,
                  menuChildren: <Widget>[
                    CupertinoMenuItem(
                      onPressed: () {
                        pressed += 1;
                      },
                      child: TestItem.item0.text,
                    ),
                    CupertinoMenuItem(
                      child: TestItem.item1.text,
                    ),
                    CupertinoMenuItem(
                      child: TestItem.item2.text,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        await tester.pumpWidget(widget);

        controller.open();
        await tester.pumpFrames(widget, const Duration(milliseconds: 200));

        expect(controller.menuStatus, MenuStatus.opening);

        // Tap when partially open
        await tester.tap(TestItem.item0.findWidget);
        await tester.pumpAndSettle();

        expect(pressed, 1);

        await tester.pumpAndSettle();

        controller.open();
        await tester.pumpAndSettle();

        // Tap when fully open
        await tester.tap(TestItem.item0.findWidget);
        await tester.pumpAndSettle();

        expect(pressed, 2);

        controller.open();
        await tester.pumpAndSettle();

        controller.close();
        await tester.pumpFrames(widget, const Duration(milliseconds: 50));

        // Do not tap if closing.
        await tester.tap(TestItem.item0.findWidget);
        await tester.pumpAndSettle();

        expect(pressed, 2);
      });
      testWidgets('HitTestBehavior can be set', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(children: <Widget>[
          CupertinoMenuItem(
            onPressed: () {},
            child: TestItem.item0.text,
          ),
          CupertinoMenuItem(
            onPressed: () {},
            behavior: HitTestBehavior.translucent,
            child: TestItem.item1.text,
          ),
        ]));
        controller.open();
        await tester.pumpAndSettle();

        final GestureDetector first = find
            .descendant(
              of: TestItem.item0.findWidget,
              matching: find.byType(GestureDetector),
            )
            .evaluate()
            .first
            .widget as GestureDetector;

        // Test default
        expect(first.behavior, HitTestBehavior.opaque);

        final GestureDetector second = find
            .descendant(
              of: TestItem.item1.findWidget,
              matching: find.byType(GestureDetector),
            )
            .evaluate()
            .first
            .widget as GestureDetector;

        // Test custom
        expect(second.behavior, HitTestBehavior.translucent);
      });

      testWidgets('panPressActivationDelay activates when set',
          (WidgetTester tester) async {
        TestItem? pressed;
        final TestGesture gesture = await tester.createGesture(
          pointer: 1,
        );

        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await tester.pumpWidget(
          buildTestApp(
            children: <Widget>[
              const CupertinoLargeMenuDivider(),
              CupertinoMenuItem(
                onPressed: () {
                  pressed ??= TestItem.item0;
                },
                child: TestItem.item0.text,
              ),
              CupertinoMenuItem(
                panActivationDelay: const Duration(milliseconds: 300),
                child: TestItem.item1.text,
              ),
              CupertinoMenuItem(
                onPressed: () {
                  pressed ??= TestItem.item2;
                },
                panActivationDelay: const Duration(milliseconds: 300),
                child: TestItem.item2.text,
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
        await gesture.moveTo(tester.getCenter(TestItem.item0.findWidget));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        expect(controller.isOpen, isTrue);

        // Item1 is disabled => should not activate
        await gesture.moveTo(tester.getCenter(TestItem.item1.findWidget));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        expect(controller.isOpen, isTrue);

        // Item2 is enabled and has a non-zero panPressActivationDelay, so it
        // should activate
        await gesture.moveTo(tester.getCenter(TestItem.item2.findWidget));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        expect(controller.isOpen, isFalse);
        expect(pressed, TestItem.item2);
      });
      testWidgets('respects requestFocusOnHover property',
          (WidgetTester tester) async {
        final TestGesture gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          pointer: 1,
        );

        await gesture.addPointer(location: Offset.zero);
        addTearDown(() => gesture.removePointer());
        final List<(TestItem, bool)> focusChanges = <(TestItem, bool)>[];
        await tester.pumpWidget(
          buildTestApp(
            children: <Widget>[
              CupertinoMenuItem(
                requestFocusOnHover: true,
                onFocusChange: (bool value) {
                  focusChanges.add((TestItem.item0, value));
                },
                onPressed: () {},
                child: TestItem.item0.text,
              ),
              // Disabled item -- should not request focus
              CupertinoMenuItem(
                requestFocusOnHover: true,
                child: TestItem.item1.text,
                onFocusChange: (bool value) {
                  focusChanges.add((TestItem.item1, value));
                },
              ),
              CupertinoMenuItem(
                requestFocusOnHover: true,
                onFocusChange: (bool value) {
                  focusChanges.add((TestItem.item2, value));
                },
                onPressed: () {},
                child: TestItem.item2.text,
              ),
              // requestFocusOnHover is false -- should not request focus
              CupertinoMenuItem(
                onFocusChange: (bool value) {
                  focusChanges.add((TestItem.item3, value));
                },
                onPressed: () {},
                child: TestItem.item3.text,
              ),
              CupertinoMenuItem(
                requestFocusOnHover: true,
                onFocusChange: (bool value) {
                  focusChanges.add((TestItem.item4, value));
                },
                onPressed: () {},
                child: TestItem.item4.text,
              ),
            ],
          ),
        );
        controller.open();
        await tester.pumpAndSettle();

        // (item0, true)
        await gesture.moveTo(tester.getCenter(TestItem.item0.findWidget));
        await tester.pumpAndSettle();

        // (item0, false)
        await gesture.moveTo(tester.getCenter(TestItem.item1.findWidget));
        await tester.pumpAndSettle();

        // (item2, true)
        await gesture.moveTo(tester.getCenter(TestItem.item2.findWidget));
        await tester.pumpAndSettle();

        // No change -- requestFocusOnHover is false
        await gesture.moveTo(tester.getCenter(TestItem.item3.findWidget));
        await tester.pumpAndSettle();

        // (item2, false)
        // (item4, true)
        await gesture.moveTo(tester.getCenter(TestItem.item4.findWidget));
        await tester.pumpAndSettle();

        expect(focusChanges, <(TestItem, bool)>[
          (TestItem.item0, true),
          (TestItem.item0, false),
          (TestItem.item2, true),
          (TestItem.item2, false),
          (TestItem.item4, true),
        ]);
      });
      testWidgets('respects closeOnActivate property',
          (WidgetTester tester) async {
        await tester.pumpWidget(CupertinoApp(
          home: Center(
            child: CupertinoMenuAnchor(
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  onPressed: () {},
                  child: TestItem.item0.text,
                ),
              ],
              builder: _buildAnchor,
            ),
          ),
        ));

        await tester.tap(find.byType(CupertinoMenuAnchor));
        await tester.pump();

        expect(find.byType(CupertinoMenuItem), findsOneWidget);

        await tester.pumpAndSettle();

        // Taps the CupertinoMenuItem which should close the menu
        await tester.tap(TestItem.item0.findWidget);
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoMenuItem), findsNothing);

        await tester.pumpWidget(
          CupertinoApp(
            home: Center(
              child: CupertinoMenuAnchor(menuChildren: <Widget>[
                CupertinoMenuItem(
                  requestCloseOnActivate: false,
                  onPressed: () {},
                  child: TestItem.item0.text,
                ),
              ], builder: _buildAnchor),
            ),
          ),
        );

        await tester.tap(find.byType(CupertinoMenuAnchor));
        await tester.pump();

        expect(find.byType(CupertinoMenuItem), findsOneWidget);

        await tester.pumpAndSettle();

        // Taps the CupertinoMenuItem which shouldn't close the menu
        await tester.tap(TestItem.item0.findWidget);
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoMenuItem), findsOneWidget);
      });
      testWidgets('Shortcut mnemonics are displayed',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: CupertinoMenuAnchor(
                controller: controller,
                menuChildren: createTestItems(
                  shortcuts: <TestItem, MenuSerializableShortcut>{
                    TestItem.item0: const SingleActivator(
                      LogicalKeyboardKey.keyA,
                      control: true,
                    ),
                    TestItem.item1: const SingleActivator(
                      LogicalKeyboardKey.keyB,
                      shift: true,
                    ),
                    TestItem.item2: const SingleActivator(
                      LogicalKeyboardKey.keyC,
                      alt: true,
                    ),
                    TestItem.item3: const SingleActivator(
                      LogicalKeyboardKey.keyD,
                      meta: true,
                    ),
                  },
                ),
              ),
            ),
          ),
        );

        // Open a menu initially.
        controller.open();
        await tester.pumpAndSettle();

        Text mnemonic0;
        Text mnemonic1;
        Text mnemonic2;
        Text mnemonic3;

        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.linux:
            mnemonic0 = tester.widget(findMnemonic(TestItem.item0.label));
            expect(mnemonic0.data, equals('Ctrl+A'));
            mnemonic1 = tester.widget(findMnemonic(TestItem.item1.label));
            expect(mnemonic1.data, equals('Shift+B'));
            mnemonic2 = tester.widget(findMnemonic(TestItem.item2.label));
            expect(mnemonic2.data, equals('Alt+C'));
            mnemonic3 = tester.widget(findMnemonic(TestItem.item3.label));
            expect(mnemonic3.data, equals('Meta+D'));
          case TargetPlatform.windows:
            mnemonic0 = tester.widget(findMnemonic(TestItem.item0.label));
            expect(mnemonic0.data, equals('Ctrl+A'));
            mnemonic1 = tester.widget(findMnemonic(TestItem.item1.label));
            expect(mnemonic1.data, equals('Shift+B'));
            mnemonic2 = tester.widget(findMnemonic(TestItem.item2.label));
            expect(mnemonic2.data, equals('Alt+C'));
            mnemonic3 = tester.widget(findMnemonic(TestItem.item3.label));
            expect(mnemonic3.data, equals('Win+D'));
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            mnemonic0 = tester.widget(findMnemonic(TestItem.item0.label));
            expect(mnemonic0.data, equals('⌃ A'));
            mnemonic1 = tester.widget(findMnemonic(TestItem.item1.label));
            expect(mnemonic1.data, equals('⇧ B'));
            mnemonic2 = tester.widget(findMnemonic(TestItem.item2.label));
            expect(mnemonic2.data, equals('⌥ C'));
            mnemonic3 = tester.widget(findMnemonic(TestItem.item3.label));
            expect(mnemonic3.data, equals('⌘ D'));
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: CupertinoMenuAnchor(
                controller: controller,
                menuChildren: createTestItems(
                  shortcuts: <TestItem, MenuSerializableShortcut>{
                    TestItem.item0:
                        const SingleActivator(LogicalKeyboardKey.arrowRight),
                    TestItem.item1:
                        const SingleActivator(LogicalKeyboardKey.arrowLeft),
                    TestItem.item2:
                        const SingleActivator(LogicalKeyboardKey.arrowUp),
                    TestItem.item3:
                        const SingleActivator(LogicalKeyboardKey.arrowDown),
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        mnemonic0 = tester.widget(findMnemonic(TestItem.item0.label));
        expect(mnemonic0.data, equals('→'));
        mnemonic1 = tester.widget(findMnemonic(TestItem.item1.label));
        expect(mnemonic1.data, equals('←'));
        mnemonic2 = tester.widget(findMnemonic(TestItem.item2.label));
        expect(mnemonic2.data, equals('↑'));
        mnemonic3 = tester.widget(findMnemonic(TestItem.item3.label));
        expect(mnemonic3.data, equals('↓'));

        // Try some weirder ones.
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: CupertinoMenuAnchor(
                controller: controller,
                menuChildren: createTestItems(
                  shortcuts: <TestItem, MenuSerializableShortcut>{
                    TestItem.item0:
                        const SingleActivator(LogicalKeyboardKey.escape),
                    TestItem.item1:
                        const SingleActivator(LogicalKeyboardKey.fn),
                    TestItem.item2:
                        const SingleActivator(LogicalKeyboardKey.enter),
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        mnemonic0 = tester.widget(findMnemonic(TestItem.item0.label));
        expect(mnemonic0.data, equals('Esc'));
        mnemonic1 = tester.widget(findMnemonic(TestItem.item1.label));
        expect(mnemonic1.data, equals('Fn'));
        mnemonic2 = tester.widget(findMnemonic(TestItem.item2.label));
        expect(mnemonic2.data, equals('↵'));
      }, variant: TargetPlatformVariant.all());
    });
  });

  group('Semantics', () {
    testWidgets('CupertinoMenuItem is not a semantic button',
        (WidgetTester tester) async {
      final SemanticsTester semantics = SemanticsTester(tester);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: CupertinoMenuItem(
              onPressed: () {},
              constraints: BoxConstraints.tight(const Size(250, 48.0)),
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
                rect: const Rect.fromLTRB(0.0, 0.0, 250, 48),
                transform: Matrix4.translationValues(275.0, 276.0, 0.0),
                flags: <SemanticsFlag>[
                  SemanticsFlag.hasEnabledState,
                  SemanticsFlag.isEnabled,
                  SemanticsFlag.isFocusable,
                ],
                textDirection: TextDirection.rtl,
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

List<Widget> createTestItems({
  void Function(TestItem)? onPressed,
  Map<TestItem, MenuSerializableShortcut> shortcuts =
      const <TestItem, MenuSerializableShortcut>{},
  bool accelerators = false,
  double? leadingWidth,
  double? trailingWidth,
  BoxConstraints? constraints,
}) {
  Widget cupertinoMenuItemButton(
    TestItem menu, {
    bool enabled = true,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Key? key,
  }) {
    return CupertinoMenuItem(
      requestFocusOnHover: true,
      key: key,
      shortcut: shortcuts[menu],
      onPressed: enabled && onPressed != null ? () => onPressed(menu) : null,
      leading: leadingIcon,
      trailing: trailingIcon,
      child: accelerators
          ? MenuAcceleratorLabel(menu.acceleratorLabel)
          : menu.text,
    );
  }

  final List<Widget> result = <Widget>[
    cupertinoMenuItemButton(TestItem.item0, leadingIcon: const Icon(Icons.add)),
    cupertinoMenuItemButton(TestItem.item1),
    const CupertinoLargeMenuDivider(),
    cupertinoMenuItemButton(TestItem.item2),
    cupertinoMenuItemButton(
      TestItem.item3,
      leadingIcon: const Icon(Icons.add),
      trailingIcon: const Icon(Icons.add),
    ),
    cupertinoMenuItemButton(TestItem.item4),
    const CupertinoLargeMenuDivider(),
    cupertinoMenuItemButton(TestItem.item5Disabled, enabled: false),
    cupertinoMenuItemButton(TestItem.item6),
  ];
  return result;
}

enum TestItem {
  item0('Item 0'),
  item1('Item 1'),
  item2('Item 2'),
  item3('Item 3'),
  item4('Item 4'),
  item5Disabled('Item 5'),
  item6('Item 6'),

  anchorButton('Press Me'),
  outsideButton('Outside');

  const TestItem(this.acceleratorLabel);
  final String acceleratorLabel;
  // Strip the accelerator markers.
  String get label =>
      MenuAcceleratorLabel.stripAcceleratorMarkers(acceleratorLabel);
  Finder get findText => find.text(label);
  Finder get findWidget => find.widgetWithText(CupertinoMenuItem, label);
  Text get text => Text(label);
}

class _DebugCupertinoMenuEntryMixin extends StatelessWidget
    with CupertinoMenuEntryMixin {
  const _DebugCupertinoMenuEntryMixin({
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

// Generic button that opens a menu. Used insead of a TextButton or
// CupertinoButton to avoid flaky tests in the future.
Widget _buildAnchor(
  BuildContext context,
  MenuController controller,
  Widget? child,
) {
  return ConstrainedBox(
    constraints: const BoxConstraints.tightFor(width: 48, height: 48),
    child: Material(
        child: InkWell(
      onTap: () {
        if (controller.isOpen) {
          controller.close();
        } else {
          controller.open();
        }
      },
      child: TestItem.anchorButton.text,
    )),
  );
}
