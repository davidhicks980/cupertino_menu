import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' ;
import 'package:flutter/physics.dart';

import 'scroll_view.dart';

// import 'anchor.dart';


void main() => runApp(const MenuApp());

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: MyCascadingMenu()),
    );
  }
}

class MyCascadingMenu extends StatefulWidget {
  const MyCascadingMenu({super.key});

  @override
  State<MyCascadingMenu> createState() => _MyCascadingMenuState();
}

class _MyCascadingMenuState extends State<MyCascadingMenu> {
  final FocusNode _buttonFocusNode = FocusNode();
  final CupertinoMenuController controller = CupertinoMenuController();

  final bool _hide  = false;

  @override
  void dispose() {
    _buttonFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
            home:Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: SuperScroll(
                      physics: const CustomPhysics(),
                      slivers: <Widget>[

                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return ListTile(
                                title: Text('Item $index'),
                              );
                            },
                            childCount: 50,
                          ),
                        ),

                      ],
                    ),
                  ),
                  Align(
                    child: CupertinoMenuAnchor(
                      controller: controller,
                      scrollPhysics: const CustomPhysics(),
                      builder: (BuildContext context, CupertinoMenuController controller, Widget? child) {
                        return ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(height: 50, width: 50),
                          child: GestureDetector(
                            onLongPressDown: (LongPressDownDetails details) {
                               if (controller.menuStatus case MenuStatus.opened || MenuStatus.opening) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                            },
                            child: const Text('Hih'),
                          ),
                        );
                      },
                      menuChildren: <Widget>[
                  CupertinoMenuItem(
                    onPressed: () {},
                    child: const Text('Hih'),
                  ),
                  const CupertinoMenuItem(
                    panActivationDelay: Duration(milliseconds: 300),
                    child: Text('Hih'),
                  ),
                  CupertinoMenuItem(
                    onPressed: () {
                      print('pressed');
                    },
                    panActivationDelay: const Duration(milliseconds: 300),
                    child: const Text('Hih'),
                  ),
                  CupertinoMenuItem(
                    onPressed: () {},
                    child: const Text('Hih'),
                  ),
                  const CupertinoMenuItem(
                    panActivationDelay: Duration(milliseconds: 300),
                    child: Text('Hih'),
                  ),
                  CupertinoMenuItem(
                    onPressed: () {
                      print('pressed');
                    },
                    panActivationDelay: const Duration(milliseconds: 300),
                    child: const Text('Hih'),
                  ),
                  CupertinoMenuItem(
                    onPressed: () {},
                    child: const Text('Hih'),
                  ),
                  const CupertinoMenuItem(
                    panActivationDelay: Duration(milliseconds: 300),
                    child: Text('Hih'),
                  ),
                  CupertinoMenuItem(
                    onPressed: () {
                      print('pressed');
                    },
                    panActivationDelay: const Duration(milliseconds: 300),
                    child: const Text('Hih'),
                  ),
                  CupertinoMenuItem(
                    onPressed: () {},
                    child: const Text('Hih'),
                  ),
                  const CupertinoMenuItem(
                    panActivationDelay: Duration(milliseconds: 300),
                    child: Text('Hih'),
                  ),
                  CupertinoMenuItem(
                    onPressed: () {
                      print('pressed');
                    },
                    panActivationDelay: const Duration(milliseconds: 300),
                    child: const Text('Hih'),
                  ),
                            ],
                    ),
                  ),
                ],
            ),
          );
  }
}


class CustomPhysics extends ScrollPhysics {
  /// Creates scroll physics that bounce back from the edge.
  const CustomPhysics({
    this.decelerationRate = ScrollDecelerationRate.normal,
    super.parent,
  });

  /// Used to determine parameters for friction simulations.
  final ScrollDecelerationRate decelerationRate;

  @override
  CustomPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPhysics(
      parent: buildParent(ancestor),
      decelerationRate: decelerationRate
    );
  }

  /// The multiple applied to overscroll to make it appear that scrolling past
  /// the edge of the scrollable contents is harder than scrolling the list.
  /// This is done by reducing the ratio of the scroll effect output vs the
  /// scroll gesture input.
  ///
  /// This factor starts at 0.52 and progressively becomes harder to overscroll
  /// as more of the area past the edge is dragged in (represented by an increasing
  /// `overscrollFraction` which starts at 0 when there is no overscroll).
  double frictionFactor(double overscrollFraction) {
    switch (decelerationRate) {
      case ScrollDecelerationRate.fast:
        return 0.26 * math.pow(1 - overscrollFraction, 2);
      case ScrollDecelerationRate.normal:
        return 0.52 * math.pow(1 - overscrollFraction, 2);
    }
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);
    if (!position.outOfRange) {
      return offset;
    }

    final double overscrollPastStart = math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd = math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast = math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0)
        || (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
        // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor((overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;

    if (easing && decelerationRate == ScrollDecelerationRate.fast) {
      return direction * offset.abs();
    }
    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) {
        return absDelta * gamma;
      }
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) => 0.0;

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation2(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
        constantDeceleration: switch (decelerationRate) {
          ScrollDecelerationRate.fast => 1400,
          ScrollDecelerationRate.normal => 0,
        },
      );
    }
    return null;
  }

  // The ballistic simulation here decelerates more slowly than the one for
  // ClampingScrollPhysics so we require a more deliberate input gesture
  // to trigger a fling.
  @override
  double get minFlingVelocity => kMinFlingVelocity * 2.0;

  // Methodology:
  // 1- Use https://github.com/flutter/platform_tests/tree/master/scroll_overlay to test with
  //    Flutter and platform scroll views superimposed.
  // 3- If the scrollables stopped overlapping at any moment, adjust the desired
  //    output value of this function at that input speed.
  // 4- Feed new input/output set into a power curve fitter. Change function
  //    and repeat from 2.
  // 5- Repeat from 2 with medium and slow flings.
  /// Momentum build-up function that mimics iOS's scroll speed increase with repeated flings.
  ///
  /// The velocity of the last fling is not an important factor. Existing speed
  /// and (related) time since last fling are factors for the velocity transfer
  /// calculations.
  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(), 40000.0);
  }

  // Eyeballed from observation to counter the effect of an unintended scroll
  // from the natural motion of lifting the finger after a scroll.
  @override
  double get dragStartDistanceMotionThreshold => 3.5;

  @override
  double get maxFlingVelocity {
    return switch (decelerationRate) {
      ScrollDecelerationRate.fast => kMaxFlingVelocity * 8.0,
      ScrollDecelerationRate.normal => super.maxFlingVelocity,
    };
  }

  @override
  SpringDescription get spring {
    switch (decelerationRate) {
      case ScrollDecelerationRate.fast:
        return SpringDescription.withDampingRatio(
          mass: 0.3,
          stiffness: 75.0,
          ratio: 1.3,
        );
      case ScrollDecelerationRate.normal:
        return super.spring;
    }
  }
}

