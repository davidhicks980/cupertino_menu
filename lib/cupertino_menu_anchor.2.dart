import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Flutter code sample for [MenuAnchor].

void main() => runApp(const CupertinoNestedApp());

class MenuBackButtonWrapper extends StatelessWidget {
  const MenuBackButtonWrapper({super.key, required this.child});
  final Widget child;

  void _popToRoute(BuildContext context, String routeName) {
    Navigator.popUntil(
      context,
      (Route<dynamic> route) {
        return route.settings.name == routeName;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoMenuAnchor(
      menuChildren: <Widget>[
        CupertinoMenuItem(
          child: const Text('Home'),
          onPressed: () {
            _popToRoute(context, HomePage.route);
          },
        ),
        if (ModalRoute.of(context)?.settings.name == DetailPage.route)
          CupertinoMenuItem(
            child: const Text('Detail'),
            onPressed: () {
              _popToRoute(context, SummaryPage.route);
            },
          ),
      ],
      builder: (
        BuildContext context,
        CupertinoMenuController controller,
        Widget? child,
      ) {
        return GestureDetector(
          onLongPressStart: (_) {
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
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});
  static String route = '/nested';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: MenuBackButtonWrapper(
            child: CupertinoNavigationBarBackButton(
          previousPageTitle: 'Home',
          onPressed: () {
            Navigator.maybePop(context);
          },
        )),
        middle: const Text('Nested Route'),
      ),
      child: const Placeholder(),
    );
  }
}

class CupertinoNestedApp extends StatelessWidget {
  const CupertinoNestedApp({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
        ],
        routes: <String, WidgetBuilder>{
          HomePage.route: (BuildContext context) => const HomePage(), // "/"
          SummaryPage.route: (BuildContext context) => const SummaryPage(), // "/detail"
          DetailPage.route: (BuildContext context) => const DetailPage(), // "/nested"
        });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static String route = '/';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: CupertinoButton(
          child: Text('Go to $SummaryPage'),
          onPressed: () {
            Navigator.of(context).pushNamed(SummaryPage.route);
          },
        ),
      ),
    );
  }
}

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  static String route = '/summary';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: MenuBackButtonWrapper(
            child: CupertinoNavigationBarBackButton(
          previousPageTitle: 'Home',
          onPressed: () {
            Navigator.maybePop(context);
          },
        )),
        middle: Text('$SummaryPage'),
      ),
      child: Center(
        child: CupertinoButton(
          child: Text('Go to $DetailPage'),
          onPressed: () {
            Navigator.of(context).pushNamed(DetailPage.route);
          },
        ),
      ),
    );
  }
}
