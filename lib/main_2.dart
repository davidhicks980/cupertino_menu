import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: LogoScale(),
        ),
      ),
    );
  }
}

class LogoScale extends StatefulWidget {
  const LogoScale({super.key});

  @override
  State<LogoScale> createState() => LogoScaleState();
}

class LogoScaleState extends State<LogoScale> {
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: (){
            setState(() {
              show = !show;
            });
          },
          child: Text(show ? 'Hide Logo' : 'Show Logo'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimationInOut(
                show: show,
                child: const FlutterLogo(size: 100.0,)
            ),
          ],
        ),
      ],
    );
  }
}

class AnimationInOut extends StatefulWidget {
  const AnimationInOut({super.key,
    required this.show,
    required this.child,
  });
  final bool show;
  final Widget child;

  @override
  State<AnimationInOut> createState() => AnimationInOutState();
}

class AnimationInOutState extends State<AnimationInOut> with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    animationController.value = widget.show ? 1.0 : 0.0;
    scaleAnimation = animationController.drive(Tween<double>(begin: 0.0, end: 1.0));
    fadeAnimation = animationController.drive(Tween<double>(begin: 0.0, end: 1.0));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimationInOut oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.show){
      animationController.forward();
    }else{
      animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: widget.child,
      ),
    );
  }
}