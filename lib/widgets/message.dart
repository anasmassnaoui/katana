import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry padding;

  Message({
    @required this.message,
    this.padding: EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
