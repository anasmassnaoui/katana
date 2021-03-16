import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final GestureTapCallback onTap;
  final String text;
  const Label(
    this.text, {
    Key key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onTap,
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(text),
        ));
    return GestureDetector(
      onTap: onTap,
      child: Expanded(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(this.text),
          ),
        ),
      ),
    );
  }
}
