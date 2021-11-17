import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:face_recognition/picture/model/recognize_face.dart';
import 'package:face_recognition/picture/service/recognizeFaceService.dart';
import 'package:face_recognition/picture/view/staff/staffCameraEditPage.dart';
import 'package:face_recognition/staff/model/staff.dart';
import 'package:face_recognition/staff/controller/staff_service.dart';
import 'package:face_recognition/staff/view/form/showPictureGalleryEdit.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../error.dart';
import '../../../loading.dart';
import '../liststaff.dart';

//edit staff profile
class ProfileStaffData extends StatefulWidget {
  ProfileStaffData(this.image, this.dataFace, this.categoryImage, this.staffID);

  final int categoryImage;
  final dynamic dataFace;
  final String image;
  final String staffID;

  @override
  _ProfileStaffDataState createState() => _ProfileStaffDataState();
}

class _ProfileStaffDataState extends State<ProfileStaffData> {
  int categoryImageLocal = 0;
  //to save this staff dataFace
  dynamic dataFaceKeys = {};

  final String empty = " ";
  //profile only
  bool enable = false;

  //dataFace
  List<RecognizeFace> faces;

  final String galleryDB = "01Gallery";
  var icon = Icons.edit;

  int widgetBuild = 0;
  int index;

  final String noEmailStaff = "noEmail@gmail.com";
  TextEditingController name = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController image = new TextEditingController();
  TextEditingController phoneNo = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController address = new TextEditingController();
  //firebase storage
  firebase_storage.Reference ref;
  List<Staff> staff;

