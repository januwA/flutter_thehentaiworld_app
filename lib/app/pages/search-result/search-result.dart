import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/app/shared_module/widgets/type_tag.dart';
import 'package:thehentaiworld/main.dart';

class SearchResult extends StatefulWidget {
  final SearchType searchType;
  final String tag;

  const SearchResult({Key key, this.tag, @required this.searchType})
      : super(key: key);
  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  TheHentaiWorldService theHentaiWorldService =
      getIt<TheHentaiWorldService>(); // 注入
  int _page = 1;
  bool loading = true;
  SearchResponse searchResponse;
  List<ThumbData> get thumbs => searchResponse.thumbs;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _setSearchResponse();
  }

  Future<void> _setSearchResponse() async {
    setState(() {
      loading = true;
    });
    SearchResponse r;
    if (widget.searchType == SearchType.tag) {
      r = await theHentaiWorldService.searchTag(tag: widget.tag, page: _page);
    } else if (widget.searchType == SearchType.search) {
      r = await theHentaiWorldService.searchTag(
          tag: widget.tag, page: _page);
    } else if (widget.searchType == SearchType.neww) {
      r = await theHentaiWorldService.searchNew(page: _page);
    } else if (widget.searchType == SearchType.updated) {
      r = await theHentaiWorldService.searchUpdated(page: _page);
    }

    if (mounted) {
      setState(() {
        searchResponse = r;
        loading = false;
      });
    }
  }

  _setPage(int newPage) {
    setState(() {
      _page = newPage;
    });
    _setSearchResponse();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: loading
            ? Center(child: CircularProgressIndicator())
            : thumbs.isEmpty
                ? Center(child: Text('No Hentai Found!'))
                : _list(),
      ),
    );
  }

  Widget _list() {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (var thumb in thumbs)
            GestureDetector(
              key: ObjectKey(thumb),
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/hentai-images', arguments: thumb);
              },
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: AjanuwImage(
                      image: AjanuwNetworkImage(thumb.originalImage),
                      // frameBuilder: AjanuwImage.defaultFrameBuilder,
                      loadingWidget: AjanuwImage.defaultLoadingWidget,
                      loadingBuilder: AjanuwImage.defaultLoadingBuilder,
                      errorBuilder: AjanuwImage.defaultErrorBuilder,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (thumb.type == ThumbType.video)
                    Align(
                      alignment: Alignment.topLeft,
                      child: TypeTag(),
                    ),
                ],
              ),
            ),
          if (searchResponse.startPage != 0 && searchResponse.endPage != 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (_page != 1)
                    _button('Prev', () {
                      if (_page >= 1) _setPage(_page - 1);
                    }),
                  _button(
                    searchResponse.startPage.toString(),
                    () {
                      _setPage(searchResponse.startPage);
                    },
                    _page == searchResponse.startPage,
                  ),
                  _button((searchResponse.startPage + 1).toString(), () {
                    _setPage(searchResponse.startPage + 1);
                  }, _page == searchResponse.startPage + 1),
                  _button('...', null),
                  _button((searchResponse.endPage - 1).toString(), () {
                    _setPage(searchResponse.endPage - 1);
                  }, _page == searchResponse.endPage - 1),
                  _button(searchResponse.endPage.toString(), () {
                    _setPage(searchResponse.endPage);
                  }, _page == searchResponse.endPage),
                  if (_page != searchResponse.endPage)
                    _button('Next', () {
                      if (_page < searchResponse.endPage) _setPage(_page + 1);
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _button(String text, Function onTap, [bool selected = false]) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? Colors.black : Color.fromRGBO(204, 204, 204, 1),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.black : Color.fromRGBO(136, 136, 136, 1),
          ),
        ),
      ),
    );
  }
}
