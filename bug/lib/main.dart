import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Stopwatch stopwatch;

  int _listener3 = 0;
  int _listener2 = 0;
  int _listener1 = 0;
  int _gesture3 = 0;
  int _gesture2 = 0;
  int _gesture1 = 0;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch()..start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _gesture1 = stopwatch.elapsedMilliseconds;
                scheduleMicrotask(() {
                  setState(() {});
                });
              },
              child: Listener(
                onPointerDown: (event) {
                  _listener1 = stopwatch.elapsedMilliseconds;
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      'LISTENER: $_listener1,\n'
                      'GESTURE: $_gesture1,\n'
                      'LISTENER ADVANTAGE: ${_gesture1 - _listener1}ms',
                    ),
                  ),
                ),
              ),
            ),
            Listener(
              onPointerDown: (event) {
                _listener2 = stopwatch.elapsedMilliseconds;
              },
              child: GestureDetector(
                onTap: () {
                  _gesture2 = stopwatch.elapsedMilliseconds;
                  scheduleMicrotask(() {
                    setState(() {});
                  });
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      'LISTENER: $_listener2,\n'
                      'GESTURE: $_gesture2,\n'
                      'LISTENER ADVANTAGE: ${_gesture2 - _listener2}',
                    ),
                  ),
                ),
              ),
            ),
            Listener(
              onPointerDown: (event) {
                _listener3 = stopwatch.elapsedMilliseconds;
              },
              child: RawGestureDetector(
                gestures: {
                   TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                        TapGestureRecognizer>(
                      () => TapGestureRecognizer(),
                      (instance) {
                        instance.onTap = () {
                          _gesture3 = stopwatch.elapsedMilliseconds;
                          scheduleMicrotask(() {
                            setState(() {});
                          });
                        };
                      },
                    )
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      'LISTENER: $_listener3,\n'
                      'GESTURE: $_gesture3,\n'
                      'LISTENER ADVANTAGE: ${_gesture3 - _listener3}',
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
