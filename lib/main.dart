import 'package:flutter/material.dart';
import 'package:katana/pages/home_page.dart';
import 'package:katana/setup/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katana',
      theme: ThemeData.dark().copyWith(accentColor: Colors.white),
      home: HomePage(),
    );
  }
}
