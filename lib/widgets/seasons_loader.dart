import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katana/blocs/catalogue_bloc.dart';
import 'package:katana/entities/season.dart';
import 'package:katana/utils/loads.dart';
import 'package:katana/widgets/episod_view.dart';
import 'package:katana/widgets/loading.dart';

class SeasonsLoader extends StatefulWidget {
  final List<Season> loadedSeasons;
  final int currentSeason;
  final List<Map<String, dynamic>> seasonsSchema;
  final ScrollController controller;
  final void Function(int, int) onPlay;

  const SeasonsLoader({
    Key key,
    this.loadedSeasons,
    this.currentSeason,
    this.seasonsSchema,
    this.controller,
    this.onPlay,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SeasonsLoaderState();
}

class SeasonsLoaderState extends State<SeasonsLoader> {
  bool loaded = false;
  bool disableNonScrollEffect = false;

  @override
  void initState() {
    super.initState();
    dispatchLoadSeason();
    widget.controller.addListener(() => loadCurrentSeason());
  }

  void loadCurrentSeason() {
    if (!loaded &&
        widget.currentSeason < widget.seasonsSchema.length &&
        widget.controller.position.pixels >=
            widget.controller.position.maxScrollExtent - 60) {
      loaded = true;
      disableNonScrollEffect = true;
      dispatchLoadSeason();
    }
  }

  void dispatchLoadSeason() {
    if (widget.currentSeason < widget.seasonsSchema.length)
      BlocProvider.of<CatalogueBloc>(context).add(
        SeasonEvent(
          link: widget.seasonsSchema[widget.currentSeason]['link'],
        ),
      );
  }

  @override
  void didUpdateWidget(covariant SeasonsLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    loaded = false;
    if (!disableNonScrollEffect) loadCurrentSeason();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  widget.seasonsSchema[index]['title'],
                  textAlign: TextAlign.end,
                ),
              ),
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemBuilder: (_, _index) => EpisodeView(
                    episode: widget.loadedSeasons[index].episodes[_index],
                    onPlay: (_) => widget.onPlay(index, _index),
                    onDownload: (link) => onDownload(context, link),
                  ),
                  itemCount: widget.loadedSeasons[index].episodes.length,
                ),
              ),
            ],
          ),
          separatorBuilder: (context, index) => Divider(),
          itemCount: widget.loadedSeasons.length,
        ),
        widget.currentSeason < widget.seasonsSchema.length
            ? Container(
                padding: EdgeInsets.all(5.0),
                child: Loading(),
              )
            : Container(),
      ],
    );
  }
}
