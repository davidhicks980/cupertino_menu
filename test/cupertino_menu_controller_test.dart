// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('CupertinoMenuController', () {
    Future<void> runOpenClose(
      WidgetTester tester,
      SampleMenu menu, {
      VoidCallback? beforeOpening,
      VoidCallback? onOpening,
      VoidCallback? onOpened,
      VoidCallback? onClosing,
      VoidCallback? afterClose,
    }) async {
      await tester.pumpWidget(menu.buildSimpleApp());
      await tester.pumpAndSettle();
      beforeOpening?.call();
      menu.control.open();
      await tester.pump();
      onOpening?.call();
      await tester.pumpAndSettle();
      onOpened?.call();
      menu.control.close();
      await tester.pump();
      onClosing?.call();
      await tester.pumpAndSettle();
      afterClose?.call();
      menu.resetControl();
    }

    testWidgets('CupertinoMenuController closes when Navigator.pop() is called',
        (WidgetTester tester) async {
      final SampleMenu menu = SampleMenu(withController: true);
      await tester.pumpWidget();
      menu.control.open();
      await tester.pumpAndSettle();
      expect(menu.findItem(0), findsOneWidget);
      expect(menu.control.isOpen, isTrue);
      Navigator.pop(menu.overlay.anchorKey.currentContext!);
      await tester.pumpAndSettle();
      expect(menu.findItem(0), findsNothing);
      expect(menu.control.isOpen, isFalse);
    });

    testWidgets(
        'CupertinoMenuController opens and closes a CupertinoMenuButton',
        (WidgetTester tester) async {
      final SampleMenu menu = SampleMenu(withController: true);

      // Create the menu. The menu is closed, so no menu items should be found in
      // the widget tree.
      await tester.pumpWidget(menu.buildSimpleApp());
      await tester.pumpAndSettle();
      expect(menu.control.animationStatus, AnimationStatus.dismissed);
      expect(menu.findItem(0), findsNothing);
      expect(menu.control.isOpen, isFalse);

      // Open the menu.
      menu.control.open();
      await tester.pump();

      // The menu is opening => AnimationStatus.forward.
      expect(menu.control.animationStatus, AnimationStatus.forward);
      expect(menu.control.isOpen, isTrue);
      expect(menu.findItem(0), findsOneWidget);

      // After 100 ms, the menu should still be animating open.
      await tester.pump(const Duration(milliseconds: 100));
      expect(menu.control.animationStatus, AnimationStatus.forward);
      expect(menu.control.isOpen, isTrue);
      expect(menu.findItem(0), findsOneWidget);

      // Interrupt the opening animation by closing the menu.
      menu.control.close();
      await tester.pump();

      // The menu is closing => AnimationStatus.reverse.
      expect(menu.control.animationStatus, AnimationStatus.reverse);
      expect(menu.control.isOpen, isTrue);
      expect(menu.findItem(0), findsOneWidget);

      // Open the menu again.
      menu.control.open();
      await tester.pump();

      // The menu is animating open => AnimationStatus.forward.
      expect(menu.control.animationStatus, AnimationStatus.forward);
      expect(menu.control.isOpen, isTrue);
      expect(menu.findItem(0), findsOneWidget);

      await tester.pumpAndSettle();

      // The menu has finished opening, so it should report it's animation
      // status as AnimationStatus.completed.
      expect(menu.control.animationStatus, AnimationStatus.completed);
      expect(menu.control.isOpen, isTrue);
      expect(menu.findItem(0), findsOneWidget);

      // Close the menu.
      menu.control.close();
      await tester.pump();

      expect(menu.control.animationStatus, AnimationStatus.reverse);
      expect(menu.control.isOpen, isTrue);
      expect(menu.findItem(0), findsOneWidget);

      // After 100 ms, the menu should still be closing.
      await tester.pump(const Duration(milliseconds: 100));
      expect(menu.control.animationStatus, AnimationStatus.reverse);
      expect(menu.control.isOpen, isTrue);
      expect(menu.findItem(0), findsOneWidget);

      // Interrupt the closing animation by opening the menu.
      menu.control.open();
      await tester.pump();

      // The menu is animating open => AnimationStatus.forward.
      expect(menu.control.animationStatus, AnimationStatus.forward);
      expect(menu.control.isOpen, isTrue);
      expect(menu.findItem(0), findsOneWidget);

      // Close the menu again.
      menu.control.close();
      await tester.pump();

      // The menu is closing => AnimationStatus.reverse.
      expect(menu.control.animationStatus, AnimationStatus.reverse);
      expect(menu.control.isOpen, isTrue);
      expect(menu.findItem(0), findsOneWidget);

      await tester.pumpAndSettle();

      // The menu has closed => AnimationStatus.dismissed.
      expect(menu.control.animationStatus, AnimationStatus.dismissed);
      expect(menu.control.isOpen, isFalse);
      expect(menu.findItem(0), findsNothing);
    });
  });
}
