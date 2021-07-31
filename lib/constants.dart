import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/timezone.dart';

const ENV_FILE = '.env';
const STUDIP_PROVIDER_URL = 'https://studip.uni-passau.de/studip/';
const OAUTH_BASE_URL = '${STUDIP_PROVIDER_URL}dispatch.php/api';
const API_BASE_URL = '${STUDIP_PROVIDER_URL}api.php/';
const CALLBACK_URL_SCHEME = 'studipassau';
const CALLBACK_URL_PATH = 'oauth_callback';
const CALLBACK_URL = '$CALLBACK_URL_SCHEME://$CALLBACK_URL_PATH';
const STUDIP_TIME_ZONE = 'Europe/Berlin';

const NOT_FOUND_COLOR = Color(0xffea3838);
const NON_LECTURE_COLOR = Color(0xff339966);
const _COLOR_TABLE = [
  NOT_FOUND_COLOR,
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

const REGULAR_LECTURE_CATEGORY = 'Sitzung';

Location? _location;

String get consumerKey => dotenv.env['CONSUMER_KEY']!;

String get consumerSecret => dotenv.env['CONSUMER_SECRET']!;

String? get sentryDsn => dotenv.env['SENTRY_DSN'];

Location get location =>
    _location ?? (_location = getLocation(STUDIP_TIME_ZONE));

Color getColor(int index) =>
    _COLOR_TABLE[(0 <= index && index < _COLOR_TABLE.length) ? index : 0];
