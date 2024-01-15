import 'package:example/cupertino_menu_anchor.dart';
import 'package:example/menu_item.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoApp, CupertinoButton, CupertinoIcons, CupertinoPageScaffold;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Future<void> openNestedMenu(WidgetTester tester, List<Key> keys) async {
//   for (final Key key in keys) {
//     await tester.tap(find.byKey(key));
//     await tester.pumpAndSettle();
//   }
// }

// class OneItem<T> {
//   const OneItem(this.text, [this.value]);
//   final T? value;
//   final String text;
//   String get nestedText => 'Nested $text';

//   List<CupertinoMenuEntry<T>> make(
//     BuildContext context, [
//     List<CupertinoMenuEntry<T>> Function(BuildContext, [String text, T? value])?
//         itemBuilder,
//   ]) {
//     return itemBuilder?.call(context, text, value) ??
//         <CupertinoMenuEntry<T>>[
//           CupertinoMenuItem<T>(
//             value: value,
//             child: Text(text),
//           ),
//         ];
//   }

//   List<CupertinoMenuEntry<T>> makeNested(
//     BuildContext context, {
//     List<CupertinoMenuEntry<T>> Function(BuildContext)? itemBuilder,
//     TextSpan title = const TextSpan(text: 'Nested Child'),
//     T? nestedValue,
//     Widget? trailing = const Icon(CupertinoIcons.forward),
//     Widget? subtitle = const Text('subtitle'),
//     bool enabled = true,
//     void Function()? onTap,
//     FutureOr<void> Function()? onClose,
//     void Function()? onOpen,
//     Key? nestedMenuKey,
//     Key? expandedMenuAnchorKey,
//     Key? collapsedMenuAnchorKey,
//     BoxConstraints? constraints,
//     CupertinoMenuController? controller,
//     Clip clip = Clip.none,
//   }) {
//     return <CupertinoMenuEntry<T>>[
//       CupertinoNestedMenu<T>(
//         trailing: trailing,
//         subtitle: subtitle,
//         enabled: enabled,
//         onTap: onTap,
//         onClose: onClose,
//         onOpen: onOpen,
//         key: nestedMenuKey,
//         expandedMenuAnchorKey: expandedMenuAnchorKey,
//         collapsedMenuAnchorKey: collapsedMenuAnchorKey,
//         constraints: constraints,
//         controller: controller,
//         clip: clip,
//         itemBuilder: itemBuilder ??
//             (BuildContext context) {
//               return <CupertinoMenuEntry<T>>[
//                 CupertinoMenuItem<T>(
//                   value: nestedValue,
//                   child: Text(nestedText),
//                 ),
//               ];
//             },
//         title: title,
//       ),
//     ];
//   }
// }

// const OneItem<void> single = OneItem<void>('One');

// CupertinoApp buildSample<T>({
//   Key? key,
//   RelativeRect Function(BuildContext)? getPosition,
//   required List<CupertinoMenuEntry<T>> Function(BuildContext) itemBuilder,
//   bool enabled = true,
//   void Function()? onCancel,
//   void Function()? onOpen,
//   void Function()? onClose,
//   void Function(T)? onSelect,
//   BoxConstraints? constraints,
//   Offset? offset,
//   Widget? child,
//   bool enableFeedback = true,
//   ScrollPhysics? physics,
//   CupertinoMenuController? controller,
//   bool useRootNavigator = false,
//   double? minSize,
//   EdgeInsetsGeometry? buttonPadding,
//   Clip clip = Clip.antiAlias,
// }) {
//   return CupertinoApp(
//     home: Stack(
//       clipBehavior: Clip.none,
//       children: <Widget>[
//         Builder(
//           builder: (BuildContext context) {
//             return Positioned.fromRelativeRect(
//               rect: getPosition?.call(context) ?? RelativeRect.fill,
//               child: CupertinoMenuButton<T>(
//                 key: key,
//                 itemBuilder: itemBuilder,
//                 enabled: enabled,
//                 onOpen: onOpen,
//                 onClose: onClose,
//                 onSelect: onSelect,
//                 onCancel: onCancel,
//                 constraints: constraints,
//                 offset: offset,
//                 enableFeedback: enableFeedback,
//                 physics: physics,
//                 controller: controller,
//                 useRootNavigator: useRootNavigator,
//                 minSize: minSize,
//                 buttonPadding: buttonPadding,
//                 clip: clip,
//                 child: child,
//               ),
//             );
//           },
//         ),
//       ],
//     ),
//   );
// }

