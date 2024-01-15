import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'cupertino_menu.0.dart';

/// Flutter code sample for [MenuAnchor].

void main() => runApp(const MenuApp());

class MenuApp extends StatefulWidget {
  const MenuApp({super.key});

  @override
  State<MenuApp> createState() => _MenuAppState();
}

class _MenuAppState extends State<MenuApp> {
  final bool _darkMode = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(useMaterial3: false,  brightness: _darkMode ? Brightness.dark : Brightness.light,),
      home:  Scaffold(
        backgroundColor: _darkMode ? Colors.black : Colors.white,
        body:   const CupertinoMenuExample(),
      )
    );
  }
}


const double _kBorderWidth = 4.0;
const double _kBorderRadius = 8.0;
const double _kClipRadius = 12.0;

const int _kBlueStartingIndex = 0;
const int _kYellowStartingIndex = 3;

/// The mondrian spinner.  A series of overlapping rectangular elements that
/// rotate.  The parent of this [MondrianSpinner] must have non-infinite bounds.
/// The [MondrianSpinner] will center itself in its parent and have a diameter
/// equal to the minimum dimension.
class MondrianSpinner extends StatefulWidget {
  const MondrianSpinner({super.key});

  @override
  _MondrianSpinnerState createState() => _MondrianSpinnerState();
}

class _MondrianSpinnerState extends State<MondrianSpinner> {
  Timer? _timer;
  int _index = 0;
  List<Rect> _positions = <Rect>[];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => setState(() {
            _index = (_index + 1) % _positions.length;
          }),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double diameter = math.min(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          _positions = <Rect>[
            Rect.fromLTWH(
              0.0,
              0.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
              diameter,
            ),
            Rect.fromLTWH(
              0.0,
              diameter / 2.0 - _kBorderWidth / 2.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
            ),
            Rect.fromLTWH(
              0.0,
              diameter / 2.0 - _kBorderWidth / 2.0,
              diameter,
              diameter / 2.0 + _kBorderWidth / 2.0,
            ),
            Rect.fromLTWH(
              diameter / 2.0 - _kBorderWidth / 2.0,
              diameter / 2.0 - _kBorderWidth / 2.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
            ),
            Rect.fromLTWH(
              diameter / 2.0 - _kBorderWidth / 2.0,
              0.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
              diameter,
            ),
            Rect.fromLTWH(
              diameter / 2.0 - _kBorderWidth / 2.0,
              0.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
            ),
            Rect.fromLTWH(
              0.0,
              0.0,
              diameter,
              diameter / 2.0 + _kBorderWidth / 2.0,
            ),
            Rect.fromLTWH(
              0.0,
              0.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
              diameter / 2.0 + _kBorderWidth / 2.0,
            ),
          ];

          return Center(
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(_kBorderRadius),
              ),
              foregroundDecoration: BoxDecoration(
                border: Border.all(
                  width: _kBorderWidth,
                ),
                borderRadius: BorderRadius.circular(_kBorderRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_kClipRadius),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(_kBorderWidth),
                      color: Colors.red[700],
                    ),
                    AnimatedPositioned(
                      left: _yellowPosition.left,
                      top: _yellowPosition.top,
                      width: _yellowPosition.width,
                      height: _yellowPosition.height,
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        color: Colors.yellow[700],
                        foregroundDecoration: BoxDecoration(
                          border: Border.all(
                            width: _kBorderWidth,
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      left: _bluePosition.left,
                      top: _bluePosition.top,
                      width: _bluePosition.width,
                      height: _bluePosition.height,
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        color: Colors.blue[700],
                        foregroundDecoration: BoxDecoration(
                          border: Border.all(
                            width: _kBorderWidth,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );

  Rect get _bluePosition =>
      _positions[(_index + _kBlueStartingIndex) % _positions.length];
  Rect get _yellowPosition =>
      _positions[(_index + _kYellowStartingIndex) % _positions.length];
}


// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.



const Color _kDefaultColor = Color(0xFF6EFAFA);

const double _kInitialFractionalDiameter = 1.0 / 1.2;
const double _kTargetFractionalDiameter = 1.0;
const double _kRotationRadians = 6 * math.pi;
const Curve _kDefaultCurve = Cubic(0.3, 0.1, 0.3, 0.9);

const Duration _kAnimationDuration = Duration(seconds: 2);

/// The spinner used by fuchsia flutter apps.
class FuchsiaSpinner extends StatefulWidget {

  /// Constructor.
  const FuchsiaSpinner({super.key,
    this.color= _kDefaultColor,
  });
  /// The color of the spinner at rest
  final Color color;

  @override
  _FuchsiaSpinnerState createState() => _FuchsiaSpinnerState();
}

class _FuchsiaSpinnerState extends State<FuchsiaSpinner>
    with SingleTickerProviderStateMixin {
  final Tween<double> _fractionalWidthTween = Tween<double>(
    begin: _kInitialFractionalDiameter,
    end: _kTargetFractionalDiameter,
  );
  final Tween<double> _fractionalHeightTween = Tween<double>(
    begin: _kInitialFractionalDiameter,
    end: _kInitialFractionalDiameter / 2,
  );
  final Tween<double> _hueTween = Tween<double>(
    begin: 0.0,
    end: 90.0,
  );
  final Curve _firstHalfCurve = const Cubic(0.75, 0.25, 0.25, 1.0);
  final Curve _secondHalfCurve = _kDefaultCurve;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );
    _controller.repeat(period: _kAnimationDuration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          final double maxDiameter = math.min(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          return AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final double tweenProgress = _tweenValue;
              final double width = maxDiameter *
                  _fractionalWidthTween.lerp(
                    tweenProgress,
                  );
              final double height = maxDiameter *
                  _fractionalHeightTween.lerp(
                    tweenProgress,
                  );
              return Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.rotationZ(
                  _kDefaultCurve.transform(_controller.value) *
                      _kRotationRadians,
                ),
                child: Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Material(
                      color: _transformHue(
                        widget.color,
                        _hueTween.lerp(tweenProgress),
                      ),
                      borderRadius: BorderRadius.circular(width / 2),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

  double get _tweenValue {
    if (_controller.value <= 0.5) {
      return _firstHalfCurve.transform(_controller.value / 0.5);
    } else {
      return 1.0 - _secondHalfCurve.transform((_controller.value - 0.5) / 0.5);
    }
  }

  /// This performs a hue rotation by [hueDegrees].
  /// See https://beesbuzz.biz/code/hsv_color_transforms.php for information
  /// about the constants used.
  Color _transformHue(Color original, double hueDegrees) {
    final double u = math.cos(hueDegrees * math.pi / 180.0);
    final double w = math.sin(hueDegrees * math.pi / 180.0);
    return Color.fromARGB(
      original.alpha,
      ((.299 + .701 * u + .168 * w) * original.red +
              (.587 - .587 * u + .330 * w) * original.green +
              (.114 - .114 * u - .497 * w) * original.blue)
          .round()
          .clamp(0, 255),
      ((.299 - .299 * u - .328 * w) * original.red +
              (.587 + .413 * u + .035 * w) * original.green +
              (.114 - .114 * u + .292 * w) * original.blue)
          .round()
          .clamp(0, 255),
      ((.299 - .3 * u + 1.25 * w) * original.red +
              (.587 - .588 * u - 1.05 * w) * original.green +
              (.114 + .886 * u - .203 * w) * original.blue)
          .round()
          .clamp(0, 255),
    );
  }
}