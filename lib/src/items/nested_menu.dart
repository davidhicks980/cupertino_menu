import 'dart:async';
import 'dart:ui';

import 'package:cupertino_menu/src/utils/swipe_listener.dart';
import 'package:flutter/cupertino.dart';

import '../../cupertino_menu.dart';
import '../utils/controllers.dart';
import 'base.dart';

class CupertinoNestedMenuChevron extends StatelessWidget {
  final List<Shadow> shadows;

  const CupertinoNestedMenuChevron({super.key, required this.shadows});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: String.fromCharCode(
          CupertinoIcons.chevron_forward.codePoint,
        ),
        style: TextStyle(
          fontSize: 17,
          height: 22 / 17,
          fontWeight: FontWeight.w500,
          fontFamily: CupertinoIcons.chevron_forward.fontFamily,
          package: CupertinoIcons.chevron_forward.fontPackage,
          textBaseline: TextBaseline.alphabetic,
          shadows: shadows,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class CupertinoNestedRoutedButton extends StatefulWidget
    implements CupertinoMenuEntry<Never> {
  const CupertinoNestedRoutedButton({
    super.key,
    required this.child,
    required this.subtitle,
    required this.onTap,
    required this.animation,
    this.trailing,
    required this.isTopButton,
  });

  final Widget child;
  final Widget? subtitle;
  final Widget? trailing;
  final Animation<double> animation;
  final void Function()? onTap;
  final bool isTopButton;

  @override
  bool get hasLeading => true;

  /// This is not currently used by the [CupertinoNestedRoutedButton] but is required by
  /// [CupertinoMenuEntry]. TODO: determine whether to measure menu items based on user-provided height, or to calculate height at runtime.
  @override
  double get height => 44;
  @override
  State<CupertinoNestedRoutedButton> createState() =>
      _CupertinoNestedRoutedButtonState();
}

class _CupertinoNestedRoutedButtonState
    extends State<CupertinoNestedRoutedButton> {
  late Animation<double>? _submenuGlyphAnimation;
  late Animation<double> _labelAnimation;
  late Animation<TextStyle>? _textStyleAnimation;

  TextStyle? _defaultTextStyle;
  @override
  void initState() {
    super.initState();
    _labelAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCirc,
      reverseCurve: Curves.easeInCubic,
    ).drive(
      TweenSequence<double>(
        [
          TweenSequenceItem(
            tween: Tween(begin: 0, end: 1.0),
            weight: 80.0,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 1.0),
            weight: 20.0,
          ),
        ],
      ),
    );
    _submenuGlyphAnimation = _labelAnimation.drive(Tween(begin: 0, end: 0.25));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDefaultTextStyle = DefaultTextStyle.of(context).style;
    if (_defaultTextStyle != newDefaultTextStyle) {
      _defaultTextStyle = newDefaultTextStyle;
      _updateTextAnimation();
    }
  }

  void _updateTextAnimation() {
    _textStyleAnimation = TextStyleTween(
      begin: _defaultTextStyle,
      end: _defaultTextStyle!.copyWith(
        letterSpacing: (_defaultTextStyle!.letterSpacing ?? 0) + 0.5,
        shadows: _buildSymmetricTextShadows(0.18),
      ),
    ).animate(_labelAnimation);
  }

  List<Shadow> _buildSymmetricTextShadows(
    double shadow,
  ) {
    final color = DefaultTextStyle.of(context).style.color ??
        CupertinoColors.label.resolveFrom(context);
    return [
      Shadow(
        color: color,
        offset: Offset(-shadow, -shadow),
      ),
      Shadow(
        color: color,
        offset: Offset(shadow, -shadow),
      ),
      Shadow(
        color: color,
        offset: Offset(shadow, shadow),
      ),
      Shadow(
        color: color,
        offset: Offset(-shadow, shadow),
      ),
    ];
  }

  double get _verticalPadding => widget.subtitle != null ? 12 : 8;
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isTopButton,
      maintainAnimation: true,
      maintainSize: true,
      maintainState: true,
      child: CupertinoMenuItemBase<Never>(
        swipePressActivationDelay: const Duration(milliseconds: 500),
        shouldPopMenuOnPressed: false,
        onTap: widget.onTap,
        trailing: widget.trailing,
        padding: EdgeInsetsDirectional.fromSTEB(
          6.5,
          _verticalPadding,
          17.5,
          _verticalPadding,
        ),
        leading: RotationTransition(
          turns: _submenuGlyphAnimation!,
          child: CupertinoNestedMenuChevron(
            shadows: _buildSymmetricTextShadows(0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text shadow is used instead of font weight
            // to get a smoother bolding effect.
            DefaultTextStyleTransition(
              maxLines: widget.subtitle != null ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: _textStyleAnimation!,
              child: widget.child,
            ),
            if (widget.subtitle != null)
              DefaultTextStyle.merge(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel,
                    context,
                  ),
                  textBaseline: TextBaseline.alphabetic,
                  letterSpacing: -0.21,
                ),
                child: widget.subtitle!,
              )
          ],
        ),
      ),
    );
  }
}

