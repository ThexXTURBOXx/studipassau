import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:timezone/timezone.dart';

const envFile = '.env';
const studIpProviderUrl = 'https://studip.uni-passau.de/studip/';
const openMensaMensaId = 196;
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

const regularLectureCategories = ['Sitzung', 'Vorlesung'];

final dateFormat = DateFormat.yMd();
final hmTimeFormat = DateFormat.Hm();
final weekdayFormat = DateFormat('EEEE');
final decimalFormat = NumberFormat('##0.00');

late PackageInfo packageInfo;

late BasePrefService prefService;

Location? _location;

String get consumerKey => dotenv.env['CONSUMER_KEY']!;

String get consumerSecret => dotenv.env['CONSUMER_SECRET']!;

String? get sentryDsn => dotenv.env['SENTRY_DSN'];

Location get location => _location ?? (_location = getLocation(studIpTimeZone));

String formatDate(DateTime dateTime) => dateFormat.format(dateTime);

String formatHmTime(DateTime dateTime) => hmTimeFormat.format(dateTime);

String formatWeekday(DateTime dateTime) => weekdayFormat.format(dateTime);

String formatDecimal(double value) => decimalFormat.format(value);

Color getColor(int index) =>
    (1 <= index && index < _colorTable.length ? _colorTable[index] : null) ??
    getPref(notFoundColorPref)!;

String get appVersion => '${packageInfo.version} '
    '(${packageInfo.buildNumber})';
