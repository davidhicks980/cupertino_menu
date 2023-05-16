part of 'route.dart';

/// Minimum space from screen edges for pull-down menu to be rendered from.
const double _kMenuScreenPadding = 8;

abstract class CupertinoMenuRouteBaseLayout extends SingleChildLayoutDelegate {
  const CupertinoMenuRouteBaseLayout({
    this.offset = Offset.zero,
    required this.anchorPosition,
    required this.textDirection,
    required this.padding,
    required this.avoidBounds,
  });

  // Rectangle of underlying button that the menu is attached to.
  final Rect anchorPosition;

  /// The amount of displacement to apply to the menu's position.
  final Offset offset;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  // The padding to apply to the bounds of the screen that the menu is on.
  final EdgeInsets padding;

  // List of rectangles that the menu should not overlap. Unusable screen area.
  final Set<Rect> avoidBounds;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(_kMenuScreenPadding) + padding,
    );
  }

  Rect findClosestScreen(Size size, Offset point) {
    final screens = DisplayFeatureSubScreen.subScreensInBounds(
      Offset.zero & size,
      avoidBounds,
    );
    if (screens.isEmpty) {
      // Added this to avoid a crash when using TestApp
      return Rect.fromLTWH(0, 0, size.width, size.height);
    }
    Rect closest = screens.first;
    for (final screen in screens) {
      if ((screen.center - point).distance <
          (closest.center - point).distance) {
        closest = screen;
      }
    }

    return closest;
  }

  Offset fitInsideScreen(Rect screen, Size childSize, Offset wantedPosition) {
    double x = wantedPosition.dx;
    double y = wantedPosition.dy;
    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < screen.left + _kMenuScreenPadding + padding.left) {
      // Desired X would overflow left, so we set X to left screen edge
      x = screen.left + _kMenuScreenPadding + padding.left;
    } else if (x + childSize.width >
        screen.right - _kMenuScreenPadding - padding.right) {
      // Overflows right
      x = screen.right - childSize.width - _kMenuScreenPadding - padding.right;
    }

    if (y < screen.top + _kMenuScreenPadding + padding.top) {
      // Overflows top
      y = _kMenuScreenPadding + padding.top;
    } else if (y + childSize.height >
        screen.bottom - _kMenuScreenPadding - padding.bottom) {
      y = screen.bottom -
          childSize.height -
          _kMenuScreenPadding -
          padding.bottom;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(CupertinoMenuRouteBaseLayout oldDelegate) =>
      anchorPosition != oldDelegate.anchorPosition ||
      textDirection != oldDelegate.textDirection ||
      padding != oldDelegate.padding ||
      !setEquals(avoidBounds, oldDelegate.avoidBounds);
}

/// A [SingleChildLayoutDelegate] that controls the layout of a base [CupertinoMenu].
class CupertinoMenuRouteLayout extends CupertinoMenuRouteBaseLayout {
  const CupertinoMenuRouteLayout({
    super.offset,
    required super.anchorPosition,
    required super.textDirection,
    required super.padding,
    required super.avoidBounds,
  });

  @override
  Offset getPositionForChild(
    Size size,
    Size childSize,
  ) {
    final double screenHeightPercent = anchorPosition.center.dy / size.height;
    final bool openUp = screenHeightPercent > 0.45;
    final double offsetY =
        openUp ? anchorPosition.top - childSize.height : anchorPosition.bottom;
    final Rect screen = findClosestScreen(size, anchorPosition.center);

    // Subtracting half of the menu's width from the anchor's midpoint
    // horizontally centers the menu and the anchor.
    //
    // If centering would cause the menu to overflow the screen, the x-value is
    // set to the edge of the screen to ensure the user-provided offset is respected.
    final offsetX = (anchorPosition.center.dx - (childSize.width / 2))
        .clamp(screen.left, screen.right);

    final placement = fitInsideScreen(
      screen,
      childSize,
      Offset(offsetX, offsetY) + offset,
    );

    return placement;
  }
}

