import 'package:openmensa/openmensa.dart';
import 'package:studipassau/bloc/providers/openmensa_provider.dart';

class OpenMensaRepo {
  final _openMensaProvider = OpenMensaDataProvider();

  Future<List<DayMenu>> getMealsOfCanteen(int canteenId) async =>
      _openMensaProvider.getMealsOfCanteen(canteenId);
}
