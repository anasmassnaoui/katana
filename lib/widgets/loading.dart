import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  Loading({
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Center(
        child: SizedBox(
          child: CircularProgressIndicator(
            value: null,
          ),
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
