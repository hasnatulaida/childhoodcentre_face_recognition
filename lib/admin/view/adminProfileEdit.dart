import 'dart:io';
import 'package:face_recognition/admin/controller/adminHandler.dart';
import 'package:face_recognition/admin/model/admin.dart';
import 'package:face_recognition/picture/service/recognizeFaceService.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import '../../loading.dart';
import 'adminCamera.dart';
import 'adminGalleryImage.dart';
import 'adminProfile.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AdminProfileEdit extends StatefulWidget {
  final String image;
  //admin profile pass id
  final dynamic dataFace;
  final int categoryImage;
  AdminProfileEdit(this.image, this.dataFace, this.categoryImage);
  @override
  _AdminProfileEditState createState() => _AdminProfileEditState();
}

class _AdminProfileEditState extends State<AdminProfileEdit> {
  int i = 0;
  int index = 0;
  int categoryImageLocal = 0;

  TextEditingController name = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController phoneNo = new TextEditingController();

  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  final String galleryDB = "01Gallery";

  List<Admin> admin;
  String _imageFile;
  ImagePicker _picker = ImagePicker();

  //FACE
  dynamic dataFaceKeys = {};
  firebase_storage.Reference ref;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    i = 0;
    super.dispose();
  }

  CircleAvatar imageFileBig() {
    if (widget.image == admin[index].image) {
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
                                initialValue: admin[index].adminID,
                                decoration: const InputDecoration(
                                  labelText: 'Admin ID',
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
                                // initialValue: admin[index].password,
                                controller: password,
                                decoration: const InputDecoration(
                                  labelText: 'Password *',
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
                                  } else {
                                    print("masuk name here");
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
                                  admin[index].phoneNo = value;
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
                                // initialValue: admin[0].email,
                                controller: email,
                                decoration: const InputDecoration(
                                  labelText: ' Email *',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Email cannot be empty";
                                  }
                                  if (!value.contains("@")) {
                                    return 'Email must has @';
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
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Admin Profile Edit");
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: Text('Admin Profile'),
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
                    desc: 'Are you sure to cancel admin details?',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (_) {
                        return AdminProfile();
                      }));
                    })
                  ..show();
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Admin>>(
          stream: AdminHandler().listAdmin(),
          builder: (context, snapshot1) {
            switch (snapshot1.connectionState) {
              case ConnectionState.none:
                return Loading();
              case ConnectionState.waiting:
                return Loading();
              case ConnectionState.active:
                admin = snapshot1.data;
                print("Admin form $admin");
                name.text = admin[index].name;
                email.text = admin[index].email;
                password.text = admin[index].password;
                phoneNo.text = admin[index].phoneNo;
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
            debugPrint('Admin data is saved');

            if (widget.categoryImage == 1) {
              setState(() async {
                dataFaceKeys[name.text.toUpperCase()] = widget.dataFace;
                print("in set state $dataFaceKeys");

                await RecognizeFaceService().updateRecognizeFaceImage(
                    admin[index].faceID, dataFaceKeys);
                ref = firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child('adminImages/${widget.image}}');

                ref.putFile(File(widget.image)).whenComplete(() async {
                  await ref.getDownloadURL().then((value) {
                    print("Admin FLOAT update $name");
                    AdminHandler()
                        .updateAdmin(
                            name.text.trim(),
                            value,
                            password.text.trim(),
                            email.text.trim(),
                            phoneNo.text.trim(),
                            admin[index].adminID,
                            admin[index].faceID,
                            admin[index].uid)
                        .whenComplete(
                          () => Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(builder: (_) {
                            return AdminProfile();
                          })),
                        );
                  });
                });
              });
            } else if (widget.categoryImage == 2) {
              setState(() {
                ref = firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child('adminImages/${widget.image}}');

                ref.putFile(File(widget.image)).whenComplete(() async {
                  await ref.getDownloadURL().then((value) {
                    print("Admin FLOAT update $name");
                    AdminHandler()
                        .updateAdmin(
                            name.text.trim(),
                            value,
                            password.text.trim(),
                            email.text.trim(),
                            phoneNo.text.trim(),
                            admin[index].adminID,
                            admin[index].faceID,
                            admin[index].uid)
                        .whenComplete(
                          () => Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(builder: (_) {
                            return AdminProfile();
                          })),
                        );
                  });
                });
              });
            } else if (admin[index].faceID == galleryDB) {
              setState(() {
                AdminHandler()
                    .updateAdmin(
                        name.text.trim(),
                        widget.image,
                        password.text.trim(),
                        email.text.trim(),
                        phoneNo.text.trim(),
                        admin[index].adminID,
                        admin[index].faceID,
                        admin[index].uid)
                    .whenComplete(
                      () => Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (_) {
                        return AdminProfile();
                      })),
                    );
              });
            } else {
              AdminHandler()
                  .updateAdmin(
                      name.text.trim(),
                      widget.image,
                      password.text.trim(),
                      email.text.trim(),
                      phoneNo.text.trim(),
                      admin[index].adminID,
                      admin[index].faceID,
                      admin[index].uid)
                  .whenComplete(
                    () => Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) {
                      return AdminProfile();
                    })),
                  );
            }
          }
        },
        child: Icon(Icons.done),
      ),
    );
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
                          return AdminCameraPage(admin[0].image,
                              widget.dataFace, categoryImageLocal);
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
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) {
                          return AdminGalleryImage(
                              _imageFile, categoryImageLocal);
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
}
