import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:openmensa/openmensa.dart';

class OpenMensaDataProvider {
  final _mensaClient = OpenMensaAPI(httpClient: RetryClient(Client()));

  Future<List<DayMenu>> getMealsOfCanteen(int canteenId) async =>
      _mensaClient.getMealsOfCanteen(canteenId);
}
