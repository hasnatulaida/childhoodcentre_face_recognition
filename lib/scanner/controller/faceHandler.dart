import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/scanner/model/face.dart';

class FaceHandler {
  CollectionReference kidCollection =
      FirebaseFirestore.instance.collection("Face");

  //face list
  List<FaceModel> faceImageFromFirestore(QuerySnapshot snapshot) {
    if (snapshot != null) {
      return snapshot.docs.map((e) {
        return FaceModel(
          dataFace: e["dataFace"],
          uid: e.id,
        );
      }).toList();
    } else {
      return null;
    }
  }

  Stream<List<FaceModel>> listFaceImage() {
    return kidCollection.snapshots().map(faceImageFromFirestore);
  }
}
