import 'package:collection/collection.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/models/news.dart';
import 'package:studipassau/models/jsonapi.dart';

class NewsRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<List<News>> parseNews() async {
    final results = await Future.wait([
      _studIPProvider.apiGetJson('news?page[limit]=10000'),
      _studIPProvider.apiGetJson('studip/news?page[limit]=10000'),
    ]);

    final allNews = results
        .expand(
          (json) => parseCollection<NewsAttributes>(
            json,
            (a) => NewsAttributes.fromJson(a as Map<String, dynamic>),
          ),
        )
        .toList();

    return allNews.sortedBy((n) => n.attributes.makeDate).reversed.toList();
  }
}
