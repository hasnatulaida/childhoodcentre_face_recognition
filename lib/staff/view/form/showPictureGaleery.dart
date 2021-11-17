import 'dart:io';

import 'package:face_recognition/staff/view/form/staffform.dart';
import 'package:flutter/material.dart';

class ShowImageGalleryNew extends StatefulWidget {
  ShowImageGalleryNew(this.image);

  final String image;

  @override
  _ShowImageGalleryNewState createState() => _ShowImageGalleryNewState();
}

class _ShowImageGalleryNewState extends State<ShowImageGalleryNew> {
  String imageGallery;
  final String galleryDB = "01Gallery";

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
        ),
      ),
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
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) {
                  return StaffForm(imageGallery, galleryDB);
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
