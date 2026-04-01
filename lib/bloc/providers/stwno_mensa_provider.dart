import 'package:catcher_2/catcher_2.dart';
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
    final prevWeek = (today - 7.days).week.weekOfYear;
    final week = today.week.weekOfYear;
    final nextWeek = (today + 7.days).week.weekOfYear;
    final responsePrev = await _client.get(
      Uri.parse('$stwnoMensaUrl$stwnoMensaId/$prevWeek.csv'),
    );
    final responseCurr = await _client.get(
      Uri.parse('$stwnoMensaUrl$stwnoMensaId/$week.csv'),
    );
    final responseNext = await _client.get(
      Uri.parse('$stwnoMensaUrl$stwnoMensaId/$nextWeek.csv'),
    );
    final bodyPrev = stwnoEncoding.decode(responsePrev.bodyBytes);
    final bodyCurr = stwnoEncoding.decode(responseCurr.bodyBytes);
    final bodyNext = stwnoEncoding.decode(responseNext.bodyBytes);
    return parsePlan(bodyPrev) + parsePlan(bodyCurr) + parsePlan(bodyNext);
  }

  List<DayMenu> parsePlan(String line) => parseSplitPlan(
    line
        .split('\r\n')
        .map((l) => l.replaceAll('\n', ''))
        .toList(growable: false),
  );

  List<DayMenu> parseSplitPlan(List<String> lines) {
    final plan = <Day, List<Meal>>{};
    for (var i = 1; i < lines.length; i++) {
      final entries = lines[i].split(';');
      try {
        addToMenu(plan, entries);
      } catch (e, s) {
        Catcher2.reportCheckedError(e, s);
      }
    }
    return plan.entries
        .map((e) => DayMenu(day: e.key, meals: e.value))
        .toList(growable: false);
  }

  void addToMenu(Map<Day, List<Meal>> plan, List<String> entry) {
    final meal = parseMeal(entry);
    if (meal != null) {
      final date = parseDate(entry[0]);
      final menus = plan.entries.where((e) => e.key.date == date);
      if (menus.isNotEmpty) {
        menus.first.value.add(meal);
      } else {
        plan[Day(date: date, closed: false)] = [meal];
      }
    }
  }

  Meal? parseMeal(List<String> entry) {
    if (entry.length != 9) {
      // Only report entries with at least 2 columns.
      // The rest are most likely just empty rows...
      if (entry.length > 1) {
        Catcher2.reportCheckedError(null, null, extraData: {'entry': entry});
      }

      return null;
    }

    return Meal(
      // Unused anyway
      id: 0,
      name: parseName(entry[3].trim()),
      notes:
          parseFoodProperties(entry[4].trim()) +
          parseAllergensAndAdditives(entry[3].trim()),
      category: parseCategory(entry[2].trim()),
      studentPrice: parsePrice(entry[6].trim()),
      employeePrice: parsePrice(entry[7].trim()),
      othersPrice: parsePrice(entry[8].trim()),
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

  List<String> parseFoodProperties(String tags) => tags
      .split(',')
      .map((e) => e.trim())
      .filter((e) => e.isNotEmpty)
      .map((e) => stwnoProperties[e] ?? stwnoAdditives[e] ?? e)
      .toList(growable: false);

  List<String> parseAllergensAndAdditives(String name) => stwnoAdditivesPattern
      .allMatches(name)
      .map((e) => e.group(1) ?? '')
      .map((e) => e.trim())
      .filter((e) => e.isNotEmpty)
      .map((e) => e.split(','))
      .expand((e) => e)
      .map((e) => e.trim())
      .filter((e) => e.isNotEmpty)
      .map((e) => stwnoAdditives[e] ?? stwnoProperties[e] ?? e)
      .toList(growable: false);

  // TODO(Nico): I18n!
  String parseCategory(String cat) {
    if (cat.startsWith('HG')) {
      return 'Hauptgericht';
    } else if (cat.startsWith('B')) {
      return 'Beilage';
    } else if (cat.startsWith('N')) {
      return 'Nachtisch';
    } else if (cat.startsWith('Suppe')) {
      return 'Suppe';
    } else {
      return 'Sonstiges';
    }
  }

  double parsePrice(String number) => stwnoPriceFormat.parse(number).toDouble();
}
