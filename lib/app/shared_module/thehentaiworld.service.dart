import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

enum ThumbType {
  image,
  video,
}

enum SearchType { neww, tag, updated }

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

class TagData {
  final String tag;
  final String label;

  TagData({this.tag, this.label});

  @override
  String toString() {
    return """{
      tag: $tag,
      label: $label
      }""";
  }
}

class HentaiImagesData {
  final List<ThumbData> miniThumbs;
  final List<ThumbData> relatedThumbs;

  HentaiImagesData({this.miniThumbs, this.relatedThumbs});
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
  /// 搜索tag
  Future<SearchResponse> searchTag({String tag, int page = 1}) async {
    dom.Document document =
        await $document('https://thehentaiworld.com/tag/$tag/page/$page/');
    return _getResponse(document);
  }

  /// 搜索new
  Future<SearchResponse> searchNew({int page = 1}) async {
    dom.Document document =
        await $document('https://thehentaiworld.com/page/$page/?new');
    return _getResponse(document);
  }

  /// 搜索updated
  Future<SearchResponse> searchUpdated({int page = 1}) async {
    dom.Document document =
        await $document('https://thehentaiworld.com/page/$page/?updated');
    return _getResponse(document);
  }

  /// 缓存tags
  /// 因为tags的变化不是很频繁
  List<TagData> _tags;

  /// 返回所有的tags
  Stream<List<TagData>> getTags() async* {
    if (_tags != null) {
      yield _tags;
    }
    dom.Document document = await $document('https://thehentaiworld.com/tags/');
    dom.Element tagListContainer = document.querySelector('#tag-list');
    List<dom.Element> tagsList = tagListContainer.querySelectorAll('.artist');
    List<TagData> tags = List<TagData>();

    for (var i = 0; i < tagsList.length; i++) {
      var tag = tagsList[i];
      tags.add(TagData(
        label: tag.text.trim(),
        tag: tag.attributes['href'].split('/').last,
      ));
      yield tags;
    }
    _tags = tags;
    return;
  }

  SearchResponse _getResponse(dom.Document document) {
    var thumbs = _queryThumbs(document, '#thumbContainer');

    dom.Element ol = document.querySelector('#more-hentai ol');
    int startPage = 0;
    int endPage = 0;
    if (ol != null) {
      var pages = ol.querySelectorAll('.page');
      startPage = int.parse(pages.first.text);
      endPage = int.parse(pages.last.text);
    }
    return SearchResponse(
      startPage: startPage,
      endPage: endPage,
      thumbs: thumbs,
    );
  }

  /// 路由为[/hentai-images], 其实有点像detail页面
  Future<HentaiImagesData> getHentaiImages(ThumbData thumb) async {
    var document = await $document(thumb.href);
    List<ThumbData> _miniThumbs = List<ThumbData>();
    if (thumb.type == ThumbType.image) {
      _miniThumbs = await _queryMiniThumbs(document);
      if (_miniThumbs.isEmpty) {
        // 有可能不存在多个视图返回的空列表，所以显示自己
        _miniThumbs.add(thumb);
      }
    }
    List<ThumbData> relatedThumbs = await _queryRelatedList(document);
    return HentaiImagesData(
      miniThumbs: _miniThumbs,
      relatedThumbs: relatedThumbs,
    );
  }

  /// 获取[#miniThumbContainer]下的thumbs
  Future<List<ThumbData>> _queryMiniThumbs(dom.Document document) async {
    return _queryThumbs(document, '#miniThumbContainer');
  }

  /// 获取[thumb]有关类容
  /// 并不是每次都一样，而是动态的
  Future<List<ThumbData>> _queryRelatedList(dom.Document document) async {
    return _queryThumbs(document, '#related');
  }

  /// 在element下查找[.thumb]元素
  List<ThumbData> _queryThumbs(dom.Document document, String selector) {
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
