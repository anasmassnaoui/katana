import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/pages/movie_page.dart';
import 'package:katana/pages/serie_page.dart';
import 'package:katana/repositories/egybest_repository.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/selector.dart';
import 'package:url_launcher/url_launcher.dart';

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

void loadCover(BuildContext context, Cover cover) {
  switch (cover.type) {
    case CoverType.Movie:
      loadPage(
          context,
          MoviePage(
            link: cover.link,
            title: cover.title,
          ));
      break;
    case CoverType.Serie:
      loadPage(
          context,
          SeriePage(
            link: cover.link,
            title: cover.title,
          ));
      break;
    default:
  }
}

void onDownload(BuildContext context, String link) async {
  final qualities = await getIt<EgybestRipository>().getVideoQualities(link);
  final choice = await selectChoice(
    context,
    Future.value(qualities.map((e) => e.quality).toList()),
  );
  if (choice != null) {
    final quality = qualities.firstWhere((e) => e.quality == choice);
    String directLink =
        await getIt<EgybestRipository>().getDirectLink(quality.link);
    launch(directLink);
  }
}