// ({CupertinoApp app, GlobalKey key}) buildAttachmentPoint<T>() {
//   final GlobalKey attachmentPointKey = GlobalKey();
//   return (
//     key: attachmentPointKey,
//     app: CupertinoApp(
//       home: Stack(
//         clipBehavior: Clip.none,
//         children: <Widget>[
//           SizedBox(
//             key: attachmentPointKey,
//             height: 50,
//             width: 50,
//           ),
//         ],
//       ),
//     )
//   );
// }
CupertinoApp buildApp(List<Widget> children) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: Column(
        children: children
      ),
    ),
  );
}

CupertinoMenuAnchor simpleAnchor({
   String text,
   GlobalKey anchorKey,
   CupertinoMenuController controller,
  required List<Widget> menuChildren,
}) {
  return CupertinoMenuAnchor(
    key: anchorKey,
    controller: controller,
    builder: (BuildContext context, CupertinoMenuController controller, Widget? child) {
      return CupertinoButton(
        onPressed: () {
          if(
            controller.animationStatus == AnimationStatus.completed ||
            controller.animationStatus == AnimationStatus.forward
          ) {
            controller.open();
          } else {
            controller.close();
          }
         },
        child: Text(text),
      );
    },
    menuChildren: menuChildren,
  );
}

// CupertinoApp buildApp(Widget Function(BuildContext) child) {
//   return CupertinoApp(
//     home: CupertinoPageScaffold(
//       child: Center(
//         child: Builder(
//           builder: child,
//         ),
//       ),
//     ),
//   );
// }

class ControlSet {
  ControlSet({required this.anchorText});
  final String anchorText;
  final GlobalKey anchorKey = GlobalKey();
  final CupertinoMenuController control = CupertinoMenuController();
  Finder get anchorFinder => find.byKey(anchorKey);
  Finder findItem(int i) => find.text(getItemLabel(i));
  String getItemLabel(int i){
    return '$anchorText $i';
  }
}

// typedef RootControlDef = ControlSet<CupertinoMenuButtonState>;
// typedef NestedControlDef = ControlSet<CupertinoNestedMenuControlMixin>;
// typedef SampleBuilder<T> = List<CupertinoMenuEntry<T>> Function(
//     BuildContext, ControlSet);
// typedef SampleNestedBuilder<T> = List<CupertinoMenuEntry<T>> Function(
//     BuildContext, ControlSet);

// typedef ButtonBuilder<T> = CupertinoMenuButton<T> Function(
//     BuildContext context);

class SampleMenu {
 SampleMenu({required this.withController});
  final bool withController;
  // ignore: use_late_for_private_fields_and_variables
  late ControlSet _overlay = ControlSet(
      anchorText: 'root $_controlCount');
  ControlSet get overlay => _overlay;
  CupertinoMenuController get control => _overlay.control;
  int _controlCount = 0;

  Finder findItem(int index){
    return _overlay.findItem(index);
  }
  String getItemLabel(int index){
    return _overlay.getItemLabel(index);
  }

  void resetControl() {
    _controlCount++;
    _overlay = ControlSet(
        anchorText: 'root $_controlCount');
  }

  CupertinoMenuAnchor build(
   { CupertinoMenuAnchorChildBuilder? anchorBuilder,
    List<Widget> Function(ControlSet)? itemBuilder,}
  ) {
    return CupertinoMenuAnchor(
      key: _overlay.anchorKey,
      controller: withController ? _overlay.control : null,
      builder: anchorBuilder ?? (BuildContext context, CupertinoMenuController controller, Widget? child) {
        return CupertinoButton(
          onPressed: () {
            if(
              controller.animationStatus == AnimationStatus.completed ||
              controller.animationStatus == AnimationStatus.forward
            ) {
              controller.open();
            } else {
              controller.close();
            }
           },
          child: Text(_overlay.anchorText),
        );
      },
      menuChildren: itemBuilder?.call(_overlay) ?? <Widget>[
        CupertinoMenuItem(
          child: Text(_overlay.getItemLabel(0)),
        )
      ],
    );
  }



