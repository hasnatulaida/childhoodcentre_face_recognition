import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:face_recognition/Authentication/model/login.dart';
import 'package:face_recognition/Authentication/model/loginData.dart';
import 'package:face_recognition/admin/view/adminmenu.dart';
import 'package:face_recognition/kid/view/newprofilekidu.dart';
import 'package:face_recognition/staff/view/form/staffFormUnrecognize.dart';
import 'package:face_recognition/staff/view/staffmenu.dart';
import 'package:face_recognition/unrecognize_face/model/unrecognize_face.dart';
import 'package:face_recognition/unrecognize_face/service/unrecognizeService.dart';
import 'package:flutter/material.dart';
//search
import 'package:intl/intl.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

class UnrecognizeFaceSticky extends StatefulWidget {
  @override
  _UnrecognizeFaceStickyState createState() => _UnrecognizeFaceStickyState();
}

class _UnrecognizeFaceStickyState extends State<UnrecognizeFaceSticky> {
  List<Login> loginUser = globalLogin;
  List<UnrecognizeFaceModel> unknown;

//search
  DateTime selectedDate = DateTime.now();

  List<UnrecognizeFaceModel> _filterList;
  bool _firstSearch = true;
  String _query = "";

  final String galleryDB = "01Gallery";

  var _searchview = new TextEditingController();