/// A [SingleChildLayoutDelegate] that controls the position of [CupertinoNestedMenu]
@immutable
class CupertinoNestedMenuRouteLayout extends CupertinoMenuRouteBaseLayout {
  const CupertinoNestedMenuRouteLayout({
    required this.finalMenuPosition,
    required this.rootAnchorPosition,
    required this.depth,
    required super.anchorPosition,
    required super.textDirection,
    required super.padding,
    required super.avoidBounds,
  });

  /// The final position of the menu, after it has finished animating.
  final Size finalMenuPosition;

  /// The anchor position of the first menu layer.
  final Rect rootAnchorPosition;
  final int depth;

  /// The percent of previously hidden menu that is now revealed.
  /// This calculation excludes the initial anchor height.
  double _getPercentRevealed(double menuPosition) {
    if (finalMenuPosition.height <= 0.0) {
      return 0.0;
    }

    return ((menuPosition / finalMenuPosition.height) -
            anchorPosition.height / finalMenuPosition.height) *
        (1 + anchorPosition.height / finalMenuPosition.height);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final Rect screen = findClosestScreen(size, anchorPosition.center);
    final double percentRevealed = _getPercentRevealed(childSize.height);
    // If the menu's anchor is in the top 45% of the screen, open upwards.
    final bool shouldOpenUp =
        (rootAnchorPosition.center.dy / size.height) > 0.45;

    // If the menu opens upwards, then use the menu's top edge as an initial offset for the
    // menu. Otherwise, use the menu's bottom edge.
    final double offsetY = shouldOpenUp
        ? anchorPosition.top
        : anchorPosition.bottom - anchorPosition.height;
    final Offset finalMenuOffset = Offset(
      anchorPosition.center.dx - (childSize.width / 2),
      offsetY,
    );
    final Rect finalMenuRect = finalMenuOffset & finalMenuPosition;
    // The preferred menu position is horizontally centered, and vertically positioned
    // so as to not overlap the anchor upon expansion.
    Rect wantedPosition = finalMenuOffset & childSize;

    // If the final menu position will obstruct the anchor, offset the wanted position by
    // the amount of overlap multiplied by the current amount of menu revealed.
    if (rootAnchorPosition.overlaps(finalMenuRect)) {
      double offset = 0.0;
      final bool isAboveAnchor = rootAnchorPosition.top < anchorPosition.top;
      if (shouldOpenUp == isAboveAnchor) {
        offset = rootAnchorPosition.bottom - finalMenuRect.top;
      } else {
        offset = rootAnchorPosition.top - finalMenuRect.bottom;
      }

      wantedPosition = wantedPosition.translate(0, offset * percentRevealed);
    }

    // If the menu drifts too far from it's anchor, pull it within 50% of the anchor's height.
    // [TODO]: If possible, make this more readable
    if ((wantedPosition.intersect(anchorPosition).height /
            anchorPosition.height) <
        0.5) {
      wantedPosition = wantedPosition.translate(
        0,
        -(wantedPosition.bottom -
                (anchorPosition.center.dy + anchorPosition.bottom) / 2) *
            percentRevealed,
      );
    }

    // Add an additional offset for personality.
    wantedPosition =
        wantedPosition.translate(0, -15.0 * percentRevealed * depth);

    return fitInsideScreen(screen, childSize, wantedPosition.topLeft);
  }

  @override
  bool shouldRelayout(CupertinoNestedMenuRouteLayout oldDelegate) =>
      anchorPosition != oldDelegate.anchorPosition ||
      textDirection != oldDelegate.textDirection ||
      padding != oldDelegate.padding ||
      rootAnchorPosition != oldDelegate.rootAnchorPosition ||
      !setEquals(avoidBounds, oldDelegate.avoidBounds);
}
