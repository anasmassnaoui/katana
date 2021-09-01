import 'package:flutter/material.dart';
import 'package:katana/widgets/rounded_box.dart';
import 'package:katana/widgets/network_image.dart' as ni;

class SerieView extends StatelessWidget {
  final String image;
  final String title;
  final String type;
  final int seasons;

  const SerieView({Key key, this.image, this.title, this.type, this.seasons})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30.0),
              ),
              child: ni.NetworkImage(link: image),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          left: 8.0,
                        ),
                        child: RoundedBox(
                          radius: 20,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RoundedBox(
                          radius: 50,
                          child: Icon(
                            Icons.close,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RoundedBox(
                          radius: 20,
                          isExpand: true,
                          child: Text(
                            type,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RoundedBox(
                          radius: 20,
                          isExpand: true,
                          child: Text(
                            'عدد المواسم : ' + seasons.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
