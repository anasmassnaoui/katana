import 'package:flutter/material.dart';
import 'package:katana/setup/get_it.dart';
import 'package:katana/utils/client.dart';
import 'package:katana/widgets/loading.dart';

class NetworkImage extends StatelessWidget {
  final String link;

  const NetworkImage({Key key, this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      link,
      headers: getIt<Client>().headers,
      loadingBuilder: (context, child, loadingProgress) =>
          (loadingProgress == null ||
                  loadingProgress.cumulativeBytesLoaded ==
                      loadingProgress.expectedTotalBytes)
              ? child
              : Loading(),
    );
  }
}
