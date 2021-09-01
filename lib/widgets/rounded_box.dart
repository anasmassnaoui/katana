import 'package:flutter/material.dart';

class RoundedBox extends StatelessWidget {
  final double radius;
  final Widget child;
  final bool isExpand;

  const RoundedBox({Key key, this.radius, this.child, this.isExpand: false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      width: isExpand ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
