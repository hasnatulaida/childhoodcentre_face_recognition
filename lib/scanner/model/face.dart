class FaceModel{
  String image;
  String name;
  DateTime date;
  String address;
  String momName;
  int momPhone;
  String dadName;
  int dadPhone;
  bool isCheck;
  String uid;
  String url;
  dynamic dataFace;

  FaceModel({
    this.image,
    this.name,
    this.date,
    this.address,
    this.momName,
    this.momPhone,
    this.dadName,
    this.dadPhone,
    this.isCheck,
    this.uid,
    this.url,
    this.dataFace,
  });

  FaceModel.copy(FaceModel from) : this(
    image: from.image,
    name: from.name,
    date: from.date,
    address: from.address,
    momName: from.momName,
    momPhone: from.momPhone,
    dadName: from.dadName,
    dadPhone: from.dadPhone,
    isCheck: from.isCheck,
    uid: from.uid,
    url: from.url,
    dataFace: from.dataFace,
  );
}
