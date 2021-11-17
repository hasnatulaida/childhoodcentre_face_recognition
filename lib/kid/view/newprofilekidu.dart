import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:face_recognition/kid/model/kid2.dart';
import 'package:face_recognition/kid/controller/kid_service2.dart';
import 'package:face_recognition/picture/model/recognize_face.dart';
import 'package:face_recognition/picture/service/recognizeFaceService.dart';
import 'package:face_recognition/picture/view/kid/unknown/kidCameraPageDadu.dart';
import 'package:face_recognition/picture/view/kid/unknown/kidCameraPageMomu.dart';
import 'package:face_recognition/picture/view/kid/unknown/kidCameraPageu.dart';
import 'package:face_recognition/picture/view/kid/unknown/showImageGalleryDadu.dart';
import 'package:face_recognition/picture/view/kid/unknown/showImageGalleryNewKidu.dart';
import 'package:face_recognition/picture/view/kid/unknown/showImageGalleryNewMomu.dart';
import 'package:face_recognition/unrecognize_face/service/unrecognizeService.dart';
import 'package:face_recognition/unrecognize_face/view/unrecognizeFace.dart';
//firebase
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
//upload gallery
import 'package:image_picker/image_picker.dart';

import '../../loading.dart';

//new kid profile
class NewProfileKidUnrecognize extends StatefulWidget {
  NewProfileKidUnrecognize(
      this.dataFace,
      this.dataFaceMom,
      this.dataFaceDad,
      this.image,
      this.imageMom,
      this.imageDad,
      this.categoryImagePage,
      this.categoryImageMomPage,
      this.categoryImageDadPage,
      //unknown uid
      this.uid,
      this.user);

  final dynamic dataFace;
  final dynamic dataFaceMom;
  final dynamic dataFaceDad;
  final String image;
  final String imageMom;
  final String imageDad;
  //only use in this page
  final int categoryImagePage;
  final int categoryImageMomPage;
  final int categoryImageDadPage;
  final String uid;
  final String user;

  @override
  _NewProfileKidUnrecognizeState createState() =>
      _NewProfileKidUnrecognizeState();
}

