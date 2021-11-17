import 'dart:io';

import 'package:face_recognition/kid/view/newprofilekidu.dart';
import 'package:flutter/material.dart';

class ShowImageGalleryNewDadUnrecognize extends StatefulWidget {
  ShowImageGalleryNewDadUnrecognize(
      this.imageKid,
      this.imageMom,
      //dad
      this.image,
      this.categoryImagePage,
      this.categoryImageMomPage,
      this.categoryImageDadPage,
      this.uid,
      this.user);

  final String image;
  final String imageKid;
  final String imageMom;
  final int categoryImagePage;
  final int categoryImageMomPage;
  final int categoryImageDadPage;
  final String uid;
  final String user;

  @override
  _ShowImageGalleryNewDadUnrecognizeState createState() =>
      _ShowImageGalleryNewDadUnrecognizeState();
}

class _ShowImageGalleryNewDadUnrecognizeState
    extends State<ShowImageGalleryNewDadUnrecognize> {
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
                      widget.imageMom,
                      imageGallery,
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
