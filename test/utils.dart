import 'dart:async';

import 'package:cupertino_menu/menu.dart';
import 'package:cupertino_menu/menu_item.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoApp, CupertinoIcons, CupertinoPageScaffold;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openNestedMenu(WidgetTester tester, List<Key> keys) async {
  for (final Key key in keys) {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }
}

class OneItem<T> {
  const OneItem(this.text, [this.value]);
  final T? value;
  final String text;
  String get nestedText => 'Nested $text';

  List<CupertinoMenuEntry<T>> make(
    BuildContext context, [
    List<CupertinoMenuEntry<T>> Function(BuildContext, [String text, T? value])?
        itemBuilder,
  ]) {
    return itemBuilder?.call(context, text, value) ??
        <CupertinoMenuEntry<T>>[
          CupertinoMenuItem<T>(
            value: value,
            child: Text(text),
          ),
        ];
  }

  List<CupertinoMenuEntry<T>> makeNested(
    BuildContext context, {
    List<CupertinoMenuEntry<T>> Function(BuildContext)? itemBuilder,
    TextSpan title = const TextSpan(text: 'Nested Child'),
    T? nestedValue,
    Widget? trailing = const Icon(CupertinoIcons.forward),
    Widget? subtitle = const Text('subtitle'),
    bool enabled = true,
    void Function()? onTap,
    FutureOr<void> Function()? onClose,
    void Function()? onOpen,
    Key? nestedMenuKey,
    Key? expandedMenuAnchorKey,
    Key? collapsedMenuAnchorKey,
    BoxConstraints? constraints,
    CupertinoMenuController? controller,
    Clip clip = Clip.none,
  }) {
    return <CupertinoMenuEntry<T>>[
      CupertinoNestedMenu<T>(
        trailing: trailing,
        subtitle: subtitle,
        enabled: enabled,
        onTap: onTap,
        onClose: onClose,
        onOpen: onOpen,
        key: nestedMenuKey,
        expandedMenuAnchorKey: expandedMenuAnchorKey,
        collapsedMenuAnchorKey: collapsedMenuAnchorKey,
        constraints: constraints,
        controller: controller,
        clip: clip,
        itemBuilder: itemBuilder ??
            (BuildContext context) {
              return <CupertinoMenuEntry<T>>[
                CupertinoMenuItem<T>(
                  value: nestedValue,
                  child: Text(nestedText),
                ),
              ];
            },
        title: title,
      ),
    ];
  }
}

const OneItem<void> single = OneItem<void>('One');

CupertinoApp buildSample<T>({
  Key? key,
  RelativeRect Function(BuildContext)? getPosition,
  required List<CupertinoMenuEntry<T>> Function(BuildContext) itemBuilder,
  bool enabled = true,
  void Function()? onCancel,
  void Function()? onOpen,
  void Function()? onClose,
  void Function(T)? onSelect,
  BoxConstraints? constraints,
  Offset? offset,
  Widget? child,
  bool enableFeedback = true,
  ScrollPhysics? physics,
  CupertinoMenuController? controller,
  bool useRootNavigator = false,
  double? minSize,
  EdgeInsetsGeometry? buttonPadding,
  Clip clip = Clip.antiAlias,
}) {
  return CupertinoApp(
    home: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return Positioned.fromRelativeRect(
              rect: getPosition?.call(context) ?? RelativeRect.fill,
              child: CupertinoMenuButton<T>(
                key: key,
                itemBuilder: itemBuilder,
                enabled: enabled,
                onOpen: onOpen,
                onClose: onClose,
                onSelect: onSelect,
                onCancel: onCancel,
                constraints: constraints,
                offset: offset,
                enableFeedback: enableFeedback,
                physics: physics,
                controller: controller,
                useRootNavigator: useRootNavigator,
                minSize: minSize,
                buttonPadding: buttonPadding,
                clip: clip,
                child: child,
              ),
            );
          },
        ),
      ],
    ),
  );
}

({CupertinoApp app, GlobalKey key}) buildAttachmentPoint<T>() {
  final GlobalKey attachmentPointKey = GlobalKey();
  return (
    key: attachmentPointKey,
    app: CupertinoApp(
      home: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          SizedBox(
            key: attachmentPointKey,
            height: 50,
            width: 50,
          ),
        ],
      ),
    )
  );
}

CupertinoApp getApp(Widget child) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: Builder(
        builder: (BuildContext context) => child,
      ),
    ),
  );
}

CupertinoApp buildApp(Widget Function(BuildContext) child) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: Center(
        child: Builder(
          builder: child,
        ),
      ),
    ),
  );
}

class ControlSet<T extends State<StatefulWidget>> {
  ControlSet({required this.anchorText});
  final String anchorText;
  final GlobalKey<T> key = GlobalKey<T>();
  final GlobalKey menuLayerKey = GlobalKey();
  final GlobalKey bottomAnchor = GlobalKey();
  final GlobalKey topAnchor = GlobalKey();
  final CupertinoMenuController control = CupertinoMenuController();
  Finder get anchorFinder => find.byKey(key);
  Finder findLayerMember(Finder finder) {
    return find.descendant(
        of: find.byKey(menuLayerKey), matching: finder, matchRoot: true);
  }