class _NewProfileKidUnrecognizeState extends State<NewProfileKidUnrecognize> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<Kid2> kid;

  String name;
  String address;
  String momName;
  String momPhone;
  String dadName;
  String dadPhone;
  bool isCheck;

  final String galleryDB = "01Gallery";
  final String navigate = "form";

  //categoryChoose
  // if 1 = camera
  //if 2 = gallery
  int categoryImageKid;
  int categoryImageMom;
  int categoryImageDad;
  //uploadGallery
  String _imageFile = 'assets/image/people.png';
  String _imageFileMom = 'assets/image/people.png';
  String _imageFileDad = 'assets/image/people.png';
  ImagePicker _picker = ImagePicker();
  int databaseChoice = 0;

  //dataFace
  dynamic dataFaceDB = {};
  dynamic dataFaceDBMom = {};
  dynamic dataFaceDBDad = {};

  dynamic dataFaceKey = {};
  String email;
  List<RecognizeFace> face;
  String uidFace;
  String uidFaceMom;
  String uidFaceDad;

  //firebase storage
  firebase_storage.Reference ref;
  firebase_storage.Reference refMom;
  firebase_storage.Reference refDad;
  DateTime time = DateTime.now();

  @override
  void dispose() {
    print("Masuk dispose");
    databaseChoice = 0;
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: Text('Kid Form'),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.WARNING,
                    headerAnimationLoop: false,
                    animType: AnimType.TOPSLIDE,
                    showCloseIcon: true,
                    closeIcon: Icon(Icons.close_fullscreen_outlined),
                    title: 'Warning',
                    desc: 'Are you sure to cancel kid details?',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (_) {
                        return UnrecognizeFaceSticky();
                      }));
                    })
                  ..show();
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Kid2>>(
          stream: KidDatabaseService2().listKid(),
          builder: (context, snapshot1) {
            //all snap picture
            if (databaseChoice == 1) {
              return StreamBuilder<List<RecognizeFace>>(
                stream: RecognizeFaceService().listFaceImage(),
                builder:
                    (context, AsyncSnapshot<List<RecognizeFace>> snapshot2) {
                  switch (snapshot2.connectionState) {
                    case ConnectionState.none:
                      return Loading();
                    case ConnectionState.waiting:
                      return Loading();
                    case ConnectionState.active:
                      face = snapshot2.data;
                      print("Face length to for loop ${face.length}");

                      for (int j = 0; j < face.length; j++) {
                        dataFaceKey = face[j].dataFace;
                      }

                      for (int h = 0; h < dataFaceKey.length; h++) {
                        print("dataFacekey loop");
                        if (dataFaceKey.keys.elementAt(h) ==
                            name.toUpperCase()) {
                          uidFace = face[h].uid;
                          print("uid is $uidFace");
                        } else if (dataFaceKey.keys.elementAt(h) ==
                            momName.toUpperCase()) {
                          uidFaceMom = face[h].uid;
                          print("uid is $uidFace");
                        }
                        if (dataFaceKey.keys.elementAt(h) ==
                            dadName.toUpperCase()) {
                          uidFaceDad = face[h].uid;
                          print("uid is $uidFace");
                        }
                      }

                      if (databaseChoice == 1) {
                        databaseChoice = 5;

                        saveKidFileDataface();
                        removeUnknownFace();
                      }
                      if (databaseChoice == 5) {
                        databaseChoice = 6;
                        saveMomFileDataface();
                      }
                      if (databaseChoice == 6) {
                        databaseChoice = 3;
                        saveDadFileDataface();
                      }

                      if (databaseChoice == 3) {
                        databaseChoice = 2;
                        if (widget.user == "kid") {
                          saveMomCameraKid();
                        } else if (widget.user == "mom") {
                          saveKidCameraMom();
                        } else
                          saveKidCameraDad();
                        //call kid > kid call mom > mom call dad
                        //already complete

                        // saveMomFile();
                        // saveDadFile();
                        // saveKidCamera();
                        // saveAllFile();
                      }

                      return Loading();
                      break;

                    case ConnectionState.done:
                      return Loading();
                  }
                  return null;
                },
              );
            }
            //after finish insert database
            if (databaseChoice == 2) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  return UnrecognizeFaceSticky();
                })),
              );
            }
            //one or all galler image
            if (databaseChoice == 4) {
              databaseChoice = 2;
              if (widget.user == "kid") {
                saveMomFileKid();
                removeUnknownFace();
              } else if (widget.user == "mom") {
                saveKidFileMom();
                removeUnknownFace();
              } else {
                saveKidFileDad();
                removeUnknownFace();
              }
              return Loading();
            } else
              switch (snapshot1.connectionState) {
                case ConnectionState.none:
                  return Loading();
                case ConnectionState.waiting:
                  return Loading();
                case ConnectionState.active:
                  kid = snapshot1.data;
                  print("kid form $kid");
                  return _buildForm();
                  break;
                case ConnectionState.done:
                  return Loading();
              }
            return Container();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            debugPrint('Kid data is saved');
            if (widget.categoryImagePage == 2 ||
                widget.categoryImageMomPage == 2 ||
                widget.categoryImageDadPage == 2) {
              print("DatabaseChoice ${widget.categoryImagePage}");
              setState(() {
                databaseChoice = 4;
              });
            } else if (widget.categoryImagePage == 1) {
              print("DatabaseChoice ${widget.categoryImagePage}");
              setState(() {
                databaseChoice = 1;
              });
            }
          }
        },
        child: Icon(Icons.done),
      ),
    );
  }

  Future removeUnknownFace() async {
    UnrecognizeService().removeFaceImage(widget.uid);
  }

  //saveRecognizeFace
  Future saveKidFileDataface() async {
    dataFaceDB[name.toUpperCase()] = widget.dataFace;

    print("in set state $dataFaceDB");

    print("in database dataface");
    return RecognizeFaceService().createNewImage(dataFaceDB);
  }

  Future saveMomFileDataface() async {
    dataFaceDBMom[name.toUpperCase()] = widget.dataFaceMom;

    print("in set state $dataFaceDBMom");

    print("in database dataface");
    return RecognizeFaceService().createNewImage(dataFaceDBMom);
  }

  Future saveDadFileDataface() async {
    dataFaceDBDad[name.toUpperCase()] = widget.dataFaceDad;

    print("in set state $dataFaceDBDad");

    print("in database dataface");
    return RecognizeFaceService().createNewImage(dataFaceDBDad);
  }

