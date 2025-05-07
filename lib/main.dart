// For persistence:
// flutter pub add shared_preferences

import 'package:flutter/material.dart';

import 'utils.dart';

Future<void> main() async {
  await uCfg.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fsink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 4, 59, 29),
        ),
      ),
      home: const MyHomePage(title: 'Fsink'),
      debugShowCheckedModeBanner: false,
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
  // three dots items
  var items = ["camera", "buttons", "list", "tabs", "isolate"];
  void menuFun(String item) {
    switch (item) {
      case "camera":
        uGoToPage(context, Page0());
        break;
      case "buttons":
        uGoToPage(context, Page1());
        break;
      case "list":
        uGoToPage(context, Page2());
        break;
      case "tabs":
        uGoToPage(context, Page3());
        break;
      case "isolate":
        uGoToPage(context, Page4());
        break;

      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return uPageMenu(
      context,
      widget.title,
      uColNoExp([]),
      uThreeDots(context, items, menuFun),
    );
  }
}

class Page0 extends StatefulWidget {
  const Page0({super.key});

  @override
  State<Page0> createState() => Page0State();
}

class Page0State extends State<Page0> {
  @override
  initState() {
    super.initState();

    uInitStateCamera();
  }

  @override
  Widget build(BuildContext context) {
    return uPage(
      context,
      "Camera",
      uColNoExp([
        uCameraPreview(),
        uRow([
          uBtnIcon(() => uCameraPicture(context), Icons.camera_alt),
          //uBtnIcon(() => uGoToPage(context, Page1()), Icons.arrow_right),
          //uBtnIcon(() => uGoToPage(context, Page2()), Icons.arrow_right),
        ]),
      ]),
    );
  }
}

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => Page1State();
}

class Page1State extends State<Page1> {
  int _counter = 0;
  int _valEntered = 0;

  @override
  initState() {
    super.initState();

    _counter = uInitPersistInt("_counter");
    uInitStateCamera();
  }

  Future<void> _inc(int num) async {
    _counter = uGetPersistInt("_counter");
    setState(() {
      _counter = _counter + num;
    });
    uSetPersistInt("_counter", _counter);
  }

  Future<void> _dec(int num) async {
    _counter = uGetPersistInt("_counter");
    setState(() {
      _counter = _counter - num;
    });
    uSetPersistInt("_counter", _counter);
  }

  Future<void> _clear() async {
    setState(() {
      _counter = 0;
    });
    uSetPersistInt("_counter", _counter);
  }

  @override
  Widget build(BuildContext context) {
    return uPage(
      context,
      "Buttons",
      uColNoExp([
        uTextNoExp('Value:', 1.5),
        uTextNoExp('$_counter', 3.0),

        uRow([
          uText('10'),
          uCol([
            uBtnIcon(() => _inc(10), Icons.add),
            uBtnIcon(() => _dec(10), Icons.remove),
          ]),
        ]),
        uRow([]),
        uRow([
          uText('50'),
          uCol([
            uBtnIcon(() => _inc(50), Icons.add),
            uBtnIcon(() => _dec(50), Icons.remove),
          ]),
        ]),
        uRow([]),
        uRow([
          uInput(
            _valEntered.toString(),
            (text) => setState(() {
              _valEntered = int.tryParse(text) ?? 0;
            }),
          ),
          uCol([
            uBtnIcon(() => _inc(_valEntered), Icons.add),
            uBtnIcon(() => _dec(_valEntered), Icons.remove),
          ]),
        ]),
        uRow([]),
        uRow([
          uText('clear'),
          uCol([
            //uBtnIcon(_clear, Icons.bolt),
            uBtnText(_clear, "Clear"),
          ]),
        ]),
      ]),
    );
  }
}

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => Page2State();
}

class Page2State extends State<Page2> {
  var sList = ["goto Home", "goto Page1", "goto flutter"];

  void fun(int index) {
    switch (index) {
      case 0:
        uGoToPage(context, MyHomePage(title: 'Fsink'));
        break;
      case 1:
        uGoToPage(context, Page1());
        break;
      case 2:
        uGoToWeb('https://flutter.dev');
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return uPage(context, "List", uListView(context, sList, fun));
  }
}

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => Page3State();
}

class Page3State extends State<Page3> {
  var sList = ["tab1", "tab2", "tab3"];
  Widget tab1() {
    return Icon(Icons.directions_train);
  }

  Widget tab2() {
    return Icon(Icons.directions_bike);
  }

  Widget tab3() {
    return Icon(Icons.directions_boat);
  }

  @override
  Widget build(BuildContext context) {
    return uPage(context, "Tabs", uTabs(sList, [tab1(), tab2(), tab3()]));
  }
}

// WIP
class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => Page4State();
}

class Page4State extends State<Page4> {
  late Thread _th1;
  int _counter = 0;

  //Must be static
  static void threadFun(TxChan sendport) {
    var num = 0;

    for (var i = 0; i < 4; i++) {
      num = num + 10;
      sendport.send(num);
      uSleepS(1);
    }
  }

  Any rxFun(Any d) {
    setState(() {
      _counter = d as int;
    });
  }

  Future<void> initAsync() async {
    _th1 = uThreadInit();
    _th1.uRxChanCallback(rxFun);
  }

  @override
  initState() {
    super.initState();
    initAsync();
  }

  @override
  void dispose() {
    try {
      _th1.uThreadStop();
    } catch (e) {}

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return uPage(context, "Isolate", 
      uColNoExp([
        uTextNoExp('$_counter', 3.0),
        uRow([]),
        uBtnText(() => _th1.uThreadStart(threadFun, _th1.sendPort), "Start"),
      ]));
  }
}
