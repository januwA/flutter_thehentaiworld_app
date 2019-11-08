import 'package:flutter/material.dart';
import 'package:thehentaiworld/app/shared_module/to_search_result.dart';
import 'package:thehentaiworld/app/shared_module/widgets/tag_button.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart' show SearchType;

class UbermenuNav extends StatefulWidget {
  @override
  UubermenuNavState createState() => UubermenuNavState();
}

class UubermenuNavState extends State<UbermenuNav> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      children: <Widget>[
        TagButton(
          text: 'New Hentai',
          onTap: () => toSearchResult(SearchType.neww),
        ),
        TagButton(
          text: 'Updated',
          onTap: () => toSearchResult(SearchType.updated),
        ),
        TagButton(
          text: 'Tags',
          onTap: () {
            Navigator.of(context).pushNamed('/tags');
          },
        ),
      ],
    );
  }
}
