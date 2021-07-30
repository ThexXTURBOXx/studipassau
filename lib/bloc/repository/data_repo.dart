import 'package:studip/studip.dart';
import 'package:studipassau/bloc/repository/base_repo.dart';
import 'package:timetable/timetable.dart';

class DataRepo extends BaseRepo {
  static DataRepo? _singleton;
  final StudIPClient? apiClient;
  List<BasicEvent>? schedule;

  factory DataRepo(StudIPClient? apiClient) {
    _singleton ??= DataRepo._internal(apiClient);
    return _singleton!;
  }

  DataRepo._internal(this.apiClient);
}