//widget image kid

  Future saveMomFileKid() async {
    refMom = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('momImages/${widget.imageMom}}');

    return refMom.putFile(File(widget.imageMom)).whenComplete(() async {
      await refMom.getDownloadURL().then((value) {
        // momImageFile = value;

        print("Kid Global Mom $value ");
        saveDadFileKid(value);
      });
    });
  }

  Future saveDadFileKid(String momValue) async {
    print("save dad file image  $momValue");
    refDad = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('dadImages/${widget.imageDad}}');

    return refDad.putFile(File(widget.imageDad)).whenComplete(() async {
      await refDad.getDownloadURL().then((value) {
        // dadImageFile = value;

        print("Kid Global Dad $value , mom $momValue");

        return KidDatabaseService2().createNewKid(
            name.trim(),
            selectedDate,
            address.trim(),
            momName.trim(),
            momPhone,
            dadName.trim(),
            dadPhone,
            galleryDB,
            galleryDB,
            galleryDB,
            widget.image,
            momValue,
            value);
      });
    });
  }

  //widget image mom
  Future saveKidFileMom() async {
    print("create new kid");

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('kidImages/${widget.image}}');

    ref.putFile(File(widget.image)).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        // kidImageFile = value;
        print("Kid Global $value");
        saveDadFileMom(value);
      });
    });
  }

  Future saveDadFileMom(String kidValue) async {
    print("save dad file image $kidValue");
    refDad = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('dadImages/${widget.imageDad}}');

    return refDad.putFile(File(widget.imageDad)).whenComplete(() async {
      await refDad.getDownloadURL().then((value) {
        // dadImageFile = value;

        print("Kid Global Dad $value  and kid $kidValue");

        return KidDatabaseService2().createNewKid(
            name.trim(),
            selectedDate,
            address.trim(),
            momName.trim(),
            momPhone,
            dadName.trim(),
            dadPhone,
            galleryDB,
            galleryDB,
            galleryDB,
            kidValue,
            widget.imageMom,
            value);
      });
    });
  }

  //widget image dad

  Future saveKidFileDad() async {
    print("create new kid");

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('kidImages/${widget.image}}');

    ref.putFile(File(widget.image)).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        // kidImageFile = value;
        print("Kid Global $value");
        saveMomFileDad(value);
      });
    });
  }

  Future saveMomFileDad(String kidValue) async {
    print("create new mom image $kidValue");
    refMom = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('momImages/${widget.imageMom}}');

    return refMom.putFile(File(widget.imageMom)).whenComplete(() async {
      await refMom.getDownloadURL().then((value) {
        print("Kid Global Mom $value and kid $kidValue");
        return KidDatabaseService2().createNewKid(
            name.trim(),
            selectedDate,
            address.trim(),
            momName.trim(),
            momPhone,
            dadName.trim(),
            dadPhone,
            galleryDB,
            galleryDB,
            galleryDB,
            kidValue,
            value,
            widget.image);
      });
    });
  }

