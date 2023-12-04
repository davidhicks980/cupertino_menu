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
import 'package:flutter/material.dart' show Colors, MenuStyle, TextButton;
import 'package:flutter/widgets.dart';

import 'cupertino_menu_anchor.dart';
import 'menu_item.dart';
import 'test_anchor.dart' show MenuController, MenuItemButton;

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
  TextDirection _directionality = TextDirection.ltr;

  double _textSizeSliderValue = 1.0;

  bool _checked = false;

  bool _background = true;
  Rect anchorPosition = const Rect.fromLTWH(0, 0, 200, 40);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _directionality,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(_textSizeSliderValue)),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              if (_background)
                Positioned.fill(
                    child: Image.asset(
                  'assets/image.avif',
                  fit: BoxFit.contain,
                )),
              Positioned.fromRect(
                  rect: anchorPosition,
                  child: Draggable(
                    onDragUpdate: (DragUpdateDetails location) {
                      setState((){
anchorPosition = anchorPosition.shift(location.delta);
                      });
                    },
                    feedback: const Icon(CupertinoIcons.bars),
                    child: CupertinoMenuAnchor(
                      menuChildren: <Widget>[
                        // MenuItemButton(
                        //   child: const Text('About'),
                        //   onPressed: () {},
                        // ),
                        // MenuItemButton(
                        //   child: const Text('About'),
                        //   onPressed: () {},
                        // ),
                        // MenuItemButton(
                        //   child: const Text('About'),
                        //   onPressed: () {},
                        // ),

                        CupertinoMenuItem(
                          trailing:
                              const Icon(CupertinoIcons.check_mark_circled),
                          child: const Text('Favorite Animal'),
                          onTap: () {},
                        ),
                        CupertinoMenuItem(
                          trailing:
                              const Icon(CupertinoIcons.folder_badge_plus),
                          child: const Text('New Folder'),
                          onTap: () {},
                        ),
                        CupertinoCheckedMenuItem(
                          checked: _checked,
                          trailing:
                              const Icon(CupertinoIcons.doc_text_viewfinder),
                          child: const Text(
                              'Scan Documents really long documents'),
                          onTap: () {
                            setState(() {
                              _checked = !_checked;
                            });
                          },
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
                      ],
                      child: Container(
                              color: Colors.lightBlue,
                              child: const Center(child: Text('OPEN MENU'),),),
                      builder: (BuildContext context, MenuController controller,
                          Widget? child) {
                        return GestureDetector(
                          onTap: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          child: child
                        );
                      },
                    ),
                  )),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                        setState(
                          () {
                            _directionality =
                                value ? TextDirection.ltr : TextDirection.rtl;
                          },
                        );
                      },
                    ),
                    CupertinoSwitch(
                      value: _background,
                      onChanged: (bool value) {
                        setState(
                          () {
                            _background = value;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
