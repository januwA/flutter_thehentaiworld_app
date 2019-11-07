import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';

import '../../../main.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TheHentaiWorldService theHentaiWorldService =
      getIt<TheHentaiWorldService>(); // 注入
  TextEditingController controller = TextEditingController();

  _search() {
    String _text = controller.text;
    Navigator.of(context).pushNamed('/tag', arguments: _text);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('The Hentai World - Huge variety of hentai content.'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              width: ScreenUtil.getInstance().setWidth(280),
              child: TextField(
                controller: controller,
                onEditingComplete: _search,
                textInputAction: TextInputAction.search,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: 'Search for hentai',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
