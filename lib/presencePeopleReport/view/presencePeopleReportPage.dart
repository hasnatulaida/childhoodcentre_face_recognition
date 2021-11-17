import 'package:face_recognition/Authentication/model/login.dart';
import 'package:face_recognition/Authentication/model/loginData.dart';
import 'package:face_recognition/admin/view/adminmenu.dart';
import 'package:face_recognition/presencePeopleReport/model/presencePeopleReport.dart';
import 'package:face_recognition/presencePeopleReport/service/presencePeopleReportHandler.dart';
import 'package:face_recognition/staff/view/staffmenu.dart';
import 'package:flutter/material.dart';
//search
import 'package:intl/intl.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../loading.dart';

class AttendeeList extends StatefulWidget {
  @override
  _AttendeeListState createState() => _AttendeeListState();
}

class _AttendeeListState extends State<AttendeeList> {
  _AttendeeListState() {
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

  List<PresencePeopleReport> attendee;
  List<Login> loginUser = globalLogin;
  DateTime selectedDate = DateTime.now();

  List<PresencePeopleReport> _filterList;
  bool _firstSearch = true;
  String _query = "";
//search
  var _searchview = new TextEditingController();

  Widget _createListView() {
    print("Masuk create List View");
    return Flexible(
      child: StickyGroupedListView<PresencePeopleReport, DateTime>(
        elements: attendee,
        order: StickyGroupedListOrder.ASC,
        groupBy: (PresencePeopleReport element) => DateTime(element.date.toDate().year,
            element.date.toDate().month, element.date.toDate().day),
        groupComparator: (DateTime value1, DateTime value2) =>
            value2.compareTo(value1),
        itemComparator: (PresencePeopleReport element1, PresencePeopleReport element2) =>
            element1.date.toDate().compareTo(element2.date.toDate()),
        floatingHeader: true,
        groupSeparatorBuilder: (PresencePeopleReport element) => Container(
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
                //date filter
                child: Text(
                  '${element.date.toDate().day}.${element.date.toDate().month}.${element.date.toDate().year}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        itemBuilder: (_, PresencePeopleReport element) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            elevation: 8.0,
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                // leading: Container(
                //   width: 10.0,
                //   height: 10.0,
                //   decoration: BoxDecoration(
                //       color: Colors.white,
                //       image: DecorationImage(
                //           image: NetworkImage(unknown[i].image),
                //           fit: BoxFit.cover),
                //       borderRadius:
                //           BorderRadius.all(Radius.circular(75.0)),
                //       boxShadow: [
                //         BoxShadow(blurRadius: 7.0, color: Colors.black)
                //       ]),
                // ),
                title: Text(element.name),
                trailing: Text('${element.date.toDate().hour}:00'),
              ),
            ),
          );
        },
      ),
    );
  }

  //Create a SearchView
  // Widget _createSearchView() {
  //   return Container(
  //     height: 70,
  //     child: Align(
  //       alignment: Alignment.centerLeft,
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         // child: Text(
  //         //   'Email',
  //         //   style: TextStyle(color: Colors.white70),
  //         // ),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Text("${selectedDate.toLocal()}".split(' ')[0]),
  //             SizedBox(
  //               width: 120.0,
  //             ),
  //             ElevatedButton(
  //               onPressed: () => _selectDate(context),
  //               child: Text('Select date'),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     decoration: BoxDecoration(
  //       border: Border.all(width: 1.0),
  //     ),
  //   );
  // }

  Widget _createSearchView() {
    return new Container(
      decoration: BoxDecoration(border: Border.all(width: 1.0)),
      child: new TextField(
        focusNode: AlwaysDisabledFocusNode(),
        controller: _searchview,
        decoration: InputDecoration(
          hintText: "Select Date",
          hintStyle: new TextStyle(color: Colors.grey[300]),
          // suffixIcon: IconButton(
          //   onPressed: () => _searchview.clear(),
          //   icon: Icon(Icons.clear),
          // ),
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
    for (int i = 0; i < attendee.length; i++) {
      var item = attendee[i];
      String date = DateFormat('dd-MM-yyyy').format(item.date.toDate());
      print("The date");

      if (date == _query) {
        _filterList.add(item);
      }
    }
    return _createFilteredListView();
  }

  //Create the Filtered ListView
  Widget _createFilteredListView() {
    return Flexible(
      child: StickyGroupedListView<PresencePeopleReport, DateTime>(
        elements: _filterList,
        order: StickyGroupedListOrder.ASC,
        groupBy: (PresencePeopleReport element) => DateTime(element.date.toDate().year,
            element.date.toDate().month, element.date.toDate().day),
        groupComparator: (DateTime value1, DateTime value2) =>
            value2.compareTo(value1),
        itemComparator: (PresencePeopleReport element1, PresencePeopleReport element2) =>
            element1.date.toDate().compareTo(element2.date.toDate()),
        floatingHeader: true,
        groupSeparatorBuilder: (PresencePeopleReport element) => Container(
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
                //date filter
                child: Text(
                  '${element.date.toDate().day}. ${element.date.toDate().month}. ${element.date.toDate().year}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        itemBuilder: (_,PresencePeopleReport element) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            elevation: 8.0,
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                title: Text(element.name),
                trailing: Text('${element.date.toDate().hour}:00'),
              ),
            ),
          );
        },
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
          title: Text('People Presence Report'),
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
      body: StreamBuilder<List<PresencePeopleReport>>(
          stream:PresencePeopleReportHandler().listAttendee(),
          builder: (context, AsyncSnapshot<List<PresencePeopleReport>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Loading();
              case ConnectionState.waiting:
                return Loading();
              case ConnectionState.active:
                attendee = snapshot.data;
                print("Attendee $attendee");

                if (attendee.isNotEmpty) {
                  print("attendee not empty");

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
                  // new Container(
                  //   // margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  //   child: new Column(
                  //     children: <Widget>[
                  //       _createSearchView(),
                  //       new Divider(
                  //         height: 10.0,
                  //         indent: 10.0,
                  //       ),
                  //       _firstSearch ? _createListView() : _performSearch()
                  //       // _createListView() ,
                  //     ],
                  //   ),
                  // );
                } else {
                  return Text("No data");
                }
                break;

              case ConnectionState.done:
                return Loading();
            }
            return null;
          }),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
