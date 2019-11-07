import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app/app.dart';
import 'app/shared_module/thehentaiworld.service.dart';

GetIt getIt = GetIt.instance;
void main() {
  getIt..registerSingleton<TheHentaiWorldService>(TheHentaiWorldService());
  runApp(MyApp());
}
