import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/staff/model/staff.dart';

class StaffService {
  CollectionReference staffCollection =
      FirebaseFirestore.instance.collection("Staff");

  //add staff
  Future createNewStaff(
      String staffID,
      String password,
      String image,
      String name,
      String phoneNo,
      String email,
      String address,
      String faceID) async {
    return await staffCollection.add({
      "staffID": staffID,
      "password": password,
      "image": image,
      "name": name,
      "phoneNo": phoneNo,
      "email": email,
      "isCheck": false,
      "address": address,
      "faceID": faceID,
    });
  }

  //update staff
  Future updateStaff(uid, String staffID, String password, image, String name,
      String phoneNo, String email, String address, String faceID) async {
    await staffCollection.doc(uid).update({
      "staffID": staffID,
      "password": password,
      "image": image,
      "name": name,
      "phoneNo": phoneNo,
      "email": email,
      "isCheck": false,
      "address": address,
      "faceID": faceID,
    });
  }

  //update isCheck
  Future updateStaffCheck(uid, bool value) async {
    await staffCollection.doc(uid).update({
      "isCheck": value,
    });
  }

  //delete staff
  Future removeStaff(uid) async {
    await staffCollection.doc(uid).delete();
  }

  //staff list
  List<Staff> staffFromFirestore(QuerySnapshot snapshot) {
    if (snapshot != null) {
      return snapshot.docs.map((e) {
        return Staff(
          uid: e.id,
          staffID: e["staffID"],
          password: e["password"],
          image: e["image"],
          name: e["name"],
          phoneNo: e["phoneNo"],
          email: e["email"],
          isCheck: e["isCheck"],
          address: e["address"],
          faceID: e["faceID"],
        );
      }).toList();
    } else {
      return null;
    }
  }

  Stream<List<Staff>> listStaff() {
    return staffCollection.snapshots().map(staffFromFirestore);
  }
}
