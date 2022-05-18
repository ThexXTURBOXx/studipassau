import 'package:openmensa/openmensa.dart';
import 'package:studipassau/bloc/providers/openmensa_provider.dart';
import 'package:studipassau/bloc/providers/stwno_mensa_provider.dart';

class MensaRepo {
  final _openMensaProvider = OpenMensaDataProvider();

  final _stwnoMensaProvider = StwnoDataProvider();

  Future<List<DayMenu>> getOpenMensaMeals(int canteenId) async =>
      _openMensaProvider.getMealsOfCanteen(canteenId);

  Future<List<DayMenu>> getStwnoMeals(String canteenId) async =>
      _stwnoMensaProvider.getMealsOfCanteen(canteenId);
}
