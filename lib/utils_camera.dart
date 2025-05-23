import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

var uCameraCfg = UtilsCameraCfg();

class UtilsCameraCfg {
  late List<CameraDescription> cameras;
  late CameraDescription firstCamera;
  late CameraController controller;
  late Future<void> initializeControllerFuture;

  ///call in main before runApp:
  /// await uCfg.init();
  Future<void> init() async {

    if ((env != linux) && (env != windows)) {
      /* if (Platform.isAndroid) { */
      cameras = await availableCameras();
      firstCamera = cameras.first;
    }
  }
}

//import 'package:camera/camera.dart';

/// Call inside initState
List<String> uInitStateCamera() {
  uCameraCfg.controller = CameraController(
    // Get a specific camera from the list of available cameras.
    uCameraCfg.firstCamera,
    // Define the resolution to use.
    ResolutionPreset.medium,
  );

  // Next, initialize the controller. This returns a Future.
  uCameraCfg.initializeControllerFuture = uCameraCfg.controller.initialize();

  List<String> descr = [];

  for (var element in uCameraCfg.cameras) {
    descr.add(element.name);
  }
  return descr;
}

Any uCameraChange(String descr) {

  var index = 0;
  for (var i = 0; i < uCameraCfg.cameras.length; i++) {
    if (uCameraCfg.cameras[i].name  == descr) {
      index = i;
      break;
    }
  }
  
  uCameraCfg.controller = CameraController(
    // Get a specific camera from the list of available cameras.
    uCameraCfg.cameras[index],
    // Define the resolution to use.
    ResolutionPreset.medium,
  );

  // Next, initialize the controller. This returns a Future.
  uCameraCfg.initializeControllerFuture = uCameraCfg.controller.initialize();
}

/// Example call:
/// return uPage(
///       context,
///       widget.title,
///       uCameraPreview()
///     );
Widget uCameraPreview() {
  return uFlex(FutureBuilder<void>(
    future: uCameraCfg.initializeControllerFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        // If the Future is complete, display the preview.
        return CameraPreview(uCameraCfg.controller);
      } else {
        // Otherwise, display a loading indicator.
        return const Center(child: CircularProgressIndicator());
      }
    },
  ));
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
    await uCameraCfg.initializeControllerFuture;

    // Attempt to take a picture and get the file `image`
    // where it was saved.
    final image = await uCameraCfg.controller.takePicture();

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


