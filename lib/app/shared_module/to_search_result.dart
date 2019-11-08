import 'package:thehentaiworld/app/router.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';

toSearchResult(SearchType type, [String tag]) {
  router.navigator.pushNamed(
    '/search-result',
    arguments: {
      'searchType': type,
      'tag': tag,
    },
  );
}
