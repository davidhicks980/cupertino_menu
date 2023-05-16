import 'package:cupertino_menu/src/items/base.dart';
import 'package:flutter/cupertino.dart';

const titleStyle = TextStyle(
  inherit: false,
  fontFamily: '.SF UI Text',
  fontSize: 12,
  height: 16 / 12,
  fontWeight: FontWeight.w400,
  textBaseline: TextBaseline.alphabetic,
);

/// The (optional) title of the pull-down menu that is usually displayed at the
/// top of pull-down menu.
///
/// [child] is typically a [Text] widget.
@immutable
class CupertinoMenuTitle extends StatelessWidget
    with CupertinoMenuEntry<Never> {
  /// Creates a title for a pull-down menu.
  const CupertinoMenuTitle({
    super.key,
    required this.child,
    this.textAlign = TextAlign.center,
  });

  final TextAlign textAlign;

  /// Eyeballed from iOS 16.
  static const double kCupertinoMenuTitleHeight = 30;

  /// Typically a [Text] widget with short one/two words content and
  /// [Text.textAlign] set to [TextAlign.center].
  final Widget child;

  @override
  double get height => 30;

  @override
  bool get hasLeading => false;
  @override
  Widget build(BuildContext context) {
    return CupertinoMenuItemStructure(
      height: height,
      padding: textAlign == TextAlign.center
          ? EdgeInsetsDirectional.zero
          : const EdgeInsetsDirectional.fromSTEB(6.5, 8, 17.5, 8),
      removeLeadingSpace: textAlign == TextAlign.center,
      child: DefaultTextStyle(
        maxLines: 2,
        style: titleStyle.copyWith(
          overflow: TextOverflow.ellipsis,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
        textAlign: textAlign,
        child: child,
      ),
    );
  }
}
