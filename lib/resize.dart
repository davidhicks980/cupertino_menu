import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/mouse_cursor.dart';

class ResizebleWidget extends StatefulWidget {
  const ResizebleWidget({super.key, required this.child, required this.id});

  final String id;
  final Widget child;
  @override
  _ResizebleWidgetState createState() => _ResizebleWidgetState();
}

const double ballDiameter = 45.0;

class _ResizebleWidgetState extends State<ResizebleWidget> {
  double? _height = 300.0;
  double? _width = 300.0;
  double? _top = 0.0;
  double? _left = 0.0;

  SystemMouseCursor _middleCursor = SystemMouseCursors.grab;

  @override
  void initState() {
    super.initState();
    CounterStorage(widget.id).readPosition().then((Rect value) {
      _height = value.height;
      _width = value.width;
      _top = value.top;
      _left = value.left;
      setState(() {});
    });
  }

  Future<void> storePosition(PointerUpEvent event) async {
    final Rect position = Rect.fromLTWH(_left!, _top!, _width!, _height!);
    final CounterStorage storage = CounterStorage(widget.id);
    storage.writePosition(position);
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    double clampX(double value) => ui.clampDouble(value, 8.0, math.max(size.width - 8.0, 8.0));
    double clampY(double value) => ui.clampDouble(value, 100.0, math.max(size.height - 100.0, 100.0));
    final double startX = clampX(_left! - ballDiameter / 2.0);
    final double startY = clampY(_top! - ballDiameter / 2.0);
    final double midX   = clampX(_left! + _width! / 2.0 - ballDiameter / 2.0);
    final double midY   = clampY(_top! + _height! / 2.0 - ballDiameter / 2.0);
    final double endX   = clampX(_left! + _width! - ballDiameter / 2.0);
    final double endY   = clampY(_top! + _height! - ballDiameter / 2.0);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned(
          top: _top,
          left: _left,
          height: _height,
          width: _width,
          child: CupertinoPopupSurface(
            child: SizedOverflowBox(
              size: Size(_width!, _height!),
              child: widget.child,
            ),
          ),
        ),
        ...<Widget>[
          // top left
          Positioned(
            top: startY,
            left: startX,
            child: ManipulatingBall(
              cursor: SystemMouseCursors.resizeDownRight,
              onDrag: (double dx, double dy) {
                _height = math.max(_height! - dy, 0);
                _width = math.max(_width! - dx, 0);
                if (_width! > 0) {
                  _left = _left! + dx;
                }
                if (_height! > 0) {
                  _top = _top! + dy;
                }
                setState(() {});
              },
              handleDragEnd: storePosition,
            ),
          ),
          // top middle
          Positioned(
            top: startY,
            left: midX,
            child: ManipulatingBall(
              cursor: SystemMouseCursors.resizeUpDown,
              handleDragEnd: storePosition,
              onDrag: (double dx, double dy) {
                final double newHeight = _height! - dy;
                _height = newHeight > 0 ? newHeight : 0;
                if (_height! > 0) {
                  _top = _top! + dy;
                }
                setState(() {});
              },
            ),
          ),
          // top right
          Positioned(
            top: startY,
            left: endX,
            child: ManipulatingBall(
              cursor: SystemMouseCursors.resizeDownLeft,
              handleDragEnd: storePosition,
              onDrag: (double dx, double dy) {
                _height = math.max(_height! - dy, 0);
                _width = math.max(_width! + dx, 0);
                if (_width! > 0) {
                  _top = math.max(_top! + dy, 0);
                }
                setState(() {});
              },
            ),
          ),
          // center right
          Positioned(
            top: midY,
            left: endX,
            child: ManipulatingBall(
              cursor: SystemMouseCursors.resizeLeftRight,
              handleDragEnd: storePosition,
              onDrag: (double dx, double dy) {
                final double newWidth = _width! + dx;
                _width = newWidth > 0 ? newWidth : 0;
                setState(() {});
              },
            ),
          ),
          // bottom right
          Positioned(
            top: endY,
            left: endX,
            child: ManipulatingBall(
              cursor: SystemMouseCursors.resizeUpLeft,
              handleDragEnd: storePosition,
              onDrag: (double dx, double dy) {
                final double newHeight = _height! + dy;
                final double newWidth = _width! + dx;
                _height = newHeight > 0 ? newHeight : 0;
                _width = newWidth > 0 ? newWidth : 0;
                setState(() {});
              },
            ),
          ),
          // bottom center
          Positioned(
            top: endY,
            left: midX,
            child: ManipulatingBall(
              cursor: SystemMouseCursors.resizeUpDown,
              onDrag: (double dx, double dy) {
                final double newHeight = _height! + dy;
                _height = newHeight > 0 ? newHeight : 0;
                setState(() {});
              },
              handleDragEnd: storePosition,
            ),
          ),
          // bottom left
          Positioned(
            top: endY,
            left: startX,
            child: ManipulatingBall(
              cursor: SystemMouseCursors.resizeUpRight,
              onDrag: (double dx, double dy) {
                _height = math.max(_height! + dy, 0);
                _width = math.max(_width! - dx, 0);
                if (_width! > 0) {
                  _left = _left! + dx;
                }
                setState(() {});
              },
              handleDragEnd: storePosition,
            ),
          ),
          //left center
          Positioned(
            top: midY,
            left: startX,
            child: ManipulatingBall(
              cursor: SystemMouseCursors.resizeLeftRight,
              onDrag: (double dx, double dy) {
                _width = math.max(_width! - dx, 0);
                if (_width! > 0) {
                  _left = _left! + dx;
                }
                setState(() {});
              },
              handleDragEnd: storePosition,
            ),
          ),
          // center center
          Positioned(
            top:  endY - 30,
            left: math.max(endX - 30,8),
            child: ManipulatingBall(
              cursor: _middleCursor,
              onDrag: (double dx, double dy) {
                _middleCursor = SystemMouseCursors.grabbing;
                _top = _top! + dy;
                _left = _left! + dx;
                setState(() {});
              },
              handleDragEnd: (PointerUpEvent event) {
                _middleCursor = SystemMouseCursors.grab;
                storePosition(event);
              },
              child:  Icon(
                CupertinoIcons.move,
                color: Colors.grey.withOpacity(0.2)
              ),
            ),
          ),
        ]
      ],
    );
  }
}

