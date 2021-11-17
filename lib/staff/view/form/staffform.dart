import 'package:face_recognition/staff/model/staff.dart';
import 'package:face_recognition/staff/view/form/showPictureGaleery.dart';
import 'package:face_recognition/picture/model/recognize_face.dart';
import 'package:face_recognition/picture/service/recognizeFaceService.dart';
import 'package:face_recognition/picture/view/staff/staffCameraPage.dart';

import 'package:flutter/material.dart';
import 'package:face_recognition/staff/controller/staff_service.dart';
import '../../../loading.dart';
import '../liststaff.dart';
import 'dart:io';

//firebase
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

//upload gallery
import 'package:image_picker/image_picker.dart';

import 'package:awesome_dialog/awesome_dialog.dart';

//new staff profile
class StaffForm extends StatefulWidget {
  StaffForm(this.image, this.dataFace);

  final dynamic dataFace;
  final String image;

  @override
  _StaffFormState createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffForm> {
  final String galleryDB = "01Gallery";
  //categoryChoose
  int categoryImage;

  //dataFace
  dynamic dataFaceDB = {};

  dynamic dataFaceKey = {};
  String email;
  List<RecognizeFace> face;
  //go to widget face
  int i = 0;

  String name;
  Staff newstaff;
  String password;
  String phoneNo;
  String address;
  //firebase storage
  firebase_storage.Reference ref;

  DateTime selectedDate = DateTime.now();
  List<Staff> staff;

  String staffId;
  String uidFace;

  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  //uploadGallery
  String _imageFile;

  final _passwordController = TextEditingController();
  ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    i = 0;
    super.dispose();
  }

//saveRecognizeFace
  Future saveFile() async {
    //problem
    dataFaceDB[name.toUpperCase()] = widget.dataFace;

    print("in set state $dataFaceDB");

    print("in database dataface");
    return RecognizeFaceService().createNewImage(dataFaceDB);
  }

  Future saveStaffFile() async {
    print("create new staff");

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('staffImages/${widget.image}}');

    staffId = "S0${staff.length + 1}";

    return ref.putFile(File(widget.image)).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        StaffService().createNewStaff(staffId.trim(), password.trim(), value,
            name.trim(), phoneNo.trim(), email.trim(), address, uidFace);
      });
    });
  }

  //imageGallery
  Future saveStaffFileGallery() async {
    print("create new staff");

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('staffImagesGallery/${widget.image}');

    staffId = "S0${staff.length + 1}";

    return ref.putFile(File(widget.image)).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        StaffService().createNewStaff(staffId.trim(), password.trim(), value,
            name.trim(), phoneNo.trim(), email.trim(), address, galleryDB);
      });
    });
  }

