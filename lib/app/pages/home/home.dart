import 'package:flutter/material.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';
import 'package:thehentaiworld/app/shared_module/widgets/logo.dart';
import 'package:thehentaiworld/app/shared_module/widgets/search_tag_field.dart';
import 'package:thehentaiworld/app/shared_module/widgets/ubermenu_nav.dart';

import '../../../main.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final theHentaiWorldService = getIt<TheHentaiWorldService>(); // 注入

  @override
  Widget build(BuildContext context) {
    final br = SizedBox(height: 30);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              br,
              Text(
                'The Hentai World - Huge variety of hentai content.',
                style: Theme.of(context).textTheme.headline5,
              ),
              br,
              UbermenuNav(),
              br,
              Hero(tag: 'logo', child: Logo()),
              SearchTagField(),
            ],
          ),
        ),
      ),
    );
  }
}
