import 'package:flutter/material.dart';

/// 分页按钮，底部导航
class MoreHentaiNavigation extends StatelessWidget {
  final int page;
  final int start;
  final int end;
  final Function(int page) onChanged;

  String get _start => start.toString();
  String get _end => start.toString();
  const MoreHentaiNavigation({
    Key key,
    @required this.start,
    @required this.end,
    @required this.page,
    @required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> _result = [];
    bool isSmall = end < 4;
    if (isSmall) {
      for (var i = 1; i <= end; i++) {
        _result.add(
          _button(
            i.toString(),
            () => onChanged(i),
            page == i,
          ),
        );
      }
    } else {
      _result.addAll([
        _button(
          _start,
          () => onChanged(start),
          page == start,
        ),
        _button(
          (start + 1).toString(),
          () => onChanged(start + 1),
          page == start + 1,
        ),
        _button('...', null),
        _button(
          (end - 1).toString(),
          () => onChanged(end - 1),
          page == end - 1,
        ),
        _button(
          _end,
          () => onChanged(end),
          page == end,
        ),
      ]);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (page != 1) _button('Prev', () => onChanged(page - 1)),
        ..._result,
        if (page != end) _button('Next', () => onChanged(page + 1)),
      ],
    );
  }

  Widget _button(String text, Function onTap, [bool selected = false]) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
      ),
    );
  }
}
