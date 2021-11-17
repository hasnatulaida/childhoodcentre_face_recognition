import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:face_recognition/kid/model/kid2.dart';
import 'package:face_recognition/kid/controller/kid_service2.dart';
import 'package:face_recognition/picture/model/recognize_face.dart';
import 'package:face_recognition/picture/service/recognizeFaceService.dart';
import 'package:face_recognition/picture/view/kid/kidCameraPage.dart';
import 'package:face_recognition/picture/view/kid/kidCameraPageDad.dart';
import 'package:face_recognition/picture/view/kid/kidCameraPageMom.dart';
import 'package:face_recognition/picture/view/kid/showImageGalleryDad.dart';
import 'package:face_recognition/picture/view/kid/showImageGalleryNewKid.dart';
import 'package:face_recognition/picture/view/kid/showImageGalleryNewMom.dart';
//firebase
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
//upload gallery
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../loading.dart';
import 'listviewkid.dart';

//new kid profile
class ProfileKidView extends StatefulWidget {
  ProfileKidView(
      this.dataFace,
      this.dataFaceMom,
      this.dataFaceDad,
      this.image,
      this.imageMom,
      this.imageDad,
      this.categoryImagePage,
      this.categoryImageMomPage,
      this.categoryImageDadPage,
      this.kidID,
      this.enable,
      this.kidDate);

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
  final String kidID;
  final bool enable;
  final DateTime kidDate;

  @override
  _ProfileKidViewState createState() => _ProfileKidViewState();
}

