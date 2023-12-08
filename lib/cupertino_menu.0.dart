import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart'
    show Brightness, CupertinoApp, CupertinoButton, CupertinoColors, CupertinoIcons, CupertinoNavigationBar, CupertinoPageScaffold, CupertinoSlider, CupertinoSwitch, CupertinoTheme, CupertinoThemeData;
import 'package:flutter/material.dart' show Colors, MenuStyle, TextButton;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'cupertino_menu_anchor.dart';
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
   TextDirection _directionality = TextDirection.ltr;
   double _textSizeSliderValue = 1.0;
   bool _darkMode = true;
   bool _background = true;
  Rect anchorPosition = const Rect.fromLTWH(0, 0, 50, 40);
  ui.Image? _lightImage;
  ui.Image? _darkImage;
  final GlobalKey lightKey = GlobalKey();
  final GlobalKey darkKey = GlobalKey();

  void visitAllChildren(RenderObject? renderObject, void Function(RenderRepaintBoundary) onBoundary) {
    if (renderObject == null || renderObject is RenderRepaintBoundary) {
       onBoundary(renderObject! as RenderRepaintBoundary);
    }
    renderObject.visitChildrenForSemantics((RenderObject child) {
      visitAllChildren(child, onBoundary);
    });
  }

  Future<void> takeScreenShot() async {
    final RenderObject child = context.findRenderObject()!;
    visitAllChildren(child, (RenderRepaintBoundary boundary) async {
      if (boundary.parent is RenderMetaData) {
        if ((boundary.parent! as RenderMetaData).metaData == Brightness.light) {
          _lightImage = boundary.toImageSync(pixelRatio: 5);
        } else {
          _darkImage = boundary.toImageSync(pixelRatio: 5);
        }
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _directionality,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(
              textScaler: TextScaler.linear(_textSizeSliderValue),
              platformBrightness:  Brightness.dark,
            ),
        child: CupertinoTheme(
          data: const CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.lightBlue,
            scaffoldBackgroundColor: Colors.white,

          ),
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                // if(_lightImage != null)
                //   Positioned(
                //     left: 0,
                //     top: -200,
                //     bottom: 0,
                //     child: RawImage(
                //       width: 250,
                //       image: _lightImage, fit: BoxFit.contain,)),
                // if(_darkImage != null)
                //   Positioned(
                //     left: 0,
                //     top: 200,
                //     bottom: 0,
                //     child: RawImage(
                //       width: 250,
                //       image: _darkImage, fit: BoxFit.contain,)),
                // if (_background)
                //   Positioned(
                //     right: -150,
                //     top: 0,
                //     bottom: 0,
                //       child: Image.asset(
                //     'assets/image.avif',
                //     fit: BoxFit.fitWidth,
                //     width: 600
                //   )),
                if (_background)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                      child: Image.asset(
                    'assets/p3.png',
                    fit: BoxFit.fitWidth,
                  )),

                 Dropdown(
                    containerKey: lightKey,
                  ),
                 CupertinoTheme(
                   data: const CupertinoThemeData(
                     brightness: Brightness.dark,
                   ),
                  child: Dropdown(
                    containerKey: darkKey,
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

                      TextButton(onPressed: takeScreenShot, child: const Text('Screenshot')),
                      CupertinoSwitch(
                        value: _darkMode,
                        onChanged: (bool value) {
                          setState(
                            () {
                              _darkMode = value;
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
      )
    );
  }
}




class Dropdown extends StatefulWidget {

  const Dropdown({super.key,  this.containerKey});
  final GlobalKey? containerKey;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  Rect _offset =  const Rect.fromLTWH(0, 0, 50, 40);

  bool _textVariant = false;
  // late final CupertinoMenuController controller = CupertinoMenuController();

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
                    rect: _offset,
                    child:  Draggable(
                        onDragUpdate: (DragUpdateDetails location) {
                          setState((){
                            _offset = _offset.shift(location.delta);
                          });
                        },
                        feedback: const Icon(CupertinoIcons.bars),
                        child: CupertinoMenuAnchor(
                          containerKey: widget.containerKey,
                          menuChildren: <Widget>[
                            CupertinoMenuItem(
                              trailing:
                                  const Icon(CupertinoIcons.check_mark_circled),
                              child: const Text('Favorite Animal'),
                              onPressed: () {},
                            ),
                            CupertinoMenuItem(
                              trailing:
                                  const Icon(CupertinoIcons.folder_badge_plus),
                              child: const Text('New Folder'),
                              onPressed: () {
                                setState(() {

                                _textVariant = !_textVariant;
                                });
                              },
                            ),

                            const CupertinoMenuLargeDivider(),
                            CupertinoMenuItem(
                              trailing: const Icon(CupertinoIcons.square_grid_2x2),
                              subtitle: _textVariant ? const Text('Small text'): const Text('An unusually long string of text to demonstrate how the menu will wrap.'),
                              onPressed: () {},
                              child:_textVariant
                                ? const Text('Small text')
                                : const Text('An unusually long string of text to demonstrate how the menu will wrap.'),
                            ),
                            const CupertinoMenuLargeDivider(),
                             CupertinoMenuItem(
                              trailing: const Icon(CupertinoIcons.square_grid_2x2),
                              child: const Text('Icons'),
                              onPressed: () {},
                            ),


                             CupertinoMenuItem(
                              trailing: const Icon(CupertinoIcons.square_grid_2x2),
                              child: const Text('Icons'),
                              onPressed: () {},
                            ),

                          ],
                          child: Container(
                                  color: Colors.lightBlue,
                                  child: const Center(child: Text('OPEN MENU'),),),
                          builder: (BuildContext context, CupertinoMenuController controller,
                              Widget? child) {
                            return GestureDetector(
                              onTap: () {
                                if(controller.animationStatus case AnimationStatus.completed || AnimationStatus.forward) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }

                              },
                              child: child
                            );
                          },
                      ),
                    ),
                  );
  }
}