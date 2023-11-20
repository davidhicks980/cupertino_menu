// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_menu/menu.dart';
import 'package:cupertino_menu/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/cupertino/app.dart';
import 'package:flutter/src/cupertino/page_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('CupertinoMenuControlMixin', () {
    Future<void> rootTest(
      WidgetTester tester, {
      required GlobalKey key,
      required CupertinoMenuControlMixin controller,
    }) async {
      expect(find.byKey(key), findsNothing);
      expect(controller.isOpen, isFalse);
      controller.open();
      await tester.pumpAndSettle();
      expect(find.byKey(key), findsOneWidget);
      expect(controller.isOpen, isTrue);
      controller.close();
      await tester.pumpAndSettle();
      expect(find.byKey(key), findsNothing);
      expect(controller.isOpen, isFalse);
      controller.open();
      await tester.pumpAndSettle();
      expect(find.byKey(key), findsOneWidget);
      expect(controller.isOpen, isTrue);
      Navigator.pop(key.currentContext!);
      await tester.pumpAndSettle();
      expect(find.byKey(key), findsNothing);
      expect(controller.isOpen, isFalse);
    }

    testWidgets(
        'CupertinoMenuController opens and closes a CupertinoMenuButton',
        (WidgetTester tester) async {
      final SampleMenu<dynamic> menu =
          SampleMenu<dynamic>(withController: true);
      await tester.pumpWidget(buildApp(menu.build));
      await rootTest(
        tester,
        key: menu.root.key,
        controller: menu.root.control,
      );
    });

    testWidgets(
        'GlobalKey<CupertinoMenuButtonState> opens and closes a CupertinoMenuButton',
        (WidgetTester tester) async {
      final SampleMenu<dynamic> menu =
          SampleMenu<dynamic>(withController: true);
      await tester.pumpWidget(buildApp(menu.build));
      await rootTest(
        tester,
        key: menu.root.key,
        controller: menu.root.key.currentState!,
      );
    });
  });

  testWidgets('[Nested] CupertinoMenuController opens a CupertinoNestedMenu',
      (WidgetTester tester) async {
    final SampleNestedMenu menu = SampleNestedMenu(withController: true);
    await tester.pumpWidget(buildApp(
      menu.build,
    ));

    void test(bool root, bool sub_1, bool sub_1_1) {
      expect(menu.root.control.isOpen, root ? isTrue : isFalse);
      expect(menu.sub_1.control.isOpen, sub_1 ? isTrue : isFalse);
      expect(menu.sub_1_1.control.isOpen, sub_1_1 ? isTrue : isFalse);
      expect(find.byKey(menu.sub_1.key), root ? findsOneWidget : findsNothing);
      expect(
          find.byKey(menu.sub_1_1.key), sub_1 ? findsOneWidget : findsNothing);
      expect(find.text(menu.sub_1_1.itemText),
          sub_1_1 ? findsOneWidget : findsNothing);
    }

    test(false, false, false);
    menu.root.control.open();
    await tester.pumpAndSettle();
    test(true, false, false);
    menu.sub_1.control.open();
    await tester.pumpAndSettle();
    test(true, true, false);
    menu.sub_1_1.control.open();
    await tester.pumpAndSettle();
    test(true, true, true);
  });
  testWidgets(
      '[Nested] CupertinoMenuController opens and closes a CupertinoNestedMenu',
      (WidgetTester tester) async {
    final SampleNestedMenu menu = SampleNestedMenu(withController: true);
    await tester.pumpWidget(buildApp(menu.build));

    void test(bool root, bool sub_1, bool sub_1_1) {
      expect(menu.root.control.isOpen, root ? isTrue : isFalse);
      expect(menu.sub_1.control.isOpen, sub_1 ? isTrue : isFalse);
      expect(menu.sub_1_1.control.isOpen, sub_1_1 ? isTrue : isFalse);
      expect(find.byKey(menu.sub_1.key), root ? findsOneWidget : findsNothing);
      expect(
          find.byKey(menu.sub_1_1.key), sub_1 ? findsOneWidget : findsNothing);
      expect(find.text(menu.sub_1_1.itemText),
          sub_1_1 ? findsOneWidget : findsNothing);
    }

    menu.root.control.open();
    await tester.pumpAndSettle();
    test(true, false, false);
    menu.sub_1.control.open();
    await tester.pumpAndSettle();
    test(true, true, false);
    menu.sub_1_1.control.open();
    await tester.pumpAndSettle();
    test(true, true, true);

    test(true, true, true);
    menu.sub_1_1.control.close();
    await tester.pumpAndSettle();
    test(true, true, false);
    menu.sub_1.control.close();
    await tester.pumpAndSettle();
    test(true, false, false);
    menu.root.control.close();
    await tester.pumpAndSettle();
    test(false, false, false);
  });

  testWidgets(
      '[Nested] GlobalKey<CupertinoNestedMenuControlMixin> opens a CupertinoNestedMenu',
      (WidgetTester tester) async {
    final SampleNestedMenu menu = SampleNestedMenu(withController: false);
    await tester.pumpWidget(buildApp(
      menu.build,
    ));

    void test(bool root, bool sub_1, bool sub_1_1) {
      expect(find.byKey(menu.sub_1.key), root ? findsOneWidget : findsNothing);
      expect(
          find.byKey(menu.sub_1_1.key), sub_1 ? findsOneWidget : findsNothing);
      expect(find.text(menu.sub_1_1.itemText),
          sub_1_1 ? findsOneWidget : findsNothing);
    }

    test(false, false, false);

    menu.sub_1_1.key.currentState!.open();
    await tester.pumpAndSettle();
    test(false, false, true);

    menu.sub_1.key.currentState!.open();
    await tester.pumpAndSettle();
    test(false, true, true);

    menu.root.key.currentState!.open();
    await tester.pumpAndSettle();
    test(true, true, true);
  });

  testWidgets(
      '[Nested] GlobalKey<CupertinoNestedMenuControlMixin> closes a CupertinoNestedMenu',
      (WidgetTester tester) async {
    final SampleNestedMenu menu = SampleNestedMenu(withController: false);
    await tester.pumpWidget(buildApp(menu.build));

    void test(bool root, bool sub_1, bool sub_1_1) {
      expect(find.byKey(menu.sub_1.key), root ? findsOneWidget : findsNothing);
      expect(
          find.byKey(menu.sub_1_1.key), sub_1 ? findsOneWidget : findsNothing);
      expect(find.text(menu.sub_1_1.itemText),
          sub_1_1 ? findsOneWidget : findsNothing);
    }

    menu.root.key.currentState!.open();
    await tester.pumpAndSettle();
    menu.sub_1.key.currentState!.open();
    await tester.pumpAndSettle();
    menu.sub_1_1.key.currentState!.open();
    await tester.pumpAndSettle();

    test(true, true, true);
    menu.sub_1_1.key.currentState!.close();
    await tester.pumpAndSettle();
    test(true, true, false);
    menu.sub_1.key.currentState!.close();
    await tester.pumpAndSettle();
    test(true, false, false);
    menu.root.key.currentState!.close();
    await tester.pumpAndSettle();
    test(false, false, false);
  });

  testWidgets(
      'GlobalKey<CupertinoMenuButtonState>.rebuild() rebuilds a CupertinoMenuButton',
      (WidgetTester tester) async {
    final SampleMenu<String> menu = SampleMenu<String>(withController: false);
    CupertinoMenuButtonState<dynamic>? rootState() =>
        menu.root.key.currentState;
    // ignore: prefer_final_locals
    bool checked = false;
    await tester.pumpWidget(buildApp(
      (BuildContext context) => menu.build(
        context,
        (BuildContext context, ControlSet<State<StatefulWidget>> control) {
          return <CupertinoMenuEntry<String>>[
            CupertinoCheckedMenuItem<String>(
              shouldPopMenuOnPressed: false,
              checked: checked,
              onTap: () {
                checked = !checked;
              },
              child: Text(control.itemText),
            ),
          ];
        },
      ),
    ));

    rootState()!.open();
    await tester.pumpAndSettle();
    expect(find.text(menu.root.itemText), findsOne);
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);

    await tester.tap(find.text(menu.root.itemText));
    rootState()!.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsOneWidget);

    await tester.tap(find.text(menu.root.itemText));
    rootState()!.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);
  });

  testWidgets('rebuildSignal rebuilds a CupertinoMenuButton',
      (WidgetTester tester) async {
    final GlobalKey rootKey = GlobalKey();
    final ValueNotifier<int> rebuildSignal = ValueNotifier<int>(0);
    const String text = 'One';
    // ignore: prefer_final_locals
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: SizedBox.square(
              key: rootKey,
              dimension: 50,
            ),
          ),
        ),
      ),
    );
    bool checked = false;
    showCupertinoMenu(
      context: rootKey.currentContext!,
      anchorPosition: RelativeRect.fill,
      rebuildSignal: rebuildSignal,
      itemBuilder: (BuildContext context) {
        return <CupertinoMenuEntry<String>>[
          CupertinoCheckedMenuItem<String>(
            shouldPopMenuOnPressed: false,
            checked: checked,
            onTap: () {
              checked = !checked;
            },
            child: const Text(text),
          ),
        ];
      },
    );

    await tester.pumpAndSettle();
    expect(find.text(text), findsOne);
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);

    await tester.tap(find.text(text));
    rebuildSignal.value++;
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsOneWidget);

    await tester.tap(find.text(text));
    rebuildSignal.value++;
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);
  });

  testWidgets('CupertinoMenuController.rebuild() rebuilds a CupertinoMenu',
      (WidgetTester tester) async {
    final CupertinoMenuController controller = CupertinoMenuController();
    const String text = 'item';
    // ignore: prefer_final_locals
    bool checked = false;
    await tester.pumpWidget(
      buildSample(
        controller: controller,
        itemBuilder: (BuildContext context) {
          return <CupertinoMenuEntry<String>>[
            CupertinoCheckedMenuItem<String>(
              shouldPopMenuOnPressed: false,
              checked: checked,
              onTap: () {
                checked = !checked;
              },
              child: const Text(text),
            ),
          ];
        },
      ),
    );

    controller.open();
    await tester.pumpAndSettle();
    expect(find.text(text), findsOne);
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);
    await tester.tap(find.text(text));
    controller.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsOneWidget);
    await tester.tap(find.text(text));
    controller.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);
  });

  testWidgets('CupertinoMenuController.rebuild() rebuilds a CupertinoNestedMenu',
      (WidgetTester tester) async {
    final SampleNestedMenu menu = SampleNestedMenu(withController: true);
    // ignore: prefer_final_locals
    String checked = '';
    await tester.pumpWidget(
      buildApp(
        (BuildContext context)=> menu.build(
          context,
            (BuildContext context, ControlSet<State<StatefulWidget>> control) {
            return <CupertinoMenuEntry<String>>[
              CupertinoCheckedMenuItem<String>(
                shouldPopMenuOnPressed: false,
                checked: checked == control.itemText,
                onTap: () {
                  checked = checked == control.itemText ? '' : control.itemText;
                },
                child: Text(control.itemText),
              ),
            ];
          }
        )
      ),
    );

    menu.root.control.open();
    await tester.pumpAndSettle();
    expect(find.text(menu.root.itemText), findsOne);
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);

    await tester.tap(find.text(menu.root.itemText));
    menu.root.control.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsOneWidget);

    await tester.tap(find.text(menu.root.itemText));
    menu.root.control.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);


    menu.sub_1.control.open();
    await tester.pumpAndSettle();
    expect(find.text(menu.sub_1.itemText), findsOne);
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);

    await tester.tap(find.text(menu.sub_1.itemText));
    menu.sub_1.control.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsOneWidget);

    await tester.tap(find.text(menu.sub_1.itemText));
    menu.sub_1.control.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);


    menu.sub_1_1.control.open();
    await tester.pumpAndSettle();
    expect(find.text(menu.sub_1_1.itemText), findsOne);
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);

    await tester.tap(find.text(menu.sub_1_1.itemText));
    menu.sub_1_1.control.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsOneWidget);

    await tester.tap(find.text(menu.sub_1_1.itemText));
    menu.sub_1_1.control.rebuild();
    await tester.pumpAndSettle();
    expect(find.semantics.byFlag(SemanticsFlag.isChecked), findsNothing);
  });
}
