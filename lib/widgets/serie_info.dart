import 'package:flutter/material.dart';

class SerieInfo extends StatelessWidget {
  final String title;
  final String story;

  const SerieInfo({Key key, this.title, this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Text(
            story,
            textDirection: story.contains(RegExp(r'[\u0600-\u06FF]'))
                ? TextDirection.rtl
                : TextDirection.ltr,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
