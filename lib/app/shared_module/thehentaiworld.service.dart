import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

enum ThumbType {
  image,
  video,
}

class ThumbData {
  final ThumbType type;

  /// 详情页面
  final String href;

  /// 封面
  final String image;

  /// 原图
  final String originalImage;

  /// type为[ThumbType.video]时，将填充视频地址
  final String videoSrc;

  ThumbData({
    this.type,
    this.href,
    this.image,
    this.originalImage,
    this.videoSrc,
  });

  @override
  String toString() {
    return """{
      type: ${this.type},
      href: ${this.href},
      image: ${this.image},
      originalImage: ${this.originalImage},
      videoSrc: ${this.videoSrc},
    }""";
  }
}

class SearchResponse {
  final int startPage;
  final int endPage;
  final List<ThumbData> thumbs;

  SearchResponse({this.startPage, this.endPage, this.thumbs});

  @override
  String toString() {
    return """{
      startPage: ${this.startPage},
      endPage: ${this.endPage},
      data: ${this.thumbs},
    }""";
  }
}

Future<dom.Document> $document(String url) async {
  var r = await http.get(url);
  return parse(r.body);
}

class TheHentaiWorldService {
  Future<SearchResponse> search({String s, int page = 1}) async {
    dom.Document document =
        await $document('https://thehentaiworld.com/tag/$s/page/$page/');

    var thumbs = queryThumbs(document, '#thumbContainer');

    dom.Element ol = document.querySelector('#more-hentai ol');
    var pages = ol.querySelectorAll('.page');
    return SearchResponse(
      startPage: int.parse(pages.first.text),
      endPage: int.parse(pages.last.text),
      thumbs: thumbs,
    );
  }

  getThumbDetail(ThumbData thumb) {}

  /// 获取[#miniThumbContainer]下的thumbs
  Future<List<ThumbData>> queryMiniThumbs(dom.Document document) async {
    return queryThumbs(document, '#miniThumbContainer');
  }

  /// 获取[thumb]有关类容
  /// 并不是每次都一样，而是动态的
  Future<List<ThumbData>> queryRelatedList(dom.Document document) async {
    return queryThumbs(document, '#related');
  }

  /// 在element下查找[.thumb]元素
  List<ThumbData> queryThumbs(dom.Document document, String selector) {
    var container = document.querySelector(selector);
    if (container == null) return List<ThumbData>();

    var thumbs = container.querySelectorAll('.thumb');
    if (thumbs == null) return List<ThumbData>();

    List<ThumbData> itemObjs = [];
    for (dom.Element item in thumbs) {
      // 判断是否为video资源
      var h4 = item.querySelector('h4');
      ThumbType type = ThumbType.image;
      if (h4 != null && h4.text.trim() == 'Video') {
        type = ThumbType.video;
      }

      String image = item.querySelector('img').attributes['src'];
      itemObjs.add(
        ThumbData(
          type: type,
          href: item.querySelector('a').attributes['href'],
          image: image,
          originalImage: image.replaceAll(RegExp(r'-\d+x\d+'), ''),
          videoSrc: type == ThumbType.video
              ? image
                  .replaceAll(RegExp(r'_thumb1-\d+x\d+'), '')
                  .replaceAll(RegExp(r'.jpg$'), '.mp4')
              : null,
        ),
      );
    }

    return itemObjs;
  }
}