/// The (optional) title of the pull-down menu that is usually displayed at the
/// top of pull-down menu.
///
/// [child] is typically a [Text] widget.
@immutable
class CupertinoNestedRoutedMenu<T> extends StatefulWidget
    implements CupertinoMenuEntry<T> {
  /// Creates a title for a pull-down menu.
  const CupertinoNestedRoutedMenu({
    super.key,
    required this.child,
    required this.itemBuilder,
    this.trailing,
    this.subtitle,
    this.enabled = true,
    this.toggle,
    this.curve = const ElasticOutCurve(2),
    this.reverseCurve = Curves.easeIn,
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration = const Duration(milliseconds: 444),
    this.backgroundColor,
    this.hasLeading = true,
  });
  final Widget child;
  final Widget? subtitle;
  final Widget? trailing;
  final void Function()? toggle;
  final List<CupertinoMenuEntry<T>> Function(BuildContext) itemBuilder;
  final Curve curve;
  final Curve reverseCurve;
  final Duration duration;
  final Duration reverseDuration;
  final bool enabled;
  final Color? backgroundColor;
  @override
  final bool hasLeading;

  @override
  double get height => 44;

  @override
  State<CupertinoNestedRoutedMenu<T>> createState() =>
      _CupertinoNestedMenuState<T>();
}

class _CupertinoNestedMenuState<T> extends State<CupertinoNestedRoutedMenu<T>> {
  bool isTopButton = true;
  List<Widget>? items;
  Animation<double>? _parentSecondaryAnimation;
  Color get backgroundColor =>
      widget.backgroundColor ?? kCupertinoMenuBackground.resolveFrom(context);

