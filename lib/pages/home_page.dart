import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:katana/widgets/catalogue_view.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TextEditingController textEditingController = TextEditingController();
  int selectedPage = 1;
  bool isSearching = false;
  String searchValue;

  void selectPage(int page) {
    if (page != selectedPage)
      setState(() {
        selectedPage = page;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: !isSearching
            ? Text('Katana')
            : TextField(
                controller: textEditingController,
                onSubmitted: (value) => setState(() => searchValue = value),
                autofocus: true,
                decoration: InputDecoration(
                    hintText: 'Search',
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    prefixIcon: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => setState(() {
                        isSearching = !isSearching;
                        searchValue = null;
                        textEditingController.clear();
                      }),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => textEditingController.clear(),
                    )),
              ),
        leading: !isSearching
            ? IconButton(
                icon: Icon(CupertinoIcons.search),
                onPressed: () => setState(() => isSearching = !isSearching),
              )
            : null,
      ),
      body: CatalogueView(
        searchValue: searchValue,
        isSearching: isSearching,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BottomButton(
                text: 'Download',
                expand: selectedPage == 0,
                icon: CupertinoIcons.cloud_download,
                onTap: () => selectPage(0),
              ),
              BottomButton(
                text: 'Home',
                expand: selectedPage == 1,
                icon: CupertinoIcons.home,
                onTap: () => selectPage(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool expand;
  final GestureTapCallback onTap;

  BottomButton({
    Key key,
    @required this.icon,
    @required this.text,
    this.expand: true,
    this.onTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => BottomButtonState();
}

class BottomButtonState extends State<BottomButton>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                widget.expand ? Colors.white : Theme.of(context).primaryColor),
        child: AnimatedSize(
          vsync: this,
          duration: Duration(milliseconds: 300),
          curve: Curves.decelerate,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(widget.icon,
                  color: widget.expand
                      ? Theme.of(context).primaryColor
                      : Colors.white),
              Visibility(
                visible: widget.expand,
                child: SizedBox(
                  width: widget.expand ? 4 : 0,
                ),
              ),
              Text(
                widget.expand ? widget.text : '',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
