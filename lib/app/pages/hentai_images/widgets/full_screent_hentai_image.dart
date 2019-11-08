import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thehentaiworld/app/pages/hentai_images/widgets/thumb_image_pages.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';

class FullScreentHentaiImage extends StatefulWidget {
  final List<ThumbData> thumbs;
  final int index;

  const FullScreentHentaiImage({
    Key key,
    @required this.thumbs,
    @required this.index,
  }) : super(key: key);
  @override
  FfulSscreentHentaiImageState createState() => FfulSscreentHentaiImageState();
}

class FfulSscreentHentaiImageState extends State<FullScreentHentaiImage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThumbImagePages(
        thumbs: widget.thumbs,
        initialPage: widget.index,
        full: true,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
