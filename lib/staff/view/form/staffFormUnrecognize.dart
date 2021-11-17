import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:face_recognition/staff/model/staff.dart';
import 'package:face_recognition/staff/controller/staff_service.dart';
import 'package:face_recognition/unrecognize_face/service/unrecognizeService.dart';
import 'package:face_recognition/unrecognize_face/view/unrecognizeFace.dart';
//firebase
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

import '../../../loading.dart';

//new staff profile
class StaffFormU extends StatefulWidget {
  StaffFormU(this.image, this.dataFace, this.uid);

  final dynamic dataFace;
  final String image;
  final String uid;

  @override
  _StaffFormUState createState() => _StaffFormUState();
}

class _StaffFormUState extends State<StaffFormU> {
  //dataFace
  dynamic dataFaceDB = {};

  dynamic dataFaceKey = {};
  String email;

  //go to widget face
  int i = 0;

  String name;
  Staff newstaff;
  String password;
  String phoneNo;
  String address;
  //firebase storage
  firebase_storage.Reference refss;

  DateTime selectedDate = DateTime.now();
  List<Staff> staff;

  String staffId;

  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  //imageGallery
  Future saveStaffFileGallery() async {
    print("create new staff");

    staffId = "S0${staff.length + 1}";
    return StaffService().createNewStaff(
        staffId.trim(),
        password.trim(),
        widget.image,
        name.trim(),
        phoneNo.trim(),
        email.trim(),
        address,
        widget.uid);
  }

  Future removeUnknownFace() async {
    UnrecognizeService().removeFaceImage(widget.uid);
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
                    ClipOval(
                      child: Image.network(
                        widget.image,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
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
                                    return 'Password must be at least 3 characters long.';
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
                        return UnrecognizeFaceSticky();
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
            if (i == 2) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  return UnrecognizeFaceSticky();
                })),
              );
            }
            if (i == 4) {
              i = 2;
              saveStaffFileGallery();
              removeUnknownFace();

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

            setState(() {
              i = 4;
            });
          }
        },
        child: Icon(Icons.done),
      ),
    );
  }
}
