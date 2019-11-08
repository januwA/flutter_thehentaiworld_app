import 'package:flutter_ajanuw_router/ajanuw_route.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';
import 'package:thehentaiworld/app/pages/hentai_images/hentai_images.dart';
import 'package:thehentaiworld/app/pages/hentai_images/widgets/full_screent_hentai_image.dart';
import 'package:thehentaiworld/app/pages/tags/tags.dart';

import 'pages/home/home.dart';
import 'pages/search-result/search-result.dart';
import 'shared_module/thehentaiworld.service.dart';

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
    path: 'search-result',
    builder: (context, r) {
      Map param = r.arguments;

      SearchType type = param['searchType'];
      String tag = param['tag'];
      assert((() {
        if (type == SearchType.tag) {
          return tag != null;
        }
        return true;
      })());
      return SearchResult(searchType: type, tag: tag);
    },
  ),
  AjanuwRoute(
    path: 'hentai-images',
    builder: (context, r) => HentaiImages(thumb: r.arguments),
  ),
  AjanuwRoute(
    path: 'full-hentai-images',
    builder: (context, r) {
      Map p = r.arguments;
      return FullScreentHentaiImage(thumbs: p['thumbs'], index: p['index']);
    },
  ),
  AjanuwRoute(
    path: 'tags',
    builder: (context, r) => Tags(),
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
