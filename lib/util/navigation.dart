import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void navigateTo(BuildContext context, String? name) {
  if (name != null) {
    final r = ModalRoute.of(context);
    if (r == null || r.settings.name != name) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamedAndRemoveUntil(context, name, (route) => false);
      });
    }
  }
}

Future<void> launchUrl(String url) async => await canLaunch(url)
    ? await launch(url)
    : throw PlatformException(
        code: 'CANT_LAUNCH_URL',
        message: "Can't launch URL $url",
      );

void closeDrawer(BuildContext context) => Scaffold.of(context).openEndDrawer();
