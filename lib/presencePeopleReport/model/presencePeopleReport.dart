import 'package:cloud_firestore/cloud_firestore.dart';

class PresencePeopleReport {
  Timestamp date;
  String name;
  String uid;

  PresencePeopleReport ({this.date, this.name, this.uid});

  PresencePeopleReport.copy(PresencePeopleReport  from)
      : this(
          date: from.date,
          name: from.name,
          uid: from.uid,
        );
}
