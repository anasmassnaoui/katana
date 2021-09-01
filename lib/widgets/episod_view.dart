import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:katana/entities/episode.dart';
import 'network_image.dart' as ni;

class EpisodeView extends StatelessWidget {
  final Episode episode;
  final void Function(String) onPlay;
  final void Function(String) onDownload;

  const EpisodeView({
    Key key,
    @required this.episode,
    this.onPlay,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      color: Colors.black,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: ni.NetworkImage(link: episode.image),
          ),
          Positioned.fill(
              child: IconButton(
            iconSize: 40,
            icon: Icon(CupertinoIcons.play_fill),
            onPressed: () => onPlay(episode.link),
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
                  onPressed: () => onDownload(episode.link),
                ),
              ),
            ),
          ),
          Positioned.fill(
              child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(left: 35, right: 5.0),
              child: Text(
                episode.title,
                textDirection: TextDirection.rtl,
              ),
            ),
          ))
        ],
      ),
    );
  }
}
