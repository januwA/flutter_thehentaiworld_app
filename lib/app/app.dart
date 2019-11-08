import 'package:flutter/material.dart';
import 'package:thehentaiworld/app/router.dart';

class MyApp extends StatelessWidget {
  final onGenerateRoute = router.forRoot(routes);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TheHentaiWorld',
      initialRoute: '',
      navigatorObservers: [router.navigatorObserver],
      navigatorKey: router.navigatorKey,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