  _UnrecognizeFaceStickyState() {
    _searchview.addListener(() {
      if (_searchview.text.isEmpty) {
        setState(() {
          _firstSearch = true;
          _query = "";
        });
      } else {
        setState(() {
          _firstSearch = false;
          _query = _searchview.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          title: Text('Unknown People Report'),
          backgroundColor: Colors.purple[200],
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                if (loginUser[0].user == "Admin") {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => (AdminMenu())),
                  );
                } else if (loginUser[0].user == "Staff") {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => (StaffMenu())),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<UnrecognizeFaceModel>>(
          stream: UnrecognizeService().listUnknownImage(),
          builder:
              (context, AsyncSnapshot<List<UnrecognizeFaceModel>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Loading..');
              case ConnectionState.waiting:
                return Text('Loading...');
              case ConnectionState.active:
                unknown = snapshot.data;
                print("Unknown List $unknown");

                if (unknown.isNotEmpty) {
                  print("unkwon not empty");
                  return Container(
                      margin:
                          EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                      child: Column(
                        children: [
                          _createSearchView(),
                          new Divider(
                            height: 10.0,
                            indent: 10.0,
                          ),
                          _firstSearch ? _createListView() : _performSearch()
                        ],
                      ));
                } else {
                  return Container();
                }
                break;

              case ConnectionState.done:
                return Text('\$${snapshot.data} (closed)');
            }
            return null;
          }),
    );
  }

  Widget _createListView() {
    return Flexible(
        child: StickyGroupedListView<UnrecognizeFaceModel, DateTime>(
      elements: unknown,
      order: StickyGroupedListOrder.ASC,
      groupBy: (UnrecognizeFaceModel element) => DateTime(
          element.date.toDate().year,
          element.date.toDate().month,
          element.date.toDate().day),
      groupComparator: (DateTime value1, DateTime value2) =>
          value2.compareTo(value1),
      itemComparator:
          (UnrecognizeFaceModel element1, UnrecognizeFaceModel element2) =>
              element1.date.toDate().compareTo(element2.date.toDate()),
      floatingHeader: true,
      groupSeparatorBuilder: (UnrecognizeFaceModel element) => Container(
        height: 50,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.blue[300],
              border: Border.all(
                color: Colors.blue[300],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${element.date.toDate().day}.${element.date.toDate().month}.${element.date.toDate().year}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      itemBuilder: (_, UnrecognizeFaceModel element) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            height: 150,
            width: 200,
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  element.image,
                ),
              ),
              title: Text(
                  'Time: ${element.date.toDate().hour}:${element.date.toDate().second}'),
              trailing: Wrap(
                spacing: 3,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      AwesomeDialog(
                          context: context,
                          dialogType: DialogType.WARNING,
                          headerAnimationLoop: false,
                          animType: AnimType.TOPSLIDE,
                          showCloseIcon: true,
                          closeIcon: Icon(Icons.close_fullscreen_outlined),
                          title: 'Warning',
                          desc: 'Are you sure to delete unknown face?',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            UnrecognizeService()
                                .removeFaceImage(element.unknownFaceID);
                          })
                        ..show();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    // iconSize: 24.0,
                    color: Colors.red,
                    onPressed: () {
                      print("Choose category");
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: new Text('Choose category:'),
                              actions: <Widget>[
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          new ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                  return StaffFormU(
                                                    element.image,
                                                    element.unknownFace,
                                                    element.unknownFaceID,
                                                  );
                                                }));
                                              },
                                              child: new Text('Staff',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ))),
                                          SizedBox(width: 10),
                                          new ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                  return NewProfileKidUnrecognize(
                                                      element.unknownFace,
                                                      galleryDB,
                                                      galleryDB,
                                                      element.image,
                                                      "assets/image/people.png",
                                                      "assets/image/people.png",
                                                      0,
                                                      0,
                                                      0,
                                                      element.unknownFaceID,
                                                      "kid");
                                                }));
                                              },
                                              child: new Text('Kid',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 10),
                                          new ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                  return NewProfileKidUnrecognize(
                                                      galleryDB,
                                                      element.unknownFace,
                                                      galleryDB,
                                                      "assets/image/people.png",
                                                      element.image,
                                                      "assets/image/people.png",
                                                      0,
                                                      0,
                                                      0,
                                                      element.unknownFaceID,
                                                      "mom");
                                                }));
                                              },
                                              child: new Text('Mom',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white))),
                                          SizedBox(width: 10),
                                          new ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                  return NewProfileKidUnrecognize(
                                                      galleryDB,
                                                      galleryDB,
                                                      element.unknownFace,
                                                      "assets/image/people.png",
                                                      "assets/image/people.png",
                                                      element.image,
                                                      0,
                                                      0,
                                                      0,
                                                      element.unknownFaceID,
                                                      "dad");
                                                }));
                                              },
                                              child: new Text('Dad',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white)))
                                        ],
                                      ),
                                    ]),
                              ],
                            );
                          });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  AlertDialog categoryKid(BuildContext context, UnrecognizeFaceModel element) {
    return AlertDialog(
      content: new Text('Image is:'),
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
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) {
                    return NewProfileKidUnrecognize(
                        element.unknownFace,
                        galleryDB,
                        galleryDB,
                        element.image,
                        "assets/image/people.png",
                        "assets/image/people.png",
                        0,
                        0,
                        0,
                        element.unknownFaceID,
                        "kid");
                  }));
                },
                child: new Text('Kid',
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
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) {
                    return NewProfileKidUnrecognize(
                        galleryDB,
                        element.unknownFace,
                        galleryDB,
                        "assets/image/people.png",
                        element.image,
                        "assets/image/people.png",
                        0,
                        0,
                        0,
                        element.unknownFaceID,
                        "mom");
                  }));
                },
                child: new Text('Mom',
                    style: TextStyle(fontSize: 16, color: Colors.white))),
            SizedBox(width: 10),
            new ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // <-- Radius
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) {
                    return NewProfileKidUnrecognize(
                        galleryDB,
                        galleryDB,
                        element.unknownFace,
                        "assets/image/people.png",
                        "assets/image/people.png",
                        element.image,
                        0,
                        0,
                        0,
                        element.unknownFaceID,
                        "dad");
                  }));
                },
                child: new Text('Dad',
                    style: TextStyle(fontSize: 16, color: Colors.white)))
          ],
        ),
      ],
    );
  }

  Widget _createFilteredListView() {
    return Flexible(
        child: StickyGroupedListView<UnrecognizeFaceModel, DateTime>(
      elements: _filterList,
      order: StickyGroupedListOrder.ASC,
      groupBy: (UnrecognizeFaceModel element) => DateTime(
          element.date.toDate().year,
          element.date.toDate().month,
          element.date.toDate().day),
      groupComparator: (DateTime value1, DateTime value2) =>
          value2.compareTo(value1),
      itemComparator:
          (UnrecognizeFaceModel element1, UnrecognizeFaceModel element2) =>
              element1.date.toDate().compareTo(element2.date.toDate()),
      floatingHeader: true,
      groupSeparatorBuilder: (UnrecognizeFaceModel element) => Container(
        height: 50,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.blue[300],
              border: Border.all(
                color: Colors.blue[300],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${element.date.toDate().day}.${element.date.toDate().month}.${element.date.toDate().year}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      itemBuilder: (_, UnrecognizeFaceModel element) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            height: 150,
            width: 200,
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  element.image,
                ),
              ),
              title: Text(
                  'Time: ${element.date.toDate().hour}:${element.date.toDate().second}'),
              trailing: Wrap(
                spacing: 3,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      UnrecognizeService()
                          .removeFaceImage(element.unknownFaceID);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.red,
                    onPressed: () {
                      print("Choose category");

                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: new Text('Choose category:'),
                              actions: <Widget>[
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          new ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                  return StaffFormU(
                                                    element.image,
                                                    element.unknownFace,
                                                    element.unknownFaceID,
                                                  );
                                                }));
                                              },
                                              child: new Text('Staff',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ))),
                                          SizedBox(width: 10),
                                          new ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                  return NewProfileKidUnrecognize(
                                                      element.unknownFace,
                                                      galleryDB,
                                                      galleryDB,
                                                      element.image,
                                                      "assets/image/people.png",
                                                      "assets/image/people.png",
                                                      0,
                                                      0,
                                                      0,
                                                      element.unknownFaceID,
                                                      "kid");
                                                }));
                                              },
                                              child: new Text('Kid',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white))),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 10),
                                          new ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                  return NewProfileKidUnrecognize(
                                                      galleryDB,
                                                      element.unknownFace,
                                                      galleryDB,
                                                      "assets/image/people.png",
                                                      element.image,
                                                      "assets/image/people.png",
                                                      0,
                                                      0,
                                                      0,
                                                      element.unknownFaceID,
                                                      "mom");
                                                }));
                                              },
                                              child: new Text('Mom',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white))),
                                          SizedBox(width: 10),
                                          new ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                  return NewProfileKidUnrecognize(
                                                      galleryDB,
                                                      galleryDB,
                                                      element.unknownFace,
                                                      "assets/image/people.png",
                                                      "assets/image/people.png",
                                                      element.image,
                                                      0,
                                                      0,
                                                      0,
                                                      element.unknownFaceID,
                                                      "dad");
                                                }));
                                              },
                                              child: new Text('Dad',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white)))
                                        ],
                                      ),
                                    ]),
                              ],
                            );
                          });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  Widget _createSearchView() {
    return new Container(
      decoration: BoxDecoration(border: Border.all(width: 1.0)),
      child: new TextField(
        focusNode: AlwaysDisabledFocusNode(),
        controller: _searchview,
        decoration: InputDecoration(
          hintText: "Select Date",
          hintStyle: new TextStyle(color: Colors.grey[300]),
        ),
        textAlign: TextAlign.center,
        onTap: () {
          _selectDate(context);
        },
      ),
    );
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
        _searchview
          ..text = DateFormat('dd-MM-yyyy').format(selectedDate)
          ..selection = TextSelection.fromPosition(TextPosition(
              offset: _searchview.text.length,
              affinity: TextAffinity.upstream));
      });
  }

  //Perform actual search
  Widget _performSearch() {
    _filterList = [];
    for (int i = 0; i < unknown.length; i++) {
      var item = unknown[i];
      String date = DateFormat('dd-MM-yyyy').format(item.date.toDate());
      print("The date");

      if (date == _query) {
        _filterList.add(item);
      }
    }
    return _createFilteredListView();
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
