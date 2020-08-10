import 'package:flutter/material.dart';

/// 分页按钮，底部导航
class MoreHentaiNavigation extends StatefulWidget {
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

  @override
  _MoreHentaiNavigationState createState() => _MoreHentaiNavigationState();
}

class _MoreHentaiNavigationState extends State<MoreHentaiNavigation> {

  get firstButton => _button(
        widget.start.toString(),
        () => widget.onChanged(widget.start),
        widget.page == widget.start,
      );

  get endButton => _button(
        widget.end.toString(),
        () => widget.onChanged(widget.end),
        widget.page == widget.end,
      );

  @override
  Widget build(BuildContext context) {
    List<Widget> _result = [];
    bool isSmall = widget.end < 8;
    if (isSmall) {
      for (var i = 1; i <= widget.end; i++) {
        _result.add(
          _button(
            i.toString(),
            () => widget.onChanged(i),
            widget.page == i,
          ),
        );
      }
    } else {
      const point = 6;
      if (widget.page <= point) {
        for (var i = widget.start; i <= point + 2; i++) {
          _result.add(
            _button(
              i.toString(),
              () => widget.onChanged(i),
              widget.page == i,
            ),
          );
        }
        _result.add(_button('...', null));
        _result.add(endButton);
      } else if (widget.page > point && widget.page < widget.end - point) {
        _result.add(firstButton);
        _result.add(_button('...', null));
        int form = widget.page - 3;
        int other = widget.page + 3;
        for (var i = form; i <= other; i++) {
          _result.add(
            _button(
              i.toString(),
              () => widget.onChanged(i),
              widget.page == i,
            ),
          );
        }
        _result.add(_button('...', null));
        _result.add(endButton);
      } else {
        _result.add(firstButton);
        _result.add(_button('...', null));
        for (var i = widget.end - (point + 2); i <= widget.end; i++) {
          _result.add(
            _button(
              i.toString(),
              () => widget.onChanged(i),
              widget.page == i,
            ),
          );
        }
      }
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        if (widget.page != 1)
          _button('Prev', () => widget.onChanged(widget.page - 1)),
        ..._result,
        if (widget.page != widget.end)
          _button('Next', () => widget.onChanged(widget.page + 1)),
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