  CupertinoMenuAnchor buildList(
    List<Widget> children,
  ) {
    return  build(
       itemBuilder:  (ControlSet control) {
          return children;
        },
    );
  }

  // CupertinoApp buildSimpleApp(
  //   [CupertinoMenuAnchorChildBuilder? anchorBuilder,
  //   List<Widget> Function(ControlSet)? itemBuilder,]
  // ) {
  //   return buildApp(build(anchorBuilder: anchorBuilder, itemBuilder: itemBuilder));
  // }

  // CupertinoApp buildListApp( {List<Widget>? children,List<Widget>? beforeWidgets,List<Widget>? afterWidgets}) {
  //   return buildApp(Column(children: <Widget>[
  //     if (beforeWidgets != null) ...beforeWidgets,
  //     build.call(itemBuilder: children != null ? (ControlSet control) => children : null),
  //     if (afterWidgets != null) ...afterWidgets
  //   ]));
  // }
}

// class SampleNestedMenu<T> extends SampleMenu<T> {
//   SampleNestedMenu({
//     required super.withController,
//   });

//   @override
//   RootControlDef root = RootControlDef(anchorText: 'root');
//   NestedControlDef sub_1 = NestedControlDef(anchorText: 'nested1');
//   NestedControlDef sub_2 = NestedControlDef(anchorText: 'nested2');
//   NestedControlDef sub_1_1 = NestedControlDef(anchorText: 'nested1.1');
//   NestedControlDef sub_1_2 = NestedControlDef(anchorText: 'nested1.2');
//   NestedControlDef sub_2_1 = NestedControlDef(anchorText: 'nested2.1');
//   NestedControlDef sub_2_2 = NestedControlDef(anchorText: 'nested2.2');

//   List<NestedControlDef> get subMenuControls =>
//       <NestedControlDef>[sub_1, sub_2, sub_1_1, sub_1_2, sub_2_1, sub_2_2];

//   @override
//   CupertinoMenuController get control => root.control;

//   @override
//   void next() {
//     _controlCount++;
//     root = RootControlDef(anchorText: 'root $_controlCount');
//     sub_1 = NestedControlDef(anchorText: 'nested1  $_controlCount');
//     sub_2 = NestedControlDef(anchorText: 'nested2  $_controlCount');
//     sub_1_1 = NestedControlDef(anchorText: 'nested1.1  $_controlCount');
//     sub_1_2 = NestedControlDef(anchorText: 'nested1.2  $_controlCount');
//     sub_2_1 = NestedControlDef(anchorText: 'nested2.1  $_controlCount');
//     sub_2_2 = NestedControlDef(anchorText: 'nested2.2  $_controlCount');
//   }

//   @override
//   CupertinoMenuButton<T> build(
//     BuildContext context,

