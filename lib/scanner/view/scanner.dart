import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/scanner/controller/faceHandler.dart';
import 'package:face_recognition/scanner/controller/peoplePresenceHandler.dart';
import 'package:face_recognition/scanner/model/face.dart';
import 'package:face_recognition/scanner/model/peoplePresenceReport.dart';
import 'package:face_recognition/presencePeopleReport/model/presencePeopleReport.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
//firebase
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image/image.dart' as imglib;
//date format
import 'package:intl/intl.dart';
//unrecognize
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:quiver/collection.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import '../../main.dart';
import '../controller/detector_painters.dart';
import 'utils.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  dynamic dataNew = {};
  dynamic dataUnknown = {};

  List e1;
  //firebase
  List<FaceModel> face;

  //notification
  int i = 0;
  String saveNamePresence = " ";
  String saveNamesecondPresence = " ";

  String imageStaff;
  CollectionReference imgRef;
  var interpreter;
  File jsonFile;
  List<PeoplePresenceReport> presence;
  String prevName = " ";
  firebase_storage.Reference ref;
  Directory tempDir;
  double threshold = 1.0;
  bool uploading = false;
  double val = 0;

  CameraController _camera;
  CameraLensDirection _direction = CameraLensDirection.front;
  bool _faceFound = false;
  Future<void> _initializeControllerFuture;

  bool _isDetecting = false;

  dynamic _scanResults;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _initializeCamera();

    imgRef = FirebaseFirestore.instance.collection('UnknownFace');
  }

  @override
  void dispose() {
    _camera.stopImageStream();
    _camera.dispose();

    _camera = null;

    super.dispose();
  }

