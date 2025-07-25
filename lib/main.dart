import 'package:flutter/material.dart';

import 'utils.dart';
import 'utils_chart.dart';
import 'utils_feed.dart';
import 'utils_csv.dart';
import 'utils_isolate.dart';
import 'utils_camera.dart';
import 'utils_webview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await uCfg.init();
  await uCameraCfg.init();

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
  Ls _items = ["buttons", "list", "tabs", "isolate", "table", "edit", "chart"];

  // three dots items
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
      case "table":
        uGoToPage(context, Page5());
        break;
      case "edit":
        uGoToPage(context, Page6());
        break;
      case "chart":
        uGoToPage(context, Page7());
        break;
      case "webview":
        uGoToPage(context, Page8());
        break;

      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    if ((env != linux) && (env != windows)) {
      /* if (Platform.isAndroid) { */
      if (! _items.contains("camera")) {
        _items.add("camera");
      }
    }
    if ((env == android) || (env == windows)) {
      if (! _items.contains("webview")) {
        _items.add("webview");
      }

    }

    return uPageMenu(
      context,
      widget.title,
      uColNoExp([]),
      uThreeDots(context, _items, menuFun),
    );
  }
}

class Page0 extends StatefulWidget {
  const Page0({super.key});

  @override
  State<Page0> createState() => Page0State();
}

class Page0State extends State<Page0> {
  List<String> _cameraNames = [];
  @override
  initState() {
    super.initState();

    _cameraNames = uInitStateCamera();
  }

  Any _cameraChange(String descr) {
    setState(() {
      uCameraChange(descr);
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return uPageMenu(
      context,
      "Camera",
      uColNoExp([
        uCameraPreview(),
      ]),
      uThreeDots(context, _cameraNames, _cameraChange),
      uBtnIcon(() => uCameraPicture(context), Icons.camera_alt)
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
  late DateTime _date;

  @override
  initState() {
    super.initState();

    _counter = uInitPersistInt("_counter");
    _date = uInitPersistDate("_date");
    _checkDay();
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

  //clear if new day
  _checkDay() {
    var time = DateTime.now();
    var ts = time.toString();
    ts = ts.split(" ")[0];
    var time2 = DateTime.parse(ts);
    if (time2.isAfter(_date)) {
      uSetPersistDate("_date", time2);
      _clear();
    }
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
          //uCol([uBtnText(_clear, "Clear")]),
          uCol([
            uBtnText(
              () => uAlert(context, "Confirm", "Are you sure", _clear),
              "Clear",
            ),
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
  String _feedTitle = "";
  List<String> _titles = [];
  List<String> _links = [];

  Future<void> initAsync() async {
    uGetFeed("https://hnrss.org/frontpage").then((feed) {
      setState(() {
        _feedTitle = feed.$1;
        _titles = feed.$2 as List<String>;
        _links = feed.$3 as List<String>;
      });
    });
  }

  void fun(int index) {
    uGoToWeb(_links[index]);
  }

  @override
  initState() {
    super.initState();
    initAsync();
  }

  @override
  Widget build(BuildContext context) {
    return uPage(
      context,
      "List",
      uColNoExp([
        uTextNoExp(_feedTitle, 1.8),
        uRefresh(initAsync, uListViewNoExp(context, _titles, _links, fun)),
      ]),
    );
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

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => Page4State();
}

class Page4State extends State<Page4> {
  late Thread _th1;
  int _counter = 0;
  bool _btnEnabled = true;

  //Must be static, must have TxChan input parameter
  static void threadFun(TxChan sendport) {
    var num = 0;

    for (var i = 0; i < 4; i++) {
      num = num + 10;
      sendport.send(num);
      uSleepS(1);
    }
    sendport.send("done");
  }

  Any rxFromThreadFun(Any messageFromThread) {
    if (messageFromThread == "done") {
      setState(() {
        _btnEnabled = true;
      });
    } else {
      setState(() {
        _btnEnabled = false;
        _counter = messageFromThread as int;
      });
    }
  }

  Future<void> initAsync() async {
    _th1 = uThreadInit();
    _th1.uRxChanCallback(rxFromThreadFun);
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
    return uPage(
      context,
      "Isolate",
      uColNoExp([
        uTextNoExp('$_counter', 3.0),
        uRow([]),
        uBtnText(
          () => _th1.uThreadStart(threadFun, _th1.sendPort),
          "Start",
          bCol: Colors.blue,
          enabled: _btnEnabled,
        ),
      ]),
    );
  }
}

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  State<Page5> createState() => Page5State();
}

class Page5State extends State<Page5> {
  List<List<Any>> _ll = [];
  var sList = [
    ["col1", "col2", "col3"],
    ["aaa", "bbb", "ccc"],
    ["aaa", "bbb", "ccc"],
  ];

  @override
  initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    await uWriteCsv("temp2.csv", sList);
    var ll = await uReadCsv("temp2.csv");
    setState(() {
      _ll = ll;
    });
  }

  @override
  Widget build(BuildContext context) {
    return uPage(
      context,
      "Table",
      //uTable(sList));
      uTable(_ll),
    );
  }
}

class Page6 extends StatefulWidget {
  const Page6({super.key});

  @override
  State<Page6> createState() => Page6State();
}

class Page6State extends State<Page6> {

  @override
  initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    uInitNotes();
  }

  @override
  Widget build(BuildContext context) {
    return uPage(
      context,
      "Edit",
      //uColNoExp([
        uNotes(),
        //uBtnIcon(() => uWriteToFile("notes.txt", uNotesGet(), append: false), Icons.add),
      //]),
    );
  }
}

class Page7 extends StatefulWidget {
  const Page7({super.key});

  @override
  State<Page7> createState() => Page7State();
}

class Page7State extends State<Page7> {

  @override
  initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {

  }

  @override
  Widget build(BuildContext context) {
    return uPage(
      context,
      "Chart",
      uColNoExp([
        uChartLine([1.0, 2.0, 3.0, 4.0], [[1.0, 2.0, 3.0, 4.0], [2.0, 4.0, 6.0, 8.0]], "xTitle", "yTitle"),
        uChartLine([1.0, 2.0, 3.0, 4.0], [[1.0, 2.0, 3.0, 4.0], [2.0, 4.0, 6.0, 8.0]], "xTitle", "yTitle"),
        uChartBar(["AAA", "bbb", "ccc", "ddd"], [[1.0, 2.0, 3.0, 4.0], [5.0, 4.0, 3.0, 2.0]], "category", "bars"),
        //uBtnIcon(() => uWriteToFile("notes.txt", uNotesGet(), append: false), Icons.add),
      ]),
    );
  }
}


class Page8 extends StatefulWidget {
  const Page8({super.key});

  @override
  State<Page8> createState() => Page8State();
}

class Page8State extends State<Page8> {

  //final _controller = uInitWebview();

  @override
  initState() {
    super.initState();
    //initAsync();
  }

  /*
  void initAsync() async {
    await uLoadWebview(_controller);
  }
  */

  @override
  Widget build(BuildContext context) {
    return uPage(
      context,
      "Webview",
      //uWebview(_controller),
      uWebview(),
    );
  }
}
