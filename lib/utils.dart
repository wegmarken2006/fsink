//flutter run -d chrome --dart-define=MY_ENV=web
//flutter run -d linux --dart-define=MY_ENV=linux
//flutter run -d windows --dart-define=MY_ENV=windows
//flutter run --dart-define=MY_ENV=android
//flutter build web --dart-define=MY_ENV=web
//flutter build linux --dart-define=MY_ENV=linux
//flutter build apk --dart-define=MY_ENV=android

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:isolate';

import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:http/http.dart' as http;

import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'package:csv/csv.dart';

import 'package:fl_chart/fl_chart.dart';

const android = "android";
const linux = "linux";
const web = "web";
const windows = "windows";

typedef Any = dynamic;
typedef Ls = List<String>;

var uCfg = UtilsCfg();

const env =
    bool.hasEnvironment("MY_ENV") ? String.fromEnvironment("MY_ENV") : android;

class UtilsCfg {
  late List<CameraDescription> cameras;
  late CameraDescription firstCamera;
  late CameraController controller;
  late Future<void> initializeControllerFuture;

  late SharedPreferences prefs;

  var noteController = TextEditingController();
  String noteText = "";
  String noteFileName = "notes.txt";

  //call in main before runApp:
  // await uCfg.init();
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    if ((env != linux) && (env != windows)) {
      /* if (Platform.isAndroid) { */
      cameras = await availableCameras();
      firstCamera = cameras.first;
    }

    prefs = await SharedPreferences.getInstance();
  }
}

Future<void> uGoToPage(BuildContext context, Widget page) async {
  await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => page));
}

Widget uFlex(Widget content) {
  return Flexible(child: content);
}

Widget uPage(
  BuildContext context,
  String title,
  Widget content, [
  Widget? fButton,
]) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
    ),
    body: Center(child: content),
    floatingActionButton: fButton,
  );
}

void uAlert(
  BuildContext context,
  String title,
  String content,
  Function onYes,
) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          // The "Yes" button
          TextButton(
            onPressed: () {
              onYes();
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
        ],
      );
    },
  );
}

/// First row in table is supposed to be columns names
Widget uTable(List<List<Any>> table) {
  List<DataColumn> dCols = [];
  List<DataRow> dRows = [];

  if (table.isNotEmpty) {
    for (var element in table[0]) {
      dCols.add(DataColumn(label: Text(element)));
    }
    for (var i = 1; i < table.length; i++) {
      var row = table[i];

      List<DataCell> dCells = [];
      for (var element in row) {
        dCells.add(DataCell(Text(element)));
      }
      dRows.add(DataRow(cells: dCells));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(columns: dCols, rows: dRows),
    );
  } else {
    return const Center(child: CircularProgressIndicator());
  }
}

Widget uPageMenu(
  BuildContext context,
  String title,
  Widget content,
  Widget menu, [
  Widget? fButton,
]) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
      actions: [menu],
    ),
    body: Center(child: content),
    floatingActionButton: fButton,
  );
}

