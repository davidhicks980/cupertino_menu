
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
  SortOption _sortValue = SortOption.name;
  bool _sortAscending = false;
  ViewOption _viewOptionsValue = ViewOption.name;

   TextDirection _directionality = TextDirection.ltr;

  double _textSizeSliderValue =1.0;

  late final List<CupertinoMenuEntry<String>> Function(BuildContext context) childrenBuilder = (BuildContext context) {
                      return <CupertinoMenuEntry<String>>[
                        CupertinoStickyMenuHeader(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration:  ShapeDecoration(
                        shape: const CircleBorder(),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            CupertinoColors.activeBlue,
                            CupertinoColors.activeBlue.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    trailing: CupertinoButton(
                      minSize: 34,
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: CupertinoColors.systemFill.resolveFrom(context),
                        ),
                        child: Icon(
                          CupertinoIcons.share,
                          color: CupertinoColors.label.resolveFrom(context),
                          size: 16,
                          semanticLabel: 'Triangle',
                        ),
                      ),
                      onPressed: () {},
                    ),
                    subtitle: const Text('Folder'),
                    child: const Text('Downloads'),
                  ),
                        CupertinoMenuItem<String>(
                          trailing: const Icon(CupertinoIcons.check_mark_circled),
                          child: const Text('Select'),
                          onTap: () {},
                        ),
                        CupertinoMenuItem<String>(
                          trailing: const Icon(CupertinoIcons.folder_badge_plus),
                          child: const Text('New Folder'),
                          onTap: () {},
                        ),
                        CupertinoMenuItem<String>(
                          trailing: const Icon(CupertinoIcons.doc_text_viewfinder),
                          child: const Text('Scan Documents really long documents'),
                          onTap: () {},
                        ),
                        CupertinoMenuItem<String>(
                          trailing: const Icon(CupertinoIcons.squares_below_rectangle),
                          child: const Text('Connect to Server a raelly long server'),
                          onTap: () {},
                        ),
                        const CupertinoMenuLargeDivider(),
                        CupertinoMenuItem<String>(
                          trailing: const Icon(CupertinoIcons.square_grid_2x2),
                          child: const Text('Icons'),
                          onTap: () {},
                        ),
                        CupertinoCheckedMenuItem<String>(
                          trailing: const Icon(CupertinoIcons.list_bullet),
                          child: const Text('List'),
                          onTap: () {},
                        ),
                        const CupertinoMenuLargeDivider(),
                        for (final SortOption option in SortOption.values)
                          CupertinoCheckedMenuItem<String>(
                            checked: _sortValue == option,
                            trailing: _sortValue == option
                                        ? _sortAscending
                                          ? const Icon(CupertinoIcons.chevron_up, size: 18)
                                          : const Icon(CupertinoIcons.chevron_down, size: 18)
                                        : null,
                            onTap: () {
                              setState(() {
                                _sortAscending = _sortValue == option && !_sortAscending;
                                _sortValue = option;
                              });
                            },
                            child: Text(option.label),
                          ),
                        const CupertinoMenuLargeDivider(),
                        CupertinoNestedMenu<String>(
                          title: const TextSpan(text: 'View Options'),
                          itemBuilder: (BuildContext context) {
                            return <CupertinoMenuEntry<String>>[
                              const CupertinoMenuTitle(
                                textAlign: TextAlign.left,
                                child: Text('Group by:'),
                              ),
                              for(final ViewOption option in ViewOption.values)
                                CupertinoCheckedMenuItem<String>(
                                  checked: _viewOptionsValue == option,
                                  child: Text(option.label),
                                  onTap: () {
                                    setState(() {
                                      _viewOptionsValue = option;
                                    });
                                  },
                                ),
                              const CupertinoMenuLargeDivider(),
                              CupertinoMenuItem<String>(
                                child: const Text('Show All Extensions'),
                                onTap: () {},
                              ),
                            ];
                          },
                        ),
                      ];
                    };

  @override
  Widget build(BuildContext context) {
    return  Directionality(
        textDirection: _directionality,
        child: Builder(
          builder: (BuildContext context) {
            return CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(
                middle: Text('CupertinoMenu Sample'),
              ),
              child:  SafeArea(
                child: Center(
                  child: SizedBox(
                    height: 800,
                    width: 400,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 600,
                          width: 800,
                          child: CupertinoMenu<String>(
                            animation: kAlwaysCompleteAnimation,
                            anchorPosition: RelativeRect.fill,
                            hasLeadingWidget: true,
                            brightness: Brightness.light,
                            anchorSize: Size.zero,
                            alignment: Alignment.center,
                            children: childrenBuilder(context),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(20),
                          height: 50,
                          width: 200,
                          child: CupertinoSlider(
                            value: _textSizeSliderValue,
                            min: 0.9,
                            max: 3,
                            onChanged: (double value) {
                            setState(() {
                              _textSizeSliderValue = value;
                            });
                          }),
                        ),
                        CupertinoSwitch(
                          value: _directionality == TextDirection.ltr,
                          onChanged: (bool value) {
                            setState(() {
                             _directionality = value ? TextDirection.ltr : TextDirection.rtl;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
    );
  }
}