class BouncingScrollSimulation2 extends Simulation {
  /// Creates a simulation group for scrolling on iOS, with the given
  /// parameters.
  ///
  /// The position and velocity arguments must use the same units as will be
  /// expected from the [x] and [dx] methods respectively (typically logical
  /// pixels and logical pixels per second respectively).
  ///
  /// The leading and trailing extents must use the unit of length, the same
  /// unit as used for the position argument and as expected from the [x]
  /// method (typically logical pixels).
  ///
  /// The units used with the provided [SpringDescription] must similarly be
  /// consistent with the other arguments. A default set of constants is used
  /// for the `spring` description if it is omitted; these defaults assume
  /// that the unit of length is the logical pixel.
  BouncingScrollSimulation2({
    required double position,
    required double velocity,
    required this.leadingExtent,
    required this.trailingExtent,
    required this.spring,
    double constantDeceleration = 0,
    super.tolerance,
  }) : assert(leadingExtent <= trailingExtent) {
    if (position < leadingExtent) {
      _springSimulation = _underscrollSimulation(position, velocity);
      _springTime = double.negativeInfinity;
    } else if (position > trailingExtent) {
      _springSimulation = _overscrollSimulation(position, velocity);
      _springTime = double.negativeInfinity;
    } else {
      // Taken from UIScrollView.decelerationRate (.normal = 0.998)
      // 0.998^1000 = ~0.135
      _frictionSimulation = FrictionSimulation(0.135, position, velocity, constantDeceleration: constantDeceleration);
      final double finalX = _frictionSimulation.finalX;
      if (velocity > 0.0 && finalX > trailingExtent) {
        _springTime = _frictionSimulation.timeAtX(trailingExtent);
        _springSimulation = _overscrollSimulation(
          trailingExtent,
          math.min(_frictionSimulation.dx(_springTime), maxSpringTransferVelocity),
        );
        assert(_springTime.isFinite);
      } else if (velocity < 0.0 && finalX < leadingExtent) {
        _springTime = _frictionSimulation.timeAtX(leadingExtent);
        _springSimulation = _underscrollSimulation(
          leadingExtent,
          math.min(_frictionSimulation.dx(_springTime), maxSpringTransferVelocity),
        );
        assert(_springTime.isFinite);
      } else {
        _springTime = double.infinity;
      }
    }
  }

  /// The maximum velocity that can be transferred from the inertia of a ballistic
  /// scroll into overscroll.
  static const double maxSpringTransferVelocity = 5000.0;

  /// When [x] falls below this value the simulation switches from an internal friction
  /// model to a spring model which causes [x] to "spring" back to [leadingExtent].
  final double leadingExtent;

  /// When [x] exceeds this value the simulation switches from an internal friction
  /// model to a spring model which causes [x] to "spring" back to [trailingExtent].
  final double trailingExtent;

  /// The spring used to return [x] to either [leadingExtent] or [trailingExtent].
  final SpringDescription spring;

  late FrictionSimulation _frictionSimulation;
  late Simulation _springSimulation;
  late double _springTime;
  double _timeOffset = 0.0;

  Simulation _underscrollSimulation(double x, double dx) {
    return ScrollSpringSimulation(spring, x, leadingExtent, dx);
  }

  Simulation _overscrollSimulation(double x, double dx) {
    return ScrollSpringSimulation(spring, x, trailingExtent, dx);
  }

  Simulation _simulation(double time) {
    final Simulation simulation;
    if (time > _springTime) {
      _timeOffset = _springTime.isFinite ? _springTime : 0.0;
      simulation = _springSimulation;
    } else {
      _timeOffset = 0.0;
      simulation = _frictionSimulation;
    }
    return simulation..tolerance = tolerance;
  }

  @override
  double x(double time) => _simulation(time).x(time - _timeOffset);

  @override
  double dx(double time) => _simulation(time).dx(time - _timeOffset);

  @override
  bool isDone(double time) => _simulation(time).isDone(time - _timeOffset);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'BouncingScrollSimulation')}(leadingExtent: $leadingExtent, trailingExtent: $trailingExtent)';
  }
}