  String get itemText => '$anchorText n';
}

typedef RootControlDef = ControlSet<CupertinoMenuButtonState>;
typedef NestedControlDef = ControlSet<CupertinoNestedMenuControlMixin>;
typedef SampleBuilder<T> = List<CupertinoMenuEntry<T>> Function(
    BuildContext, ControlSet);
typedef SampleNestedBuilder<T> = List<CupertinoMenuEntry<T>> Function(
    BuildContext, ControlSet);

typedef ButtonBuilder<T> = CupertinoMenuButton<T> Function(
    BuildContext context);

class SampleMenu<T> {
  SampleMenu({required this.withController});
  final bool withController;
  // ignore: use_late_for_private_fields_and_variables
  late RootControlDef _root = ControlSet<CupertinoMenuButtonState<T>>(
      anchorText: 'root $_controlCount');
  RootControlDef get root => _root;
  CupertinoMenuController get control => _root.control;
  int _controlCount = 0;
  void next() {
    _controlCount++;
    _root = ControlSet<CupertinoMenuButtonState<T>>(
        anchorText: 'root $_controlCount');
  }

  CupertinoMenuButton<T> build(
    BuildContext context, [
    SampleBuilder<T>? itemBuilder,
  ]) {
    return CupertinoMenuButton<T>(
      key: _root.key,
      controller: withController ? _root.control : null,
      itemBuilder: (BuildContext context) {
        return itemBuilder?.call(context, _root) ??
            <CupertinoMenuEntry<T>>[
              CupertinoMenuItem<T>(
                child: Text(_root.itemText),
              )
            ];
      },
    );
  }

  ButtonBuilder<T> buildItem(
    CupertinoMenuEntry<T> child,
  ) {
    return (BuildContext context) {
      return build(
        context,
        (BuildContext context, ControlSet<State<StatefulWidget>> control) {
          return <CupertinoMenuEntry<T>>[
            child,
          ];
        },
      );
    };
  }

  ButtonBuilder<T> buildList(
    List<CupertinoMenuEntry<T>> children,
  ) {
    return (BuildContext context) {
      return build(
        context,
        (BuildContext context, ControlSet<State<StatefulWidget>> control) {
          return children;
        },
      );
    };
  }

  CupertinoApp buildItemApp(CupertinoMenuEntry<T> child) {
    return buildApp(buildItem(child));
  }

  CupertinoApp buildListApp(List<CupertinoMenuEntry<T>> children) {
    return buildApp(buildList(children));
  }
}

class SampleNestedMenu<T> extends SampleMenu<T> {
  SampleNestedMenu({
    required super.withController,
  });

  @override
  RootControlDef root = RootControlDef(anchorText: 'root');
  NestedControlDef sub_1 = NestedControlDef(anchorText: 'nested1');
  NestedControlDef sub_2 = NestedControlDef(anchorText: 'nested2');
  NestedControlDef sub_1_1 = NestedControlDef(anchorText: 'nested1.1');
  NestedControlDef sub_1_2 = NestedControlDef(anchorText: 'nested1.2');
  NestedControlDef sub_2_1 = NestedControlDef(anchorText: 'nested2.1');
  NestedControlDef sub_2_2 = NestedControlDef(anchorText: 'nested2.2');

  List<NestedControlDef> get subMenuControls =>
      <NestedControlDef>[sub_1, sub_2, sub_1_1, sub_1_2, sub_2_1, sub_2_2];

  @override
  CupertinoMenuController get control => root.control;

  @override
  void next() {
    _controlCount++;
    root = RootControlDef(anchorText: 'root $_controlCount');
    sub_1 = NestedControlDef(anchorText: 'nested1  $_controlCount');
    sub_2 = NestedControlDef(anchorText: 'nested2  $_controlCount');
    sub_1_1 = NestedControlDef(anchorText: 'nested1.1  $_controlCount');
    sub_1_2 = NestedControlDef(anchorText: 'nested1.2  $_controlCount');
    sub_2_1 = NestedControlDef(anchorText: 'nested2.1  $_controlCount');
    sub_2_2 = NestedControlDef(anchorText: 'nested2.2  $_controlCount');
  }

