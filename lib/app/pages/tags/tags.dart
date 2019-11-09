import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/app/shared_module/to_search_result.dart';
import 'package:thehentaiworld/app/shared_module/widgets/logo.dart';
import 'package:thehentaiworld/app/shared_module/widgets/search_tag_field.dart';
import 'package:thehentaiworld/app/shared_module/widgets/tag_button.dart';
import 'package:thehentaiworld/app/shared_module/widgets/ubermenu_nav.dart';

import '../../../main.dart';

class Tags extends StatefulWidget {
  @override
  _TagsState createState() => _TagsState();
}

class _TagsState extends State<Tags> {
  TheHentaiWorldService theHentaiWorldService =
      getIt<TheHentaiWorldService>(); // 注入
  bool loading = true;
  Stream<List<TagData>> _tags$;
  List<TagData> _tags;

  /// 每次渲染100个
  final int cound = 100;
  int page = 1;

  /// 一次渲染5000多个元素有点吃力
  List<TagData> _tagsRange = [];
  List<TagData> get tagsRange {
    int start = _tagsRange.length;
    int end = min(page * cound, _tags.length);
    _tagsRange.addAll(_tags.getRange(start, end));
    return _tagsRange;
  }

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    loading = true;
    setState(() {
      _tags$ = theHentaiWorldService.getTags().asBroadcastStream();
      loading = false;
    });
  }

  _loadMoreTag() {
    setState(() {
      page += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: loading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Hero(tag: 'logo', child: Logo()),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: UbermenuNav(),
                    ),
                    SearchTagField(),
                    SizedBox(height: 10),
                    Expanded(
                      child: Scrollbar(
                        child: NotificationListener(
                          onNotification: (Notification notification) {
                            if (notification is ScrollEndNotification) {
                              // 下拉到底部-10的距离时，触发加载更多
                              if (_scrollController.position.extentAfter < 10) {
                                _loadMoreTag();
                              }
                            }

                            return true;
                          },
                          child: ListView(
                            controller: _scrollController,
                            children: <Widget>[
                              if (_tags == null)
                                StreamBuilder(
                                  stream: _tags$,
                                  builder: (context,
                                      AsyncSnapshot<List<TagData>> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ));
                                    }

                                    if (snapshot.connectionState ==
                                            ConnectionState.active ||
                                        snapshot.connectionState ==
                                            ConnectionState.done) {
                                      _tags = snapshot.data;
                                      return _tagList(context);
                                    }
                                    return SizedBox();
                                  },
                                )
                              else
                                _tagList(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Wrap _tagList(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: <Widget>[
        for (var tag in tagsRange)
          TagButton(
            key: ValueKey(tag.tag),
            text: tag.label,
            color: tag.color,
            onTap: () => toSearchResult(SearchType.tag, tag.tag),
          ),
      ],
    );
  }
}
