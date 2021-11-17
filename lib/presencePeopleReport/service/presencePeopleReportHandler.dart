import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/presencePeopleReport/model/presencePeopleReport.dart';

class PresencePeopleReportHandler {
  CollectionReference attendeeCollection =
      FirebaseFirestore.instance.collection("PresencePeopleReport");

  //add attendee
  Future createNewAttendee(DateTime date, String name) {
    return attendeeCollection.add({
      "date": date,
      "name": name,
    });
  }

  //update attendee
  Future updateAttendee(uid, DateTime date, String name) async {
    await attendeeCollection.doc(uid).update({
      "date": date,
      "name": name,
    });
  }

  //delete attendee
  Future removeAttendee(uid) async {
    await attendeeCollection.doc(uid).delete();
  }

  //Presnece People Report
  List<PresencePeopleReport> attendeeFromFirestore(QuerySnapshot snapshot) {
    if (snapshot != null) {
      return snapshot.docs.map((e) {
        return PresencePeopleReport (
          date: e["date"],
          name: e["name"],
          uid: e.id,
        );
      }).toList();
    } else {
      return null;
    }
  }

  Stream<List<PresencePeopleReport>> listAttendee() {
    return attendeeCollection.snapshots().map(attendeeFromFirestore);
  }
}
