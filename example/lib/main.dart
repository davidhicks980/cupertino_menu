import 'package:cupertino_menu/cupertino_menu.dart';
import 'package:cupertino_menu/cupertino_menu_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final ValueNotifier<bool> _darkThemeToggle = ValueNotifier<bool>(true);

/// This file includes basic example for [CupertinoMenuButton]
void main() {
  runApp(
    const CupertinoMenuExample(),
  );
}

class CupertinoMenuExample extends StatefulWidget {
  const CupertinoMenuExample({super.key});

  @override
  State<CupertinoMenuExample> createState() => _CupertinoMenuExampleState();
}

class _CupertinoMenuExampleState extends State<CupertinoMenuExample> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _darkThemeToggle,
      builder: (BuildContext context, bool value, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            platformBrightness: value ? Brightness.dark : Brightness.light,
          ),
          child: CupertinoApp(
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            routes: <String, WidgetBuilder>{
              '/next': (BuildContext context) => const Text('Next'),
            },
            title: 'CupertinoMenu Example',
            home: const MyHomePage(),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _isImageShown = false;
  Color _backgroundColor = Colors.white;
  // bool _rtl = false;
  @override
  Widget build(BuildContext context) {
    timeDilation = 5.0;

    return Material(
      child: CupertinoPageScaffold(
        backgroundColor: _backgroundColor,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              const Align(
                alignment: Alignment.topLeft,
                child: CupertinoMenuSample(),
              ),
              const Align(
                alignment: Alignment(-0.5, -1),
                child: CupertinoMenuSample(),
              ),
              const Align(
                alignment: Alignment(0.5, -1),
                child: CupertinoMenuSample(),
              ),
              const Align(
                alignment: Alignment.topRight,
                child: CupertinoMenuSample(),
              ),
              const Align(
                alignment: Alignment(-1, -0.2),
                child: CupertinoMenuSample(),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: CupertinoMenuSample(),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: CupertinoMenuSample(),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: CupertinoMenuSample(),
              ),
              const Align(
                child: CupertinoMenuSample(),
              ),
              const Align(
                alignment: Alignment.bottomLeft,
                child: CupertinoMenuSample(),
              ),
              Align(
                alignment: const Alignment(-1, 0.7),
                child: Settings(
                  imageShown: _isImageShown,
                  backgroundColor: _backgroundColor,
                  onImageToggled: (bool value) {
                    setState(() {
                      _isImageShown = value;
                    });
                  },
                  onColorToggled: (bool value) {
                    setState(() {
                      _backgroundColor = value ? Colors.black : Colors.white;
                    });
                  },
                  onThemeToggled: (bool value) {
                    _darkThemeToggle.value = value;
                  },
                  onDirectionalityToggled: (bool value) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({
    super.key,
    required this.imageShown,
    required this.backgroundColor,
    required this.onImageToggled,
    required this.onColorToggled,
    required this.onThemeToggled,
    required this.onDirectionalityToggled,
  });
  final ValueChanged<bool> onImageToggled;
  final ValueChanged<bool> onColorToggled;
  final ValueChanged<bool> onThemeToggled;
  final ValueChanged<bool> onDirectionalityToggled;

  final bool imageShown;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    bool show = false;
    return Transform.scale(
      alignment: Alignment.topLeft,
      scale: 0.9,
      child: StatefulBuilder(
        builder: (BuildContext context, setState) {
          return show
              ? SizedBox(
                  width: 300,
                  height: 300,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontSize: 12,
                    ),
                    child: CupertinoListSection.insetGrouped(
                      hasLeading: false,
                      backgroundColor: Colors.transparent,
                      children: <Widget>[
                        CupertinoListTile.notched(
                          backgroundColor: Colors.transparent,
                          title: const Text('Hide'),
                          trailing: SizedBox(
                            height: 20,
                            child: CupertinoSwitch(
                              value: Directionality.of(context) ==
                                  TextDirection.rtl,
                              onChanged: (bool value) {
                                setState(() {
                                  show = false;
                                });
                              },
                            ),
                          ),
                        ),
                        CupertinoListTile.notched(
                          backgroundColor: Colors.transparent,
                          title: const Text('Right-to-left'),
                          trailing: SizedBox(
                            height: 20,
                            child: CupertinoSwitch(
                              value: Directionality.of(context) ==
                                  TextDirection.rtl,
                              onChanged: onDirectionalityToggled,
                            ),
                          ),
                        ),
                        CupertinoListTile.notched(
                          backgroundColor: Colors.transparent,
                          title: const Text('Background'),
                          trailing: SizedBox(
                            height: 20,
                            child: CupertinoSwitch(
                              value: imageShown,
                              onChanged: onImageToggled,
                            ),
                          ),
                        ),
                        CupertinoListTile.notched(
                          backgroundColor: Colors.transparent,
                          title: const Text('Dark Mode'),
                          trailing: SizedBox(
                            height: 20,
                            child: CupertinoSwitch(
                              value: MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark,
                              onChanged: onThemeToggled,
                            ),
                          ),
                        ),
                        CupertinoListTile.notched(
                          backgroundColor: Colors.transparent,
                          backgroundColorActivated: Colors.transparent,
                          title: const Text('Black background'),
                          trailing: SizedBox(
                            height: 20,
                            child: CupertinoSwitch(
                              value: backgroundColor == Colors.black,
                              onChanged: onColorToggled,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: CupertinoButton(
                    onPressed: () {
                      setState(() {
                        show = true;
                      });
                    },
                    child: const Icon(CupertinoIcons.settings),
                  ),
                );
        },
      ),
    );
  }
}

class CupertinoMenuSample extends StatefulWidget {
  const CupertinoMenuSample({
    super.key,
    this.onSelected,
    this.offset,
  });

  final ValueChanged<String?>? onSelected;
  final Offset? offset;
  @override
  State<CupertinoMenuSample> createState() => _CupertinoMenuSampleState();
}

class _CupertinoMenuSampleState extends State<CupertinoMenuSample> {
  String _checkedValue = 'Cat';
  bool _isCheckableChecked = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoMenuButton(
      offset: widget.offset,
      itemBuilder: (BuildContext context) {
        return <Widget>[
          CupertinoStickyMenuHeader(
            leading: SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  CupertinoIcons.folder,
                  color: CupertinoColors.label.resolveFrom(context),
                )),
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
          CupertinoNestedMenu(
            itemBuilder: (BuildContext context) => <Widget>[
              CupertinoCheckedMenuItem(
                checked: _checkedValue == 'Cat',
                shouldPopMenuOnPressed: false,
                onTap: () {
                  setState(() {
                    _checkedValue = 'Cat';
                  });
                },
                child: const Text('Cat'),
              ),
              CupertinoCheckedMenuItem(
                checked: _checkedValue == 'Feline',
                onTap: () {
                  setState(() {
                    _checkedValue = 'Feline';
                  });
                },
                shouldPopMenuOnPressed: false,
                child: const Text('Feline'),
              ),
              CupertinoCheckedMenuItem(
                checked: _checkedValue == '🐱',
                onTap: () {
                  setState(() {
                    _checkedValue = 'Feline';
                  });
                },
                child: const Text(
                  '🐱, and pop the menu',
                  style: TextStyle(height: 1.35),
                ),
              ),
            ],
            subtitle: Text(_checkedValue, style: const TextStyle(height: 1.35)),
            child: const Text('Favorite Animal'),
          ),
          CupertinoCheckedMenuItem(
            shouldPopMenuOnPressed: false,
            trailing: const Icon(
              CupertinoIcons.question,
            ),
            checked: _isCheckableChecked,
            child: const Text('Checkable'),
            onTap: () {
              setState(() {
                _isCheckableChecked = !_isCheckableChecked;
              });
            },
          ),
          CupertinoMenuItem(
            trailing: const Icon(
              CupertinoIcons.textformat_size,
            ),
            child: const Text(
              'Simple',
            ),
            onTap: () {},
          ),
          const CupertinoMenuItem(
            shouldPopMenuOnPressed: false,
            trailing: Icon(
              CupertinoIcons.textformat_size,
            ),
            isDefaultAction: true,
            child: Text('Default'),
          ),
          const CupertinoMenuItem(
            trailing: Icon(CupertinoIcons.cloud_upload),
            enabled: false,
            child: Text('Disabled'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(
              CupertinoIcons.triangle,
              semanticLabel: 'Triangle',
            ),
            child: Text('Triangle'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(
              CupertinoIcons.square,
              semanticLabel: 'Square',
            ),
            child: Text('Square'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(
              CupertinoIcons.circle,
              semanticLabel: 'Circle',
            ),
            child: Text('Circle'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(
              CupertinoIcons.star,
              semanticLabel: 'Star',
            ),
            child: Text('Star'),
          ),
          const CupertinoMenuLargeDivider(),
          const CupertinoMenuItem(
            isDestructiveAction: true,
            trailing: Icon(
              CupertinoIcons.delete,
              semanticLabel: 'Delete',
            ),
            child: Text('Delete'),
          ),
        ];
      },
    );
  }
}
