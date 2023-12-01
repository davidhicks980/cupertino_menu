import 'package:flutter/cupertino.dart'
    show
        CupertinoApp,
        CupertinoButton,
        CupertinoColors,
        CupertinoIcons,
        CupertinoNavigationBar,
        CupertinoPageScaffold,
        CupertinoSlider,
        CupertinoSwitch,
        CupertinoThemeData;
import 'package:flutter/widgets.dart';

import 'menu.dart';
import 'menu_item.dart';

// import 'menu.dart';
// import 'menu_item.dart';

enum SortOption {
  name('Name'),
  kind('Kind'),
  date('Date'),
  size('Size'),
  tags('Tags'),
  who('Who'),
  what('What'),
  where('Where'),
  why('When'),
  how('How'),
  howMany('How Many'),
  howMuch('How Much'),
  howLong('How Long');

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



class CupertinoMenuExample extends StatefulWidget {
  const CupertinoMenuExample({super.key});

  @override
  State<CupertinoMenuExample> createState() => _CupertinoMenuExampleState();
}

class _CupertinoMenuExampleState extends State<CupertinoMenuExample> {
  final SortOption _sortValue = SortOption.name;
  final bool _sortAscending = false;
  final ViewOption _viewOptionsValue = ViewOption.name;

  TextDirection _directionality = TextDirection.ltr;

  double _textSizeSliderValue = 1.0;

   List<Widget> Function(BuildContext context) get childrenBuilder => (BuildContext context) {
    return <Widget>[
      CupertinoStickyMenuHeader(
        leading: Container(
          width: 42,
          height: 42,
          decoration: ShapeDecoration(
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
      CupertinoMenuItem(
        trailing: const Icon(CupertinoIcons.check_mark_circled),
        child: const Text('Select'),
        onTap: () {},
      ),
      CupertinoMenuItem(
        trailing: const Icon(CupertinoIcons.folder_badge_plus),
        child: const Text('New Folder'),
        onTap: () {},
      ),
      CupertinoMenuItem(
        trailing: const Icon(CupertinoIcons.doc_text_viewfinder),
        child: const Text('Scan Documents really long documents'),
        onTap: () {},
      ),
      const CupertinoMenuLargeDivider(),
      CupertinoMenuItem(
        trailing: const Icon(CupertinoIcons.square_grid_2x2),
        child: const Text('Icons'),
        onTap: () {},
      ),
      CupertinoCheckedMenuItem(
        trailing: const Icon(CupertinoIcons.list_bullet),
        child: const Text('List'),
        onTap: () {},
      ),
      const CupertinoMenuLargeDivider(),
      CupertinoNestedMenu(
        title: const TextSpan(text: 'Large Submenu'),
        itemBuilder: (BuildContext context) => <CupertinoMenuEntry>[
          CupertinoNestedMenu(
              title: const TextSpan(text: 'Large Submenu'),
              itemBuilder: (BuildContext context) =>
                  <CupertinoMenuEntry>[
                    const CupertinoMenuItem(child: Text('It just keeps going')),
                    const CupertinoMenuItem(
                        child: Text('Really, another one?')),
                    const CupertinoMenuItem(
                        child: Text('Is this really necessary?')),
                    CupertinoNestedMenu(
                        title: const TextSpan(text: 'Large Submenu'),
                        itemBuilder: (BuildContext context) =>
                            <CupertinoMenuEntry>[
                              const CupertinoMenuItem(
                                  child: Text('It just keeps going')),
                              const CupertinoMenuItem(
                                  child: Text('Really, another one?')),
                              const CupertinoMenuItem(
                                  child: Text('Is this really necessary?')),
                              CupertinoNestedMenu(
                                  title: const TextSpan(text: 'Large Submenu'),
                                  itemBuilder: (BuildContext context) =>
                                      <CupertinoMenuEntry>[
                                        const CupertinoMenuItem(
                                            child: Text('It just keeps going')),
                                        const CupertinoMenuItem(
                                            child:
                                                Text('Really, another one?')),
                                        const CupertinoMenuItem(
                                            child: Text(
                                                'Is this really necessary?')),
                                      ])
                            ])
                  ])
        ],
      )
    ];
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _directionality,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(_textSizeSliderValue)),
        child:  SafeArea(
                child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CupertinoMenuButton(itemBuilder: childrenBuilder),
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
                      Text('Text ${MediaQuery.textScalerOf(context).scale(1)}'),
                      CupertinoSwitch(
                        value: _directionality == TextDirection.ltr,
                        onChanged: (bool value) {
                          setState(() {
                            _directionality =
                                value ? TextDirection.ltr : TextDirection.rtl;
                          });
                        },
                      ),
                    ],
                  ),
              ),
      ),
    );
  }
}
