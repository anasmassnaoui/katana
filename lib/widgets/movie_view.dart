import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:katana/widgets/rounded_box.dart';
import 'package:katana/widgets/network_image.dart' as ni;

class MovieView extends StatelessWidget {
  final String image;
  final String title;
  final String type;
  final String duration;
  final String link;
  final void Function(String) onPlay;
  final void Function(String) onDownload;

  const MovieView({
    Key key,
    this.image,
    this.title,
    this.type,
    this.duration,
    this.link,
    this.onPlay,
    this.onDownload,
  }) : super(key: key);

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
              child: Container(
                color: Colors.black,
                child: Stack(children: [
                  Opacity(
                    opacity: 0.2,
                    child: ni.NetworkImage(link: image),
                  ),
                  Positioned.fill(
                      child: IconButton(
                    iconSize: 40,
                    icon: Icon(CupertinoIcons.play_fill),
                    onPressed: () => onPlay(link),
                  )),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.only(left: 5.0),
                          icon: Icon(
                            CupertinoIcons.cloud_download,
                          ),
                          onPressed: () => onDownload(link),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
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
                            duration,
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