  BorderRadius get _initialNestedMenuClip {
    final submenuIndex = InheritedIndex.maybeOf(context);
    if (submenuIndex == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(14),
        topRight: Radius.circular(14),
      );
    } else if (submenuIndex ==
        CupertinoMenuLayerController.of(context).childCount - 1) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(14),
        bottomRight: Radius.circular(14),
      );
    } else {
      return BorderRadius.zero;
    }
  }

  void listener(AnimationStatus status) {
    if (context.mounted && status == AnimationStatus.dismissed) {
      setState(() {
        isTopButton = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)!.secondaryAnimation;
    if (_parentSecondaryAnimation != animation) {
      _parentSecondaryAnimation?.removeStatusListener(listener);
      _parentSecondaryAnimation = animation;
      _parentSecondaryAnimation?.addStatusListener(listener);
    }
  }

  @override
  void dispose() {
    _parentSecondaryAnimation?.removeStatusListener(listener);
    super.dispose();
  }

  bool _handleAnimationNotification(
    MenuLayerAnimationNotification notification,
  ) {
    if (mounted) {
      notification.dispatch(context);
    }

    return false;
  }

  void showMenu() {
    if (isTopButton == false) {
      return;
    }
    setState(() {
      isTopButton = false;
    });
    final RenderBox anchorBox = context.findRenderObject()! as RenderBox;
    final RenderBox overlayBox =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final navigator = Navigator.of(context, rootNavigator: true);
    final Rect anchorPosition = Rect.fromPoints(
      anchorBox.localToGlobal(
        Offset.zero,
        ancestor: overlayBox,
      ),
      anchorBox.localToGlobal(
        anchorBox.size.bottomRight(Offset.zero),
        ancestor: overlayBox,
      ),
    );

    final depth = CupertinoMenuLayerController.of(context).depth;
    showNestedCupertinoMenu<CupertinoMenuValue<T?>>(
      context: context,
      offset: Offset.zero,
      depth: depth + 1,
      pageBuilder: (
        BuildContext childContext,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ).wrap(
          NotificationListener(
            onNotification: _handleAnimationNotification,
            child: CupertinoNestedMenuPage(
              reportAnimationProgress: () {
                if (mounted) {
                  MenuLayerAnimationNotification(
                    depth: depth + 1,
                    progress: animation.value,
                  ).dispatch(context);
                }
              },
              anchorPosition: anchorPosition,
              items: CupertinoMenuOverlay.buildMenuItems([
                CupertinoNestedRoutedButton(
                  subtitle: widget.subtitle,
                  animation: animation,
                  isTopButton: true,
                  onTap: () {
                    if (animation.status != AnimationStatus.reverse) {
                      Navigator.of(childContext).pop(
                        CupertinoMenuValue<T?>(popToDepth: depth),
                      );
                    }
                  },
                  child: widget.child,
                ),
                ...widget.itemBuilder(context)
              ]),
              curve: widget.curve,
              reverseCurve: widget.reverseCurve,
              animation: animation,
              depth: depth + 1,
              menuClip: _initialNestedMenuClip,
              parent: CupertinoMenuController.of(context),
              swipeNotifier: CupertinoSwipeListener.notifierOf(context),
            ),
          ),
        );
      },
    ).then((CupertinoMenuValue<T?>? value) {
      if (!mounted || value?.popToDepth == depth) {
        return;
      }
      print(value?.popToDepth == depth);

      Navigator.of(context).pop(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoNestedRoutedButton(
      onTap: showMenu,
      subtitle: widget.subtitle,
      trailing: widget.trailing,
      animation: const AlwaysStoppedAnimation(0),
      isTopButton: isTopButton,
      child: widget.child,
    );
  }
}

Future<T?> showNestedCupertinoMenu<T>({
  required BuildContext context,
  required Offset offset,
  required Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
  ) pageBuilder,
  required int depth,
  Duration duration = const Duration(milliseconds: 500),
  Duration reverseDuration = const Duration(milliseconds: 444),
  VoidCallback? onClosed,
  VoidCallback? onOpened,
}) async {
  return Navigator.of(context).push<T>(
    CupertinoMenuRoute(
      barrierLabel: getLocalizedBarrierLabel(context),
      curve: Curves.linear,
      reverseCurve: Curves.linear,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      menuBuilder: (
        BuildContext childContext,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return pageBuilder(context, animation, secondaryAnimation);
      },
    ),
  );
}

class CupertinoNestedMenuPage<T> extends StatefulWidget {
  const CupertinoNestedMenuPage({
    super.key,
    required this.parent,
    required this.items,
    required this.depth,
    required this.anchorPosition,
    required this.menuClip,
    required this.animation,
    required this.curve,
    required this.reverseCurve,
    required this.swipeNotifier,
    required this.reportAnimationProgress,
  });

  final CupertinoMenuModelData parent;
  final List<CupertinoMenuEntry<T>> items;
  final Rect anchorPosition;
  final BorderRadius menuClip;
  final int depth;
  final void Function() reportAnimationProgress;

  final ValueNotifier<CupertinoSwipeDetails> swipeNotifier;
  final Animation<double> animation;
  final Curve curve;
  final Curve reverseCurve;

  @override
  State<CupertinoNestedMenuPage<T>> createState() =>
      _CupertinoNestedMenuPageState<T>();
}

class _CupertinoNestedMenuPageState<T>
    extends State<CupertinoNestedMenuPage<T>> {
  late CurvedAnimation animation;
  final hitTest = GlobalKey<RawGestureDetectorState>();

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(widget.reportAnimationProgress);
    animation = CurvedAnimation(
      parent: widget.animation,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    );
  }

  @override
  void didUpdateWidget(covariant CupertinoNestedMenuPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(widget.reportAnimationProgress);
      widget.animation.addListener(widget.reportAnimationProgress);
    }
    if (widget.curve != oldWidget.curve ||
        widget.reverseCurve != oldWidget.reverseCurve) {
      animation = CurvedAnimation(
        parent: widget.animation,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
      );
    }
  }

  @override
  void dispose() {
    widget.animation.removeListener(widget.reportAnimationProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext childContext) {
    return CupertinoMenuController(
      data: widget.parent,
      child: CupertinoSwipeListener(
        notifier: widget.swipeNotifier,
        child: CupertinoMenuLayerController(
          depth: widget.depth,
          anchorPosition: widget.anchorPosition,
          hasLeadingWidget: true,
          childCount: widget.items.length,
          child: Builder(
            builder: (context) {
              return CustomSingleChildLayout(
                delegate: CupertinoNestedMenuRouteLayout(
                  depth: widget.depth,
                  finalMenuPosition:
                      CupertinoMenuLayerController.sizeOf(context),
                  anchorPosition: widget.anchorPosition,
                  rootAnchorPosition: widget.parent.anchorPosition,
                  textDirection: Directionality.of(context),
                  padding: MediaQuery.paddingOf(context),
                  avoidBounds: MediaQuery.displayFeaturesOf(context)
                      .where(
                        (feature) =>
                            feature.bounds.shortestSide > 0 ||
                            feature.state ==
                                DisplayFeatureState.postureHalfOpened,
                      )
                      .map((feature) => feature.bounds)
                      .toSet()
                    ..add(widget.parent.anchorPosition),
                ),
                child: CupertinoNestedMenuOverlay(
                  items: widget.items,
                  nestedAnchor: widget.anchorPosition,
                  initialClip: widget.menuClip,
                  animation: animation,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
