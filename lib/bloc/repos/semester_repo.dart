import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/models/semester.dart';

class SemesterRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<List<Semester>> getSemesters() async {
    final json = await _studIPProvider.apiGetJson(
      'semesters?page[limit]=10000',
    );
    return parseCollection(
      json,
      (item) => SemesterAttributes.fromJson(item as Map<String, dynamic>),
    );
  }
}
