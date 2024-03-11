import 'package:flutter/material.dart';

class BugApp extends StatefulWidget {
  const BugApp({super.key});

  @override
  State<BugApp> createState() => _BugAppState();
}

class _BugAppState extends State<BugApp> {
  int diffX = 0;
  int diffY = 0;

  late final Stopwatch stop1;

  late final Stopwatch stop2;

  // setup pan gesture
  @override
  void initState() {
    super.initState();
    // setup pan gesture
    stop1 = Stopwatch();
    stop2 = Stopwatch();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 150,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (PointerDownEvent event) {
              stop1.start();
            },
            onPointerUp: (PointerUpEvent event) {
                                       print('done1');

            },
            child: Container(
              color: Colors.red,
              width: 300,
              height: 300,
              child: Center(
              child: Text('diffX: $diffX, diffY: $diffY',
                  style: const TextStyle(color: Colors.black, fontSize: 20)),
            ),
            ),
          ),
        ),
        GestureDetector(
          excludeFromSemantics: true,
          behavior: HitTestBehavior.translucent,

          onTapDown: (TapDownDetails event) {
          },
          onTapUp: (TapUpDetails event) {
                         print('done2');

          },
          child: Container(
            color: Colors.red.withOpacity(0.5),
            width: 300,
            height: 300,
            child: Center(
              child: Text('diffX: $diffX, diffY: $diffY',
                  style: const TextStyle(color: Colors.black, fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }
}
