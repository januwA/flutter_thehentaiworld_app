import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:random_color/random_color.dart';

enum ThumbType {
  image,
  video,
}

enum SearchType { neww, tag, updated, search }

class ThumbData {
  final ThumbType type;

  /// 详情页面
  final String href;

  /// 封面
  final String image;

  /// 原图
  final String originalImage;

  /// type为[ThumbType.video]时，将填充视频地址
  String videoSrc;

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

/// tag列表的tag
class TagData {
  final String tag;
  final String label;
  final Color color;
  final String count;

  const TagData({this.tag, this.label, this.color, this.count});

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
  final List<TagData> tags;

  const HentaiImagesData({this.miniThumbs, this.relatedThumbs, this.tags});
}

class SearchResponse {
  final int startPage;
  final int endPage;
  final List<ThumbData> thumbs;

  const SearchResponse({this.startPage, this.endPage, this.thumbs});

  @override
  String toString() {
    return """{
      startPage: ${this.startPage},
      endPage: ${this.endPage},
      data: ${this.thumbs},
    }""";
  }
}

Future<dom.Document> $document(String url) async =>
    parse((await http.get(url)).body);

class TheHentaiWorldService {
  /// document.querySelector('[rel=alternate]')
  dom.Element _getLinkAlternate(dom.Document document) =>
      document.querySelector('[rel=alternate]');

  /// 搜索的时候，有些搜索会被重定向
  /// 然而有些不会
  String _searchDirectString;

  /// 搜索前务必清理[_searchDirectString]
  void cleanSearchDirectString() => _searchDirectString = null;

  /// 点击搜索按钮
  Future<SearchResponse> searchString({String str, int page = 1}) async {
    if (_searchDirectString == null || _searchDirectString == 'search') {
      dom.Document document =
          await $document('https://thehentaiworld.com/page/$page/?s=$str');

      if (_searchDirectString == null) {
        var link = _getLinkAlternate(document);
        if (link != null) {
          String href = link.attributes['href'];
          // url上的第一个path
          _searchDirectString = Uri.parse(href).pathSegments.first;
        }
      }
      return _getResponse(document);
    } else if (_searchDirectString == 'tag') {
      return searchTag(tag: str, page: page);
    } else {
      // 其他情况暂不处理
      return null;
    }
  }

  /// 搜索tag, 按下回车键
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
  RandomColor _randomColor = RandomColor();

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
        color: _randomColor.randomColor(),
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
      _miniThumbs = _queryThumbs(document, '#miniThumbContainer');
      if (_miniThumbs.isEmpty) {
        // 有可能不存在多个视图返回的空列表，所以显示自己
        _miniThumbs.add(thumb);
      }
    }

    return HentaiImagesData(
      miniThumbs: _miniThumbs,
      relatedThumbs: _queryThumbs(document, '#related'),
      tags: _queryHentaiDetailTags(document),
    );
  }

  List<TagData> _queryHentaiDetailTags(dom.Document document) {
    var tagsUl = document.querySelector('#tags');
    if (tagsUl == null) return List<TagData>();
    return tagsUl.querySelectorAll("li").map((e) {
      var a = e.querySelector('a');
      var tag = a.attributes['href'].split("/").last;
      return TagData(
        label: a.text,
        count: e.querySelector('span').text,
        tag: tag,
        color: _randomColor.randomColor(),
      );
    }).toList();
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
                  .replaceAll(RegExp(r'_thumb\d+-\d+x\d+'), '')
                  .replaceAll(RegExp(r'.jpg$'), '.mp4')
              : null,
        ),
      );
    }

    return itemObjs;
  }

  /// 获取video src
  Future<String> getVideoSrc(String pageUrl) async {
    var doc = await $document(pageUrl);
    var t = doc.querySelector('video#video');
    if (t != null) {
      return t.querySelector('source').attributes['src'];
    }
    return null;
  }
}
