import 'package:cloud_firestore/cloud_firestore.dart';

//UnknownFace
class UnrecognizeFaceModel {
  String image;
  Timestamp date;
  String unknownFaceID;
  dynamic unknownFace;

  UnrecognizeFaceModel(
      {this.image, this.date, this.unknownFaceID, this.unknownFace});
}
