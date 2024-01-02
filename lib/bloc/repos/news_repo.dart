import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/pages/news/widgets/news_item.dart';

class NewsRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<List<News>> parseNews() async {
    final jsonNews =
        await _studIPProvider.apiGetJson('studip/news?limit=10000');
    final collection = jsonNews['collection'];

    return collection is Map
        ? (collection as Map<String, dynamic>)
            .values
            .map(News.fromJson)
            .toList(growable: false)
        : [];
  }
}
