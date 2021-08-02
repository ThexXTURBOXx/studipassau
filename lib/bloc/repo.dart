import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studip/studip.dart';
import 'package:timetable/timetable.dart';

class StudiPassauRepo {
  static final StudiPassauRepo _singleton = StudiPassauRepo._internal();

  final _storage = const FlutterSecureStorage();

  late StudIPClient apiClient;
  dynamic userData;
  List<BasicEvent>? schedule;

  factory StudiPassauRepo() => _singleton;

  StudiPassauRepo._internal();

  FlutterSecureStorage get storage => _storage;

  String get userId => userData['user_id'].toString();

  String get username => userData['username'].toString();

  String get formattedName => userData['name']['formatted'].toString();

  String get avatarNormal => userData['avatar_normal'].toString();
}
