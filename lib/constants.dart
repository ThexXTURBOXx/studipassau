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
Location? _location;

String get consumerKey => dotenv.env['CONSUMER_KEY']!;

String get consumerSecret => dotenv.env['CONSUMER_SECRET']!;

String? get sentryDsn => dotenv.env['SENTRY_DSN'];

Location get location =>
    _location ?? (_location = getLocation(STUDIP_TIME_ZONE));
