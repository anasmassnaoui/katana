import 'package:flutter/material.dart';

void loadPage(BuildContext context, Widget child) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => child));
}
