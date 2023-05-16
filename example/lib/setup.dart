import 'package:cupertino_menu/cupertino_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final themeNotifier = ValueNotifier(Brightness.light);

void onThemeModeChange() {
  if (themeNotifier.value == Brightness.light) {
    themeNotifier.value = Brightness.dark;
  } else {
    themeNotifier.value = Brightness.light;
  }
}

@immutable
class ExampleButton extends StatelessWidget {
  const ExampleButton({super.key, required this.onTap});

  /// Shortcut constructor to allow easy passing to
  /// [CupertinoMenuButton.buttonBuilder] as tear-off:
  ///
  /// ```dart
  /// buttonBuilder: ExampleButton.builder,
  /// ```
  ///
  /// instead of:
  ///
  /// ```dart
  /// buttonBuilder: (_, showMenu) => ExampleButton(onTap: showMenu),
  /// ```
  const ExampleButton.builder(
    BuildContext _,
    this.onTap, {
    super.key,
  });

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) => CupertinoButton(
        onPressed: onTap,
        pressedOpacity: 1,
        child: const Icon(CupertinoIcons.ellipsis_circle),
      );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Brightness>(
        valueListenable: themeNotifier,
        builder: (context, value, child) => CupertinoApp(
          routes: <String, WidgetBuilder>{
            '/next': (BuildContext context) => const Text('Next'),
          },
          localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
          title: 'PullDownButton Example',
          theme: CupertinoThemeData(
            brightness: themeNotifier.value,
            textTheme: const CupertinoTextThemeData(),
          ),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: child!,
          ),
          home: child,
        ),
        child: const MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _isBackgroundShown = false;
  Color backgroundColor = Colors.black;

  int selectedMenu = 0;
  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: SafeArea(
          child: Stack(
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: Dropdown(),
              ),
              const Align(
                alignment: Alignment.topCenter,
                child: Dropdown(),
              ),
              const Align(
                alignment: Alignment(-0.5, -1),
                child: Dropdown(),
              ),
              const Align(
                alignment: Alignment(0.5, -1),
                child: Dropdown(),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Dropdown(),
              ),
              Center(
                heightFactor: 1.5,
                child: SizedBox(
                  height: 200,
                  child: CupertinoListSection.insetGrouped(
                    children: [
                      CupertinoListTile.notched(
                        title: const Text('Background'),
                        trailing: SizedBox(
                          height: 20,
                          child: CupertinoSwitch(
                            value: _isBackgroundShown,
                            onChanged: (shown) {
                              setState(() {
                                _isBackgroundShown = shown;
                              });
                            },
                          ),
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Black background'),
                        trailing: SizedBox(
                          height: 20,
                          child: CupertinoSwitch(
                            value: backgroundColor == Colors.black,
                            onChanged: (_) {
                              setState(() {
                                backgroundColor =
                                    backgroundColor == Colors.white
                                        ? Colors.black
                                        : Colors.white;
                              });
                            },
                          ),
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Dark Mode'),
                        trailing: SizedBox(
                          height: 20,
                          child: CupertinoSwitch(
                            value: CupertinoTheme.brightnessOf(context) ==
                                Brightness.dark,
                            onChanged: (_) {
                              onThemeModeChange();
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                child: Container(
                  height: 354,
                  width: 536,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    image: _isBackgroundShown
                        ? DecorationImage(
                            image: Image.network(
                              'https://fastly.picsum.photos/id/866/536/354.jpg?hmac=tGofDTV7tl2rprappPzKFiZ9vDh5MKj39oa2D--gqhA',
                            ).image,
                          )
                        : null,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment(-1, 0),
                child: Dropdown(),
              ),
              const Align(
                alignment: Alignment(1, 0),
                child: Dropdown(),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Dropdown(),
              ),
              const Align(
                child: Dropdown(),
              ),
            ],
          ),
        ),
      );
}

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  bool _checked = false;
  @override
  Widget build(BuildContext context) => CupertinoMenuButton<String>(
        onSelected: print,
        itemBuilder: (context) => [
          const CupertinoMenuActionItem(
            icon: Icon(CupertinoIcons.hexagon),
            value: 'Hexagon',
            child: Text('Hexagon'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(CupertinoIcons.triangle),
            value: 'Triangle',
            child: Text('Triangle'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(CupertinoIcons.square),
            value: 'Square',
            child: Text('Square'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(CupertinoIcons.circle),
            value: 'Circle',
            child: Text('Circle'),
          ),
          const CupertinoMenuTitle(
            child: Text('Group By'),
          ),
          CupertinoNestedRoutedMenu<String>(
            itemBuilder: (context) => [
              const CupertinoMenuLargeDivider(),
              const CupertinoMenuItem(
                trailing: Icon(CupertinoIcons.cloud_upload),
                child: Text('Connect to remote server'),
              ),
              const CupertinoMenuLargeDivider(),
              const CupertinoMenuItem(
                trailing: Icon(CupertinoIcons.square_grid_2x2),
                child: Text('Grid'),
              ),
              CupertinoNestedRoutedMenu(
                itemBuilder: (context) => [
                  const CupertinoMenuLargeDivider(),
                  const CupertinoMenuItem(
                    trailing: Icon(CupertinoIcons.cloud_upload),
                    value: 'Emit value',
                    child: Text('Emit value'),
                  ),
                  const CupertinoMenuLargeDivider(),
                  const CupertinoMenuItem(
                    trailing: Icon(CupertinoIcons.square_grid_2x2),
                    child: Text('Grid'),
                  ),
                ],
                child: const Text('Copy'),
              ),
            ],
            child: const Text('Copy'),
          ),
          CupertinoNestedRoutedMenu<String>(
            trailing: const Icon(CupertinoIcons.check_mark_circled),
            subtitle:
                const Text('A really long subtitle that should be truncated'),
            itemBuilder: (BuildContext context) => [
              CupertinoNestedRoutedMenu<String>(
                itemBuilder: (BuildContext context) => [
                  CupertinoNestedRoutedMenu<String>(
                    itemBuilder: (BuildContext context) => [
                      CupertinoNestedRoutedMenu<String>(
                        itemBuilder: (BuildContext context) => [
                          const CupertinoMenuLargeDivider(),
                          const CupertinoMenuItem(
                            trailing: Icon(
                              CupertinoIcons.cloud_upload,
                            ),
                            child: Text(
                              'Connect to remote server',
                            ),
                          ),
                          const CupertinoMenuLargeDivider(),
                          const CupertinoMenuActionItem(
                            enabled: false,
                            icon: Icon(CupertinoIcons.scissors),
                            child: Text('Cut'),
                          ),
                          const CupertinoMenuActionItem(
                            icon: Icon(
                              CupertinoIcons.doc_on_clipboard,
                            ),
                            child: Text('Paste'),
                          ),
                          const CupertinoMenuActionItem(
                            icon: Icon(
                              CupertinoIcons.doc_text_search,
                            ),
                            child: Text('Look Up'),
                          ),
                        ],
                        child: const Text('List'),
                      ),
                      const CupertinoMenuLargeDivider(),
                      const CupertinoMenuItem(
                        trailing: Icon(CupertinoIcons.cloud_upload),
                        child: Text('Connect to remote server'),
                      ),
                      const CupertinoMenuLargeDivider(),
                      const CupertinoMenuItem(
                        trailing: Icon(
                          CupertinoIcons.square_grid_2x2,
                        ),
                        child: Text('Grid'),
                      ),
                    ],
                    child: const Text('List'),
                  ),
                  const CupertinoMenuLargeDivider(),
                  const CupertinoMenuItem(
                    trailing: Icon(CupertinoIcons.cloud_upload),
                    child: Text('Connect to remote server'),
                  ),
                  const CupertinoMenuLargeDivider(),
                  const CupertinoMenuItem(
                    trailing: Icon(CupertinoIcons.square_grid_2x2),
                    child: Text('Grid'),
                  ),
                ],
                child: const Text('List'),
              ),
              const CupertinoMenuLargeDivider(),
              const CupertinoMenuItem(
                trailing: Icon(CupertinoIcons.cloud_upload),
                child: Text('Connect to remote server'),
              ),
              const CupertinoMenuLargeDivider(),
              const CupertinoMenuItem(
                trailing: Icon(CupertinoIcons.square_grid_2x2),
                child: Text('Grid'),
              ),
              const CupertinoMenuItem(
                trailing: Icon(CupertinoIcons.square_grid_2x2),
                child: Text('Grid'),
              ),
              const CupertinoMenuItem(
                trailing: Icon(CupertinoIcons.square_grid_2x2),
                child: Text('Grid'),
              ),
              const CupertinoMenuItem(
                trailing: Icon(CupertinoIcons.square_grid_2x2),
                child: Text('Grid'),
              ),
            ],
            child: const Text(
              'Reaaaaaaaalllllllyyyyyyyyyyyyy Lonnnnnnnnnggggggggggg Submeeeennnnnnuuu',
            ),
          ),
          const CupertinoMenuLargeDivider(),
          CupertinoCheckedMenuItem<Never>(
            trailing: const Icon(CupertinoIcons.list_bullet),
            checked: _checked,
            child: const Text('Due Date'),
            onTap: () {
              setState(() {
                _checked = !_checked;
              });
            },
          ),
          const CupertinoMenuItem(
            isDefaultAction: true,
            value: 'Default',
            child: Text('Default'),
          ),
          const CupertinoMenuLargeDivider(),
          CupertinoNestedRoutedMenu(
            itemBuilder: (context) => [
              const CupertinoMenuLargeDivider(),
              const CupertinoMenuItem(
                trailing: Icon(CupertinoIcons.cloud_upload),
                child: Text('Connect to remote server'),
              ),
              const CupertinoMenuLargeDivider(),
              const CupertinoMenuItem(
                trailing: Icon(CupertinoIcons.square_grid_2x2),
                child: Text('Grid'),
              ),
              CupertinoNestedRoutedMenu(
                itemBuilder: (context) => [
                  const CupertinoMenuLargeDivider(),
                  const CupertinoMenuItem(
                    trailing: Icon(CupertinoIcons.cloud_upload),
                    child: Text('Connect to remote server'),
                  ),
                  const CupertinoMenuLargeDivider(),
                  const CupertinoMenuItem(
                    trailing: Icon(CupertinoIcons.square_grid_2x2),
                    child: Text('Grid'),
                  ),
                  CupertinoNestedRoutedMenu(
                    itemBuilder: (context) => [
                      const CupertinoMenuLargeDivider(),
                      const CupertinoMenuItem(
                        trailing: Icon(CupertinoIcons.cloud_upload),
                        child: Text('Connect to remote server'),
                      ),
                      const CupertinoMenuLargeDivider(),
                      const CupertinoMenuItem(
                        trailing: Icon(CupertinoIcons.square_grid_2x2),
                        child: Text('Grid'),
                      ),
                      CupertinoNestedRoutedMenu(
                        itemBuilder: (context) => [
                          const CupertinoMenuLargeDivider(),
                          const CupertinoMenuItem(
                            trailing: Icon(CupertinoIcons.cloud_upload),
                            child: Text('Connect to remote server'),
                          ),
                          const CupertinoMenuLargeDivider(),
                          const CupertinoMenuItem(
                            trailing: Icon(CupertinoIcons.square_grid_2x2),
                            child: Text('Grid'),
                          ),
                        ],
                        subtitle: const Text('Due Date'),
                        child: const Text('Sort By'),
                      ),
                    ],
                    subtitle: const Text('Due Date'),
                    child: const Text('Sort By'),
                  ),
                ],
                subtitle: const Text('Due Date'),
                child: const Text('Sort By'),
              ),
            ],
            subtitle: const Text('Due Date'),
            child: const Text('Sort By'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(CupertinoIcons.tray_arrow_down),
            child: Text('Inbox'),
          ),
          const CupertinoMenuActionItem(
            icon: Icon(CupertinoIcons.archivebox),
            child: Text('Archive'),
          ),
          const CupertinoMenuActionItem(
            isDestructiveAction: true,
            icon: Icon(CupertinoIcons.delete),
            child: Text('Trash'),
          ),
        ],
      );
}