//CAMERA

  Future saveMomCameraKid() async {
    refMom = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('momImages/${widget.imageMom}}');

    return refMom.putFile(File(widget.imageMom)).whenComplete(() async {
      await refMom.getDownloadURL().then((value) {
        // momImageFile = value;

        print("Kid Global Mom $value ");
        saveDadCameraKid(value);
      });
    });
  }

  Future saveDadCameraKid(String momValue) async {
    print("save dad file image  and $momValue");
    refDad = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('dadImages/${widget.imageDad}}');

    return refDad.putFile(File(widget.imageDad)).whenComplete(() async {
      await refDad.getDownloadURL().then((value) {
        print("Kid Global Dad $value ");

        return KidDatabaseService2().createNewKid(
            name.trim(),
            selectedDate,
            address.trim(),
            momName.trim(),
            momPhone,
            dadName.trim(),
            dadPhone,
            uidFace,
            uidFaceMom,
            uidFaceDad,
            widget.image,
            momValue,
            value);
      });
    });
  }

  //widget image caemra mom
  Future saveKidCameraMom() async {
    print("create new kid");

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('kidImages/${widget.image}}');

    ref.putFile(File(widget.image)).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        // kidImageFile = value;
        print("Kid Global $value");
        saveDadCameraMom(value);
      });
    });
  }

  Future saveDadCameraMom(String kidValue) async {
    print("save dad file image $kidValue");
    refDad = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('dadImages/${widget.imageDad}}');

    return refDad.putFile(File(widget.imageDad)).whenComplete(() async {
      await refDad.getDownloadURL().then((value) {
        print("Kid Global Dad $value  kid $kidValue");

        return KidDatabaseService2().createNewKid(
            name.trim(),
            selectedDate,
            address.trim(),
            momName.trim(),
            momPhone,
            dadName.trim(),
            dadPhone,
            uidFace,
            uidFaceMom,
            uidFaceDad,
            kidValue,
            widget.imageMom,
            value);
      });
    });
  }

