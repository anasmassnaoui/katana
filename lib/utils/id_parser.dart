String getId(String id) =>
    Uri.parse(id).pathSegments.lastWhere((e) => e.isNotEmpty);
