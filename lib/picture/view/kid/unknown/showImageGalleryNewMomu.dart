import 'dart:io';

import 'package:face_recognition/kid/view/newprofilekidu.dart';
import 'package:flutter/material.dart';

class ShowImageGalleryNewMomUnrecognize extends StatefulWidget {
  ShowImageGalleryNewMomUnrecognize(
      this.imageKid,
      this.image,
      this.imageDad,
      this.categoryImagePage,
      this.categoryImageMomPage,
      this.categoryImageDadPage,
      this.uid,
      this.user);

//mom image
  final String image;
  final String imageKid;
  final String imageDad;
  final int categoryImagePage;
  final int categoryImageMomPage;
  final int categoryImageDadPage;
  final String uid;
  final String user;

  @override
  _ShowImageGalleryNewMomUnrecognizeState createState() =>
      _ShowImageGalleryNewMomUnrecognizeState();
}

class _ShowImageGalleryNewMomUnrecognizeState
    extends State<ShowImageGalleryNewMomUnrecognize> {
  String imageGallery;
  final String galleryDB = "01Gallery";
  final String navigate = "form";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            centerTitle: true,
            title: Text('Picture'),
            backgroundColor: Colors.purple[200],
            automaticallyImplyLeading: false,
          )),
      body: Image.file(
        File(widget.image),
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              setState(() {
                imageGallery = widget.image;
                print("Image Gallery ${widget.image}");
                //buat ni
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  return NewProfileKidUnrecognize(
                      galleryDB,
                      galleryDB,
                      galleryDB,
                      widget.imageKid,
                      widget.image,
                      widget.imageDad,
                      widget.categoryImagePage,
                      widget.categoryImageMomPage,
                      widget.categoryImageDadPage,
                      widget.uid,
                      widget.user);
                }));
              });
            },
            label: Text('Save'),
            icon: Icon(Icons.done),
          ),
          SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              Navigator.pop(context);
            },
            label: Text('Cancel'),
            icon: Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }
}
