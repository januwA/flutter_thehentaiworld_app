import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app/router.dart';
import 'app/shared_module/thehentaiworld.service.dart';
import 'store/main.store.dart';

GetIt getIt = GetIt.instance;
void main() {
  getIt
    ..registerSingleton<MainStore>(MainStore())
    ..registerSingleton<TheHentaiWorldService>(TheHentaiWorldService());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TheHentaiWorld',
      initialRoute: '',
      navigatorObservers: [router.navigatorObserver],
      navigatorKey: router.navigatorKey,
      onGenerateRoute: router.forRoot(routes),
    );
  }
}
