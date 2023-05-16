import 'package:flutter/cupertino.dart';

import '../../cupertino_menu.dart';
import 'base.dart';
import 'divider.dart';

enum CupertinoMenuActionSize {
  /// Compact, icon only representation.
  ///
  /// Used to configure how the [CupertinoMenuActionRow] show its
  /// [CupertinoMenuItem]'s and their maximum count. Maximum 4 items.
  small,

  /// Medium, icon and title vertically aligned.
  ///
  /// Used to configure how the [CupertinoMenuActionRow] show its
  /// [CupertinoMenuItem]'s and their maximum count. Maximum 3 items.
  medium,
}

/// A horizontally-placed Cupertino menu item.
///
/// Action items should be placed adjacent to each other in a group of 3 or 4.
///
/// When placed in a group of 3, each item will display an
/// [icon] above a [child]. In a group of 4, items will only display an [icon].
///
/// Setting [isDestructiveAction] to `true` indicates that the action is
/// irreversible or will result in deleted data. When `true`, the item's
/// label and icon will be [CupertinoColors.destructiveRed]
///
/// If the [onPressed] callback is null, the item will not react to touch and
/// it's contents will be [CupertinoColors.inactiveGray].
///
///
/// See also:
///  * [CupertinoMenuButton], a Cupertino-style menu.
///  * [CupertinoMenuItem], a full-width Cupertino menu item
class CupertinoMenuActionItem<T> extends CupertinoInteractiveMenuItem<T> {
  const CupertinoMenuActionItem({
    super.key,
    required super.child,
    required this.icon,
    super.isDestructiveAction,
    super.enabled = true,
    super.onTap,
    super.value,
  });

  /// An icon that will be placed in the center of this action item.

  final Icon icon;
  @override
  Widget buildChild(BuildContext context) {
    final menuItemSize = CupertinoMenuActionRow.of(context);
    final actionIcon = IconTheme.merge(
      data: const IconThemeData(size: 21),
      child: icon,
    );

    if (menuItemSize == CupertinoMenuActionSize.small) {
      return Center(child: actionIcon);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: actionIcon),
          DefaultTextStyle.merge(
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1),
            child: Flexible(child: child),
          ),
        ],
      );
    }
  }
}

class _ActionRowState extends InheritedWidget {
  const _ActionRowState({
    required this.state,
    required super.child,
  });

  final CupertinoMenuActionRowState state;

  @override
  bool updateShouldNotify(_ActionRowState oldWidget) =>
      oldWidget.state != state;
}

class CupertinoMenuActionRow extends StatefulWidget
    implements CupertinoMenuEntry<Never> {
  const CupertinoMenuActionRow({
    super.key,
    required this.children,
  }) : assert(
          children.length == 3 || children.length == 4,
          "CupertinoMenuActionRow can only have 3 or 4 children",
        );

  CupertinoMenuActionSize get size {
    return children.length == 4
        ? CupertinoMenuActionSize.small
        : CupertinoMenuActionSize.medium;
  }

  @override
  bool get hasLeading => false;

  @override
  double get height => size == CupertinoMenuActionSize.small ? 44.0 : 62.0;

  final List<Widget> children;

  static CupertinoMenuActionSize? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ActionRowState>()
        ?.state
        .size;
  }

  @override
  State<CupertinoMenuActionRow> createState() => CupertinoMenuActionRowState();
}

class CupertinoMenuActionRowState extends State<CupertinoMenuActionRow> {
  CupertinoMenuActionSize get size => widget.size;
  CupertinoDynamicColor get backgroundColor =>
      kCupertinoMenuBackground.resolveFrom(context);

  @override
  Widget build(BuildContext context) {
    return _ActionRowState(
      state: this,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          height: widget.height,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: widget.children.first,
            ),
            for (final child in widget.children.skip(1))
              Expanded(
                child: CupertinoMenuVerticalDividerWrapper(
                  child: child,
                ),
              )
          ],
        ),
      ),
    );
  }
}