class _ProfileKidViewState extends State<ProfileKidView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  List<Kid2> kid;
  String email;
  DateTime selectedDate = DateTime.now();
  TextEditingController name = new TextEditingController();
  TextEditingController address = new TextEditingController();
  TextEditingController momName = new TextEditingController();
  TextEditingController momPhone = new TextEditingController();
  TextEditingController dadName = new TextEditingController();
  TextEditingController dadPhone = new TextEditingController();
  TextEditingController date = new TextEditingController();

  final String galleryDB = "01Gallery";
  final String navigate = "profile";
  String title;
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

  List<RecognizeFace> face;

  String uidFace;
  String uidFaceMom;
  String uidFaceDad;

  //firebase storage
  firebase_storage.Reference ref;
  firebase_storage.Reference refMom;
  firebase_storage.Reference refDad;

  var icon;
  int indexKid;
  bool enableLocal;

  @override
  void initState() {
    enableLocal = widget.enable;
    enableLocal == true ? icon = Icons.done : icon = Icons.edit;
    enableLocal == true ? title = "Form" : title = "Profile";
    date..text = DateFormat('dd-MM-yyyy').format(widget.kidDate);
    super.initState();
  }

  @override
  void dispose() {
    print("Masuk dispose");
    databaseChoice = 0;
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    name.dispose();
    address.dispose();
    momName.dispose();
    momPhone.dispose();
    dadName.dispose();
    dadPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: Text('Kid $title'),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                if (enableLocal == true) {
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
                          return KidList();
                        }));
                      })
                    ..show();
                } else
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) {
                    return KidList();
                  }));
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Kid2>>(
          stream: KidDatabaseService2().listKid(),
          builder: (context, snapshot1) {
            return StreamBuilder<List<RecognizeFace>>(
              stream: RecognizeFaceService().listFaceImage(),
              builder: (context, AsyncSnapshot<List<RecognizeFace>> snapshot2) {
                //snapshot 1 = kid
                switch (snapshot1.connectionState) {
                  case ConnectionState.none:
                    return Loading();
                  case ConnectionState.waiting:
                    return Loading();
                  case ConnectionState.active:
                    kid = snapshot1.data;
                    print("kid form $kid");
                    for (int j = 0; j < kid.length; j++) {
                      print("masuk for ${widget.kidID}");
                      if (kid[j].kidID == widget.kidID) {
                        indexKid = j;
                        print("masuk if $indexKid");
                      }
                    }
                    name.text = kid[indexKid].name;
                    address.text = kid[indexKid].address;
                    momName.text = kid[indexKid].momName;
                    momPhone.text = kid[indexKid].momPhone;
                    dadName.text = kid[indexKid].dadName;
                    dadPhone.text = kid[indexKid].dadPhone;
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
                              name.text.toUpperCase()) {
                            uidFace = face[h].uid;
                            print("uid is $uidFace");
                          }
                        }

                        return _buildForm();
                        break;

                      case ConnectionState.done:
                        return Loading();
                    }

                    break;
                  case ConnectionState.done:
                    return Loading();
                }
                return Container();
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate() && enableLocal == true) {
            debugPrint('Kid data is saved');
            setState(() {
              icon = Icons.edit;
              enableLocal = false;
              title = "Profile";
            });
            if (widget.categoryImagePage == 2 ||
                widget.categoryImageMomPage == 2 ||
                widget.categoryImageDadPage == 2) {
              print("DatabaseChoice ${widget.categoryImagePage}");
              saveKidFile();
            } else if (widget.categoryImagePage == 1 &&
                widget.categoryImageMomPage == 1 &&
                widget.categoryImageDadPage == 1) {
              print("DatabaseChoice ${widget.categoryImagePage}");
              saveKidFileDataface();
              saveMomFileDataface();
              saveDadFileDataface();
              saveKidCamera();
            } else if (kid[indexKid].faceID == galleryDB) {
              KidDatabaseService2().updateKid(
                  widget.kidID,
                  name.text.trim(),
                  selectedDate,
                  address.text.trim(),
                  momName.text.trim(),
                  momPhone.text.trim(),
                  dadName.text.trim(),
                  dadPhone.text.trim(),
                  galleryDB,
                  galleryDB,
                  galleryDB,
                  kid[indexKid].kidImage,
                  kid[indexKid].momImage,
                  kid[indexKid].dadImage);
            } else {
              KidDatabaseService2().updateKid(
                  widget.kidID,
                  name.text.trim(),
                  selectedDate,
                  address.text.trim(),
                  momName.text.trim(),
                  momPhone.text.trim(),
                  dadName.text.trim(),
                  dadPhone.text.trim(),
                  kid[indexKid].faceID,
                  kid[indexKid].faceIDMom,
                  kid[indexKid].faceIDDad,
                  kid[indexKid].kidImage,
                  kid[indexKid].momImage,
                  kid[indexKid].dadImage);
            }
          } else
            setState(() {
              enableLocal = true;
              icon = Icons.done;
              title = "Form";
            });
        },
        child: Icon(icon),
      ),
    );
  }

  //saveRecognizeFace
  Future saveKidFileDataface() async {
    dataFaceDB[name.text.toUpperCase()] = widget.dataFace;

    print("in set state $dataFaceDB");

    print("in database dataface");
    return RecognizeFaceService().createNewImage(dataFaceDB);
  }

  Future saveMomFileDataface() async {
    dataFaceDBMom[name.text.toUpperCase()] = widget.dataFaceMom;

    print("in set state $dataFaceDBMom");

    print("in database dataface");
    return RecognizeFaceService().createNewImage(dataFaceDBMom);
  }

  Future saveDadFileDataface() async {
    dataFaceDBDad[name.text.toUpperCase()] = widget.dataFaceDad;

    print("in set state $dataFaceDBDad");

    print("in database dataface");
    return RecognizeFaceService().createNewImage(dataFaceDBDad);
  }

  Future saveKidFile() async {
    print("create new kid");

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('kidImages/${widget.image}}');

    ref.putFile(File(widget.image)).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        print("Kid Global $value");
        saveMomFile(value);
      });
    });
  }

  Future saveMomFile(String kidValue) async {
    print("create new mom image $kidValue");
    refMom = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('momImages/${widget.imageMom}}');

    return refMom.putFile(File(widget.imageMom)).whenComplete(() async {
      await refMom.getDownloadURL().then((value) {
        print("Kid Global Mom $value");
        saveDadFile(kidValue, value);
      });
    });
  }

  Future saveDadFile(String kidValue, String momValue) async {
    print("save dad file image $kidValue and $momValue");
    refDad = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('dadImages/${widget.imageDad}}');

    return refDad.putFile(File(widget.imageDad)).whenComplete(() async {
      await refDad.getDownloadURL().then((value) {
        print("Kid Global Dad $value");
        return KidDatabaseService2().updateKid(
            widget.kidID,
            name.text.trim(),
            selectedDate,
            address.text.trim(),
            momName.text.trim(),
            momPhone.text.trim(),
            dadName.text.trim(),
            dadPhone.text.trim(),
            galleryDB,
            galleryDB,
            galleryDB,
            kidValue,
            momValue,
            value);
      });
    });
  }

