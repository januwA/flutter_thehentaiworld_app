import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/store/main.store.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';

import '../../../main.dart';
import '../../shared_module/widgets/type_tag.dart';
import 'widgets/thumb_image_pages.dart';

class HentaiImages extends StatefulWidget {
  final ThumbData thumb;

  const HentaiImages({Key key, @required this.thumb}) : super(key: key);
  @override
  HhentaiImagesState createState() => HhentaiImagesState();
}

class HhentaiImagesState extends State<HentaiImages> {
  TheHentaiWorldService theHentaiWorldService =
      getIt<TheHentaiWorldService>(); // 注入

  MainStore mainStore = getIt<MainStore>(); // 注入
  VideoController vc;

  HentaiImagesData _hentaiImagesData;
  List<ThumbData> get relatedThumbs => _hentaiImagesData.relatedThumbs;
  List<ThumbData> get miniThumbs => _hentaiImagesData.miniThumbs;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    loading = true;
    if (widget.thumb.type == ThumbType.video) {
      vc = VideoController(
        source: VideoPlayerController.network(widget.thumb.videoSrc),
        autoplay: true,
        loop: true,
        volume: mainStore.openVolume ? 1.0 : 0.0,
      );
      vc.showVideoCtrl(false);
      vc.initialize();
    }
    _init();
  }

  Future<void> _init() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                if (widget.thumb.type == ThumbType.video)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoBox(controller: vc),
                  )
                else
                  AspectRatio(
                    aspectRatio: 9 / 15,
                    child: ThumbImagePages(
                      thumbs: miniThumbs,
                      onTap: (page) {
                        Navigator.of(context).pushNamed(
                          '/full-hentai-images',
                          arguments: {
                            'thumbs': miniThumbs,
                            'index': page,
                          },
                        );
                      },
                    ),
                  ),
                SizedBox(height: 10),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SelectableText(
                      'Related Hentai',
                      style: Theme.of(context).textTheme.title,
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
                // AspectRatio(
                //   aspectRatio: 9 / 15,
                //   child: ThumbImagePages(
                //     thumbs: relatedThumbs,
                //     onTap: (index) {
                //       // 跳转其他页面时，暂停视频的播放
                //       if (vc?.videoCtrl?.value?.isPlaying ?? false) {
                //         vc.togglePlay();
                //       }
                //       Navigator.of(context).pushNamed(
                //         '/hentai-images',
                //         arguments: relatedThumbs[index],
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
    );
  }
}
