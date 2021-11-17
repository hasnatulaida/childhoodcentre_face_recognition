import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/admin/model/admin.dart';

class AdminHandler {
  CollectionReference adminCollection =
      FirebaseFirestore.instance.collection("Admin");

  //add admin
  Future createNewAdmin(String name, String image, String password,
      String email, String phoneNo, String adminID, String faceID) async {
    return await adminCollection.add({
      "image": image,
      "name": name,
      "password": password,
      "phoneNo": phoneNo,
      "email": email,
      "faceID": faceID,
      "adminID": adminID,
    });
  }

  //update admin
  Future updateAdmin(String name, String image, String password, String email,
      String phoneNo, String adminID, String faceID, String uid) async {
    await adminCollection.doc(uid).update({
      "image": image,
      "name": name,
      "email": email,
      "password": password,
      "phoneNo": phoneNo,
      "faceID": faceID,
      "adminID": adminID,
    });
  }

  //staff list
  List<Admin> adminFromFirestore(QuerySnapshot snapshot) {
    if (snapshot != null) {
      print("Admin database here");
      return snapshot.docs.map((e) {
        return Admin(
          uid: e.id,
          image: e["image"],
          name: e["name"],
          email: e["email"],
          password: e["password"],
          phoneNo: e["phoneNo"],
          faceID: e["faceID"],
          adminID: e["adminID"],
        );
      }).toList();
    } else {
      return null;
    }
  }

  Stream<List<Admin>> listAdmin() {
    return adminCollection.snapshots().map(adminFromFirestore);
  }
}
