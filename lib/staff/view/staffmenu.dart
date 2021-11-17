import 'package:face_recognition/Authentication/Screens/Login/components/background.dart';
import 'package:face_recognition/Authentication/Screens/Login/login_screen.dart';
import 'package:face_recognition/kid/view/listviewkid.dart';
import 'package:face_recognition/presencePeopleReport/view/presencePeopleReportPage.dart';
import 'package:face_recognition/unrecognize_face/view/unrecognizeFace.dart';
import 'package:flutter/material.dart';

class StaffMenu extends StatefulWidget {
  @override
  _StaffMenuState createState() => _StaffMenuState();
}

class _StaffMenuState extends State<StaffMenu> {
  String title = 'Staff Menu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: Text(title),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => (LoginScreen())),
                );
              },
            ),
          ],
        ),
      ),
      body: Background(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.purple[200], // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(builder: (_) {
                            return KidList();
                          }));
                        },
                        child: Text("Manage Kid",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25)),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.purple[200], // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => (AttendeeList())),
                          );
                        },
                        child: Text("People Presence Report",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25)),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.purple[200], // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    (UnrecognizeFaceSticky())),
                          );
                        },
                        child: Text("Unknown People Report",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25)),
                      ),
                    ),
                  ]))),
    );
  }
}