//cancel staff detail
  void alertSaveImage() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('ALERT!',
                style: TextStyle(fontSize: 30, color: Colors.black)),
            content: new Text('Are you sure to cancel Staff Details?'),
            actions: <Widget>[
              new ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) {
                      return StaffList();
                    }));
                  },
                  child: new Text('Yes',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.red,
                          fontWeight: FontWeight.bold))),
              new ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text('No',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.green,
                          fontWeight: FontWeight.bold)))
            ],
          );
        });
  }

  void _chooseCatergoryTakePicture() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
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
                          categoryImage = 1;
                        });
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return StaffCameraPage();
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
                            categoryImage = 2;
                            print("Image path $_imageFile");
                          });
                        }
                        // _showImageGallery();
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return ShowImageGalleryNew(_imageFile);
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

  //form edit
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
              Padding(
                padding: const EdgeInsets.fromLTRB(120, 20, 0, 30),
                child: Stack(
                  children: <Widget>[
                    imageFileBig(),
                    //staff Camera
                    ClipOval(
                      child: Material(
                        color: Colors.green,
                        child: InkWell(
                          onTap: () {
                            _chooseCatergoryTakePicture();
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
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
                                enabled: false,
                                initialValue: "S0${staff.length + 1}",
                                decoration: const InputDecoration(
                                  labelText: 'Staff ID',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                              )),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(width: 1.0, color: Colors.grey)),
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
                                enabled: true,
                                initialValue: password,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  RegExp regExHighLow =
                                      new RegExp(r"(?=.*[A-Z])(?=.*[a-z])\w+");
                                  RegExp regExHigh =
                                      new RegExp(r"(?=.*[A-Z])\w+");
                                  RegExp regExLow =
                                      new RegExp(r"(?=.*[a-z])\w+");
                                  RegExp numberExp =
                                      new RegExp(r"(?=.*[0-9])\w+");
                                  // RegExp numExp2 = new RegExp("");
                                  if (value.isEmpty) {
                                    return 'Password cannot be empty';
                                  } else if (value.length < 4) {
                                    return 'Password must be at least 4 characters long.';
                                  } else if (value.length > 10) {
                                    return 'Maximum password is 10.';
                                  } else if ((regExHighLow.hasMatch(value) ||
                                          regExHigh.hasMatch(value) ||
                                          regExLow.hasMatch(value)) &&
                                      numberExp.hasMatch(value)) {
                                    password = value;
                                    return null;
                                  } else
                                    return 'Must at least 2 characters and 2 numbers';
                                },
                              )),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(width: 1.0, color: Colors.grey)),
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
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(width: 1.0, color: Colors.grey)),
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
                                  labelText: ' Phone No. *',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Phone number cannot be empty';
                                  } else if (value.length != 10) {
                                    return 'Phone number must be 10 characters long.';
                                  }
                                  phoneNo = value;
                                  return null;
                                },
                              )),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(width: 1.0, color: Colors.grey)),
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
                                  } else {
                                    address = value;
                                    return null;
                                  }
                                },
                              )),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(width: 1.0, color: Colors.grey)),
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
                                  labelText: ' Email',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    email = "noEmail@gmail.com";
                                    return null;
                                  } else if (!value.contains("@")) {
                                    return "Please enter @";
                                  } else {
                                    email = value;
                                    return null;
                                  }
                                },
                              )),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(width: 1.0, color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  //image circle
  CircleAvatar imageFileBig() {
    if (widget.image == "assets/image/people.png") {
      return CircleAvatar(
        radius: 70,
        child: ClipOval(
          child: Image.asset(
            widget.image,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else
      return CircleAvatar(
        radius: 70,
        backgroundImage: FileImage(File(widget.image)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: Text('Staff Form'),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // _showAlertDialog();
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.WARNING,
                    headerAnimationLoop: false,
                    animType: AnimType.TOPSLIDE,
                    showCloseIcon: true,
                    closeIcon: Icon(Icons.close_fullscreen_outlined),
                    title: 'Warning',
                    desc: 'Are you sure to cancel staff details?',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (_) {
                        return StaffList();
                      }));
                    })
                  ..show();
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Staff>>(
          stream: StaffService().listStaff(),
          builder: (context, snapshot1) {
            if (i == 1) {
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
                        }
                      }

                      if (i == 1) {
                        i = 3;

                        saveFile();
                      }

                      if (i == 3) {
                        i = 2;
                        saveStaffFile();
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
            if (i == 2) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  return StaffList();
                })),
              );
            }
            if (i == 4) {
              i = 2;
              saveStaffFileGallery();
              return Loading();
            } else
              switch (snapshot1.connectionState) {
                case ConnectionState.none:
                  return Loading();
                case ConnectionState.waiting:
                  return Loading();
                case ConnectionState.active:
                  staff = snapshot1.data;
                  print("staff form $staff");
                  return _buildForm();
                  break;
                case ConnectionState.done:
                  return Loading();
              }
            return Container();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate() &&
              widget.image != "assets/image/people.png") {
            debugPrint('Staff data is saved');

            if (categoryImage == 2) {
              setState(() {
                i = 4;
              });
            } else {
              setState(() {
                i = 1;
              });
            }
          }
        },
        child: Icon(Icons.done),
      ),
    );
  }
}
