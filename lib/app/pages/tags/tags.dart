import 'package:flutter/material.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/app/shared_module/widgets/logo.dart';
import 'package:thehentaiworld/app/shared_module/widgets/search_tag_field.dart';
import 'package:thehentaiworld/app/shared_module/widgets/tag_button.dart';
import 'package:random_color/random_color.dart';
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
  RandomColor _randomColor = RandomColor();

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
                    Logo(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: UbermenuNav(),
                    ),
                    SearchTagField(),
                    SizedBox(height: 10),
                    Expanded(
                      child: Scrollbar(
                        child: ListView(
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
                                    return _tagLists(context);
                                  }
                                  return SizedBox();
                                },
                              )
                            else
                              _tagLists(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Wrap _tagLists(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: <Widget>[
        for (var tag in _tags)
          TagButton(
            key: ValueKey(tag.tag),
            text: tag.label,
            color: _randomColor.randomColor(),
            onTap: () {
              Navigator.of(context).pushNamed(
                '/search-result',
                arguments: {
                  'searchType': SearchType.tag,
                  'tag': tag.tag,
                },
              );
            },
          ),
      ],
    );
  }
}
