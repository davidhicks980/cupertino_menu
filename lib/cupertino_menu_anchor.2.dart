import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A demonstration showing how to use [CupertinoMenuAnchor] to create a
/// navigation history menu similar to the navigation history stack on iOS.

/// Flutter code sample for [CupertinoMenuAnchor].
void main() => runApp(const CupertinoNestedApp());

/// A wrapper that shows a navigation history menu when the back button is
/// pressed down.
class MenuBackButtonWrapper extends StatelessWidget {
  const MenuBackButtonWrapper({
    super.key,
    required this.viewCount,
    required this.child,
  });

  final int viewCount;
  final Widget child;

  void _popToRoute(BuildContext context, int viewIndex) {
    Navigator.popUntil(
      context,
      (Route<dynamic> route) {
        return route.settings.name == 'View $viewIndex' ||
            route.settings.name == '/';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoMenuController controller = CupertinoMenuController();

    // Close the menu if the route is popped.
    return PopScope(
      onPopInvoked: (bool popped) {
        if (popped) {
          controller.close();
        }
      },
      child: CupertinoMenuAnchor(
        controller: controller,
        menuChildren: <Widget>[
          for (int i = 1; i < viewCount; i++)
            CupertinoMenuItem(
              child: Text('View $i'),
              onPressed: () {
                _popToRoute(context, i);
              },
            ),
        ],
        builder: (
          BuildContext context,
          CupertinoMenuController controller,
          Widget? child,
        ) {
          return GestureDetector(
            // Long press can't be used here because it would cancel the pan
            // gesture.
            onTapDown: (TapDownDetails details) {
              if (controller.menuStatus
                  case MenuStatus.opening || MenuStatus.opened) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}

/// A view that pushes itself onto the navigation stack.
class RecursiveView extends StatelessWidget {
  const RecursiveView({super.key, required this.depth});
  final int depth;

  @override
  Widget build(BuildContext context) {
    Widget? leading;
    if (depth != 0) {
      // Wrap the back button with a menu that shows the navigation history.
      leading = MenuBackButtonWrapper(
        viewCount: depth,
        child: CupertinoNavigationBarBackButton(
          previousPageTitle: 'View ${depth - 1}',
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      );
    }
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: leading,
        middle: Text('View $depth'),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            '''Push some views and long press the '''
            '''\nback button to show a navigation history menu.''',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CupertinoColors.systemGreen,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: CupertinoButton.filled(
              child: Text('Push View ${depth + 1}'),
              onPressed: () {
                _pushNextPage(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pushNextPage(BuildContext context) {
    final int nextDepth = depth + 1;
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        settings: RouteSettings(name: 'View $nextDepth'),
        builder: (BuildContext context) {
          return RecursiveView(depth: nextDepth);
        },
      ),
    );
  }
}

class CupertinoNestedApp extends StatelessWidget {
  const CupertinoNestedApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
        ],
        home: RecursiveView(depth: 0));
  }
}