//widget camera image dad

  Future saveKidCameraDad() async {
    print("create new kid");

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('kidImages/${widget.image}}');

    ref.putFile(File(widget.image)).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        print("Kid Global $value");
        saveMomCameraDad(value);
      });
    });
  }

  Future saveMomCameraDad(String kidValue) async {
    print("create new mom image $kidValue");
    refMom = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('momImages/${widget.imageMom}}');

    return refMom.putFile(File(widget.imageMom)).whenComplete(() async {
      await refMom.getDownloadURL().then((value) {
        print("Kid Global Mom $value and kid $kidValue");
        return KidDatabaseService2().createNewKid(
            name.trim(),
            selectedDate,
            address.trim(),
            momName.trim(),
            momPhone,
            dadName.trim(),
            dadPhone,
            uidFace,
            uidFaceMom,
            uidFaceDad,
            kidValue,
            value,
            widget.imageDad);
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

//kid
  void _chooseCatergoryTakePicture() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Kid Picture"),
            content: new Text('Choose your option for picture:'),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          categoryImageKid = 1;
                          print("Category image kid camera $categoryImageKid");
                        });

                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return KidCameraPageUnrecognize(
                              widget.dataFace,
                              widget.dataFaceMom,
                              widget.dataFaceDad,
                              widget.image,
                              widget.imageMom,
                              widget.imageDad,
                              categoryImageKid,
                              widget.categoryImageMomPage,
                              widget.categoryImageDadPage,
                              widget.uid,
                              widget.user);
                        }));
                      },
                      child: new Text('Snap Picture',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ))),
                  SizedBox(width: 10),
                  new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () async {
                        final imageFile =
                            await _picker.getImage(source: ImageSource.gallery);
                        if (mounted) {
                          setState(() {
                            _imageFile = imageFile.path;
                            categoryImageKid = 2;
                            print(
                                "Image path kid $_imageFile & category image kid gallery $categoryImageKid");
                          });
                        }
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return ShowImageGalleryNewKidUnrecognize(
                              _imageFile,
                              widget.imageMom,
                              widget.imageDad,
                              categoryImageKid,
                              widget.categoryImageMomPage,
                              widget.categoryImageDadPage,
                              widget.uid,
                              widget.user);
                        }));
                      },
                      child: new Text('From Gallery',
                          style: TextStyle(fontSize: 16, color: Colors.white)))
                ],
              ),
            ],
          );
        });
  }

  void _chooseCatergoryTakePictureMom() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Mom Picture"),
            content: new Text('Choose your option for picture:'),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          categoryImageMom = 1;
                        });
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return KidCameraPageMomUnrecognize(
                              widget.dataFace,
                              widget.dataFaceMom,
                              widget.dataFaceDad,
                              widget.image,
                              widget.imageMom,
                              widget.imageDad,
                              widget.categoryImagePage,
                              categoryImageMom,
                              widget.categoryImageDadPage,
                              widget.uid,
                              widget.user);
                        }));
                      },
                      child: new Text('Snap Picture',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ))),
                  SizedBox(width: 10),
                  new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () async {
                        final imageFile =
                            await _picker.getImage(source: ImageSource.gallery);
                        if (mounted) {
                          setState(() {
                            _imageFileMom = imageFile.path;
                            categoryImageMom = 2;
                            print("Image path mom $_imageFile");
                          });
                        }
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return ShowImageGalleryNewMomUnrecognize(
                              widget.image,
                              _imageFileMom,
                              widget.imageDad,
                              widget.categoryImagePage,
                              categoryImageMom,
                              widget.categoryImageDadPage,
                              widget.uid,
                              widget.user);
                        }));
                      },
                      child: new Text('From Gallery',
                          style: TextStyle(fontSize: 16, color: Colors.white)))
                ],
              ),
            ],
          );
        });
  }

  void _chooseCatergoryTakePictureDad() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Dad Picture"),
            content: new Text('Choose your option for picture:'),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          categoryImageDad = 1;
                        });
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return KidCameraPageDadUnrecognize(
                              widget.dataFace,
                              widget.dataFaceMom,
                              widget.dataFaceDad,
                              widget.image,
                              widget.imageMom,
                              widget.imageDad,
                              widget.categoryImagePage,
                              widget.categoryImageMomPage,
                              categoryImageDad,
                              widget.uid,
                              widget.user);
                        }));
                      },
                      child: new Text('Snap Picture',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ))),
                  SizedBox(width: 10),
                  new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () async {
                        final imageFile =
                            await _picker.getImage(source: ImageSource.gallery);
                        if (mounted) {
                          setState(() {
                            _imageFileDad = imageFile.path;
                            categoryImageDad = 2;
                            print("Image path dad $_imageFile");
                          });
                        }
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return ShowImageGalleryNewDadUnrecognize(
                              widget.image,
                              widget.imageMom,
                              _imageFileDad,
                              widget.categoryImagePage,
                              widget.categoryImageMomPage,
                              categoryImageDad,
                              widget.uid,
                              widget.user);
                        }));
                      },
                      child: new Text('From Gallery',
                          style: TextStyle(fontSize: 16, color: Colors.white)))
                ],
              ),
            ],
          );
        });
  }

  CircleAvatar imageFileBig() {
    if (widget.user == "kid") {
      return CircleAvatar(
        radius: 45,
        child: ClipOval(
          child: Image.network(
            widget.image,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else
      return CircleAvatar(
        radius: 45,
        backgroundImage: FileImage(File(widget.image)),
      );
  }

  CircleAvatar imageFileBigMom() {
    if (widget.user == "mom") {
      return CircleAvatar(
        radius: 45,
        child: ClipOval(
          child: Image.network(
            widget.imageMom,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else
      return CircleAvatar(
        radius: 45,
        backgroundImage: FileImage(File(widget.imageMom)),
      );
  }

  CircleAvatar imageFileBigDad() {
    if (widget.user == "dad") {
      return CircleAvatar(
        radius: 45,
        child: ClipOval(
          child: Image.network(
            widget.imageDad,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else
      return CircleAvatar(
        radius: 45,
        backgroundImage: FileImage(File(widget.imageDad)),
      );
  }

  Form _buildForm() {
    return Form(
        key: _formKey,
        child: SizedBox(
          height: 900,
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                  Colors.purple[200],
                  Color.fromRGBO(0, 41, 102, 41)
                ])),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 0, 30),
                      child: Stack(
                        children: <Widget>[
                          imageFileBig(),
                          widget.user == "kid"
                              ? Text(" ")
                              : ClipOval(
                                  child: Material(
                                    color: Colors.green,
                                    child: InkWell(
                                      onTap: () {
                                        _chooseCatergoryTakePicture();
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    //mom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                      child: Stack(
                        children: <Widget>[
                          imageFileBigMom(),
                          widget.user == "mom"
                              ? Text(" ")
                              : ClipOval(
                                  child: Material(
                                    color: Colors.green,
                                    child: InkWell(
                                      onTap: () {
                                        _chooseCatergoryTakePictureMom();
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    //dad
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 15, 30),
                      child: Stack(
                        children: <Widget>[
                          imageFileBigDad(),
                          widget.user == "dad"
                              ? Text(" ")
                              : ClipOval(
                                  child: Material(
                                    color: Colors.green,
                                    child: InkWell(
                                      onTap: () {
                                        _chooseCatergoryTakePictureDad();
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
                        child: Container(
                          height: 70,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Name *',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Name cannot be empty';
                                    } else if (value.length < 3) {
                                      return 'Name must be at least 3 characters long.';
                                    } else if (value.length < 3) {
                                      return 'Do not use the @ char';
                                    }
                                    name = value;
                                    return null;
                                  },
                                )),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border:
                                  Border.all(width: 1.0, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 4),
                        child: Container(
                          height: 70,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text("${selectedDate.toLocal()}"
                                      .split(' ')[0]),
                                  SizedBox(
                                    width: 120.0,
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _selectDate(context),
                                    child: Text('Select date'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border:
                                  Border.all(width: 1.0, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
                        child: Container(
                          height: 70,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: ' Address *',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Address cannot be empty';
                                    } else if (value.length < 3) {
                                      return 'Address must be at least 3 characters long.';
                                    }
                                    address = value;
                                    return null;
                                  },
                                )),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border:
                                  Border.all(width: 1.0, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
                        child: Container(
                          height: 70,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: ' Mother Name *',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Name cannot be empty';
                                    } else if (value.length < 3) {
                                      return 'Name must be at least 3 characters long.';
                                    } else if (value.length < 3) {
                                      return 'Do not use the @ char';
                                    }
                                    momName = value;
                                    return null;
                                  },
                                )),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border:
                                  Border.all(width: 1.0, color: Colors.grey)),
                        ),
                      ),
                      //MOBILE
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
                        child: Container(
                          height: 70,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: ' Mother Phone No. *',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Mobile Phone cannot be empty';
                                    } else if (value.length != 10) {
                                      return 'Mobile Phone must 10 digits';
                                    }
                                    momPhone = value;
                                    return null;
                                  },
                                )),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border:
                                  Border.all(width: 1.0, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
                        child: Container(
                          height: 70,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: ' Father Name *',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Name cannot be empty';
                                    } else if (value.length < 3) {
                                      return 'Name must be at least 3 characters long.';
                                    } else if (value.length < 3) {
                                      return 'Do not use the @ char';
                                    }
                                    dadName = value;
                                    return null;
                                  },
                                )),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border:
                                  Border.all(width: 1.0, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 4),
                        child: Container(
                          height: 70,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: ' Father Phone No. *',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Mobile Phone cannot be empty';
                                    } else if (value.length != 10) {
                                      return 'Mobile Phone must 10 digits';
                                    }
                                    dadPhone = value;
                                    return null;
                                  },
                                )),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border:
                                  Border.all(width: 1.0, color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ))
              ],
            ),
          ),
        ));
  }
}
