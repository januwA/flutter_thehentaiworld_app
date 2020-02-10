import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/store/main.store.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import '../../../main.dart';
import '../../shared_module/thehentaiworld.service.dart';
import '../../shared_module/to_search_result.dart';
import '../../shared_module/widgets/type_tag.dart';

class HentaiImages extends StatefulWidget {
  final ThumbData thumb;

  const HentaiImages({Key key, @required this.thumb}) : super(key: key);
  @override
  HhentaiImagesState createState() => HhentaiImagesState();
}

class HhentaiImagesState extends State<HentaiImages> {
  final theHentaiWorldService = getIt<TheHentaiWorldService>(); // 注入
  final mainStore = getIt<MainStore>(); // 注入
  VideoController vc;

  HentaiImagesData _hentaiImagesData;
  bool loading = true;
  List<ThumbData> get relatedThumbs => _hentaiImagesData.relatedThumbs;
  List<ThumbData> get miniThumbs => _hentaiImagesData.miniThumbs;
  List<HentaiTag> get tags => _hentaiImagesData.tags;
  bool get isVideo => widget.thumb.type == ThumbType.video;
  double get _volume => mainStore.openVolume ? 1.0 : 0.0;

  bool showTag = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    if (isVideo) {
      vc ??= VideoController(
        source: VideoPlayerController.network(widget.thumb.videoSrc),
        autoplay: true,
        looping: true,
        volume: _volume,
      )
        ..setControllerLayer(show: false)
        ..initialize();
    }
    _init();
  }

  Future<void> _init() async {
    setState(() {
      loading = true;
    });
    _hentaiImagesData =
        await theHentaiWorldService.getHentaiImages(widget.thumb);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void setOpenVolume() {
    if (vc != null) {
      mainStore.openVolume = vc.volume != 0.0 ? true : false;
    }
  }

  @override
  void dispose() {
    setOpenVolume();
    vc?.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  _toogleTags() {
    setState(() {
      showTag = !showTag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                if (isVideo)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoBox(controller: vc),
                  )
                else
                  for (var item in miniThumbs)
                    AjanuwImage(
                      image: AjanuwNetworkImage(item.originalImage),
                      fit: BoxFit.cover,
                      loadingWidget: AjanuwImage.defaultLoadingWidget,
                      loadingBuilder: AjanuwImage.defaultLoadingBuilder,
                      errorBuilder: AjanuwImage.defaultErrorBuilder,
                    ),
                SizedBox(height: 10),
                Center(
                  child: RaisedButton(
                    color: Colors.orange,
                    onPressed: _toogleTags,
                    child: Text(
                      "Toogle Tags",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedCrossFade(
                      firstChild: Wrap(
                        alignment: WrapAlignment.start,
                        children: <Widget>[
                          for (HentaiTag tag in tags)
                            RaisedButton(
                              onPressed: () {
                                toSearchResult(SearchType.tag, tag.tag);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(tag.text),
                                  SizedBox(width: 6),
                                  Text(tag.count),
                                ],
                              ),
                            ),
                        ],
                      ),
                      secondChild: SizedBox(),
                      crossFadeState: showTag
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                    ),
                  ],
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SelectableText(
                      'Related Hentai',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GridView.count(
                  primary: false,
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  children: relatedThumbs.map((ThumbData thumb) {
                    return InkWell(
                      onTap: () {
                        setOpenVolume();
                        vc?.pause(); // 跳转其他页面时，暂停视频的播放
                        Navigator.of(context).pushNamed(
                          '/hentai-images',
                          arguments: thumb,
                        );
                      },
                      child: Card(
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: AjanuwImage(
                                image: AjanuwNetworkImage(thumb.image),
                                fit: BoxFit.cover,
                                frameBuilder: AjanuwImage.defaultFrameBuilder,
                              ),
                            ),
                            if (thumb.type == ThumbType.video)
                              Align(
                                alignment: Alignment.topLeft,
                                child: TypeTag(text: 'Video'),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
