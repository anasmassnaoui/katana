import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void loadPage(BuildContext context, Widget child) {
  // Navigator.push(
  //     context,
  //     PageRouteBuilder(
  //       pageBuilder: (_, __, ___) => child,
  //       opaque: false,
  //     ));

  // Navigator.push(context, MaterialPageRoute(builder: (_) => child));

  // showModalBottomSheet(
  //   isScrollControlled: true,
  //   context: context,
  //   isDismissible: false,
  //   //shape: OutlineInputBorder(
  //   //    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
  //   //    borderSide: BorderSide(style: BorderStyle.none)),
  //   //clipBehavior: Clip.hardEdge,
  //   //backgroundColor: Colors.transparent,
  //   builder: (_) => child,
  // );

  // showCupertinoDialog(context: context, builder: (_) => Material(child: child));

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Material(
      child: child,
      type: MaterialType.transparency,
    ),
  );
}