//CAMERA

  Future saveKidCamera() async {
    print("create new kid");

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('kidImages/${widget.image}}');

    ref.putFile(File(widget.image)).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        // kidImageFile = value;
        print("Kid Global $value");
        saveMomCamera(value);
      });
    });
  }

  Future saveMomCamera(String kidValue) async {
    print("create new mom image $kidValue");
    refMom = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('momImages/${widget.imageMom}}');

    return refMom.putFile(File(widget.imageMom)).whenComplete(() async {
      await refMom.getDownloadURL().then((value) {
        // momImageFile = value;

        print("Kid Global Mom $value and kid $kidValue");
        saveDadCamera(kidValue, value);
      });
    });
  }

  Future saveDadCamera(String kidValue, String momValue) async {
    print("save dad file image $kidValue and $momValue");
    refDad = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('dadImages/${widget.imageDad}}');

    return refDad.putFile(File(widget.imageDad)).whenComplete(() async {
      await refDad.getDownloadURL().then((value) {
        print("Kid Global Dad $value , mom $momValue and kid $kidValue");

        return KidDatabaseService2().updateKid(
            widget.kidID,
            name.text.trim(),
            selectedDate,
            address.text.trim(),
            momName.text.trim(),
            momPhone.text.trim(),
            dadName.text.trim(),
            dadPhone.text.trim(),
            uidFace,
            uidFaceMom,
            uidFaceDad,
            kidValue,
            momValue,
            value);
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate != null ? selectedDate : DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        date
          ..text = DateFormat('dd-MM-yyyy').format(selectedDate)
          ..selection = TextSelection.fromPosition(TextPosition(
              offset: date.text.length, affinity: TextAffinity.upstream));
      });
  }

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
                          return KidCameraPage(
                              widget.dataFace,
                              widget.dataFaceMom,
                              widget.dataFaceDad,
                              widget.image,
                              widget.imageMom,
                              widget.imageDad,
                              categoryImageKid,
                              widget.categoryImageMomPage,
                              widget.categoryImageDadPage,
                              navigate,
                              widget.kidID,
                              widget.kidDate);
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
                          return ShowImageGalleryNewKid(
                              _imageFile,
                              widget.imageMom,
                              widget.imageDad,
                              categoryImageKid,
                              widget.categoryImageMomPage,
                              widget.categoryImageDadPage,
                              navigate,
                              widget.kidID,
                              widget.kidDate);
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
                          return KidCameraPageMom(
                              widget.dataFace,
                              widget.dataFaceMom,
                              widget.dataFaceDad,
                              widget.image,
                              widget.imageMom,
                              widget.imageDad,
                              widget.categoryImagePage,
                              categoryImageMom,
                              widget.categoryImageDadPage,
                              navigate,
                              widget.kidID,
                              widget.kidDate);
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
                        // _showImageGallery();
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return ShowImageGalleryNewMom(
                              widget.image,
                              _imageFileMom,
                              widget.imageDad,
                              widget.categoryImagePage,
                              categoryImageMom,
                              widget.categoryImageDadPage,
                              navigate,
                              widget.kidID,
                              widget.kidDate);
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
                          return KidCameraPageDad(
                              widget.dataFace,
                              widget.dataFaceMom,
                              widget.dataFaceDad,
                              widget.image,
                              widget.imageMom,
                              widget.imageDad,
                              widget.categoryImagePage,
                              widget.categoryImageMomPage,
                              categoryImageDad,
                              navigate,
                              widget.kidID,
                              widget.kidDate);
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
                        // _showImageGallery();
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return ShowImageGalleryNewDad(
                              widget.image,
                              widget.imageMom,
                              _imageFileDad,
                              widget.categoryImagePage,
                              widget.categoryImageMomPage,
                              categoryImageDad,
                              navigate,
                              widget.kidID,
                              widget.kidDate);
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
    if (widget.image == kid[indexKid].kidImage) {
      return CircleAvatar(
        radius: 45,
        child: ClipOval(
          child: Image.network(
            kid[indexKid].kidImage,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else
      return CircleAvatar(
          radius: 45, backgroundImage: FileImage(File(widget.image)));
  }

  CircleAvatar imageFileBigMom() {
    if (widget.imageMom == kid[indexKid].momImage) {
      return CircleAvatar(
        radius: 45,
        child: ClipOval(
          child: Image.network(
            kid[indexKid].momImage,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else
      //use when edit picture
      return CircleAvatar(
        radius: 45,
        backgroundImage: FileImage(File(widget.imageMom)),
      );
  }

  CircleAvatar imageFileBigDad() {
    if (widget.imageDad == kid[indexKid].dadImage) {
      return CircleAvatar(
        radius: 45,
        child: ClipOval(
          child: Image.network(
            kid[indexKid].dadImage,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else
      //use when edit picture
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
                          enableLocal == true
                              ? ClipOval(
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
                                )
                              : Text(" "),
                        ],
                      ),
                    ),
                    //mom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                      child: Stack(
                        children: <Widget>[
                          imageFileBigMom(),
                          enableLocal == true
                              ? ClipOval(
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
                                )
                              : Text(" "),
                        ],
                      ),
                    ),
                    //dad
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 15, 30),
                      child: Stack(
                        children: <Widget>[
                          imageFileBigDad(),
                          enableLocal == true
                              ? ClipOval(
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
                                )
                              : Text(" "),
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
                                  enabled: enableLocal,
                                  // initialValue: kid[indexKid].name,
                                  controller: name,
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
                                    enabled: enableLocal,
                                    // initialValue: kid[indexKid].address,
                                    focusNode: AlwaysDisabledFocusNode(),
                                    controller: date,
                                    decoration: const InputDecoration(
                                      labelText: ' Registration date',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      icon: Icon(Icons.calendar_today),
                                    ),
                                    onTap: () {
                                      _selectDate(context);
                                    })),
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
                                  enabled: enableLocal,
                                  // initialValue: kid[indexKid].address,
                                  controller: address,
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
                                  enabled: enableLocal,
                                  // initialValue: kid[indexKid].momName,
                                  controller: momName,
                                  decoration: const InputDecoration(
                                    labelText: ' Mother Name *',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Name cannot be empty';
                                    } else if (value.length < 3) {
                                      return 'Name must be at least 4 characters long.';
                                    } else if (value.length < 3) {
                                      return 'Do not use the @ char';
                                    }
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
                                  enabled: enableLocal,
                                  // initialValue: kid[indexKid].momPhone,
                                  controller: momPhone,
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
                                    // momPhone = value;
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
                                  enabled: enableLocal,
                                  controller: dadName,
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
                                  enabled: enableLocal,
                                  controller: dadPhone,
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

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
