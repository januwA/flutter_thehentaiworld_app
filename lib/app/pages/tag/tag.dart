import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/main.dart';

class Tag extends StatefulWidget {
  final String tag;

  const Tag({Key key, @required this.tag}) : super(key: key);
  @override
  _TagState createState() => _TagState();
}

class _TagState extends State<Tag> {
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
    SearchResponse r =
        await theHentaiWorldService.search(s: widget.tag, page: _page);
    setState(() {
      searchResponse = r;
      loading = false;
    });
  }

  _setPage(int newPage) {
    setState(() {
      _page = newPage;
    });
    _setSearchResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.tag)),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : thumbs.isEmpty ? Center(child: Text('No Hentai Found!')) : _list(),
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
              onTap: () {

              },
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: AjanuwImage(
                      image: AjanuwNetworkImage(thumb.originalImage),
                      frameBuilder: AjanuwImage.defaultFrameBuilder,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (thumb.type == ThumbType.video)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Video',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
