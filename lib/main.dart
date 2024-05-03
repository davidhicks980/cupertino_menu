import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'bug.dart';
import 'cupertino_menu.0.dart';
import 'test_anchor.dart' as test;

/// Flutter code sample for [MenuAnchor].

void main() => runApp(const MaterialApp(home: CupertinoMenuExample()));

class VariableAlignemnt extends StatefulWidget {
  const VariableAlignemnt({super.key});

  @override
  State<VariableAlignemnt> createState() => _VariableAlignemntState();
}

class _VariableAlignemntState extends State<VariableAlignemnt> {
  bool _isDefaultAlignment = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        localizationsDelegates: const <LocalizationsDelegate>[
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: CupertinoApp(
          home: Material(
            child: Builder(
              builder: (BuildContext context) {
                final  MediaQueryData data = MediaQuery.of(context);
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: ColoredBox(
                    color: const Color(0xFF55FFFF),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          top: 100,
                          left: 100,
                          child: Text('Width: ${data.size.width} Height: ${data.size.height}'),
                        ),

                        ElevatedButton(onPressed: () {
                          setState(() {
                          _isDefaultAlignment = !_isDefaultAlignment;

                          });
                        }, child:  Text(_isDefaultAlignment ? 'It is currently default' : 'Custom Alignment')),

                         Positioned(
                          top: 200,
                          left: 200,
                          child: CupertinoMenuAnchor(
                            alignment: _isDefaultAlignment  ? null :  AlignmentDirectional.topStart,
                            menuAlignment: _isDefaultAlignment  ? null :  AlignmentDirectional.topEnd,
                            menuChildren:  <Widget>[
                              CupertinoMenuItem(requestCloseOnActivate: false,
                              onPressed: () {
                                setState(() {

                                });
                                _isDefaultAlignment = !_isDefaultAlignment;
                              },child: const Text('Label'),
                              ),
                            ],
                            builder: _buildAnchor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        ));
  }
}
// class MyCascadingMenu extends StatefulWidget {
//   const MyCascadingMenu({super.key});

//   @override
//   State<MyCascadingMenu> createState() => _MyCascadingMenuState();
// }

// class _MyCascadingMenuState extends State<MyCascadingMenu> {




//   @override
//   Widget build(BuildContext context) {
//     return   CustomInkWell(
//       spla
//       onTap: () {
//       print('onTap');
//       },
//       child: const Text('Press me'),
//     );
//   }
// }



Widget _buildAnchor(
  BuildContext context,
  CupertinoMenuController controller,
  Widget? child,
) {
  return ConstrainedBox(
    constraints: const BoxConstraints.tightFor(width: 56, height: 56),
    child: Material(
      child: InkWell(
        onTap: () {
          if (controller.menuStatus
              case MenuStatus.opened || MenuStatus.opening) {
            controller.close();
          } else {
            controller.open();
          }
        },
        child: const Text('Anchor')
      ),
    ),
  );
}