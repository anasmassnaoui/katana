import 'package:flutter/material.dart';

void loadPage(BuildContext context, Widget child) {
  Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => child,
        opaque: false,
      ));
  // showModalBottomSheet(
  //   isScrollControlled: false,
  //   context: context,
  //   isDismissible: false,
  //   //shape: OutlineInputBorder(
  //   //    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
  //   //    borderSide: BorderSide(style: BorderStyle.none)),
  //   //clipBehavior: Clip.hardEdge,
  //   //backgroundColor: Colors.transparent,
  //   builder: (_) => child,
  // );

  // showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (_) => child,
  // );
}
