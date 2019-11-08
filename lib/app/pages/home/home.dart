import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  TheHentaiWorldService theHentaiWorldService =
      getIt<TheHentaiWorldService>(); // 注入

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: ScreenUtil.instance.setHeight(20)),
              Text(
                'The Hentai World - Huge variety of hentai content.',
                style: Theme.of(context).textTheme.headline,
              ),
              SizedBox(height: ScreenUtil.instance.setHeight(30)),
              UbermenuNav(),
              SizedBox(height: ScreenUtil.instance.setHeight(20)),
              Logo(),
              SearchTagField(),
            ],
          ),
        ),
      ),
    );
  }
}
