import 'package:flutter/material.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';

import '../../../main.dart';

class SearchTagField extends StatefulWidget {
  @override
  _SearchTagFieldState createState() => _SearchTagFieldState();
}

class _SearchTagFieldState extends State<SearchTagField> {
  TextEditingController controller = TextEditingController();
  TheHentaiWorldService theHentaiWorldService =
      getIt<TheHentaiWorldService>(); // 注入

  _toSearch() {
    theHentaiWorldService.cleanSearchDirectString();
    Navigator.of(context).pushNamed(
      '/search-result',
      arguments: {
        'searchType': SearchType.search,
        'tag': controller.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onEditingComplete: _toSearch,
      textInputAction: TextInputAction.search,
      autocorrect: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(
          left: 8,
          top: 6,
          right: 6,
          bottom: 6,
        ),
        hintText: 'Search for hentai',
        hintStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(),
      ),
    );
  }
}