/// Use this Expanded version inside uCol.
///
/// Example:
///
/// return uPage(
///      context,
///      "List",
///      uColNoExp([
///        uListView(context, _titles, _links, fun)]),
///    );
Widget uListView(
  BuildContext context,
  List lst,
  List subLst,
  Function(int) fun,
) {
  if (lst.isNotEmpty) {
    return uExp(
      ListView.builder(
        itemCount: lst.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(
                    context,
                  ).primaryColorLight, //Colors.lightGreenAccent,
              child: Text('${index + 1}'),
            ),
            title: Text('${lst[index]}'),
            subtitle: subLst.isNotEmpty ? Text('${subLst[index]}') : null,
            onTap: () => fun(index),
          );
        },
      ),
    );
  } else {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Use the no Expanded version inside uRefresh
Widget uListViewNoExp(
  BuildContext context,
  List lst,
  List subLst,
  Function(int) fun,
) {
  if (lst.isNotEmpty) {
    return ListView.builder(
      itemCount: lst.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).primaryColorLight, //Colors.lightGreenAccent,
            child: Text('${index + 1}'),
          ),
          title: Text('${lst[index]}'),
          subtitle: subLst.isNotEmpty ? Text('${subLst[index]}') : null,
          onTap: () => fun(index),
        );
      },
    );
  } else {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Swipe down Refresh. Pass a not Expanded widget to avoid "Incorrect use of ParentDataWidget" error.
Widget uRefresh(RefreshCallback fun, Widget widget) {
  return uExp(RefreshIndicator(onRefresh: fun, child: widget));
}

Widget uTabs(List<String> names, List<Widget> pages) {
  List<Widget> tabs = [];

  for (var elem in names) {
    tabs.add(Tab(text: elem));
  }

  return DefaultTabController(
    length: names.length,
    child: Column(
      children: [
        TabBar(tabs: tabs),
        Expanded(child: TabBarView(children: pages)),
      ],
    ),
  );

  /*
  return DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          tabs: tabs,
        ),
      ),
      body: TabBarView(children: pages),
    ),
  );
  */
}

Widget uBtnIcon(Function() fun, [IconData? icon]) {
  return uFlex(FloatingActionButton(onPressed: fun, child: Icon(icon)));
}

Widget uBtnText(
  Function() fun,
  String text, {
  Color? bCol = Colors.red,
  Color? fCol = Colors.white,
  bool enabled = true,
}) {
  return uFlex(
    ElevatedButton(
      onPressed: enabled ? fun : null,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.square(60.0),
        backgroundColor: bCol,
        foregroundColor: fCol,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(text),
    ),
  );
}

Widget uCol(List<Widget> items) {
  return uExp(
    Column(mainAxisAlignment: MainAxisAlignment.center, children: items),
  );
}

Widget uColNoExp(List<Widget> items) {
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: items);
}

Widget uRow(List<Widget> items) {
  if (items.isNotEmpty) {
    return uExp(
      Row(mainAxisAlignment: MainAxisAlignment.center, children: items),
    );
  } else {
    return Row(children: [uExp(Text(' ', textAlign: TextAlign.center))]);
  }
}

Widget uExp(Widget item) {
  return Expanded(child: item);
}

Widget uText(String text, [double sizeMul = 1.0]) {
  double size = 14.0 * sizeMul;
  return uExp(
    Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: size)),
  );
}

Widget uTextNoExp(String text, [double sizeMul = 1.0]) {
  double size = 14.0 * sizeMul;
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: size),
  );
}

/// Call inside initState() {}
void uInitNotes() async {
  uCfg.noteFileName = uGetPersistString("noteFile");
  uCfg.noteController.text = await uReadFromFile(uCfg.noteFileName);
}

void uNotesRefresh() async {
  uCfg.noteController.text = await uReadFromFile(uCfg.noteFileName);
}

Widget uNotes() {
  return Scaffold(
    appBar: AppBar(
      toolbarHeight: 80.0,
      title: const Text('Notes'),
      actions: [
        uInput(
          uCfg.noteFileName,
          (txt) {
            uCfg.noteFileName = txt;
          },
          funOnSubmit: (txt) {
            uCfg.noteFileName = txt;
            uSetPersistString("noteFile", txt);
            uNotesRefresh();
          },
        ),
        uBtnIcon(
          () => uWriteToFile(uCfg.noteFileName, uNotesGet(), append: false),
          Icons.save,
        ),
      ],
    ),
    body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: //uExp(
          TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          fillColor: Colors.blueGrey,
          filled: true,
        ),
        controller: uCfg.noteController,
        keyboardType: TextInputType.multiline,
        maxLines: 50,
        //),
      ),
    ),
  );

  /*
  return uExp(
      SizedBox(
        child: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            fillColor: Colors.black,
            filled: true,
          ),
          controller: uCfg.noteController,
          keyboardType: TextInputType.multiline,
          maxLines: 100,
        ),
      ),
    );
    */
}