//tensorflow
  Future loadModel() async {
    try {
      final gpuDelegateV2 = tfl.GpuDelegateV2(
          options: tfl.GpuDelegateOptionsV2(
        false,
        tfl.TfLiteGpuInferenceUsage.fastSingleAnswer,
        tfl.TfLiteGpuInferencePriority.minLatency,
        tfl.TfLiteGpuInferencePriority.auto,
        tfl.TfLiteGpuInferencePriority.auto,
      ));

      var interpreterOptions = tfl.InterpreterOptions()
        ..addDelegate(gpuDelegateV2);
      interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
    } on Exception {
      print('Failed to load model.');
    }
  }

  void _initializeCamera() async {
    await loadModel();
    //camera rotation
    CameraDescription description = await getCamera(_direction);
    ImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera =
        CameraController(description, ResolutionPreset.low, enableAudio: false);
    _initializeControllerFuture = _camera.initialize();

    await _initializeControllerFuture;
    await Future.delayed(Duration(milliseconds: 500));

    for (int i = 0; i < face.length; i++) {
      dataNew = face[i].dataFace;
    }

    _camera.startImageStream((CameraImage image) {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        String res;
        dynamic finalResult = Multimap<String, Face>();
        detect(image, _getDetectionMethod(), rotation).then(
          (dynamic result) async {
            if (result.length == 0)
              _faceFound = false;
            else
              _faceFound = true;
            Face _face;
            imglib.Image convertedImage =
                _convertCameraImage(image, _direction);
            for (_face in result) {
              double x, y, w, h;
              x = (_face.boundingBox.left - 10);
              y = (_face.boundingBox.top - 10);
              w = (_face.boundingBox.width + 10);
              h = (_face.boundingBox.height + 10);
              imglib.Image croppedImage = imglib.copyCrop(
                  convertedImage, x.round(), y.round(), w.round(), h.round());
              croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
              res = _recog(croppedImage);
              finalResult.add(res, _face);
            }
            setState(() {
              _scanResults = finalResult;
            });

            _isDetecting = false;
          },
        ).catchError(
          (_) {
            _isDetecting = false;
          },
        );
      }
    }); //image camera
  } //end inititalize camera

  HandleDetection _getDetectionMethod() {
    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
    return faceDetector.processImage;
  }

  //save Presence People List
  Future presencePeopleReportList(String name) async {
    print("Attendee List here");

    if (presence.isEmpty && name != prevName) {
      setState(() {
        prevName = name;
      });
      return PeoplePresenceReportHandler()
          .createNewPresendePeopleReport(DateTime.now(), name);
    } else {
      print("Attendee for loop ");
      bool presenceName = false;
      List<PresencePeopleReport> presenceid;
      for (int k = 0; k < presence.length; k++) {
        if ((DateFormat('dd-MM-yyyy').format(presence[k].date.toDate()) ==
            DateFormat('dd-MM-yyyy').format(DateTime.now()))) {
          if (name == presence[k].name) {
            print("Masuk sini 1");
            presenceName = false;
          } else {
            print("Masuk sini 2");
            presenceName = true;
          }
        } else if ((DateFormat('dd-MM-yyyy')
                .format(presence[k].date.toDate()) !=
            DateFormat('dd-MM-yyyy').format(DateTime.now()))) {
          if (name == presence[k].name) {
            print("Masuk sini 3");
            presenceName = true;
          }
        }
      }

      if (presenceName == true) {
        return PeoplePresenceReportHandler()
            .createNewPresendePeopleReport(DateTime.now(), name);
      }
    }
  }

  // face result
  Widget _buildResults() {
    const Text noResultsText = const Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);

    return CustomPaint(
      painter: painter,
    );
  }

  //camera view
  Widget _buildImage() {
    if (_camera == null || !_camera.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                _buildResults(),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  imglib.Image _convertCameraImage(
      CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)
        ? imglib.copyRotate(img, -90)
        : imglib.copyRotate(img, 90);
    return img1;
  }

  String _recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    // ignore: deprecated_member_use
    List output = List(1 * 192).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    return compare(e1).toUpperCase();
  }

  String compare(List currEmb) {
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";
    if (dataNew.length == 0) {
      count(predRes);
      return predRes = "NOT RECOGNIZED";
    }

    for (String label in dataNew.keys) {
      currDist = euclideanDistance(dataNew[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    print(minDist.toString() + " " + predRes);

    count(predRes);
    setState(() {
      saveNamePresence = predRes;
    });
    if (predRes != "NOT RECOGNIZED" &&
        predRes != "No Face saved" &&
        saveNamePresence != saveNamesecondPresence) {
      saveNamesecondPresence = predRes;
      presencePeopleReportList(predRes);
    }

    return predRes;
  }

  void count(String predRes) async {
    if (predRes == "NOT RECOGNIZED" && i < 11) {
      setState(() {
        i++;
      });
    }

    if (predRes == "NOT RECOGNIZED" && i == 10) {
      showNotification();
    }
  }

  void showNotification() {
    DateTime selectedDate = DateTime.now();
    flutterLocalNotificationsPlugin.show(
        0,
        "Unknown face detected",
        "Found on ${selectedDate.hour}:${selectedDate.second}",
        NotificationDetails(
            android: AndroidNotificationDetails(
                channel.id, channel.name, channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }

  //unrecognize face
  Widget unrecognizeFace() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (i == 10) {
            taskCompletion();
          }
          print("Last in widget");
          return Container();
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void taskCompletion() async {
    if (!await sendUnrecognizeFace()) {
      return;
    }
  }

  //send Unrecognize Face to database
  Future<bool> sendUnrecognizeFace() async {
    final path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

    await _camera.stopImageStream();

    dataUnknown = e1;

    await _camera.takePicture(path).then((value) => _initializeCamera());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("Inside widget binding");
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('unkownFace/$path}');

      await ref.putFile(File(path)).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          imgRef.add({
            'image': value,
            'date': DateTime.now(),
            'unknownFace': dataUnknown
          });
        });
      });

      setState(() {
        print("Future i: $i");
        i = 0;
      });
    });

    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return false;
    }
    return true;
  } // ASYNC

  void taskCompletion2() async {
    if (!await takePicture()) {
      return;
    }
  }

  //take Picture
  Future<bool> takePicture() async {
    print("Future take Picture");

    final path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

    print("Image path take picture: $path");

    await _camera.stopImageStream();

    await _camera.takePicture(path).then((value) => _camera = null);

    print("Image path take picture upload file: $path");

    setState(() {
      imageStaff = path;
    });

    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      // wait for the end of that frame.
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return false;
    }
    return true;
  } // ASYNC

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: const Text('Kid Guard Scanner'),
          backgroundColor: Colors.purple[200],
        ),
      ),
      body: StreamBuilder<List<FaceModel>>(
        stream: FaceHandler().listFaceImage(),
        builder: (context, snapshot) {
          face = snapshot.data;
          // print("Data New in widget build: $dataNew");

          //i from count fn
          if (i == 10) {
            print("Widget build: Inside unrecognize face");
            return unrecognizeFace();
          }
          return StreamBuilder<List<PeoplePresenceReport>>(
            stream: PeoplePresenceReportHandler().listPresencePeopleReport(),
            builder:
                (context, AsyncSnapshot<List<PeoplePresenceReport>> snapshot2) {
              presence = snapshot2.data;
              print("Attendee has data: $presence");
              return _buildImage();
            },
          );
        },
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          onPressed: _toggleCameraDirection,
          heroTag: null,
          child: _direction == CameraLensDirection.back
              ? const Icon(Icons.camera_front)
              : const Icon(Icons.camera_rear),
        ),
      ]),
    );
  } // end widget build
}
