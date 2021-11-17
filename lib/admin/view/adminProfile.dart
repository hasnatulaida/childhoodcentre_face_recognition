import 'package:face_recognition/admin/controller/adminHandler.dart';
import 'package:face_recognition/admin/model/admin.dart';
import 'package:flutter/material.dart';

import '../../loading.dart';
import 'adminProfileEdit.dart';
import 'adminmenu.dart';

class AdminProfile extends StatefulWidget {
  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final String faceID = "01Gallery";
  final String adminID = "A01";
  final String imageAdmin = "assets/image/people.png";

  String email;
  int i = 0;

  int index = 0;

  DateTime selectedDate = DateTime.now();

  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  List<Admin> admin;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    i = 0;
    super.dispose();
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
                    CircleAvatar(
                      radius: 70,
                      child: ClipOval(
                        child: Image.network(
                          admin[index].image,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
                                enabled: false,
                                initialValue: admin[index].password,
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
                                enabled: false,
                                initialValue: admin[index].name,
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
                                enabled: false,
                                initialValue: admin[index].phoneNo,
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
                                enabled: false,
                                initialValue: admin[index].email,
                                decoration: const InputDecoration(
                                  labelText: ' Email *',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  email = value;
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
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  return AdminMenu();
                }));
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Admin>>(
          stream: AdminHandler().listAdmin(),
          builder: (context, snapshot) {
            if (i == 2) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  return AdminProfileEdit(
                      admin[index].image, admin[index].faceID, 0);
                })),
              );
            } else
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Loading();
                case ConnectionState.waiting:
                  return Loading();
                case ConnectionState.active:
                  admin = snapshot.data;
                  return _buildForm();
                  break;
                case ConnectionState.done:
                  return Loading();
              }
            return Container();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            i = 2;
          });
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}
