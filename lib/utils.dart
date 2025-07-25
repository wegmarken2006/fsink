//flutter run -d chrome --dart-define=MY_ENV=web
//flutter run -d linux --dart-define=MY_ENV=linux
//flutter run -d windows --dart-define=MY_ENV=windows
//flutter run --dart-define=MY_ENV=android
//flutter build web --dart-define=MY_ENV=web
//flutter build linux --dart-define=MY_ENV=linux
//flutter build apk --dart-define=MY_ENV=android

//if error:
// flutter clean
// flutter pub upgrade

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';



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
  late SharedPreferences prefs;

  var noteController = TextEditingController();
  String noteText = "";
  String noteFileName = "notes.txt";

  //call in main before runApp:
  // await uCfg.init();
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    
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
  int fileLen = 0;
  try {
    fileLen = await file.length();
  } catch(e) {}

  if (append && (fileLen > 0)) {
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



