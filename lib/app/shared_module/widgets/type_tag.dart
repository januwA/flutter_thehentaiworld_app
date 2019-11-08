import 'package:flutter/material.dart';

class TypeTag extends StatelessWidget {
  final String text;

  const TypeTag({Key key, this.text = 'Video'}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 6, top: 6),
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.8),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
