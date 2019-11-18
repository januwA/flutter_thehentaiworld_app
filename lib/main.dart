import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app/app.dart';
import 'app/shared_module/thehentaiworld.service.dart';
import 'store/main.store.dart';

GetIt getIt = GetIt.instance;
void main() {
  getIt
    ..registerSingleton<MainStore>(MainStore())
    ..registerSingleton<TheHentaiWorldService>(TheHentaiWorldService());
  runApp(MyApp());
}
