class _CupertinoSliverList extends SliverList {
  const _CupertinoSliverList({required super.delegate, required this.borderThickness});

  final double borderThickness;

  @override
  RenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    return _RenderCupertinoSliverList(childManager: element, borderThickness: borderThickness);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderCupertinoSliverList renderObject) {

    renderObject.borderThickness = borderThickness;

  }

}

class _RenderCupertinoSliverList extends RenderSliverList{
  _RenderCupertinoSliverList({required super.childManager, required this.borderThickness});

  double borderThickness;


  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (firstChild == null) {
      return;
    }
    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    final Offset mainAxisUnit, crossAxisUnit, originOffset;
    final bool addExtent;
    switch (applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0.0, -1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset + Offset(0.0, geometry!.paintExtent);
        addExtent = true;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset;
        addExtent = false;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0.0, 1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset;
        addExtent = false;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset + Offset(geometry!.paintExtent, 0.0);
        addExtent = true;
    }

    final Path backgroundFillPath = Path()
      ..fillType = PathFillType.evenOdd;
    RenderBox? child = firstChild;
    while (child != null) {
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx + mainAxisUnit.dx * mainAxisDelta + crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy + mainAxisUnit.dy * mainAxisDelta + crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent) {
        childOffset += mainAxisUnit * paintExtentOf(child);
      }


      // If the child's visible interval (mainAxisDelta, mainAxisDelta + paintExtentOf(child))
      // does not intersect the paint extent interval (0, constraints.remainingPaintExtent), it's hidden.
      if (mainAxisDelta < constraints.remainingPaintExtent && mainAxisDelta + paintExtentOf(child) > 0) {
        backgroundFillPath.addRect(Rect.fromLTWH(
          childOffset.dx,
          childOffset.dy,
          child.size.width,
          child.size.height - (child != lastChild ? borderThickness : 0),
        ));
      }

      child = childAfter(child);
    }

    context.canvas.drawPath(
      backgroundFillPath,
      Paint()
        ..color = CupertinoColors.black
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );

    super.paint(context, offset);
  }
}