//     /// A builder to run for each menu item.
//     [
//     SampleBuilder<T>? builder,
//   ]) {
//     return CupertinoMenuButton<T>(
//       key: root.key,
//       controller: withController ? root.control : null,
//       itemBuilder: (BuildContext context) {
//         return <CupertinoMenuEntry<T>>[
//           ...builder?.call(context, root) ?? <CupertinoNestedMenu<T>>[],
//           CupertinoNestedMenu<T>(
//             key: sub_1.key,
//             menuLayerKey: sub_1.menuLayerKey,
//             collapsedMenuAnchorKey: sub_1.bottomAnchor,
//             expandedMenuAnchorKey: sub_1.topAnchor,
//             controller: withController ? sub_1.control : null,
//             title: TextSpan(text: sub_1.anchorText),
//             itemBuilder: (BuildContext context) {
//               return <CupertinoMenuEntry<T>>[
//                 ...builder?.call(context, sub_1) ?? <CupertinoMenuItem<T>>[],
//                 CupertinoNestedMenu<T>(
//                     key: sub_1_1.key,
//                     menuLayerKey: sub_1_1.menuLayerKey,
//                     collapsedMenuAnchorKey: sub_1_1.bottomAnchor,
//                     expandedMenuAnchorKey: sub_1_1.topAnchor,
//                     controller: withController ? sub_1_1.control : null,
//                     title: TextSpan(text: sub_1_1.anchorText),
//                     itemBuilder: (BuildContext context) {
//                       return <CupertinoMenuEntry<T>>[
//                         ...builder?.call(context, sub_1_1) ??
//                             <CupertinoMenuItem<T>>[
//                               CupertinoMenuItem<T>(
//                                 child: Text(sub_1_1.itemText),
//                               )
//                             ],
//                       ];
//                     }),
//                 CupertinoNestedMenu<T>(
//                   key: sub_1_2.key,
//                   menuLayerKey: sub_1_2.menuLayerKey,
//                   collapsedMenuAnchorKey: sub_1_2.bottomAnchor,
//                   expandedMenuAnchorKey: sub_1_2.topAnchor,
//                   controller: withController ? sub_1_2.control : null,
//                   title: TextSpan(text: sub_1_2.anchorText),
//                   itemBuilder: (BuildContext context) {
//                     return <CupertinoMenuEntry<T>>[
//                       ...builder?.call(context, sub_1_2) ??
//                           <CupertinoMenuEntry<T>>[
//                             CupertinoMenuItem<T>(
//                               child: Text(sub_1_2.itemText),
//                             )
//                           ]
//                     ];
//                   },
//                 )
//               ];
//             },
//           ),
//           CupertinoNestedMenu<T>(
//             key: sub_2.key,
//             menuLayerKey: sub_2.menuLayerKey,
//             collapsedMenuAnchorKey: sub_2.bottomAnchor,
//             expandedMenuAnchorKey: sub_2.topAnchor,
//             controller: withController ? sub_2.control : null,
//             title: TextSpan(text: sub_2.anchorText),
//             itemBuilder: (BuildContext context) {
//               return <CupertinoMenuEntry<T>>[
//                 ...builder?.call(context, sub_2) ?? <CupertinoMenuItem<T>>[],
//                 CupertinoNestedMenu<T>(
//                   key: sub_2_1.key,
//                   menuLayerKey: sub_2_1.menuLayerKey,
//                   collapsedMenuAnchorKey: sub_2_1.bottomAnchor,
//                   expandedMenuAnchorKey: sub_2_1.topAnchor,
//                   controller: withController ? sub_2_1.control : null,
//                   title: TextSpan(text: sub_2_1.anchorText),
//                   itemBuilder: (BuildContext context) {
//                     return <CupertinoMenuEntry<T>>[
//                       ...builder?.call(context, sub_2_1) ??
//                           <CupertinoMenuEntry<T>>[
//                             CupertinoMenuItem<T>(
//                               child: Text(sub_2_1.itemText),
//                             )
//                           ],
//                     ];
//                   },
//                 ),
//                 CupertinoNestedMenu<T>(
//                   key: sub_2_2.key,
//                   menuLayerKey: sub_2_2.menuLayerKey,
//                   collapsedMenuAnchorKey: sub_2_2.bottomAnchor,
//                   expandedMenuAnchorKey: sub_2_2.topAnchor,
//                   controller: withController ? sub_2_2.control : null,
//                   title: TextSpan(text: sub_2_2.anchorText),
//                   itemBuilder: (BuildContext context) {
//                     return <CupertinoMenuEntry<T>>[
//                       ...builder?.call(context, sub_2_2) ??
//                           <CupertinoMenuEntry<T>>[
//                             CupertinoMenuItem<T>(
//                               child: Text(sub_2_2.itemText),
//                             )
//                           ],
//                     ];
//                   },
//                 )
//               ];
//             },
//           )
//         ];
//       },
//     );
//   }

//   @override
//   ButtonBuilder<T> buildList(
//     List<CupertinoMenuEntry<T>> children,
//   ) {
//     return (BuildContext context) => build(
//           context,
//           (BuildContext context, ControlSet<State<StatefulWidget>> control) {
//             return children;
//           },
//         );
//   }

//   @override
//   ButtonBuilder<T> buildItem(
//     CupertinoMenuEntry<T> child,
//   ) {
//     return buildList(<CupertinoMenuEntry<T>>[child]);
//   }

//   @override
//   CupertinoApp buildItemApp(CupertinoMenuEntry<T> child) {
//     return buildApp(buildItem(child));
//   }

//   @override
//   CupertinoApp buildListApp(List<CupertinoMenuEntry<T>> children) {
//     return buildApp(buildList(children));
//   }
// }
