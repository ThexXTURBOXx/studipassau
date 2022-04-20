import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openmensa/openmensa.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';

class StudiPassauRepo {
  static final StudiPassauRepo _singleton = StudiPassauRepo._internal();

  final _storage = const FlutterSecureStorage();

  late StudIPClient apiClient;
  final mensaClient = OpenMensaAPI();
  dynamic userData;
  List<StudiPassauEvent>? schedule;
  List<DayMenu>? mensaPlan;

  factory StudiPassauRepo() => _singleton;

  StudiPassauRepo._internal();

  FlutterSecureStorage get storage => _storage;

  String get userId => userData['user_id'].toString();

  String get username => userData['username'].toString();

  String get formattedName => userData['name']['formatted'].toString();

  String get avatarNormal => userData['avatar_normal'].toString();
}
