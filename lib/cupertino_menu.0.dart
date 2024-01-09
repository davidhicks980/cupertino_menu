import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart'
    show
        Brightness,
        CupertinoApp,
        CupertinoButton,
        CupertinoCheckbox,
        CupertinoColors,
        CupertinoContextMenu,
        CupertinoContextMenuAction,
        CupertinoIcons,
        CupertinoNavigationBar,
        CupertinoPageScaffold,
        CupertinoSlider,
        CupertinoSwitch,
        CupertinoTheme,
        CupertinoThemeData;
import 'package:flutter/material.dart'
    show ButtonStyle, CheckboxListTile, Colors, InkResponse, InkWell, ListTile, MaterialStateProperty, MenuAnchor, MenuController, MenuItemButton, MenuStyle, Slider, SubmenuButton, TextButton, Theme, showAboutDialog;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'cupertino_menu_anchor.dart';
import 'menu_bar.dart';
import 'menu_item.dart';
import 'resize.dart';

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
  Rect anchorPosition = const Rect.fromLTWH(0, 0, 50, 40);
  Rect settingsPosition = const Rect.fromLTWH(0, 0, 50, 40);
  ui.Image? _lightImage;
  ui.Image? _darkImage;
   GlobalKey lightKey = GlobalKey();
   GlobalKey darkKey = GlobalKey();

  void visitAllChildren(RenderObject? renderObject,
      void Function(RenderRepaintBoundary) onBoundary) {
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
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: _darkMode ? Brightness.dark : Brightness.light,
              ),
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
                  const MyMenuBar(),
                  const Positioned(
                      left: 300,
                      top: 150,
                      bottom: 0,
                      right: 0,
                      child: MyCascadingMenu(message: 'test'),),

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
              ),
            ),
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
          child:  ListView(
            shrinkWrap: true,
              children: <Widget>[


                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: ConstrainedBox(

                        constraints: const BoxConstraints.tightFor(width: 200, height: 30),
                       child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                   <Widget>[ Text(widget.textSizeSliderValue.toStringAsPrecision(2)),
                    Slider(
                          value: widget.textSizeSliderValue,
                          min: 0.9,
                          max: 2,
                          onChanged: widget.onTextSizeSliderChanged),
                     ]
                  )),
                ),

                    CheckboxListTile.adaptive(
                      onChanged: widget.onDirectionalityChanged,
                      value: widget.directionality == TextDirection.ltr,
                  title:  Text('Direction ${widget.directionality}'),
                ),

                 CheckboxListTile.adaptive(
                       value: widget.background,
                      onChanged: widget.onBackgroundChanged,
                  title:  const Text('Background'),
                ),
                 CheckboxListTile.adaptive(
                       value: widget.darkMode,
                      onChanged: widget.onDarkModeChanged,
                  title:  const Text('Dark mode'),
                ),

              ],
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
  bool _textVariant = false;
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
            child:
        CupertinoMenuAnchor(
        childFocusNode: _buttonFocusNode,
        menuChildren: <Widget>[
          CupertinoMenuItem(
            panActivationDelay: const Duration(milliseconds: 300),
            trailing: const Icon(CupertinoIcons.check_mark_circled),
            closeOnActivate: false,
            onPressed: () {
              print('activated');
            },
            child: const Text('Favorite Animal'),
          ),
          CupertinoMenuItem(
            trailing: const Icon(CupertinoIcons.folder_badge_plus),
            closeOnActivate: false,

            onPressed: () {
              setState(() {
                _textVariant = !_textVariant;
              });
            },
            child: const Text('New Folder'),
          ),
          const CupertinoMenuLargeDivider(),
          CupertinoMenuItem(
            trailing: const Icon(CupertinoIcons.square_grid_2x2),
            closeOnActivate: false,

            subtitle: _textVariant
                ? const Text('Small text')
                : const Text(
                    'An unusually long string of text to demonstrate how the menu will wrap.'),
            onPressed: () {},
            child: _textVariant
                ? const Text('Small text')
                : const Text(
                    'An unusually long string of text to demonstrate how the menu will wrap.'),
          ),
          const CupertinoMenuLargeDivider(),
          CupertinoMenuItem(
            closeOnActivate: false,

            trailing: const Icon(CupertinoIcons.square_grid_2x2),
            child: const Text('Icons'),
            onPressed: () {},
          ),
          CupertinoMenuItem(
            closeOnActivate: false,

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
          return TextButton(
            focusNode: _buttonFocusNode,
            onPressed: () {
              if (controller.animationStatus case AnimationStatus.forward || AnimationStatus.completed) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: const Text(
              'OPEN MENU',
            ),
          );
        },
        ),
      ),
    );
  }
}

