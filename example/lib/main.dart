import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final _darkThemeToggle = ValueNotifier<bool>(true);

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
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: _darkThemeToggle,
        builder: (BuildContext context, bool value, Widget? child) {
          return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            platformBrightness: value ? Brightness.dark : Brightness.light,
          ),
          child: CupertinoApp(
            localizationsDelegates: const [
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _isImageShown = false;
  Color _backgroundColor = Colors.black;
  // bool _rtl = false;
  @override
  Widget build(BuildContext context) => Material(
        child: CupertinoPageScaffold(
          backgroundColor: _backgroundColor,
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: _isImageShown
                  ? DecorationImage(
                      image: AssetImage('assets/image.avif'),
                      fit: BoxFit.fitHeight,
                    )
                  : null,
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CupertinoMenuSample(),
                  ),
                  const Align(
                    alignment: Alignment(-0.5, -1),
                    child: CupertinoMenuSample(),
                  ),
                  Align(
                    alignment: Alignment(0.5, -1),
                    child: CupertinoMenuSample(),
                  ),
                  const Align(
                    alignment: Alignment(1, -1),
                    child: CupertinoMenuSample(),
                  ),
                  const Align(
                    alignment: Alignment(-1, -0.2),
                    child: CupertinoMenuSample(),
                  ),
                  const Align(
                    alignment: Alignment(-1, 0),
                    child: CupertinoMenuSample(),
                  ),
                  const Align(
                    alignment: Alignment(1, 0),
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
                    alignment: Alignment(-1, 0.7),
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
                          _backgroundColor =
                              value ? Colors.black : Colors.white;
                        });
                      },
                      onThemeToggled: (bool value) {
                        print(value);
                        _darkThemeToggle.value = value;
                      },
                      onDirectionalityToggled: (bool value) {
                        // setState(() {
                        //   _rtl = value;
                        // });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
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
    var show = false;
    return Transform.scale(
      alignment: Alignment.topLeft,
      scale: 0.9,
      child: StatefulBuilder(
        builder: (context, setState) => show
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
                    children: [
                      CupertinoListTile.notched(
                        backgroundColor: Colors.transparent,
                        title: const Text('Hide'),
                        trailing: SizedBox(
                          height: 20,
                          child: CupertinoSwitch(
                            value:
                                Directionality.of(context) == TextDirection.rtl,
                            onChanged: (value) {
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
                            value:
                                Directionality.of(context) == TextDirection.rtl,
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
              ),
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
  String _checkedValue = "Cat";
  bool _isCheckableChecked = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoMenuButton<String>(
      onSelect: (value) {
        setState(() {
          _checkedValue = value;
        });
      },
      offset: widget.offset,
      itemBuilder: (context) {
        return [
          CupertinoStickyMenuHeader(
            child: const Text('Downloads'),
            leading: Container(
              width: 42,
              height: 42,
              child: Image(
                image: AssetImage("assets/file.png"),
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
            subtitle: Text("Folder"),
          ),
          CupertinoNestedMenu(
            itemBuilder: (context) => [
               CupertinoCheckedMenuItem(
                value: "Cat",
                checked: _checkedValue == "Cat",
                child: Text('Cat'),
                shouldPopMenuOnPressed: false,
                onTap: (){
                  setState(() {
                    _checkedValue = "Cat";
                  });
                },
              ),
               CupertinoCheckedMenuItem(
                value: "Feline",
                checked: _checkedValue == "Feline",
                onTap: (){
                  setState(() {
                    _checkedValue = "Feline";
                  });
                },
                shouldPopMenuOnPressed: false,
                child: Text('Feline'),
              ),
               CupertinoCheckedMenuItem(
                value: "🐱",
                checked: _checkedValue == "🐱",
                child: Text('🐱, and pop the menu'),
              ),
            ],
            subtitle:  Text(_checkedValue),
            child: const Text('Favorite Animal'),
          ),
          CupertinoCheckedMenuItem(
            shouldPopMenuOnPressed: false,
            trailing: const Icon(
              CupertinoIcons.question,
            ),
            checked: _isCheckableChecked,
            child: Text("Checkable"),
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
            child: Text(
              'Simple',
            ),
            onTap: () {},
          ),
          CupertinoMenuItem(
            shouldPopMenuOnPressed: false,
            trailing: const Icon(
              CupertinoIcons.textformat_size,
            ),
            child: Text('Default'),
            isDefaultAction: true,
          ),
          const CupertinoMenuItem(
            trailing: Icon(CupertinoIcons.cloud_upload),
            value: 'Disabled',
            enabled: false,
            child: Text('Disabled'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(
              CupertinoIcons.triangle,
              semanticLabel: 'Triangle',
            ),
            value: 'Triangle',
            child: Text('Triangle'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(
              CupertinoIcons.square,
              semanticLabel: 'Square',
            ),
            value: 'Square',
            child: Text('Square'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(
              CupertinoIcons.circle,
              semanticLabel: 'Circle',
            ),
            value: 'Circle',
            child: Text('Circle'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(
              CupertinoIcons.star,
              semanticLabel: 'Star',
            ),
            value: 'Star',
            child: Text('Star'),
          ),
          const CupertinoMenuLargeDivider(),
          const CupertinoMenuItem(
            value: 'Delete',
            child: Text('Delete'),
            isDestructiveAction: true,
            trailing: Icon(
              CupertinoIcons.delete,
              semanticLabel: 'Delete',
            ),
          ),
        ];
      },
    );
  }
}

