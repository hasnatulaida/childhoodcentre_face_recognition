import 'package:face_recognition/staff/model/staff.dart';
import 'package:flutter/material.dart';
import 'package:face_recognition/staff/controller/staff_service.dart';
import 'package:face_recognition/staff/view/liststaff.dart';

import '../../../error.dart';
import '../../../loading.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class StaffDeleteList extends StatefulWidget {
  @override
  _StaffDeleteListState createState() => _StaffDeleteListState();
}

class _StaffDeleteListState extends State<StaffDeleteList> {
  List<Staff> staff;
  int staffIndex;
  int finishRemove = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: new Text("Delete Staff"),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                for (int i = 0; i < staff.length; i++) {
                  await StaffService().updateStaffCheck(staff[i].uid, false);
                }
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  return StaffList();
                }));
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Staff>>(
          stream: StaffService().listStaff(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Loading();
            }
            if (snapshot.hasError) {
              return ErrorPage();
            } else {
              staff = snapshot.data;
              staff.sort((a, b) => a.name.compareTo(b.name));
              if (finishRemove == staff.length) {
                print("masuk here");
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) {
                    return StaffList();
                  })),
                );

                return Container();
              } else
                return Container(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView.builder(
                        itemCount: staff.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              height: 100,
                              child: new Card(
                                  color: Colors.white,
                                  elevation: 5.0,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                        staff[index].image,
                                      ),
                                    ),
                                    title: Text("${staff[index].name}"),
                                    subtitle: Text("${staff[index].phoneNo}"),
                                    trailing: new Checkbox(
                                        value: staff[index].isCheck,
                                        onChanged: (bool value) {
                                          staffIndex = index;

                                          setState(() async {
                                            await StaffService()
                                                .updateStaffCheck(
                                                    staff[index].uid, value);
                                          });
                                        }),
                                  )));
                        }));
            }
          }),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.WARNING,
                  headerAnimationLoop: false,
                  animType: AnimType.TOPSLIDE,
                  showCloseIcon: true,
                  closeIcon: Icon(Icons.close_fullscreen_outlined),
                  title: 'Warning',
                  desc: 'Are you sure to delete staff?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    for (int i = 0; i < staff.length; i++) {
                      if (staff[i].isCheck == true) {
                        StaffService().removeStaff(staff[i].uid);
                      }
                      finishRemove = i;
                      print("Finish remove $finishRemove");
                    }
                  })
                ..show();
            },
            label: Text('Delete'),
            icon: Icon(Icons.delete),
          ),
          SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              setState(() async {
                Navigator.of(context).pop(null);

                for (int i = 0; i < staff.length; i++) {
                  await StaffService().updateStaffCheck(staff[i].uid, false);
                }
              });
            },
            label: Text('Cancel'),
            icon: Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }
}