String uNotesGet() {
  return uCfg.noteController.text;
}

/// option parameter nulti: true for multiline input
Widget uInput(
  String label,
  Function(String) funOnChange, {
  Function(String)? funOnSubmit,
  String text = "",
  bool multi = false,
}) {
  return uExp(
    SizedBox(
      width: 200,
      child: TextField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        onChanged: (text) {
          funOnChange(text);
        },
        onSubmitted: (text) {
          funOnSubmit!(text);
        },
      ),
    ),
  );
}

Widget uThreeDots(
  BuildContext context,
  List<String> lst,
  Function(String) fun,
) {
  return PopupMenuButton<String>(
    onSelected: (item) => fun(item),
    itemBuilder: (BuildContext context) {
      return lst.map((String choice) {
        return PopupMenuItem<String>(value: choice, child: Text(choice));
      }).toList();
    },
  );
}

void uSleepS(int seconds) {
  var duration = Duration(seconds: seconds);
  sleep(duration);
}

//import 'package:csv/csv.dart';

Future<List<List<Any>>> uReadCsv(String fileName) async {
  var path = await uGetFileFullPath(fileName);
  final input = File(path).openRead();
  final listData =
      await input
          .transform(utf8.decoder)
          .transform(CsvToListConverter())
          .toList();

  //var rData = await uReadFromFile(fileName);
  //var file = File(path);
  //var rData = file.readAsStringSync();

  /*
  List<List<Any>> listData =
      CsvToListConverter(
        fieldDelimiter: ",",
        eol: "\n",
        shouldParseNumbers: false,
      ).convert(rData).toList();
      */
  return listData;
}

Future<void> uWriteCsv(String fileName, List<List<Any>> toWrite) async {
  var res = ListToCsvConverter().convert(toWrite);

  await uWriteToFile(fileName, res);
}

//import 'dart:isolate';

typedef TxChan = SendPort;

class Thread {
  late Isolate isolate;
  late ReceivePort receivePort;
  late SendPort sendPort;
  late ReceivePort exitPort;
  //var uThreadStart = Isolate.spawn;
  bool isRunning = false;

  Thread();

  /// Input "fun" must be static, must have TxChan input parameter.
  void uThreadStart(Function(TxChan) fun, TxChan par) async {
    if (!isRunning) {
      isRunning = true;
      isolate = await Isolate.spawn(fun, par, onExit: exitPort.sendPort);
    }
  }

  void uThreadStop() {
    isolate.kill();
    receivePort.close();
    exitPort.close();
    isRunning = false;
  }

  void uRxChanCallback(Function(Any) onReceive) {
    receivePort.listen(onReceive);
  }

  void uSend(Any message) {
    sendPort.send(message);
  }
}

Thread uThreadInit() {
  var receivePort = ReceivePort();
  //var isolate = await Isolate.spawn(fun!, par);
  //receivePort.listen(onReceive);

  var thread = Thread();
  thread.receivePort = receivePort;
  thread.exitPort = ReceivePort();
  thread.sendPort = receivePort.sendPort;

  thread.exitPort.listen((_) {
    thread.isRunning = false;
  });

  return thread;
}

//import 'package:external_path/external_path.dart';
//import 'package:permission_handler/permission_handler.dart';

Future<String> uGetPathForImageSave() async {
  var fileName = "${DateTime.now()}.png";
  fileName = fileName.replaceAll(":", "_");
  fileName = fileName.replaceAll(" ", "");

  var path = "";
  if (env == android) {
    await Permission.storage.request();
    path = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOAD,
    );
  }

  path = "$path/$fileName";

  return path;
}

