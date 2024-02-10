// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'menu.dart';

/// An enhanced enum to define the available menus and their shortcuts.
///
/// Using an enum for menu definition is not required, but this illustrates how
/// they could be used for simple menu systems.
enum MenuEntry {
  itemOne('Item 1', SingleActivator(LogicalKeyboardKey.keyS, shift: true)),
  itemTwo('Item 2', SingleActivator(LogicalKeyboardKey.keyS, control: true)),
  itemThree('Item 3', SingleActivator(LogicalKeyboardKey.keyS, alt: true));

  const MenuEntry(this.label, [this.shortcut]);

  final String label;
  final MenuSerializableShortcut? shortcut;
}


class MyCupertinoMenu extends StatefulWidget {
  const MyCupertinoMenu({super.key});

  @override
  State<MyCupertinoMenu> createState() => _MyCupertinoMenuState();
}

class _MyCupertinoMenuState extends State<MyCupertinoMenu> {
  ShortcutRegistryEntry? _shortcutsEntry;

  bool get isItemThreeEnabled => _isItemThreeEnabled;
  bool _isItemThreeEnabled = true;
  set isItemThreeEnabled(bool value) {
    if(value != _isItemThreeEnabled) {
      setState(() {
        _isItemThreeEnabled = value;
      });
    }
  }

  String get message => _message;
  String _message = 'No shortcut has been activated.';
  set message(String value) {
    if(value != _message) {
      setState(() {
        _message = value;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dispose of any previously registered shortcuts, since they are about to
    // be replaced.
    _shortcutsEntry?.dispose();
    // Collect the shortcuts from the different menu selections so that they can
    // be registered to apply to the entire app. Menus don't register their
    // shortcuts, they only display the shortcut hint text.
    final Map<ShortcutActivator, Intent> shortcuts = <ShortcutActivator, Intent>{
      for (final MenuEntry item in MenuEntry.values)
        if (item.shortcut != null)
          item.shortcut!: VoidCallbackIntent(() => _handleShortcut(item)),
    };
    // Register the shortcuts with the ShortcutRegistry so that they are
    // available to the entire application.
    _shortcutsEntry = ShortcutRegistry.of(context).addAll(shortcuts);
  }

  @override
  void dispose() {
    _shortcutsEntry?.dispose();
    super.dispose();
  }

  void _handleShortcut(MenuEntry entry) {
    message = switch (entry) {
      MenuEntry.itemThree when !_isItemThreeEnabled =>
        "Whoops, Item 3 should be disabled! Shortcuts shouldn't work!",
      MenuEntry.itemThree ||
      MenuEntry.itemOne ||
      MenuEntry.itemTwo =>
        'The shortcut for ${entry.label} was activated!'
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(message),
        Align(
          child: CupertinoMenuAnchor(
            menuChildren: <Widget>[
              CupertinoMenuItem(
                onPressed: () {
                  message = 'Item 1 was pressed.';
                },
                shortcut: MenuEntry.itemOne.shortcut,
                child: Text(MenuEntry.itemOne.label),
              ),
              CupertinoMenuItem(
                onPressed: () {
                  isItemThreeEnabled = !isItemThreeEnabled;
                  message = 'Item 2 was pressed.';
                },
                requestCloseOnActivate: false,
                shortcut: MenuEntry.itemTwo.shortcut,
                subtitle: Text(
                    'Tap to ${isItemThreeEnabled ? "disable" : "enable"}'
                    ' item 3.',),
                child: Text(MenuEntry.itemTwo.label),
              ),
              const CupertinoLargeMenuDivider(),
              CupertinoMenuItem(
                onPressed: _isItemThreeEnabled
                    ? () {
                        message = 'Item 3 was pressed';
                      }
                    : null,
                shortcut: MenuEntry.itemThree.shortcut,
                subtitle: _isItemThreeEnabled
                    ? const Text('Enabled')
                    : const Text('Disabled'),
                child: Text(MenuEntry.itemThree.label),
              ),
            ],
            builder: (
              BuildContext context,
              CupertinoMenuController controller,
              Widget? child,
            ) {
              return TextButton(
                onPressed: () {
                  if (controller.menuStatus
                      case MenuStatus.opened || MenuStatus.opening) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: const Text('OPEN MENU'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CupertinoMenuApp extends StatelessWidget {
  const CupertinoMenuApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: CupertinoPageScaffold(
        child: MyCupertinoMenu(),
      ),
    );
  }
}

