import 'package:flutter/material.dart';
import 'package:face_recognition/kid/controller/kid_service2.dart';
import 'package:face_recognition/kid/view/listviewkid.dart';

import '../error.dart';
import '../loading.dart';
import 'model/kid2.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DeleteList extends StatefulWidget {
  @override
  _DeleteListState createState() => _DeleteListState();
}

class _DeleteListState extends State<DeleteList> {
  List<Kid2> kid;

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
          title: new Text("Delete Kid"),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                for (int i = 0; i < kid.length; i++) {
                  await KidDatabaseService2()
                      .updateKidCheck(kid[i].kidID, false);
                }
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
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Loading();
            }
            if (snapshot.hasError) {
              return ErrorPage();
            }
            kid = snapshot.data;

            kid.sort((a, b) => a.name.compareTo(b.name));

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                  itemCount: kid.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new Card(
                        color: Colors.white,
                        elevation: 5.0,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                              kid[index].kidImage,
                            ),
                          ),
                          title: Text("${kid[index].name}"),
                          subtitle: Text("${kid[index].address}"),
                          trailing: new Checkbox(
                              value: kid[index].isCheck,
                              onChanged: (bool value) {
                                setState(() async {
                                  await KidDatabaseService2()
                                      .updateKidCheck(kid[index].kidID, value);
                                });
                              }),
                        ));
                  }),
            );
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
                  desc: 'Are you sure to delete kid?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    setState(() async {
                      for (int i = 0; i < kid.length; i++) {
                        if (kid[i].isCheck == true) {
                          await KidDatabaseService2().removeKid(kid[i].kidID);
                        }
                      }

                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => (KidList())),
                      );
                    });
                  })
                ..show();
            },
            label: Text('Delete'),
            icon: Icon(Icons.delete),
          ),
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              setState(() async {
                Navigator.of(context).pop(null);

                for (int i = 0; i < kid.length; i++) {
                  await KidDatabaseService2()
                      .updateKidCheck(kid[i].kidID, false);
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
