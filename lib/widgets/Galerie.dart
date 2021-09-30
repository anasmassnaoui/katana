import 'package:flutter/material.dart';
import 'package:katana/entities/catalogue.dart';
import 'package:katana/entities/cover.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/client.dart';
import 'package:katana/utils/loads.dart';
import 'package:katana/widgets/loading.dart';

class Galerie extends StatelessWidget {
  final Catalogue catalogue;
  final void Function({
    List<Cover> oldCovers,
    int page,
    bool hasReachedMax,
  }) fetchCovers;

  const Galerie({
    Key key,
    this.catalogue,
    this.fetchCovers,
  }) : super(key: key);

  Widget buildFooter() {
    if (!catalogue.hasReachedMax)
      //return CupertinoActivityIndicator.partiallyRevealed();
      return Loading(padding: EdgeInsets.symmetric(vertical: 10));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!catalogue.hasReachedMax &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 60) {
          fetchCovers(
            oldCovers: catalogue.covers,
            page: catalogue.page,
            hasReachedMax: catalogue.hasReachedMax,
          );
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => GestureDetector(
                  onTap: () {
                    final cover = catalogue.covers[index];
                    loadCover(context, cover);
                  },
                  child: Card(
                    child: Image.network(
                      catalogue.covers[index].image,
                      fit: BoxFit.fill,
                      headers: getIt<Client>().headers,
                    ),
                  ),
                ),
                childCount: catalogue.covers.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.7,
                  crossAxisCount:
                      (MediaQuery.of(context).size.width / 140).round())),
          SliverToBoxAdapter(
            child: buildFooter(),
          )
        ],
      ),
    );
  }
}