  @override
  CupertinoMenuButton<T> build(
    BuildContext context,

    /// A builder to run for each menu item.
    [
    SampleBuilder<T>? builder,
  ]) {
    return CupertinoMenuButton<T>(
      key: root.key,
      controller: withController ? root.control : null,
      itemBuilder: (BuildContext context) {
        return <CupertinoMenuEntry<T>>[
          ...builder?.call(context, root) ?? <CupertinoNestedMenu<T>>[],
          CupertinoNestedMenu<T>(
            key: sub_1.key,
            menuLayerKey: sub_1.menuLayerKey,
            collapsedMenuAnchorKey: sub_1.bottomAnchor,
            expandedMenuAnchorKey: sub_1.topAnchor,
            controller: withController ? sub_1.control : null,
            title: TextSpan(text: sub_1.anchorText),
            itemBuilder: (BuildContext context) {
              return <CupertinoMenuEntry<T>>[
                ...builder?.call(context, sub_1) ?? <CupertinoMenuItem<T>>[],
                CupertinoNestedMenu<T>(
                    key: sub_1_1.key,
                    menuLayerKey: sub_1_1.menuLayerKey,
                    collapsedMenuAnchorKey: sub_1_1.bottomAnchor,
                    expandedMenuAnchorKey: sub_1_1.topAnchor,
                    controller: withController ? sub_1_1.control : null,
                    title: TextSpan(text: sub_1_1.anchorText),
                    itemBuilder: (BuildContext context) {
                      return <CupertinoMenuEntry<T>>[
                        ...builder?.call(context, sub_1_1) ??
                            <CupertinoMenuItem<T>>[
                              CupertinoMenuItem<T>(
                                child: Text(sub_1_1.itemText),
                              )
                            ],
                      ];
                    }),
                CupertinoNestedMenu<T>(
                  key: sub_1_2.key,
                  menuLayerKey: sub_1_2.menuLayerKey,
                  collapsedMenuAnchorKey: sub_1_2.bottomAnchor,
                  expandedMenuAnchorKey: sub_1_2.topAnchor,
                  controller: withController ? sub_1_2.control : null,
                  title: TextSpan(text: sub_1_2.anchorText),
                  itemBuilder: (BuildContext context) {
                    return <CupertinoMenuEntry<T>>[
                      ...builder?.call(context, sub_1_2) ??
                          <CupertinoMenuEntry<T>>[
                            CupertinoMenuItem<T>(
                              child: Text(sub_1_2.itemText),
                            )
                          ]
                    ];
                  },
                )
              ];
            },
          ),
          CupertinoNestedMenu<T>(
            key: sub_2.key,
            menuLayerKey: sub_2.menuLayerKey,
            collapsedMenuAnchorKey: sub_2.bottomAnchor,
            expandedMenuAnchorKey: sub_2.topAnchor,
            controller: withController ? sub_2.control : null,
            title: TextSpan(text: sub_2.anchorText),
            itemBuilder: (BuildContext context) {
              return <CupertinoMenuEntry<T>>[
                ...builder?.call(context, sub_2) ?? <CupertinoMenuItem<T>>[],
                CupertinoNestedMenu<T>(
                  key: sub_2_1.key,
                  menuLayerKey: sub_2_1.menuLayerKey,
                  collapsedMenuAnchorKey: sub_2_1.bottomAnchor,
                  expandedMenuAnchorKey: sub_2_1.topAnchor,
                  controller: withController ? sub_2_1.control : null,
                  title: TextSpan(text: sub_2_1.anchorText),
                  itemBuilder: (BuildContext context) {
                    return <CupertinoMenuEntry<T>>[
                      ...builder?.call(context, sub_2_1) ??
                          <CupertinoMenuEntry<T>>[
                            CupertinoMenuItem<T>(
                              child: Text(sub_2_1.itemText),
                            )
                          ],
                    ];
                  },
                ),
                CupertinoNestedMenu<T>(
                  key: sub_2_2.key,
                  menuLayerKey: sub_2_2.menuLayerKey,
                  collapsedMenuAnchorKey: sub_2_2.bottomAnchor,
                  expandedMenuAnchorKey: sub_2_2.topAnchor,
                  controller: withController ? sub_2_2.control : null,
                  title: TextSpan(text: sub_2_2.anchorText),
                  itemBuilder: (BuildContext context) {
                    return <CupertinoMenuEntry<T>>[
                      ...builder?.call(context, sub_2_2) ??
                          <CupertinoMenuEntry<T>>[
                            CupertinoMenuItem<T>(
                              child: Text(sub_2_2.itemText),
                            )
                          ],
                    ];
                  },
                )
              ];
            },
          )
        ];
      },
    );
  }

  @override
  ButtonBuilder<T> buildList(
    List<CupertinoMenuEntry<T>> children,
  ) {
    return (BuildContext context) => build(
          context,
          (BuildContext context, ControlSet<State<StatefulWidget>> control) {
            return children;
          },
        );
  }

  @override
  ButtonBuilder<T> buildItem(
    CupertinoMenuEntry<T> child,
  ) {
    return buildList(<CupertinoMenuEntry<T>>[child]);
  }

  @override
  CupertinoApp buildItemApp(CupertinoMenuEntry<T> child) {
    return buildApp(buildItem(child));
  }

  @override
  CupertinoApp buildListApp(List<CupertinoMenuEntry<T>> children) {
    return buildApp(buildList(children));
  }
}
