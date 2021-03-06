import 'dart:io';

import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/store/main.store.dart';
import 'package:video_box/video.controller.dart';
import 'package:video_box/video_box.dart';
import 'package:video_player/video_player.dart';
import 'package:toast/toast.dart';

import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widgets/tag.dart';
import '../../../main.dart';
import '../../shared_module/thehentaiworld.service.dart';
import '../../shared_module/widgets/type_tag.dart';

/// 详情页面
class HentaiImages extends StatefulWidget {
  final ThumbData thumb;

  const HentaiImages({Key key, @required this.thumb}) : super(key: key);
  @override
  HhentaiImagesState createState() => HhentaiImagesState();
}

class HhentaiImagesState extends State<HentaiImages> {
  final theHentaiWorldService = getIt<TheHentaiWorldService>(); // 注入
  final mainStore = getIt<MainStore>(); // 注入
  final api = AjanuwHttp();

  Offset _tapPosition;

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
    _init();
  }

  Future<void> _initVideo() async {
    if (!isVideo) return;

    // 探测video src是否可用
    var r = await api.head(widget.thumb.videoSrc);
    if (r.statusCode != 200) {
      widget.thumb.videoSrc =
          widget.thumb.videoSrc.replaceFirst('.mp4', '.webm');
      var r = await api.head(widget.thumb.videoSrc);
      if (r.statusCode != 200) {
        widget.thumb.videoSrc =
            await theHentaiWorldService.getVideoSrc(widget.thumb.href);
      }
    }

    vc ??= VideoController(
      source: VideoPlayerController.network(widget.thumb.videoSrc),
      autoplay: true,
      looping: true,
      volume: _volume,
    )
      ..setControllerLayer(false)
      ..initialize();
  }

  Future<void> _init() async {
    setState(() {
      loading = true;
    });

    await _initVideo();

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

  void _showCustomMenu(String originalImage) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    showMenu(
      context: context,
      items: <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Download'),
        ),
      ],
      position: RelativeRect.fromRect(
          _tapPosition & Size.zero, // smaller rect, the touch area
          Offset.zero & overlay.size // Bigger rect, the entire screen
          ),
    ).then<void>((int r) {
      if (r == null) {
        print('cancel');
        return;
      }

      if (r == 1) _download(originalImage);
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _download(String originalImage) async {
    // 1. 获取权限
    var storageStatus = await Permission.storage.status;

    // 没有权限则申请
    if (!storageStatus.isGranted) {
      storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) return;
    }

    // 2. 获取保存目录
    // 缓存目录路径，不免每次都选择目录
    final String dirPath = await FilePicker.platform.getDirectoryPath();

    if (dirPath == null) return;
    final String savePath = path.join(dirPath, path.basename(originalImage));

    // 3. 从网络获取图片保存到用户手机
    Toast.show("开始下载", context);
    api.getStream(originalImage).then((r) {
      var f$ = File(savePath).openWrite();
      r.stream.listen(
        f$.add,
        onDone: () {
          Toast.show("下载完成", context);
          f$.close();
        },
        onError: (e) {
          Toast.show("保存失败", context, textColor: Colors.red);
          f$.close();
        },
      );
    }).catchError((e) {
      print(e);
      Toast.show("下载失败", context, textColor: Colors.red);
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
                          GestureDetector(
                            onLongPress: () => _showCustomMenu(
                                widget.thumb.videoSrc), // 长按打开Menu菜单
                            onTapDown: _storePosition, // 按下去的时候记住位置
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: VideoBox(controller: vc),
                            ),
                          )
                        else
                          for (var item in miniThumbs)
                            GestureDetector(
                              onLongPress: () => _showCustomMenu(
                                  item.originalImage), // 长按打开Menu菜单
                              onTapDown: _storePosition, // 按下去的时候记住位置
                              child: AjanuwImage(
                                image: AjanuwNetworkImage(item.originalImage),
                                fit: BoxFit.cover,
                                loadingWidget: AjanuwImage.defaultLoadingWidget,
                                loadingBuilder:
                                    AjanuwImage.defaultLoadingBuilder,
                                errorBuilder: (_, __, ___) => Icon(Icons.error),
                              ),
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
