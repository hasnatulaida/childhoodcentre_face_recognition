import 'package:cloud_firestore/cloud_firestore.dart';

class Kid2 {
  String kidImage;
  String momImage;
  String dadImage;
  String name;
  String address;
  String momName;
  String momPhone;
  String dadName;
  String dadPhone;
  bool isCheck;
  String kidID;
  Timestamp date; //registerDate
  String faceID;
  String faceIDMom;
  String faceIDDad;

  Kid2(
      {this.kidImage,
      this.momImage,
      this.dadImage,
      this.name,
      this.address,
      this.momName,
      this.momPhone,
      this.dadName,
      this.dadPhone,
      this.isCheck,
      this.kidID,
      this.date,
      this.faceID,this.faceIDMom,this.faceIDDad});

  Kid2.copy(Kid2 from)
      : this(
            kidImage: from.kidImage,
            momImage: from.momImage,
            dadImage: from.dadImage,
            name: from.name,
            address: from.address,
            momName: from.momName,
            momPhone: from.momPhone,
            dadName: from.dadName,
            dadPhone: from.dadPhone,
            isCheck: from.isCheck,
            kidID: from.kidID,
            date: from.date,
            faceID: from.faceID,faceIDMom:from.faceIDMom,faceIDDad:from.faceIDDad);
}
