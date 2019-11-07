import 'package:flutter_ajanuw_router/ajanuw_route.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';
import 'package:thehentaiworld/app/pages/tag/tag.dart';

import 'pages/home/home.dart';

AjanuwRouter router = AjanuwRouter();

final List<AjanuwRoute> routes = [
  AjanuwRoute(
    path: '',
    redirectTo: '/home',
  ),
  AjanuwRoute(
    path: 'home',
    builder: (context, r) => Home(),
  ),
  AjanuwRoute(
    path: 'tag',
    builder: (context, r) => Tag(tag: r.arguments),
  ),
  AjanuwRoute(
    path: 'not-found',
    builder: (context, r) => Home(),
  ),
  AjanuwRoute(
    path: '**',
    redirectTo: '/not-found',
  ),
];
