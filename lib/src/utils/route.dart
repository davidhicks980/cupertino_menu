import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_menu/src/utils/swipe_listener.dart';

import 'controllers.dart';

part 'route_layout.dart';

final key = GlobalKey();

class CupertinoMenuRoute<T> extends PopupRoute<T> {
  CupertinoMenuRoute({
    required this.barrierLabel,
    required this.menuBuilder,
    required this.curve,
    required this.reverseCurve,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
  }) : super(
          traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
        );

  @override
  bool allowSnapshotting = true;

  final Curve curve;
  final Curve reverseCurve;

  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) menuBuilder;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return menuBuilder(context, animation, secondaryAnimation);
  }

  @override
  Animation<double> createAnimation() => CurvedAnimation(
        parent: super.createAnimation(),
        curve: curve,
        reverseCurve: reverseCurve,
      );
}

class CupertinoMenu extends StatefulWidget {
  const CupertinoMenu({
    super.key,
    required this.child,
    required this.animation,
    required this.anchorPosition,
    required this.hasLeadingWidget,
    required this.secondaryAnimation,
    required this.alignment,
    required this.offset,
    required this.childCount,
  });

  final int childCount;
  final Widget child;
  final Rect anchorPosition;
  final Offset offset;
  final Alignment alignment;
  final bool hasLeadingWidget;
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;

  @override
  State<CupertinoMenu> createState() => _CupertinoMenuState();
}

class _CupertinoMenuState extends State<CupertinoMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _layerVisibilityNotifier;
  late final _swipeNotifier = ValueNotifier(
    const CupertinoSwipeDetails(
      complete: true,
      globalPosition: Offset.zero,
    ),
  );
  final ValueNotifier<bool> _isRootMenuClosing = ValueNotifier(false);

  int _topLayer = 0;

  void _updateTopLayer() {
    final layer = (_layerVisibilityNotifier.value - 0.01).floor();
    if (layer != _topLayer) {
      setState(() {
        _topLayer = layer;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _layerVisibilityNotifier = AnimationController(
      vsync: this,
      value: 0.0,
      upperBound: 100,
      duration: const Duration(milliseconds: 20),
    )..addListener(_updateTopLayer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context)?.popped.then((_) {
      if (mounted) {
        _isRootMenuClosing.value = true;
      }
    });
  }

  @override
  void dispose() {
    _layerVisibilityNotifier.dispose();
    _swipeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<MenuLayerAnimationNotification>(
      onNotification: _handleLayerAnimationNotification,
      child: CupertinoMenuModel(
        data: CupertinoMenuModelData(
          alignment: widget.alignment,
          anchorPosition: widget.anchorPosition,
          isClosing: _isRootMenuClosing,
          visibilityAnimation: _layerVisibilityNotifier.view,
          topLayer: _topLayer,
        ),
        child: CupertinoMenuLayerController(
          childCount: widget.childCount,
          depth: 0,
          anchorPosition: widget.anchorPosition,
          hasLeadingWidget: widget.hasLeadingWidget,
          child: CupertinoSwipeListener(
            notifier: _swipeNotifier,
            root: true,
            child: CustomSingleChildLayout(
              delegate: CupertinoMenuRouteLayout(
                offset: widget.offset,
                anchorPosition: widget.anchorPosition,
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
                  ..add(widget.anchorPosition),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  bool _handleLayerAnimationNotification(
    MenuLayerAnimationNotification notification,
  ) {
    final progress = notification.progress + notification.depth;

    if (progress < _layerVisibilityNotifier.value) {
      _layerVisibilityNotifier.animateBack(progress);
    } else {
      _layerVisibilityNotifier.animateTo(progress);
    }
    return true;
  }
}
