import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:timezone/timezone.dart';

const envFile = '.env';
const studIpProviderUrl = 'https://studip.uni-passau.de/studip/';
const openMensaMensaId = 196;
const stwnoMensaId = 'UNI-P';
const stwnoMensaUrl = 'https://www.stwno.de/infomax/daten-extern/csv/';
const oauthBaseUrl = '${studIpProviderUrl}dispatch.php/api';
const apiBaseUrl = '${studIpProviderUrl}api.php/';
const callbackUrlScheme = 'studipassau';
const callbackUrlPath = 'oauth_callback';
const callbackUrl = '$callbackUrlScheme://$callbackUrlPath';
const studIpTimeZone = 'Europe/Berlin';
const bugReportEmail = 'info@femtopedia.de';
const bugReportSubject = '[Bug] Bug in StudiPassau';
const bugReportUrl = 'mailto:$bugReportEmail?subject=$bugReportSubject';
const aboutEmail = 'nico.mexis@kabelmail.de';
const aboutSubject = 'StudiPassau Feedback';
const aboutEmailUrl = 'mailto:$aboutEmail?subject=$aboutSubject';
const telegramBotUrl = 'http://t.me/UniPassauBot';
const translationUrl = 'https://app.localizely.com/projects/'
    '32cea4c8-ff53-4e34-94d8-bcdc8643b236/main/translations';
const githubUrl = 'https://github.com/ThexXTURBOXx/studipassau';

const iconBgColor = Color(0xFF2898F1);

const _colorTable = [
  null,
  Color(0xff008512),
  Color(0xff682c8b),
  Color(0xffb02e7c),
  Color(0xff129c94),
  Color(0xfff26e00),
  Color(0xffa85d45),
  Color(0xff6ead10),
  Color(0xffd60000),
  Color(0xffffbd33),
  Color(0xff66b671),
  Color(0xffa480b9),
  Color(0xffd082b0),
  Color(0xff71c4bf),
  Color(0xfff7a866),
  Color(0xffcb9e8f),
];

const int eventDaysInFuture = 15;

const regularLectureCategories = ['Sitzung', 'Vorlesung'];

const stwnoEncoding = latin1;

final RegExp stwnoAdditivesPattern = RegExp(r'\s*\(([^)]+)\)\s*');

// TODO(Nico): I18n!
/// From https://stwno.de/de/gastronomie/speiseplan/uni-passau/uni-passau-mensa
const Map<String, String> stwnoProperties = {
  'G': 'Geflügel',
  'S': 'Schweinefleisch',
  'R': 'Rindfleisch',
  'L': 'Lamm',
  'W': 'Wild',
  'F': 'Fisch',
  'A': 'Alkohol',
  'V': 'vegetarisch',
  'VG': 'vegan',
  'MV': 'Mensa Vital',
  'B': 'DE-ÖKO-006 mit ausschließlich biologisch erzeugten Rohstoffen',
  'J': 'Juradistl',
  'BL': 'Bioland',
};

// TODO(Nico): I18n!
/// From https://stwno.de/de/gastronomie/speiseplan/uni-passau/uni-passau-mensa
const Map<String, String> stwnoAdditives = {
  '1': 'mit Farbstoff',
  '2': 'mit Konservierungsstoff',
  '3': 'mit Antioxidationsmittel',
  '4': 'mit Geschmacksverstärker',
  '5': 'geschwefelt',
  '6': 'geschwärzt',
  '7': 'gewachst',
  '8': 'mit Phosphat',
  '9': 'mit Süssungsmittel Saccharin',
  '10': 'mit Süssungsmittel Aspartam, enth.Phenylalaninquelle',
  '11': 'mit Süssungsmittel Cyclamat',
  '12': 'mit Süssungsmittel Acesulfam',
  '13': 'chininhaltig',
  '14': 'coffeinhaltig',
  '15': 'gentechnisch verändert',
  '16': 'enthält Sulfite',
  '17': 'enthält Phenylalanin',
  'AA': 'Weizengluten',
  'AB': 'Roggengluten',
  'AC': 'Gerstengluten',
  'AD': 'Hafergluten',
  'AE': 'Dinkelgluten',
  'AF': 'Kamutgluten',
  'B': 'Krebstiere',
  'C': 'Eier',
  'D': 'Fisch',
  'E': 'Erdnüsse',
  'F': 'Soja',
  'G': 'Milch und Milchprodukte',
  'HA': 'Mandel',
  'HB': 'Haselnuss',
  'HC': 'Walnuss',
  'HD': 'Cashew',
  'HE': 'Pecannuss',
  'HF': 'Paranuss',
  'HG': 'Pistazie',
  'HH': 'Macadamianuss',
  'HI': 'Queenslandnuss',
  'I': 'Sellerie',
  'J': 'Senf',
  'K': 'Sesamsamen',
  'L': 'Schwefeldioxid und Sulfite',
  'M': 'Lupinen',
  'N': 'Weichtiere',
  'O': 'Nitrat',
  'P': 'Nitritpökelsalz',
};

final dateTimeSaveFormat = DateFormat('yyyy-MM-ddTHH:mm:ss', 'en_US');
final dateFormat = DateFormat.yMd();
final stwnoDateFormat = DateFormat('dd.MM.yyyy', 'de');
final hmTimeFormat = DateFormat.Hm();
final weekdayFormat = DateFormat('EEEE');
final euroFormat = NumberFormat.simpleCurrency(name: 'EUR');
final stwnoPriceFormat = NumberFormat('##0.00', 'de');

const wideScreenWidth = 600;

late PackageInfo packageInfo;

late BasePrefService prefService;

String targetRoute = routeSchedule;

Location? _location;

Location get location => _location ?? (_location = getLocation(studIpTimeZone));

String formatDate(DateTime dateTime) => dateFormat.format(dateTime);

String formatHmTime(DateTime dateTime) => hmTimeFormat.format(dateTime);

String formatWeekday(DateTime dateTime) => weekdayFormat.format(dateTime);

String formatEuroPrice(double value) => euroFormat.format(value);

Color getColor(int index) =>
    (1 <= index && index < _colorTable.length ? _colorTable[index] : null) ??
    getPref(notFoundColorPref)!;

String get appVersion => '${packageInfo.version} '
    '(${packageInfo.buildNumber})';

extension BoolParsing on String {
  bool parseBool() => toLowerCase() == 'true';
}

void showErrorMessage(BuildContext context, BlocState state) {
  if (state.errored) {
    switch (state.state) {
      case StudiPassauState.authenticationError:
        showSnackBar(context, S.of(context).authError);
        break;
      case StudiPassauState.fetchError:
        showSnackBar(context, S.of(context).fetchError);
        break;
      case StudiPassauState.httpError:
        showSnackBar(context, S.of(context).httpError);
        break;
      default:
        showSnackBar(context, S.of(context).miscError);
        break;
    }
  }
}

void showSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

/// Debug method as described in https://github.com/flutter/flutter/issues/22665
void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
}
