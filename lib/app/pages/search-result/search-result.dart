import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';
import 'package:thehentaiworld/app/pages/search-result/widgets/more_hentai_navigation.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/app/shared_module/widgets/type_tag.dart';
import 'package:thehentaiworld/main.dart';

/// 搜索返回的列表页面
class SearchResult extends StatefulWidget {
  final SearchType searchType;
  final String tag;

  const SearchResult({Key key, this.tag, @required this.searchType})
      : super(key: key);
  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final theHentaiWorldService = getIt<TheHentaiWorldService>(); // 注入
  int _page = 1;
  bool loading = true;
  SearchResponse searchResponse;
  List<ThumbData> get thumbs => searchResponse.thumbs;
  ScrollController controller = ScrollController();
  final TextEditingController pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setSearchResponse();
  }

  @override
  void dispose() {
    controller?.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> _setSearchResponse() async {
    setState(() {
      loading = true;
    });
    SearchResponse r;
    if (widget.searchType == SearchType.tag) {
      r = await theHentaiWorldService.searchTag(tag: widget.tag, page: _page);
    } else if (widget.searchType == SearchType.search) {
      r = await theHentaiWorldService.searchString(
        str: widget.tag,
        page: _page,
      );
    } else if (widget.searchType == SearchType.neww) {
      r = await theHentaiWorldService.searchNew(page: _page);
    } else if (widget.searchType == SearchType.updated) {
      r = await theHentaiWorldService.searchUpdated(page: _page);
    }

    // print(r);
    if (mounted) {
      setState(() {
        searchResponse = r;
        loading = false;
      });
    }
  }

  void _setPage(int newPage) {
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
              onTap: () => Navigator.of(context)
                  .pushNamed('/hentai-images', arguments: thumb),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: AjanuwImage(
                      image: AjanuwNetworkImage(thumb.image),
                      loadingWidget: AjanuwImage.defaultLoadingWidget,
                      loadingBuilder: AjanuwImage.defaultLoadingBuilder,
                      alt: 'image load error.',
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
              child: MoreHentaiNavigation(
                page: _page,
                start: searchResponse.startPage,
                end: searchResponse.endPage,
                onChanged: _setPage,
              ),
            ),

          // to page
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 40,
                  child: TextField(
                    controller: pageController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'PAGE #',
                      contentPadding: EdgeInsets.all(0),
                      hintStyle: TextStyle(color: Colors.black38),
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                    cursorColor: Theme.of(context).accentColor,
                    cursorWidth: 2,
                    cursorRadius: Radius.circular(4.0),
                  ),
                ),
                SizedBox(width: 10),
                FlatButton(
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  child: Text('GO'),
                  onPressed: () => _setPage(int.parse(pageController.text)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
