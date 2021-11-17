import 'package:face_recognition/staff/model/staff.dart';
import 'package:flutter/material.dart';
import 'package:face_recognition/admin/view/adminmenu.dart';
import 'package:face_recognition/error.dart';
import 'package:face_recognition/staff/controller/staff_service.dart';
import 'package:face_recognition/staff/view/form/deleteStaff.dart';
import 'package:face_recognition/staff/view/form/staffform.dart';
import 'package:face_recognition/staff/view/form/staffformdata.dart';

import '../../loading.dart';

class StaffList extends StatefulWidget {
  @override
  _StaffListState createState() => _StaffListState();
}

class _StaffListState extends State<StaffList> {
  var _searchview = new TextEditingController();

  List<Staff> staff;

  bool _firstSearch = true;
  String _query = "";
  final String galleryDB = "01Gallery";

  List<Staff> _filterList;

  @override
  void initState() {
    super.initState();
  }

  _StaffListState() {
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
            title: new Text("Manage Staff"),
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
        body: StreamBuilder<List<Staff>>(
            stream: StaffService().listStaff(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }
              if (snapshot.hasError) {
                return ErrorPage();
              }
              print("Staff snapshot ${snapshot.data.length}");
              staff = snapshot.data;
              staff.sort((a, b) => a.name.compareTo(b.name));
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
                                return StaffForm(
                                    "assets/image/people.png", "01");
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
                                return StaffDeleteList();
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
          itemCount: staff.length,
          itemBuilder: (BuildContext context, int index) {
            print("staff index $index");
            return new Card(
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
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) {
                      return ProfileStaffData(staff[index].image,
                          staff[index].faceID, 0, staff[index].staffID);
                    }));
                  },
                ));
          }),
    );
  }

  //Perform actual search
  Widget _performSearch() {
    _filterList = [];
    for (int i = 0; i < staff.length; i++) {
      var item = staff[i];

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
                      _filterList[index].image,
                    ),
                  ),
                  title: Text("${_filterList[index].name}"),
                  subtitle: Text("${_filterList[index].phoneNo}"),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) {
                      return ProfileStaffData(staff[index].image,
                          staff[index].faceID, 0, staff[index].staffID);
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
