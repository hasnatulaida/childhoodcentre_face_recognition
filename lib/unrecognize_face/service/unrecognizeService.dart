import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/unrecognize_face/model/unrecognize_face.dart';

//UnknownFaceService
class UnrecognizeService {
  CollectionReference unknownCollection =
      FirebaseFirestore.instance.collection("UnknownFace");

  //delete unknown
  //removeUnknownFace
  Future removeFaceImage(uid) async {
    await unknownCollection.doc(uid).delete();
  }

  //kid list
  List<UnrecognizeFaceModel> unknownImageFromFirestore(QuerySnapshot snapshot) {
    if (snapshot != null) {
      return snapshot.docs.map((e) {
        return UnrecognizeFaceModel(
            image: e["image"], unknownFaceID: e.id, date: e["date"], unknownFace: e["unknownFace"]);
      }).toList();
    } else {
      return null;
    }
  }

  Stream<List<UnrecognizeFaceModel>> listUnknownImage() {
    return unknownCollection.snapshots().map(unknownImageFromFirestore);
  }
}
