import 'package:flutter/cupertino.dart';
import 'package:katana/widgets/loading.dart';

Future<String> selectChoice(
    BuildContext context, Future<List<String>> choices) {
  return showCupertinoModalPopup<String>(
    context: context,
    semanticsDismissible: true,
    builder: (context) => FutureBuilder(
      future: choices,
      builder: (context, snapshot) {
        final choices = snapshot.data as List<String>;
        return CupertinoActionSheet(
          message: !snapshot.hasData ? Loading() : null,
          actions: snapshot.hasData
              ? choices
                  .map((choice) => CupertinoActionSheetAction(
                      onPressed: () => Navigator.of(context).pop(choice),
                      child: Text(choice)))
                  .toList()
              : [],
        );
      },
    ),
  );
}
