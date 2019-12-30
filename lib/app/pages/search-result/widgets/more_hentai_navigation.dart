import 'package:flutter/material.dart';

/// 分页按钮，底部导航
class MoreHentaiNavigation extends StatelessWidget {
  final int page;
  final int start;
  final int end;
  final Function(int page) onChanged;
  const MoreHentaiNavigation({
    Key key,
    @required this.start,
    @required this.end,
    @required this.page,
    @required this.onChanged,
  }) : super(key: key);

  get firstButton => _button(
        start.toString(),
        () => onChanged(start),
        page == start,
      );

  get endButton => _button(
        end.toString(),
        () => onChanged(end),
        page == end,
      );

  @override
  Widget build(BuildContext context) {
    List<Widget> _result = [];
    bool isSmall = end < 8;
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
      const point = 6;
      if (page <= point) {
        for (var i = start; i <= point + 2; i++) {
          _result.add(
            _button(
              i.toString(),
              () => onChanged(i),
              page == i,
            ),
          );
        }
        _result.add(_button('...', null));
        _result.add(endButton);
      } else if (page > point && page < end - point) {
        _result.add(firstButton);
        _result.add(_button('...', null));
        int form = page - 3;
        int other = page + 3;
        for (var i = form; i <= other; i++) {
          _result.add(
            _button(
              i.toString(),
              () => onChanged(i),
              page == i,
            ),
          );
        }
        _result.add(_button('...', null));
        _result.add(endButton);
      } else {
        _result.add(firstButton);
        _result.add(_button('...', null));
        for (var i = end - (point + 2); i <= end; i++) {
          _result.add(
            _button(
              i.toString(),
              () => onChanged(i),
              page == i,
            ),
          );
        }
      }
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
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
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? Colors.black : Color.fromRGBO(204, 204, 204, 1),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text.toString(),
          style: TextStyle(
            color: selected ? Colors.black : Color.fromRGBO(136, 136, 136, 1),
          ),
        ),
      ),
    );
  }
}
