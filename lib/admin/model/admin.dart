class Admin {
  String name;
  String image;
  String email;
  String password;
  String phoneNo;
  String adminID;
  String faceID;
  String uid;

  Admin({
    this.uid,
    this.image,
    this.name,
    this.email,
    this.password,
    this.phoneNo,
    this.faceID,
    this.adminID,
  });

  Admin.copy(Admin from)
      : this(
          uid: from.uid,
          image: from.image,
          name: from.name,
          email: from.email,
          password: from.password,
          phoneNo: from.phoneNo,
          faceID: from.faceID,
          adminID: from.adminID,
        );
}
