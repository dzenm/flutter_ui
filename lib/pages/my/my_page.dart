import 'package:flutter/material.dart';

import 'study/study.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    Study.main();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Expanded(child: HomePage())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _getListData() {
    List<Map<String, dynamic>> list = [
      {
        'title': 'image 1',
        'imageUrl': 'https://www.itying.com/images/flutter/1.png',
        'description': 'this is image 1',
      },
      {
        'title': 'image 2',
        'imageUrl': 'https://www.itying.com/images/flutter/2.png',
        'description': 'this is image 2',
      },
      {
        'title': 'image 3',
        'imageUrl': 'https://www.itying.com/images/flutter/3.png',
        'description': 'this is image 3',
      },
      {
        'title': 'image 4',
        'imageUrl': 'https://www.itying.com/images/flutter/4.png',
        'description': 'this is image 4',
      },
      {
        'title': 'image 5',
        'imageUrl': 'https://www.itying.com/images/flutter/5.png',
        'description': 'this is image 5',
      },
      {
        'title': 'image 6',
        'imageUrl': 'https://www.itying.com/images/flutter/6.png',
        'description': 'this is image 6',
      }
    ];
    var tempList = list.map((arguments) {
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return HeroPage(arguments: arguments);
          }));
        },
        child: Container(
            decoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(233, 233, 233, 0.9), width: 1)),
            child: Column(
              children: <Widget>[
                Hero(tag: arguments['imageUrl'], child: Image.network(arguments['imageUrl'])),
                const SizedBox(height: 12),
                Text(
                  arguments['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                )
              ],
            )),
      );
    });
    // ('xxx','xxx')
    return tempList.toList();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisSpacing: 10.0,
      //水平子 Widget 之间间距
      mainAxisSpacing: 10.0,
      //垂直子 Widget 之间间距
      padding: const EdgeInsets.all(10),
      crossAxisCount: 2,
      //一行的 Widget 数量
      // childAspectRatio:0.7,  //宽度和高度的比例
      children: _getListData(),
    );
  }
}

class HeroPage extends StatefulWidget {
  final Map arguments;

  const HeroPage({super.key, required this.arguments});

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("详情页面"),
      ),
      body: ListView(
        children: [
          Hero(tag: widget.arguments["imageUrl"], child: Image.network(widget.arguments["imageUrl"])),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(widget.arguments["description"], style: const TextStyle(fontSize: 22)),
          )
        ],
      ),
    );
  }
}
