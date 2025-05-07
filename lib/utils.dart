import 'package:flutter/material.dart';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:isolate';

typedef Any = dynamic;

var uCfg = UtilsCfg();

class UtilsCfg {
  late List<CameraDescription> cameras;
  late CameraDescription firstCamera;
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  late SharedPreferences prefs;

  //call in main before runApp:
  // await uCfg.init();
  Future<void> init() async {
    cameras = await availableCameras();
    firstCamera = cameras.first;

    prefs = await SharedPreferences.getInstance();
  }
}

Future<void> uGoToPage(BuildContext context, Widget page) async {
  await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => page));
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

Widget uListView(BuildContext context, List lst, Function(int) fun) {
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
        subtitle: Text('${lst[index]}'),
        onTap: () => fun(index),
      );
    },
  );
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
  return FloatingActionButton(onPressed: fun, child: Icon(icon));
}

Widget uBtnText(
  Function() fun,
  String text, {
  Color? bCol = Colors.red,
  Color? fCol = Colors.white,
  bool enabled = true,
}) {
  return ElevatedButton(
    onPressed: enabled ? fun : null,
    style: ElevatedButton.styleFrom(
      minimumSize: Size.square(60.0),
      backgroundColor: bCol,
      foregroundColor: fCol,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
    child: Text(text),
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

Widget uInput(String text, Function(String) fun) {
  return uExp(
    SizedBox(
      width: 200,
      child: TextField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: text,
        ),
        onChanged: (text) {
          fun(text);
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

////import 'dart:isolate';

typedef TxChan = SendPort;

class Thread {
  late Isolate isolate;
  late ReceivePort receivePort;
  late SendPort sendPort;
  late ReceivePort exitPort;
  //var uThreadStart = Isolate.spawn;
  bool isRunning = false;

  Thread();

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

////import 'package:url_launcher/url_launcher.dart';
Future<void> uGoToWeb(String address) async {
  Uri url = Uri.parse(address);

  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

////import 'package:shared_preferences/shared_preferences.dart';
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

////import 'package:camera/camera.dart';
//call in initState
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

// Example call:
// return uPage(
//       context,
//       widget.title,
//       uCameraPreview()
//     );
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

// pass to floatingActionButton, example:
//  return uPage(
//      context,
//      widget.title,
//      uCameraPreview(),
//      uBtnIcon(() => uCameraPicture(context), Icons.camera_alt)
//    );
//
Future<void> uCameraPicture(BuildContext context) async {
  try {
    // Ensure that the camera is initialized.
    await uCfg.initializeControllerFuture;

    // Attempt to take a picture and get the file `image`
    // where it was saved.
    final image = await uCfg.controller.takePicture();

    if (!context.mounted) return;

    // If the picture was taken, display it on a new screen.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DisplayPictureScreen(
              // Pass the automatically generated path to
              // the DisplayPictureScreen widget.
              imagePath: image.path,
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

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
