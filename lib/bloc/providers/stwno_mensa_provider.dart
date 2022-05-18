import 'package:http/http.dart' as http;
import 'package:openmensa/openmensa.dart';
import 'package:studipassau/constants.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timetable/timetable.dart';

// TODO(Nico): Overhaul this whole mess that I just ported from Java to Dart...
class StwnoDataProvider {
  static final http.Client _client = http.Client();

  Future<List<DayMenu>> getMealsOfCanteen(String canteenId) async {
    final today = DateTime.now().toUtc().atStartOfDay;
    final week = today.week.weekOfYear;
    final nextWeek = (today + 7.days).week.weekOfYear;
    final responseCurr =
        await _client.get(Uri.parse('$stwnoMensaUrl$stwnoMensaId/$week.csv'));
    final responseNext = await _client
        .get(Uri.parse('$stwnoMensaUrl$stwnoMensaId/$nextWeek.csv'));
    final bodyCurr = stwnoEncoding.decode(responseCurr.bodyBytes);
    final bodyNext = stwnoEncoding.decode(responseNext.bodyBytes);
    return parsePlan(bodyCurr.split('\n')) + parsePlan(bodyNext.split('\n'));
  }

  List<DayMenu> parsePlan(List<String> lines) {
    final plan = <DayMenu>[];
    for (var i = 1; i < lines.length; i++) {
      final entries = lines[i].split(';');
      try {
        addToMenu(plan, entries);
      } catch (ignored) {
        // Ignore exceptions and just parse next one...
      }
    }
    return plan;
  }

  void addToMenu(List<DayMenu> plan, List<String> entries) {
    final meal = parseMeal(entries);
    if (meal != null) {
      final date = parseDate(entries[0]);
      final menus = plan.where((e) => e.day.date == date);
      if (menus.isNotEmpty) {
        menus.first.meals.add(meal);
      } else {
        plan.add(DayMenu(day: Day(date: date, closed: false), meals: [meal]));
      }
    }
  }

  Meal? parseMeal(List<String> entries) {
    if (entries.length != 9) {
      return null;
    }

    return Meal(
      id: 0,
      name: '${parseName(entries[3])} '
          '(${parseAllergensAndAdditives(entries[3]).join(", ")})',
      notes: parseFoodProperties(entries[4]),
      category: entries[2],
      studentPrice: parsePrice(entries[6]),
      employeePrice: parsePrice(entries[7]),
      othersPrice: parsePrice(entries[8]),
      pupilPrice: null,
    );
  }

  DateTime parseDate(String date) => stwnoDateFormat.parse(date);

  String parseName(String name) {
    final split = name
        .split(stwnoAdditivesPattern)
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    if (split.isEmpty) {
      return name;
    } else if (split.length == 1) {
      return split[0];
    } else {
      final parts = split.sublist(1).join(', ');
      return '${split[0]} ($parts)';
    }
  }

  List<String> parseFoodProperties(String tags) => tags.split(r',\s*');

  Set<String> parseAllergensAndAdditives(String name) => stwnoAdditivesPattern
      .allMatches(name)
      .map((e) => e.group(1) ?? '')
      .filter((e) => e != '')
      .map((e) => e.split(r',\s*'))
      .expand((e) => e)
      .toSet();

  double parsePrice(String number) =>
      stwnoDecimalFormat.parse(number).toDouble();
}
