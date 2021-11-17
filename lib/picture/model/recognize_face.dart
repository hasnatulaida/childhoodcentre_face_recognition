//Face
class RecognizeFace {
  String uid; //faceID
  dynamic dataFace;

  RecognizeFace({
    this.uid,
    this.dataFace,
  });

  RecognizeFace.copy(RecognizeFace from)
      : this(
          uid: from.uid,
          dataFace: from.dataFace,
        );
}
