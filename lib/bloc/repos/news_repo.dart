import 'package:collection/collection.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/pages/news/widgets/news_item.dart';

class NewsRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<List<News>> parseNews() async {
    final jsonNews = await _studIPProvider.apiGetJson('news?page[limit]=10000');
    final collection = jsonNews['data'];

    final jsonStudipNews = await _studIPProvider.apiGetJson(
      'studip/news?page[limit]=10000',
    );
    final collection2 = jsonStudipNews['data'];

    return ((collection is List
                ? collection.map(News.fromJson).toList(growable: false)
                : <News>[]) +
            (collection2 is List
                ? collection2.map(News.fromJson).toList(growable: false)
                : <News>[]))
        .sortedBy((n) => n.makeDate);
  }
}
