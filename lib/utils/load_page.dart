import 'package:flutter/material.dart';

void loadPage(BuildContext context, Widget child) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (_) => DraggableScrollableSheet(
  //       initialChildSize: 0.5,
  //       builder: (context, controller) => child,
  //     ),
  //   ),
  // );
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: OutlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        borderSide: BorderSide(style: BorderStyle.none)),
    clipBehavior: Clip.hardEdge,
    builder: (_) => child,
  );

  // showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (_) => child,
  // );
}
