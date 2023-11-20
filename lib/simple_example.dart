


import 'dart:ui';

import 'package:flutter/cupertino.dart' show CupertinoApp, CupertinoButton, CupertinoColors, CupertinoIcons, CupertinoNavigationBar, CupertinoPageScaffold, CupertinoSlider, CupertinoSwitch, CupertinoThemeData;
import 'package:flutter/widgets.dart';

import 'menu.dart';
import 'menu_item.dart';


enum SortOption {
  name('Name'),
  kind('Kind'),
  date('Date'),
  size('Size'),
  tags('Tags');

  const SortOption(this.label);
  final String label;
}

enum ViewOption {
  name('Name'),
  kind('Kind'),
  date('Date'),
  size('Size'),
  tags('Shared by');

  const ViewOption(this.label);
  final String label;
}

class CupertinoMenuApp extends StatelessWidget {
  const CupertinoMenuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: CupertinoMenuExample(),
    );
  }
}

class CupertinoMenuExample extends StatefulWidget {
  const CupertinoMenuExample({super.key});

  @override
  State<CupertinoMenuExample> createState() => _CupertinoMenuExampleState();
}

class _CupertinoMenuExampleState extends State<CupertinoMenuExample> {

  late final List<CupertinoMenuEntry<String>> Function(BuildContext context) childrenBuilder = (BuildContext context) {
                      return <CupertinoMenuEntry<String>>[
                        const CupertinoMenuItem(value: 'Name', child: Text('Name')),
                      ];
                    };

  @override
  Widget build(BuildContext context) {
    return  CupertinoApp(
    home: CupertinoPageScaffold(
      child: Center(
        child: Builder(
          builder: (BuildContext context)=> CupertinoMenuButton<String>(
            itemBuilder: childrenBuilder,
            child: const Text('Show menu'),
          )
        ),
      ),
    ),
  );
  }
}
