import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/store/main.store.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import 'widgets/tag.dart';
import '../../../main.dart';
import '../../shared_module/thehentaiworld.service.dart';
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

  ScrollController controller = ScrollController();

  VideoController vc;

  HentaiImagesData _hentaiImagesData;
  bool loading = true;
  List<ThumbData> get relatedThumbs => _hentaiImagesData.relatedThumbs;
  List<ThumbData> get miniThumbs => _hentaiImagesData.miniThumbs;
  List<TagData> get tags => _hentaiImagesData.tags;
  bool get isVideo => widget.thumb.type == ThumbType.video;
  double get _volume => mainStore.openVolume ? 1.0 : 0.0;

  bool showTag = false;

  @override
  void initState() {
    super.initState();
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
    if (vc != null) mainStore.setOpenVolume(vc.volume);
  }

  @override
  void dispose() {
    setOpenVolume();
    vc?.dispose();
    controller?.dispose();
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
      backgroundColor: Colors.white,
      body: loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _init,
              child: CustomScrollView(
                controller: controller,
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
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
                              errorBuilder: (_, __) => Icon(Icons.error),
                            ),
                        SizedBox(height: 20),
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
                        AnimatedCrossFade(
                          firstChild: Wrap(
                            children: tags.map((tag) => Tag(tag)).toList(),
                          ),
                          secondChild: SizedBox(),
                          crossFadeState: showTag
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: Duration(milliseconds: 300),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: SelectableText(
                            'Related Hentai',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverGrid.count(
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
            ),
    );
  }
}