/// An enhanced enum to define the available menus and their shortcuts.
///
/// Using an enum for menu definition is not required, but this illustrates how
/// they could be used for simple menu systems.
enum MenuEntry {
  about('About'),
  showMessage(
      'Show Message', SingleActivator(LogicalKeyboardKey.keyS, control: true)),
  hideMessage(
      'Hide Message', SingleActivator(LogicalKeyboardKey.keyS, control: true)),
  colorMenu('Color Menu'),
  colorRed('Red Background',
      SingleActivator(LogicalKeyboardKey.keyR, control: true)),
  colorGreen('Green Background',
      SingleActivator(LogicalKeyboardKey.keyG, control: true)),
  colorBlue('Blue Background',
      SingleActivator(LogicalKeyboardKey.keyB, control: true));

  const MenuEntry(this.label, [this.shortcut]);
  final String label;
  final MenuSerializableShortcut? shortcut;
}

class MyCascadingMenu extends StatefulWidget {
  const MyCascadingMenu({super.key, required this.message});

  final String message;

  @override
  State<MyCascadingMenu> createState() => _MyCascadingMenuState();
}

class _MyCascadingMenuState extends State<MyCascadingMenu> {
  MenuEntry? _lastSelection;
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  ShortcutRegistryEntry? _shortcutsEntry;

  Color get backgroundColor => _backgroundColor;
  Color _backgroundColor = Colors.red;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      setState(() {
        _backgroundColor = value;
      });
    }
  }

  bool get showingMessage => _showingMessage;
  bool _showingMessage = false;
  set showingMessage(bool value) {
    if (_showingMessage != value) {
      setState(() {
        _showingMessage = value;
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
    final Map<ShortcutActivator, Intent> shortcuts =
        <ShortcutActivator, Intent>{
      for (final MenuEntry item in MenuEntry.values)
        if (item.shortcut != null)
          item.shortcut!: VoidCallbackIntent(() => _activate(item)),
    };
    // Register the shortcuts with the ShortcutRegistry so that they are
    // available to the entire application.
    _shortcutsEntry = ShortcutRegistry.of(context).addAll(shortcuts);
  }

  @override
  void dispose() {
    _shortcutsEntry?.dispose();
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MenuAnchor(
          menuChildren: <Widget>[
            MenuItemButton(
              child: Text(MenuEntry.about.label),
              onPressed: () => _activate(MenuEntry.about),
            ),
            if (_showingMessage)
              MenuItemButton(
                onPressed: () => _activate(MenuEntry.hideMessage),
                shortcut: MenuEntry.hideMessage.shortcut,
                child: Text(MenuEntry.hideMessage.label),
              ),
            if (!_showingMessage)
              MenuItemButton(
                onPressed: () => _activate(MenuEntry.showMessage),
                shortcut: MenuEntry.showMessage.shortcut,
                child: Text(MenuEntry.showMessage.label),
              ),
            SubmenuButton(
              menuChildren: <Widget>[
                MenuItemButton(
                  onPressed: () => _activate(MenuEntry.colorRed),
                  shortcut: MenuEntry.colorRed.shortcut,
                  child: Text(MenuEntry.colorRed.label),
                ),
                MenuItemButton(
                  onPressed: () => _activate(MenuEntry.colorGreen),
                  shortcut: MenuEntry.colorGreen.shortcut,
                  child: Text(MenuEntry.colorGreen.label),
                ),
                MenuItemButton(
                  onPressed: () => _activate(MenuEntry.colorBlue),
                  shortcut: MenuEntry.colorBlue.shortcut,
                  child: Text(MenuEntry.colorBlue.label),
                ),
              ],
              child: const Text('Background Color'),
            ),
          ],
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
            return TextButton(
              focusNode: _buttonFocusNode,
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: const Text('OPEN MENU'),
            );
          },
        ),
      ],
    );
  }

  void _activate(MenuEntry selection) {
    setState(() {
      _lastSelection = selection;
    });

    switch (selection) {
      case MenuEntry.about:
        showAboutDialog(
          context: context,
          applicationName: 'MenuBar Sample',
          applicationVersion: '1.0.0',
        );
      case MenuEntry.hideMessage:
      case MenuEntry.showMessage:
        showingMessage = !showingMessage;
      case MenuEntry.colorMenu:
        break;
      case MenuEntry.colorRed:
        backgroundColor = Colors.red;
      case MenuEntry.colorGreen:
        backgroundColor = Colors.green;
      case MenuEntry.colorBlue:
        backgroundColor = Colors.blue;
    }
  }
}
