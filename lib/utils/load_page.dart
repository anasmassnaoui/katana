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
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => child,
  );
}
