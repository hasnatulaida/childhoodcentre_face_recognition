import 'package:face_recognition/Authentication/components/text_field_container.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
  }) : super(key: key);

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool showPass = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: showPass,
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          // suffixIcon: Icon(
          //   Icons.visibility,
          //   color: kPrimaryColor,
          // ),
          suffixIcon: IconButton(
              icon: Icon(Icons.visibility),
              onPressed: () {
                if (showPass == true) {
                  setState(() {
                    showPass = false;
                  });
                } else {
                  setState(() {
                    showPass = true;
                  });
                }
              },
              color: kPrimaryColor),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
