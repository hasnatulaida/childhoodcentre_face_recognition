import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/picture/model/recognize_face.dart';

//FaceHandler
class RecognizeFaceService {
  CollectionReference recognizeFaceCollection =
      FirebaseFirestore.instance.collection("Face");

  //add image

  Future createNewImage(dynamic data) {
    return recognizeFaceCollection.add({
      "dataFace": data,
    });
  }

  //update recognize image
  //updateFace
  Future updateRecognizeFaceImage(uid, dynamic image) async {
    await recognizeFaceCollection.doc(uid).update({"dataFace": image});
  }

  //delete recognize image
  //removeFace
  Future removeImage(uid) async {
    await recognizeFaceCollection.doc(uid).delete();
  }

  //recognize image list
  //faceFromFirestore
  List<RecognizeFace> recognizefACEFromFirestore(QuerySnapshot snapshot) {
    if (snapshot != null) {
      return snapshot.docs.map((e) {
        return RecognizeFace(
          dataFace: e["dataFace"],
          uid: e.id,
        );
      }).toList();
    } else {
      return null;
    }
  }

  Stream<List<RecognizeFace>> listFaceImage() {
    return recognizeFaceCollection.snapshots().map(recognizefACEFromFirestore);
  }
}
