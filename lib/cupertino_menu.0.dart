import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart'
    show Brightness, CupertinoIcons, CupertinoLargeMenuDivider, CupertinoMenuAnchor, CupertinoMenuController, CupertinoMenuItem,  MenuStatus;
import 'package:flutter/material.dart'
    show CheckboxListTile, Colors, FilledButton, Material, Slider;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';


import 'resize.dart';
import 'test_anchor.dart';

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
  const CupertinoMenuExample({super.key, this.onDarkModeChanged});
  final VoidCallback? onDarkModeChanged;

  @override
  State<CupertinoMenuExample> createState() => _CupertinoMenuExampleState();
}

class _CupertinoMenuExampleState extends State<CupertinoMenuExample> {
   TextDirection _directionality = TextDirection.ltr;
   double _textSizeSliderValue = 1.0;
   bool _darkMode = true;
   bool _background = true;
  Rect anchorPosition = const Rect.fromLTWH(0, 0, 5, 5);
  Rect settingsPosition = const Rect.fromLTWH(0, 0, 5, 5);
  GlobalKey lightKey = GlobalKey();
  GlobalKey darkKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Directionality(
        textDirection: _directionality,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_textSizeSliderValue),
            platformBrightness: _darkMode ? Brightness.dark : Brightness.light,
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
                  //       right: -150,
                  //       top: 0,
                  //       bottom: 0,
                  //       child: Image.asset('assets/image.avif',
                  //           fit: BoxFit.fitWidth, width: 600)),
                  if (_background)
                    Positioned(
                        top: 0,
                        left: 0,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Image.asset(
                          'assets/p3.png',
                          fit: BoxFit.cover,
                        )),



                  Dropdown(
                    containerKey: lightKey,
                  ),

