import 'package:flutter/cupertino.dart';

import 'base.dart';

/// An item in a Cupertino menu.
///
/// By default, a [CupertinoMenuItem] is minimum of [kMinInteractiveDimensionCupertino]
/// pixels height.
///
/// See also:
/// * [CupertinoMenu], a menu widget that can be toggled on and off.
@immutable
class CupertinoMenuItem<T> extends CupertinoMenuItemBase<T> {
  /// An item in a Cupertino menu.
  const CupertinoMenuItem({
    super.key,
    required super.child,
    super.onTap,
    super.isDestructiveAction,
    super.value,
    super.padding,
    super.enabled = true,
    super.isDefaultAction,
    super.trailing,
    super.height,
    super.shouldPopMenuOnPressed = true,
  });
}

/// A checkmark in a [CupertinoCheckedMenuItem].
class CupertinoCheckMark extends StatelessWidget {
  const CupertinoCheckMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: String.fromCharCode(
          CupertinoIcons.check_mark.codePoint,
        ),
        style: TextStyle(
          fontSize: 16,
          height: 22 / 17,
          fontWeight: FontWeight.w600,
          fontFamily: CupertinoIcons.check_mark.fontFamily,
          package: CupertinoIcons.check_mark.fontPackage,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// An item in a Cupertino menu with a leading checkmark.
///
/// Whether or not the checkmark is displayed can be set by by [checked].
@immutable
class CupertinoCheckedMenuItem<T> extends CupertinoMenuItemBase<T> {
  /// An item in a Cupertino menu.
  const CupertinoCheckedMenuItem({
    required super.child,
    super.key,
    super.onTap,
    super.isDestructiveAction,
    super.enabled = true,
    super.isDefaultAction,
    super.trailing,
    this.checked = true,
  });

  @override
  bool get hasLeading => true;

  @override
  Widget? get leading => checked ?? false ? const CupertinoCheckMark() : null;

  /// Whether to display a checkmark next to the menu item.
  ///
  /// Defaults to false.
  ///
  /// When true, an [CupertinoIcons.check_mark] checkmark is displayed.
  ///
  /// When this popup menu item is selected, the checkmark will fade in or out
  /// as appropriate to represent the implied new state.
  final bool? checked;
}