  String staffId;
  String title = "Profile";

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
    password.dispose();
    image.dispose();
    name.dispose();
    phoneNo..dispose();
    email.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
                          categoryImageLocal = 1;
                        });
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return StaffCameraEditPage(
                              index,
                              widget.image,
                              widget.dataFace,
                              categoryImageLocal,
                              widget.staffID);
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
                            categoryImageLocal = 2;
                            print("Image path $_imageFile");
                          });
                        }
                        // _showImageGallery();
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return ShowImageGalleryEdit(_imageFile, index,
                              categoryImageLocal, widget.staffID);
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

  Form _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
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
                    enable == true
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
                                  size: 50,
                                ),
                              ),
                            ),
                          )
                        : Text(" ")
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
                                initialValue: staff[index].staffID,
                                decoration: const InputDecoration(
                                  labelText: 'Staff ID *',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Staff ID cannot be empty';
                                  } else if (value.length < 3) {
                                    return 'Staff ID must be at least 3 characters long.';
                                  } else if (value.length < 3) {
                                    return 'Staff ID not use the @ char';
                                  }
                                  staffId = value;
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
                                // initialValue: staff[widget.index].password,
                                enabled: enable,
                                controller: password,
                                decoration: const InputDecoration(
                                  labelText: 'Password *',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Password cannot be empty';
                                  } else if (value.length < 3) {
                                    return 'Password must be at least 3 characters long.';
                                  }
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
                                // initialValue: staff[widget.index].name,
                                enabled: enable,
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
                                // initialValue: staff[widget.index].phoneNo,
                                enabled: enable,
                                controller: phoneNo,
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
                                enabled: enable,
                                controller: address,
                                decoration: const InputDecoration(
                                  labelText: ' Address *',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Address cannot be empty';
                                  } else {
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
                                enabled: enable,
                                controller: email,
                                decoration: const InputDecoration(
                                  labelText: ' Email',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return null;
                                  } else if (value == empty) {
                                    return null;
                                  } else if (!value.contains("@")) {
                                    return "Please enter @";
                                  } else {
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
    if (widget.image == staff[index].image) {
      return CircleAvatar(
        radius: 70,
        child: ClipOval(
          child: Image.network(
            widget.image,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else
      return CircleAvatar(
          radius: 70, backgroundImage: FileImage(File(widget.image)));
  }

//saveFile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: Text('Staff $title'),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                if (enable == true) {
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
                        setState(() {
                          enable = false;
                          icon = Icons.edit;
                          title = "Profile";
                          print("enter SETSTATE ENABLE FALSE");
                        });
                      })
                    ..show();
                } else {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) {
                    return StaffList();
                  }));
                }
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Staff>>(
          stream: StaffService().listStaff(),
          builder: (context, snapshot) {
            print("enter recognizeFaceWidget 2");
            return StreamBuilder<List<RecognizeFace>>(
              stream: RecognizeFaceService().listFaceImage(),
              builder: (context, AsyncSnapshot<List<RecognizeFace>> snapshot2) {
                if (!snapshot.hasData) {
                  return Loading();
                }
                if (snapshot.hasError) {
                  return ErrorPage();
                }
                staff = snapshot.data;
                for (int j = 0; j < staff.length; j++) {
                  print("masuk for ${widget.staffID}");
                  if (staff[j].staffID == widget.staffID) {
                    index = j;
                    print("masuk if $index");
                  }
                }
                password.text = staff[index].password;
                image.text = staff[index].image;
                name.text = staff[index].name;
                phoneNo.text = staff[index].phoneNo;
                staff[index].email == noEmailStaff
                    ? email.text = empty
                    : email.text = staff[index].email;
                address.text = staff[index].address;

                switch (snapshot2.connectionState) {
                  case ConnectionState.none:
                    return Loading();
                  case ConnectionState.waiting:
                    return Loading();
                  case ConnectionState.active:
                    faces = snapshot2.data;
                    print("Face length to for loop ${faces.length} 2");

                    for (int j = 0; j < faces.length; j++) {
                      print("in loop face 2");
                      // dataFaceKey = face[j].dataFace;
                      print(
                          " staff index face ${staff[index].faceID} while face id ${faces[j].uid} ");
                      if (staff[index].faceID == faces[j].uid) {
                        dataFaceKeys = faces[j].dataFace;
                        print("datafacekey loop $dataFaceKeys");

                        break;
                      }
                    }
                    return _buildForm();
                    break;

                  case ConnectionState.done:
                    return Loading();
                }
                return null;
              },
            );
            // }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate() && enable == true) {
            debugPrint('Staff data is saved');
            print("categoryImage ${widget.categoryImage}");
            print("face id = ${staff[index].faceID}");
            print("password ${password.text}");

            setState(() {
              enable = false;
              title = "Profile";
              icon = Icons.edit;
            });

            // update picture
            if (widget.categoryImage == 1) {
              setState(() async {
                dataFaceKeys[name.text.toUpperCase()] = widget.dataFace;
                print("in set state $dataFaceKeys");

                await RecognizeFaceService().updateRecognizeFaceImage(
                    staff[index].faceID, dataFaceKeys);
                ref = firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child('staffImages/${widget.image}}');

                ref.putFile(File(widget.image)).whenComplete(() async {
                  await ref.getDownloadURL().then((value) {
                    StaffService().updateStaff(
                      staff[index].uid,
                      staffId.trim(),
                      password.text.trim(),
                      value,
                      name.text.trim(),
                      phoneNo.text.trim(),
                      email.text.isEmpty || email.text == empty
                          ? noEmailStaff
                          : email.text.trim(),
                      address.text.trim(),
                      staff[index].faceID,
                    );
                  });
                });
              });
            }
            //uploadfile
            else if (widget.categoryImage == 2) {
              setState(() async {
                ref = firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child('staffImagesGallery/${widget.image}');

                ref.putFile(File(widget.image)).whenComplete(() async {
                  await ref.getDownloadURL().then((value) {
                    StaffService().updateStaff(
                      staff[index].uid,
                      staffId.trim(),
                      password.text.trim(),
                      value,
                      name.text.trim(),
                      phoneNo.text.trim(),
                      email.text.isEmpty || email.text == empty
                          ? noEmailStaff
                          : email.text.trim(),
                      address.text.trim(),
                      galleryDB,
                    );
                  });
                });
              });
            }
            //tak upload tpi guna gallery image
            else if (staff[index].faceID == galleryDB) {
              print("gallery here");
              setState(() {
                StaffService().updateStaff(
                    staff[index].uid,
                    staffId.trim(),
                    password.text.trim(),
                    widget.image,
                    name.text.trim(),
                    phoneNo.text.trim(),
                    email.text.isEmpty || email.text == empty
                        ? noEmailStaff
                        : email.text.trim(),
                    address.text.trim(),
                    galleryDB);
              });
            } else {
              StaffService().updateStaff(
                  staff[index].uid,
                  staffId.trim(),
                  password.text.trim(),
                  widget.image,
                  name.text.trim(),
                  phoneNo.text.trim(),
                  email.text.isEmpty || email.text == empty
                      ? noEmailStaff
                      : email.text.trim(),
                  address.text.trim(),
                  staff[index].faceID);
            }
          } else {
            print("enter here enable false");
            setState(() {
              widgetBuild = 1;
              enable = true;
              icon = Icons.done;
              title = "Form";
              print("enter SETSTATE ENABLE FALSE");
            });
          }
        },
        child: Icon(icon),
      ),
    );
  }
}
