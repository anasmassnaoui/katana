class Quality {
  final String quality;
  final String link;

  Quality(this.quality, this.link);

  @override
  String toString() {
    return "$quality: $link";
  }
}
