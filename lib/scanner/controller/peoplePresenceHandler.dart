import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/scanner/model/peoplePresenceReport.dart';

class PeoplePresenceReportHandler {
  CollectionReference attendeeCollection =
      FirebaseFirestore.instance.collection("PresencePeopleReport");

  //add presence people
  Future createNewPresendePeopleReport(DateTime date, String name) {
    return attendeeCollection.add({
      "date": date,
      "name": name,
    });
  }

  //update presence people
  Future updatePresencePeopleReport(uid, DateTime date, String name) async {
    await attendeeCollection.doc(uid).update({
      "date": date,
      "name": name,
    });
  }

  //Presence people list
  List<PeoplePresenceReport> presencePeopleReportFromFirestore(
      QuerySnapshot snapshot) {
    if (snapshot != null) {
      return snapshot.docs.map((e) {
        return PeoplePresenceReport(
          date: e["date"],
          name: e["name"],
          uid: e.id,
        );
      }).toList();
    } else {
      return null;
    }
  }

  Stream<List<PeoplePresenceReport>> listPresencePeopleReport() {
    return attendeeCollection
        .snapshots()
        .map(presencePeopleReportFromFirestore);
  }
}
