import 'package:flutter/material.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/app/shared_module/to_search_result.dart';

class Tag extends StatelessWidget {
  final TagData tag;

  const Tag(this.tag, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () => toSearchResult(SearchType.tag, tag.tag),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SelectableText(
            tag.label,
            style: TextStyle(
              color: tag.color,
            ),
          ),
          SizedBox(width: 4),
          Text(
            tag.count,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
