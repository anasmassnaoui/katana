import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Color color;

  Loading({this.padding, this.color: Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Center(
        child: SizedBox(
          child: CircularProgressIndicator(
            value: null,
            color: color,
          ),
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
