import 'package:openmensa/openmensa.dart';

class OpenMensaDataProvider {
  final _mensaClient = OpenMensaAPI();

  Future<List<DayMenu>> getMealsOfCanteen(int canteenId) async =>
      _mensaClient.getMealsOfCanteen(canteenId);
}
