import 'package:cloud_firestore/cloud_firestore.dart';

class PeoplePresenceReport {
  Timestamp date;
  String name;
  String uid;

 PeoplePresenceReport ({this.date, this.name, this.uid});

  PeoplePresenceReport .copy(PeoplePresenceReport  from)
      : this(
          date: from.date,
          name: from.name,
          uid: from.uid,
        );
}
