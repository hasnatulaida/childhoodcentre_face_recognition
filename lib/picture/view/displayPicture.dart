import 'package:flutter/material.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen(this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture'),
        actions: <Widget>[
          GestureDetector(
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            onTap: () {
              
            },
          ),
        ],
      ),
      body: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
            color: Colors.red,
            image: DecorationImage(
                image: NetworkImage(imagePath), fit: BoxFit.cover),
            borderRadius: BorderRadius.all(Radius.circular(75.0)),
            boxShadow: [BoxShadow(blurRadius: 7.0, color: Colors.black)]),
      ),
    );
  }
}
