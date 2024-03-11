import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          mainAxisMargin: 2,
          thumbVisibility: MaterialStateProperty.all(true),
          trackVisibility: MaterialStateProperty.all(true),
          thickness: MaterialStateProperty.all(8),
          trackColor: MaterialStateProperty.all(const Color.fromARGB(255, 239, 239, 239)),
          thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered) || states.contains(MaterialState.dragged)) {
              return Colors.black54;
            } else {
              return Colors.black26;
            }
          }),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  bool _counter = true;
  List<Widget> items = <Widget>[];
  late final Ticker _ticker;
  int viewId = 0;

  @override
  void initState() {
    _ticker = createTicker((Duration elapsed) => _buildItems());
    super.initState();
  }

  int rowIndex = 0;

  void _buildItems() {
    if (rowIndex >= (_counter ? 5 : 100)) {
      _ticker.stop();
      return;
    }
    setState(() {
      items.add(_buildTable());
      items.add(_buildTable());
      items.add(_buildTable());
      items.add(_buildTable());
      items.add(_buildTable());
      rowIndex+=5;
    });
  }

  void _incrementCounter() {
    _ticker.stop();
    viewId++;
    _counter = !_counter;
    items.clear();
    rowIndex = 0;
    _ticker.start();
  }

  Table _buildTable() {
    return Table(
      children: <TableRow>[
        for (int i = 0; i < 1; i++)
          TableRow(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                child: const SelectionArea(child: Text('row')),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: const SelectionArea(child: Text('row')),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: const SelectionArea(child: Text('row')),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: const SelectionArea(child: Text('row')),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: const SelectionArea(child: Text('row')),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: const SelectionArea(child: Text('row')),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[...items.map((Widget e) => SliverToBoxAdapter(child: e))],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
