import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/picture/model/recognize_face.dart';
import 'package:face_recognition/picture/service/recognizeFaceService.dart';
import 'package:camera/camera.dart';
import 'package:face_recognition/staff/view/form/staffformdata.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:quiver/collection.dart';
import 'package:flutter/services.dart';

//firebase
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

//take Picture
import 'package:path/path.dart' show join;

import '../utils.dart';

class StaffCameraEditPage extends StatefulWidget {
  final int index;
  final String image;
  final dynamic dataFace;
  final int categoryImage;
  final String staffID;

  StaffCameraEditPage(
      this.index, this.image, this.dataFace, this.categoryImage, this.staffID);

  @override
  _StaffCameraEditPageState createState() => _StaffCameraEditPageState();
}

class _StaffCameraEditPageState extends State<StaffCameraEditPage> {
  //for database
  dynamic dataNew = {};
  //new one
  dynamic dataFaceList = {};

  List e1;

  CollectionReference imgRef;
  var interpreter;
  File jsonFile;
  //firebase
  List<RecognizeFace> face;

  firebase_storage.Reference ref;
  Directory tempDir;
  double threshold = 1.0;
  bool uploading = false;
  double val = 0;

  CameraController _camera;
  CameraLensDirection _direction = CameraLensDirection.front;
  bool _faceFound = false;
  //unrecognize
  Future<void> _initializeControllerFuture;

  //image
  String imageStaff;
  int capture = 0;

  bool _isDetecting = false;
  // CollectionReference imgRef;
  // ignore: unused_field
  dynamic _scanResults;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    imageStaff = widget.image;

    _initializeCamera();
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

  Future<void> _initializeCamera() async {
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
    print("dataNew: $dataNew");

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
              // int startTime = new DateTime.now().millisecondsSinceEpoch;
              res = _recog(croppedImage);
              // int endTime = new DateTime.now().millisecondsSinceEpoch;
              // print("Inference took ${endTime - startTime}ms");
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

  //camera view
  Widget _buildImage() {
    if (_camera == null || !_camera.value.isInitialized) {
      return Center(
        // child: Text("Camera not buid"),
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
    // imglib -> Image package from https://pub.dartlang.org/packages/image
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
    if (dataNew.length == 0) return "No Face saved";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";
    for (String label in dataNew.keys) {
      currDist = euclideanDistance(dataNew[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    print(minDist.toString() + " " + predRes);

    return predRes;
  }

  void _saveFile() {
    print("Naviagte to Profile $imageStaff and $dataFaceList");
    //add id
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
      return ProfileStaffData(
          imageStaff, dataFaceList, widget.categoryImage, widget.staffID);
    }));
  }

  Widget showpicture() {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Picture'),R
      //   centerTitle: false,
      //   actions: <Widget>[
      //     Divider(
      //       indent: 15.0,
      //     ),
      //     GestureDetector(
      //       child: Text(
      //         'Cancel',
      //         style: TextStyle(
      //           fontSize: 18,
      //           color: Colors.white,
      //         ),
      //       ),
      //       onTap: () async {
      //         //add id
      //         await Navigator.of(context)
      //             .pushReplacement(MaterialPageRoute(builder: (_) {
      //           return StaffCameraEditPage(widget.index, widget.image,
      //               widget.dataFace, widget.categoryImage,widget.staffID);
      //         }));
      //       },
      //     ),
      //     Divider(
      //       indent: 15.0,
      //     ),
      //     GestureDetector(
      //       child: Text(
      //         'OK',
      //         style: TextStyle(
      //           fontSize: 18,
      //           color: Colors.white,
      //         ),
      //       ),
      //       onTap: () {
      //         _saveFile();
      //       },
      //     ),
      //   ],
      // ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: Text('Picture'),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
        ),
      ),
      body: Image.file(
        File(imageStaff),
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              _saveFile();
            },
            label: Text('Save'),
            icon: Icon(Icons.done),
          ),
          SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () async {
              await Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (_) {
                return StaffCameraEditPage(widget.index, widget.image,
                    widget.dataFace, widget.categoryImage, widget.staffID);
              }));
            },
            label: Text('Cancel'),
            icon: Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }

  // Future uploadFace() async {
  //   return RecognizeFaceService().createNewImage(dataNew);
  // }

  //capture image
  Future<void> _handle() async {
    print("Add Image");

    setState(() {
      capture++;
      _camera = null;
      dataFaceList = e1;
      print("Add Image dataFace: $dataFaceList");
    });

    await _initializeCamera();

    // await taskCompletion();

    // return showpicture();

    await takePicture();
  }

  // Future<void> taskCompletion() async {
  //   if (!await takePicture()) {
  //     print("show picture");
  //     return;
  //   }
  // }

  //take Picture
  Future<bool> takePicture() async {
    print("Future take Picture");

    final path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

    print("Image path take picture: $path");

    await _camera.stopImageStream();

    await _camera.takePicture(path);

    setState(() async {
      imageStaff = path;
      print("Image path take picture upload file: $imageStaff");
    });

    if (!mounted) return false;

    return true;
  } // ASYNC

  @override
  Widget build(BuildContext context) {
    if (imageStaff != widget.image) {
      _camera.stopImageStream();
      setState(() {
        _camera = null;
      });

      return showpicture();
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Camera'),
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Icon(Icons.close),
      //       onPressed: () {
      //         Navigator.of(context)
      //             .pushReplacement(MaterialPageRoute(builder: (_) {
      //           return StaffFormEditData(widget.index, widget.image,
      //               widget.dataFace, widget.categoryImage, widget.staffID);
      //         }));
      //       },
      //     ),
      //   ],
      // ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: Text('Picture'),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  return ProfileStaffData(widget.image, widget.dataFace,
                      widget.categoryImage, widget.staffID);
                }));
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<RecognizeFace>>(
        stream: RecognizeFaceService().listFaceImage(),
        builder: (context, snapshot) {
          print("Take picture");
          face = snapshot.data;

          return _buildImage();
        },
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          backgroundColor: (_faceFound) ? Colors.blue : Colors.blueGrey,
          child: Icon(Icons.add),
          onPressed: () async {
            //add face
            if (capture < 1) {
              return _handle();
            } //end if
          },
          heroTag: null,
        ),
        SizedBox(
          height: 10,
        ),
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