Future<void> uWriteToFile(
  String fileName,
  String toWrite, {
  bool append = true,
}) async {
  var path = await uGetFileFullPath(fileName);
  var file = File(path);

  if (append) {
    toWrite = "\r\n$toWrite";
    file.writeAsString(toWrite, mode: FileMode.append);
  } else {
    file.writeAsString(toWrite);
  }
}

Future<String> uGetFileFullPath(String fileName) async {
  fileName = fileName.replaceAll(":", "_");
  fileName = fileName.replaceAll(" ", "");

  var path = "";
  if (env == android) {
    await Permission.storage.request();
    path = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOAD,
    );
  } else if ((env == linux) || (env == windows)) {
    final Directory directory = await getApplicationDocumentsDirectory();
    path = directory.path;
  } else {
    var current = Directory.current;
    path = current.toString();
  }

  if (env == windows) {
    path = "$path\\$fileName";
  } else {
    path = "$path/$fileName";
  }

  path = path.replaceAll("'", "");

  return path;
}

Future<String> uReadFromFile(String fileName) async {
  try {
    var path = await uGetFileFullPath(fileName);
    var file = File(path);

    var str = await file.readAsString();

    return str;
  } catch (e) {
    return "";
  }
}

//import 'package:url_launcher/url_launcher.dart';

Future<void> uGoToWeb(String address) async {
  Uri url = Uri.parse(address);

  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

//import 'package:shared_preferences/shared_preferences.dart';

int uInitPersistInt(String valName) {
  var value = (uCfg.prefs.getInt(valName) ?? 0);
  return value;
}

int uGetPersistInt(String valName) {
  var value = (uCfg.prefs.getInt(valName) ?? 0);
  return value;
}

void uSetPersistInt(String valName, int value) {
  uCfg.prefs.setInt(valName, value);
}

DateTime uInitPersistDate(String valName) {
  var value = (uCfg.prefs.getString(valName) ?? "1970-01-01");
  var time = DateTime.parse(value);
  return time;
}

DateTime uGetPersistDate(String valName) {
  var value = (uCfg.prefs.getString(valName) ?? "1970-01-01");
  var time = DateTime.parse(value);
  return time;
}

void uSetPersistDate(String valName, DateTime time) {
  var dateS = time.toString();
  dateS = dateS.split(" ")[0];

  uCfg.prefs.setString(valName, dateS);
}

String uGetPersistString(String valName) {
  var value = (uCfg.prefs.getString(valName) ?? "");
  return value;
}

void uSetPersistString(String valName, String value) {
  uCfg.prefs.setString(valName, value);
}

//import 'package:camera/camera.dart';

/// Call inside initState
void uInitStateCamera() {
  uCfg.controller = CameraController(
    // Get a specific camera from the list of available cameras.
    uCfg.firstCamera,
    // Define the resolution to use.
    ResolutionPreset.medium,
  );

  // Next, initialize the controller. This returns a Future.
  uCfg.initializeControllerFuture = uCfg.controller.initialize();
}

/// Example call:
/// return uPage(
///       context,
///       widget.title,
///       uCameraPreview()
///     );
Widget uCameraPreview() {
  return FutureBuilder<void>(
    future: uCfg.initializeControllerFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        // If the Future is complete, display the preview.
        return CameraPreview(uCfg.controller);
      } else {
        // Otherwise, display a loading indicator.
        return const Center(child: CircularProgressIndicator());
      }
    },
  );
}

