import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Something Went Wrong Try later",
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}