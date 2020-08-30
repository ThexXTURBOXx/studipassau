import 'package:StudiPassau/bloc/repository/base_repo.dart';
import 'package:studip/studip.dart';

class OAuthRepo extends BaseRepo {
  static OAuthRepo _singleton;
  StudIPClient apiClient;
  dynamic userData;

  factory OAuthRepo() {
    _singleton ??= OAuthRepo._internal();
    return _singleton;
  }

  OAuthRepo._internal();

  String get userId => userData['user_id'].toString();

  String get username => userData['username'].toString();
}