                  // CupertinoTheme(
                  //   data: const CupertinoThemeData(
                  //     brightness: Brightness.dark,
                  //   ),
                  //   child: Dropdown(
                  //     containerKey: darkKey,
                  //   ),
                  // ),
                  // DropdownMenuExample(),
                  ExcludeSemantics(
                    child: ExcludeFocusTraversal(
                      child: ExcludeFocus(
                        child: Settings(
                            textSizeSliderValue: _textSizeSliderValue,
                            directionality: _directionality,
                            darkMode: _darkMode,
                            background: _background,
                            onTextSizeSliderChanged: (double size) {
                              setState(() {
                                _textSizeSliderValue = size;
                              });
                            },
                            onDirectionalityChanged: (bool? isLTR) {
                              setState(() {
                                _directionality = isLTR!
                                    ? TextDirection.ltr
                                    : TextDirection.rtl;
                              });
                            },
                            onDarkModeChanged: (bool? isDark) {
                              setState(() {
                                _darkMode = isDark!;
                              });
                              widget.onDarkModeChanged?.call();
                            },
                            onBackgroundChanged: (bool? isBackground) {
                              setState(() {
                                _background = isBackground!;
                              });
                            }),
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}

class Settings extends StatefulWidget {
  const Settings({
    super.key,
    required this.textSizeSliderValue,
    required this.directionality,
    required this.darkMode,
    required this.background,
    required this.onTextSizeSliderChanged,
    required this.onDirectionalityChanged,
    required this.onDarkModeChanged,
    required this.onBackgroundChanged,
  });

  final double textSizeSliderValue;
  final TextDirection directionality;
  final bool darkMode;
  final bool background;
  final ValueChanged<double> onTextSizeSliderChanged;
  final ValueChanged<bool?> onDirectionalityChanged;
  final ValueChanged<bool?> onDarkModeChanged;
  final ValueChanged<bool?> onBackgroundChanged;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Offset _offset = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return ResizebleWidget(
        id: 'settings',
        child: Draggable(
          rootOverlay: true,
          onDragUpdate: (DragUpdateDetails location) {
            setState(() {
              _offset = _offset + location.delta;
            });
          },
          feedback: const SizedBox(),
          child: Material(
            child: OverflowBox(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 200, maxHeight: 30),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(widget.textSizeSliderValue
                                  .toStringAsPrecision(2)),
                              Flexible(
                                child: Slider(
                                    value: widget.textSizeSliderValue,
                                    min: 0.9,
                                    max: 2,
                                    onChanged: widget.onTextSizeSliderChanged),
                              ),
                            ])),
                  ),
                  CheckboxListTile.adaptive(
                    onChanged: widget.onDirectionalityChanged,
                    value: widget.directionality == TextDirection.ltr,
                    dense: true,
                    title: Text('Direction ${widget.directionality}'),
                  ),
                  CheckboxListTile.adaptive(
                    value: widget.background,
                    onChanged: widget.onBackgroundChanged,
                    dense: true,
                    title: const Text('Background'),
                  ),
                  CheckboxListTile.adaptive(
                    value: widget.darkMode,
                    onChanged: widget.onDarkModeChanged,
                    dense: true,
                    title: const Text('Dark mode'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class Dropdown extends StatefulWidget {
  const Dropdown({super.key, this.containerKey});
  final GlobalKey? containerKey;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  final FocusNode _buttonFocusNode = FocusNode();
  late final CupertinoMenuController controller = CupertinoMenuController();
  Offset _offset = const Offset(200, 200);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Draggable(
        feedback: const SizedBox.shrink(),
        feedbackOffset: _offset,
        onDragUpdate: (DragUpdateDetails location) {
          setState(() {
            _offset = _offset.translate(location.delta.dx, location.delta.dy);
          });
        },
        child: Menu(
          buttonFocusNode: _buttonFocusNode,

          )
      ),
    );
  }
}

class Menu extends StatefulWidget {

  const Menu({super.key,  this.buttonFocusNode, this.insets});
  final FocusNode? buttonFocusNode;
  final EdgeInsetsGeometry? insets;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
    bool textVariant = false;
    CupertinoMenuController? controller = CupertinoMenuController();

  @override
  Widget build(BuildContext context) {
    final Random random = Random();
    final String superLong = 'subtitle ' * 1000;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: CupertinoMenuAnchor(
              childFocusNode: widget.buttonFocusNode,
              controller: controller,
              onStatusChanged: (MenuStatus status) {
                print('Menu status: $status');

              },
              menuChildren: <Widget>[
                CupertinoMenuItem(
                  // requestFocusOnHover: true,
                  // panActivationDelay: const Duration(milliseconds: 300),
                  leading: const Icon(CupertinoIcons.alarm),
                  trailing: const Icon(CupertinoIcons.check_mark_circled),
                  requestCloseOnActivate: false,
                  subtitle: const Text('Subtitle'),
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyA, shift: true),
                  onPressed: () {
                    final ui.Offset value = Offset(50, random.nextDouble() * 20 + 40);
                    controller?.open(position:  Offset(50, random.nextDouble() * 100 + 40));
                    print(value);
                  },
                  child: const MenuAcceleratorLabel('&C&h&eckmark'),
                ),

                CupertinoMenuItem(
                  // requestFocusOnHover: true,
                  hoveredColor: Colors.green,
                  pressedColor: const Color.fromRGBO(255, 0, 0, 1),
                  trailing: const Icon(CupertinoIcons.folder_badge_plus),
                  requestCloseOnActivate: false,
                  onPressed: () {
                    setState(() {
                      textVariant = !textVariant;
                    });
                  },
                  child: const Text('New Folder'),
                ),
                const CupertinoLargeMenuDivider(),
                CupertinoMenuItem(
                  // requestFocusOnHover: true,
                  leading: Text( superLong),
                  requestCloseOnActivate: false,
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyA, meta: true, ),

                  subtitle: textVariant
                      ? const Text('Small text')
                      :  Text(superLong),
                  onPressed: () {},
                  child: textVariant
                      ? const Text('Small text')
                      :  Text(key:const Key('a'), superLong),
                ),

                CupertinoMenuItem(
                  // requestFocusOnHover: true,
                  requestCloseOnActivate: false,
                  trailing: const Icon(CupertinoIcons.square_grid_2x2),
                  child: const Text('Icons'),
                  onPressed: () {},
                ),
                const CupertinoLargeMenuDivider(),
                CupertinoMenuItem(
                  // requestFocusOnHover: true,

                  requestCloseOnActivate: false,
                  trailing: const Icon(CupertinoIcons.square_grid_2x2),
                  child: const Text('Icons', style: TextStyle(color: Colors.red, fontSize: 10)),
                  onPressed: () {},
                ),
                CupertinoMenuItem(
                  // requestFocusOnHover: true,

                  requestCloseOnActivate: false,
                  trailing: const Icon(CupertinoIcons.square_grid_2x2),
                  child: const Text('Icons'),
                  onPressed: () {},
                ),
              ],
              builder: (
                BuildContext context,
                CupertinoMenuController controller,
                Widget? child,
              ) {
                return FilledButton(
                  focusNode: widget.buttonFocusNode,
                  onPressed: () {
                    if (controller.menuStatus
                        case MenuStatus.opening || MenuStatus.opened) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(height: 50),
                    child: const Text(
                      'OPEN MENU',
                    ),
                  ),
                );
              },
            ),
    );

  }
}