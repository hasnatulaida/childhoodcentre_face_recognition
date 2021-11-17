import 'package:face_recognition/Authentication/components/rounded_button.dart';
import 'package:face_recognition/Authentication/components/rounded_input_field.dart';
import 'package:face_recognition/Authentication/components/rounded_password_field.dart';
import 'package:face_recognition/Authentication/model/login.dart';
import 'package:face_recognition/Authentication/model/loginData.dart';
import 'package:face_recognition/admin/controller/adminHandler.dart';
import 'package:face_recognition/admin/model/admin.dart';
import 'package:face_recognition/admin/view/adminmenu.dart';
import 'package:face_recognition/staff/model/staff.dart';
import 'package:face_recognition/staff/controller/staff_service.dart';
import 'package:face_recognition/staff/view/staffmenu.dart';
import 'package:flutter/material.dart';

import '../../../../loading.dart';
import 'background.dart';

class Body extends StatefulWidget {
  const Body({
    Key key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  // final emailAdmin = "admin@gmail.com";
  // final passwordAdmin = "abc123";
  String text = " ";

  List<Staff> staff;
  List<Login> loginUser = globalLogin;

  List<Admin> admin;

  String emailLogin;

  String passwordLogin;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder<List<Staff>>(
          stream: StaffService().listStaff(),
          builder: (context, snapshot1) {
            // if (!snapshot.hasData) {
            //   _showAlertDialog();
            // }
            // if (snapshot.hasError) {
            //   return ErrorPage();
            // }
            staff = snapshot1.data;
            return StreamBuilder<List<Admin>>(
                stream: AdminHandler().listAdmin(),
                builder: (context, snapshot2) {
                  switch (snapshot2.connectionState) {
                    case ConnectionState.none:
                      return Loading();
                    case ConnectionState.waiting:
                      return Loading();
                    case ConnectionState.active:
                      admin = snapshot2.data;
                      // print("Admin form ${admin[index].name}");
                      // return Text("Admin ${snapshot.data.length}");
                      return Background(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // Text(
                              //   "LOGIN",
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // ),
                              // SizedBox(height: size.height * 0.03),
                              // SvgPicture.asset(
                              //   "assets/icons/login.svg",
                              //   height: size.height * 0.35,
                              // ),
                              Image.asset(
                                "assets/icons/intro.png",
                                height: size.height * 0.35,
                              ),
                              SizedBox(height: size.height * 0.03),
                              RoundedInputField(
                                hintText: "User ID or Email",
                                onChanged: (value) {
                                  emailLogin = value;
                                },
                              ),
                              RoundedPasswordField(
                                onChanged: (value) {
                                  passwordLogin = value;
                                },
                              ),
                              // SizedBox(height: size.height * 0.03),
                              // Text("Forgot your password?"),
                              Text("$text",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.red)),
                              RoundedButton(
                                text: "LOGIN",
                                press: () {
                                  if (passwordLogin == admin[0].password &&
                                      (emailLogin == admin[0].email ||
                                          emailLogin == admin[0].adminID)) {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) {
                                      return AdminMenu();
                                    }));
                                    setState(() {
                                      loginUser[0].user = "Admin";
                                    });
                                  } else {
                                    for (int i = 0; i < staff.length; i++) {
                                      if (passwordLogin == staff[i].password &&
                                          (emailLogin == staff[i].email ||
                                              emailLogin == staff[i].staffID)) {
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (_) {
                                          return StaffMenu();
                                        }));

                                        setState(() {
                                          loginUser[0].user = "Staff";
                                        });
                                      } else {
                                        setState(() {
                                          text = "Wrong username or email";
                                        });
                                      }
                                    }
                                  }
                                },
                              ),
                              // SizedBox(height: size.height * 0.03),
                              // AlreadyHaveAnAccountCheck(
                              //   press: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return SignUpScreen();
                              //         },
                              //       ),
                              //     );
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      );
                      break;
                    case ConnectionState.done:
                      return Loading();
                  }
                  return Container();
                });
          }),
    );
  }


}
