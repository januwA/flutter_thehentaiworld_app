import 'package:flutter/material.dart';

class TagButton extends StatelessWidget {
  final String text;
  final Function onTap;
  final Color color;

  const TagButton({Key key, this.text, this.onTap, this.color = Colors.grey})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: Theme.of(context).textTheme.button.copyWith(
              color: color,
            ),
      ),
    );
  }
}
