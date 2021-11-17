import 'package:face_recognition/Authentication/model/login.dart';
import 'package:face_recognition/Authentication/model/loginData.dart';
import 'package:face_recognition/admin/view/adminmenu.dart';
import 'package:face_recognition/kid/deletelist.dart';
import 'package:face_recognition/kid/model/kid2.dart';
import 'package:face_recognition/kid/controller/kid_service2.dart';
import 'package:face_recognition/kid/view/newprofilekid.dart';
import 'package:face_recognition/kid/view/profilekid.dart';
import 'package:face_recognition/staff/view/staffmenu.dart';
import 'package:flutter/material.dart';

import '../../loading.dart';

class KidList extends StatefulWidget {
  @override
  _KidListState createState() => _KidListState();
}

class _KidListState extends State<KidList> {
  var _searchview = new TextEditingController();

  List<Kid2> newkid;
  bool _firstSearch = true;
  String _query = "";

  final String galleryDB = "01Gallery";
  List<Kid2> _filterList;
  List<Login> loginUser = globalLogin;

  @override
  void initState() {
    super.initState();
  }

  _KidListState() {
    //Register a closure to be called when the object changes.
    _searchview.addListener(() {
      if (_searchview.text.isEmpty) {
        //Notify the framework that the internal state of this object has changed.
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
          child: new AppBar(
            centerTitle: true,
            title: new Text("Manage Kid"),
            backgroundColor: Colors.purple[200],
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  if (loginUser[0].user == "Admin") {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => (AdminMenu())),
                    );
                  } else if (loginUser[0].user == "Staff") {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => (StaffMenu())),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        body: StreamBuilder<List<Kid2>>(
            stream: KidDatabaseService2().listKid(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Loading();
                case ConnectionState.waiting:
                  return Loading();
                case ConnectionState.active:
                  newkid = snapshot.data;
                  newkid.sort((a, b) => a.name.compareTo(b.name));
                  return new Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    child: new Column(
                      children: <Widget>[
                        _createSearchView(),
                        new Divider(
                          height: 10.0,
                          indent: 10.0,
                        ),
                        Container(
                          child: Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.purple[200], // background
                                  onPrimary: Colors.white, // foreground
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (_) {
                                    return NewProfileKid(
                                        galleryDB,
                                        galleryDB,
                                        galleryDB,
                                        "assets/image/people.png",
                                        "assets/image/people.png",
                                        "assets/image/people.png",
                                        0,
                                        0,
                                        0);
                                  }));
                                },
                                child: Text('Add'),
                              ),
                              new Divider(
                                indent: 200.0,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.purple[200], // background
                                  onPrimary: Colors.white, // foreground
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (_) {
                                    return DeleteList();
                                  }));
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                        new Divider(
                          height: 10.0,
                          indent: 10.0,
                        ),
                        _firstSearch ? _createListView() : _performSearch()
                        // _createListView() ,
                      ],
                    ),
                  );
                  break;
                case ConnectionState.done:
                  return Loading();
              }
              return Container();
            }));
  }

  //Create a SearchView
  Widget _createSearchView() {
    return new Container(
      decoration: BoxDecoration(border: Border.all(width: 1.0)),
      child: new TextField(
        controller: _searchview,
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: new TextStyle(color: Colors.grey[300]),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

//Create a ListView widget
  Widget _createListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: newkid.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
                color: Colors.white,
                elevation: 5.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      newkid[index].kidImage,
                    ),
                    // AssetImage('assets/image/people.png'),
                  ),
                  title: Text("${newkid[index].name}"),
                  subtitle: Text("${newkid[index].address}"),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) {
                      return ProfileKidView(
                          newkid[index].faceID,
                          newkid[index].faceID,
                          newkid[index].faceID,
                          newkid[index].kidImage,
                          newkid[index].momImage,
                          newkid[index].dadImage,
                          0,
                          0,
                          0,
                          newkid[index].kidID,
                          false,
                          newkid[index].date.toDate());
                    }));
                  },
                ));
          }),
    );
  }

  //Perform actual search
  Widget _performSearch() {
    _filterList = [];
    for (int i = 0; i < newkid.length; i++) {
      var item = newkid[i];

      if (item.name.toLowerCase().contains(_query.toLowerCase())) {
        _filterList.add(item);
      }
    }
    return _createFilteredListView();
  }

  //Create the Filtered ListView
  Widget _createFilteredListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
                color: Colors.white,
                elevation: 5.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      _filterList[index].kidImage,
                    ),
                  ),
                  title: Text("${_filterList[index].name}"),
                  subtitle: Text("${_filterList[index].address}"),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) {
                      return ProfileKidView(
                          galleryDB,
                          galleryDB,
                          galleryDB,
                          newkid[index].kidImage,
                          newkid[index].momImage,
                          newkid[index].dadImage,
                          0,
                          0,
                          0,
                          newkid[index].kidID,
                          false,
                          newkid[index].date.toDate());
                    }));
                  },
                ));
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
