// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';

import '../items/base.dart';

abstract class MenuLayerNotification extends Notification {
  int get depth;
}

class MenuLayerPositionNotification extends Notification {
  final Size rect;

  MenuLayerPositionNotification({
    required this.rect,
  });
  @override
  String toString() {
    return "MenuNotification($rect)";
  }
}

class MenuLayerAnimationNotification extends MenuLayerNotification {
  final double progress;
  @override
  final int depth;

  MenuLayerAnimationNotification({required this.progress, required this.depth});
  @override
  String toString() {
    return "MenuNotification($progress, $depth)";
  }
}

class CupertinoMenuModelData {
  final Animation<double> visibilityAnimation;
  final ValueNotifier<bool> isClosing;
  final Rect anchorPosition;
  final Alignment alignment;
  final int topLayer;
  const CupertinoMenuModelData({
    required this.visibilityAnimation,
    required this.isClosing,
    required this.anchorPosition,
    required this.alignment,
    required this.topLayer,
  });

  @override
  bool operator ==(covariant CupertinoMenuModelData other) {
    if (identical(this, other)) return true;

    return other.visibilityAnimation == visibilityAnimation &&
        other.isClosing == isClosing &&
        other.anchorPosition == anchorPosition &&
        other.alignment == alignment &&
        other.topLayer == topLayer;
  }

  @override
  int get hashCode {
    return visibilityAnimation.hashCode ^
        isClosing.hashCode ^
        anchorPosition.hashCode ^
        alignment.hashCode ^
        topLayer.hashCode;
  }

  CupertinoMenuModelData copyWith({
    Animation<double>? visibilityAnimation,
    ValueNotifier<bool>? isClosing,
    Rect? anchorPosition,
    Alignment? alignment,
    int? topLayer,
  }) {
    return CupertinoMenuModelData(
      visibilityAnimation: visibilityAnimation ?? this.visibilityAnimation,
      isClosing: isClosing ?? this.isClosing,
      anchorPosition: anchorPosition ?? this.anchorPosition,
      alignment: alignment ?? this.alignment,
      topLayer: topLayer ?? this.topLayer,
    );
  }
}

class CupertinoMenuModel extends InheritedWidget {
  const CupertinoMenuModel({
    super.key,
    required super.child,
    required this.data,
  });

  final CupertinoMenuModelData data;

  @override
  bool updateShouldNotify(CupertinoMenuModel oldWidget) {
    return oldWidget.data != data;
  }

  static CupertinoMenuModel? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CupertinoMenuModel>();
  }

  static CupertinoMenuModel of(BuildContext context) {
    final CupertinoMenuModel? result = maybeOf(context);
    assert(result != null, 'No CupertinoMenuModel found in context');
    return result!;
  }
}

class CupertinoMenuLayerArea extends InheritedNotifier<ValueNotifier<Size>> {
  const CupertinoMenuLayerArea({
    super.key,
    required super.child,
    required super.notifier,
  });
}

class CupertinoMenuLayerModel extends InheritedWidget {
  const CupertinoMenuLayerModel({
    super.key,
    required super.child,
    required this.anchorPosition,
    required this.area,
    required this.depth,
    required this.hasLeadingWidget,
    required this.childCount,
  });

  final Rect? anchorPosition;
  final ValueNotifier<Size> area;
  final int depth;
  final bool hasLeadingWidget;
  final int childCount;

  @override
  bool updateShouldNotify(covariant CupertinoMenuLayerModel other) {
    return other.anchorPosition != anchorPosition ||
        other.area != area ||
        other.depth != depth ||
        other.hasLeadingWidget != hasLeadingWidget ||
        other.childCount != childCount;
  }
}

/// An inherited wrapper allows a [Widget] to know it's index in the list.
///
/// Used by [CupertinoMenu] to determine whether an item should have rounded borders.
class InheritedIndex extends InheritedWidget with CupertinoMenuEntry<Never> {
  const InheritedIndex({
    super.key,
    required this.index,
    required super.child,
  });

  /// The index of the menu item.
  final int index;

  static int? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedIndex>()?.index;

  @override
  bool updateShouldNotify(InheritedIndex oldWidget) {
    return index != oldWidget.index;
  }
}

/// Provides layer information to the members of a [CupertinoMenu] or a
/// [CupertinoNestedRoutedMenu].
///
/// See also:
/// * [CupertinoMenuController], which provides information about all menu layers
class CupertinoMenuLayerController extends StatefulWidget {
  const CupertinoMenuLayerController({
    super.key,
    required this.child,
    required this.anchorPosition,
    required this.depth,
    required this.hasLeadingWidget,
    required this.childCount,
  });

  // The menu layer's contents
  final Widget child;

  // The attachment point of the menu layer.
  final Rect? anchorPosition;

  // The number of menu layers below this layer. The base menu layer has a depth of 0.
  final int depth;

  // Whether any menu items in this layer have a leading widget.
  final bool hasLeadingWidget;

  // The number of menu items on this layer.
  final int childCount;

  static CupertinoMenuLayerModel of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CupertinoMenuLayerModel>()!;

  static Size sizeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CupertinoMenuLayerArea>()!
      .notifier!
      .value;

  @override
  State<CupertinoMenuLayerController> createState() =>
      _CupertinoMenuLayerControllerState();
}

class _CupertinoMenuLayerControllerState
    extends State<CupertinoMenuLayerController> {
  final ValueNotifier<Size> _area = ValueNotifier(Size.zero);

  bool _handlePositionNotification(MenuLayerPositionNotification notification) {
    _area.value = notification.rect;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<MenuLayerPositionNotification>(
      onNotification: _handlePositionNotification,
      child: CupertinoMenuLayerModel(
        anchorPosition: widget.anchorPosition,
        area: _area,
        depth: widget.depth,
        hasLeadingWidget: widget.hasLeadingWidget,
        childCount: widget.childCount,
        child: CupertinoMenuLayerArea(
          notifier: _area,
          child: widget.child,
        ),
      ),
    );
  }
}

class CupertinoMenuController extends StatefulWidget {
  const CupertinoMenuController({
    super.key,
    this.onVisibilityChanged,
    required this.data,
    required this.child,
  });

  final Widget child;
  final CupertinoMenuModelData data;
  final ValueChanged<double>? onVisibilityChanged;

  static CupertinoMenuModelData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CupertinoMenuModel>()!.data;

  @override
  State<CupertinoMenuController> createState() =>
      _CupertinoMenuControllerState();
}

class _CupertinoMenuControllerState extends State<CupertinoMenuController> {
  int topLayer = 0;

  void updateActiveLayer() {
    final layer = (widget.data.visibilityAnimation.value - 0.01).floor();
    if (layer != topLayer) {
      setState(() {
        topLayer = layer;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.data.visibilityAnimation.addListener(updateActiveLayer);
  }

  @override
  void dispose() {
    widget.data.visibilityAnimation.removeListener(updateActiveLayer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoMenuModel(
      data: widget.data.copyWith(topLayer: topLayer),
      child: widget.child,
    );
  }
}