enum BallState { hovered, dragging, inactive }

class ManipulatingBall extends StatefulWidget {
  const ManipulatingBall(
      {super.key,
      required this.onDrag,
      required this.handleDragEnd,
      required this.cursor,  this.child});

  final void Function(
    double dx,
    double dy,
  ) onDrag;
  final PointerUpEventListener handleDragEnd;
  final MouseCursor cursor;
  final Widget? child;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  Offset position = Offset.zero;
  Color color = Colors.grey.withOpacity(0.1);
  Border border = Border.all(color: Colors.transparent);
  double ballScale = 1;
  bool _hovered = false;
  bool _dragging = false;

  Offset delta = Offset.zero;

  void _handleUpdate(PointerMoveEvent details) {
    delta = details.delta;
    position += delta;
    widget.onDrag(details.delta.dx, details.delta.dy);
  }

  void _updateColors() {
    switch ((_hovered, _dragging)) {
      case (_, true):
        color = Colors.blue.shade700.withOpacity(0.6);
        border = Border.all(color: Colors.blue.shade700);
        ballScale = 2.5;
      case (true, _):
        color = Colors.blue.withOpacity(0.5);
        border = Border.all(color: Colors.indigo);
        ballScale = 1.75;
      default:
        color = Colors.grey.withOpacity(0.2);
        border = Border.all(color: Colors.transparent);
        ballScale = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateColors();
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (PointerEnterEvent event) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (PointerExitEvent event) {
        setState(() {
          _hovered = false;
        });
      },
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          setState(() {
            _dragging = true;
          });
          widget.onDrag(delta.dx, delta.dy);
        },
        onPointerUp: (PointerUpEvent event) {
          setState(() {
            _dragging = false;
          });
          widget.handleDragEnd(event);
        },
        onPointerMove: _dragging? _handleUpdate : null,
        child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Container(
              width: ballDiameter,
              height: ballDiameter,
              transformAlignment: Alignment.center,
              color: Colors.transparent,
              child: Center(
                child: AnimatedScale(
                  scale: ballScale,
                  duration: const Duration(milliseconds: 100),
                  child: IconTheme(
                    data:  IconThemeData(size: ballDiameter, color: _dragging ? CupertinoColors.activeBlue.withOpacity(0.2):null),
                    child: widget.child ?? AnimatedContainer(
                      width: ballDiameter / 4,
                      height: ballDiameter / 4,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.decelerate,
                      decoration: widget.child != null ? null : BoxDecoration(
                        color: color,
                        border: border,
                        shape: BoxShape.circle,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
    ),);
  }
}

class CounterStorage {
  CounterStorage(
    this._key,
  );
  final String _key;
  Future<File> get _localFile async {
    final Directory appDocumentsDir =  Directory.systemTemp;
    return File('${appDocumentsDir.path}/$_key.json');
  }

  Future<Rect> readPosition() async {
    try {
      if (kIsWeb) {
        return const Rect.fromLTWH(0, 0, 300, 300);
      }
      final File file = await _localFile;

      // Read the file
      final String contents = await file.readAsString();
      final {
        'left': double left,
        'top': double top,
        'width': double width,
        'height': double height
      } = jsonDecode(contents) as Map<String, dynamic>;
      return Rect.fromLTWH(left, top, width, height);
    } catch (e) {
      // If encountering an error, return 0
      return const Rect.fromLTWH(0, 0, 300, 400);
    }
  }

  Future<void> writePosition(Rect position) async {
    if (kIsWeb) {
      return;
    }
    final File file = await _localFile;
    if (file.existsSync()) {
      file.deleteSync();
    }

    // Write the file
    file.writeAsStringSync(jsonEncode(<String, double>{
      'left': position.left,
      'top': position.top,
      'width': position.width,
      'height': position.height,
    }));
  }
}