/// Pass to floatingActionButton, example:
///
///  return uPage(
///      context,
///      widget.title,
///      uCameraPreview(),
///      uBtnIcon(() => uCameraPicture(context), Icons.camera_alt)
///    );
///
///  Optional save flag to store the image in Download
Future<void> uCameraPicture(BuildContext context, [bool save = false]) async {
  try {
    // Ensure that the camera is initialized.
    await uCfg.initializeControllerFuture;

    // Attempt to take a picture and get the file `image`
    // where it was saved.
    final image = await uCfg.controller.takePicture();

    var pathToSave = "";
    if (save || env != android) {
      pathToSave = await uGetPathForImageSave();
      image.saveTo(pathToSave);
    }

    if (!context.mounted) return;

    // If the picture was taken, display it on a new screen.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DisplayPictureScreen(
              // Pass the automatically generated path to
              // the DisplayPictureScreen widget.
              imagePath: image.path,
              pathToSave: pathToSave,
            ),
      ),
    );
  } catch (e) {
    // If an error occurs, log the error to the console.
    print(e);
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String pathToSave;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.pathToSave,
  });

  @override
  Widget build(BuildContext context) {
    if (env == android) {
      return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Image.file(File(imagePath)),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        body: Image.asset(pathToSave),
      );
    }
  }
}

//import 'package:webfeed_plus/webfeed_plus.dart';

/*
Future<(String, List, List)> uGetFeed(String address) async {
  List<String> titles = [];
  List<String> links = [];

  var feedUrl = address;
  String title = "?";

  var text = await http.read(Uri.parse(feedUrl));
  var channel = RssFeed.parse(text);

  title = channel.title!;
  if (channel.items != null) {
    for (var item in channel.items!) {
      titles.add(item.title!);
      links.add(item.link!);
    }
  }
  
  return (title, titles, links);
}
*/

Future<(String, List, List)> uGetFeed(String address) async {
  List<String> titles = [];
  List<String> links = [];
  List<RssItem> items = [];

  String title = "?";

  try {
    final response = await http.get(Uri.parse(address));
    if (response.statusCode == 200) {
      final feed = RssFeed.parse(response.body);

      items = feed.items ?? [];
      title = feed.title!;
      if (feed.items != null) {
        for (var item in items) {
          titles.add(item.title!);
          links.add(item.link!);
        }
      }
    }
  } catch (e) {
    print('Error fetching RSS feed: $e');
  }

  print(title);
  return (title, titles, links);
}

Widget uChartLine(
  List<double> x,
  List<List<double>> y,
  String xTitle,
  String yTitle,
) {
  List<Color> colors = [];

  for (var i = 0; i < y.length; i++) {
    colors.add(
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    );
  }

  List<FlSpot> spots = [];
  List<LineChartBarData> llbd = [];
  for (var i = 0; i < y.length; i++) {
    spots = [];
    for (var j = 0; j < x.length; j++) {
      spots.add(FlSpot(x[j], y[i][j]));
    }
    llbd.add(LineChartBarData(spots: spots, color: colors[i]));
  }
  return uFlex(
    LineChart(
      LineChartData(
        lineBarsData: llbd,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(axisNameWidget: Text(yTitle)),
          bottomTitles: AxisTitles(axisNameWidget: Text(xTitle)),
        ),
      ),
    ),
  );
}

Widget uChartBar(
  List<String> xNames,
  List<List<double>> y,
  String xTitle,
  String yTitle,
) {
  List<Color> colors = [];

  for (var i = 0; i < y.length; i++) {
    colors.add(
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    );
  }

  List<BarChartGroupData> lbc = [];
  for (var j = 0; j < xNames.length; j++) {
    BarChartRodData bcrd;
    List<BarChartRodData> lbcrd = [];
    for (var i = 0; i < y.length; i++) {
      bcrd = BarChartRodData(toY: y[i][j], color: colors[i]);
      lbcrd.add(bcrd);
    }
    lbc.add(BarChartGroupData(x: j, barRods: lbcrd));
  }
  Widget getTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(xNames[value.toInt()], style: TextStyle(color: Colors.black)),
    );
  }

  return uFlex(
    BarChart(
      BarChartData(
        barGroups: lbc,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(axisNameWidget: Text(yTitle)),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(xTitle),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getTitles,
            ),
          ),
        ),
      ),
    ),
  );
}
