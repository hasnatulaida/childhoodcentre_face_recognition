import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/kid/model/kid2.dart';

class KidDatabaseService2 {
  CollectionReference kidCollection =
      FirebaseFirestore.instance.collection("Kid");

  //add kid
  Future createNewKid(
      String name,
      DateTime date,
      String address,
      String momName,
      String momPhone,
      String dadName,
      String dadPhone,
      String faceID,
      String faceIDMom,
      String faceIDDad,
      String kidImage,
      String momImage,
      String dadImage) async {
    return await kidCollection.add({
      "kidImage": kidImage,
      "momImage": momImage,
      "dadImage": dadImage,
      "name": name,
      "date": date,
      "address": address,
      "momName": momName,
      "momPhone": momPhone,
      "dadName": dadName,
      "dadPhone": dadPhone,
      "isCheck": false,
      "faceID": faceID,
      "faceIDMom": faceIDMom,
      "faceIDDad": faceIDDad,
    });
  }

  //update kid
  Future updateKid(
      kidID,
      String name,
      DateTime date,
      String address,
      String momName,
      String momPhone,
      String dadName,
      String dadPhone,
      String faceID,
      String faceIDMom,
      String faceIDDad,
      String kidImage,
      String momImage,
      String dadImage) async {
    await kidCollection.doc(kidID).update({
      "kidImage": kidImage,
      "momImage": momImage,
      "dadImage": dadImage,
      "name": name,
      "date": date,
      "address": address,
      "momName": momName,
      "momPhone": momPhone,
      "dadName": dadName,
      "dadPhone": dadPhone,
      "isCheck": false,
      "faceID": faceID,
      "faceIDMom": faceIDMom,
      "faceIDDad": faceIDDad,
    });
  }

  //update isCheck
  Future updateKidCheck(kidID, bool value) async {
    await kidCollection.doc(kidID).update({
      "isCheck": value,
    });
  }

  //delete kid
  Future removeKid(kidID) async {
    await kidCollection.doc(kidID).delete();
  }

  //kid list
  List<Kid2> kidFromFirestore(QuerySnapshot snapshot) {
    if (snapshot != null) {
      return snapshot.docs.map((e) {
        return Kid2(
            kidID: e.id,
            kidImage: e["kidImage"],
            momImage: e["momImage"],
            dadImage: e["dadImage"],
            name: e["name"],
            date: e["date"],
            address: e["address"],
            momName: e["momName"],
            momPhone: e["momPhone"],
            dadName: e["dadName"],
            dadPhone: e["dadPhone"],
            isCheck: e["isCheck"],
            faceID: e["faceID"],
            faceIDMom: e["faceIDMom"],
            faceIDDad: e["faceIDDad"]);
      }).toList();
    } else {
      return null;
    }
  }

  Stream<List<Kid2>> listKid() {
    return kidCollection.snapshots().map(kidFromFirestore);
  }
}
