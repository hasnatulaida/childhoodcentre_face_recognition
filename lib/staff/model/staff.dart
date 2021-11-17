class Staff {
  String staffID;
  String password;
  String image; //imageURL
  String name;
  String phoneNo; //find the correct
  String email;
  bool isCheck;
  String address;
  String uid;
  String faceID;

  Staff(
      {this.staffID,
      this.password,
      this.image,
      this.name,
      this.phoneNo,
      this.email,
      this.isCheck,
      this.address,
      this.uid,
      this.faceID});

  Staff.copy(Staff from)
      : this(
            staffID: from.staffID,
            password: from.password,
            image: from.image,
            name: from.name,
            phoneNo: from.phoneNo,
            email: from.email,
            isCheck: from.isCheck,
            address: from.address,
            uid: from.uid,
            faceID: from.faceID);
}
