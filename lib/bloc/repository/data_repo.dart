import 'package:StudiPassau/bloc/repository/base_repo.dart';
import 'package:studip/studip.dart';

class DataRepo extends BaseRepo {
  static DataRepo _singleton;
  final StudIPClient apiClient;
  dynamic schedule;

  factory DataRepo(StudIPClient apiClient) {
    _singleton ??= DataRepo._internal(apiClient);
    return _singleton;
  }

  DataRepo._internal(this.apiClient);
}
