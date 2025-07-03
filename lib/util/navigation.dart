import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

void navigateTo(BuildContext context, String? name, {Object? arguments}) {
  if (name != null) {
    final r = ModalRoute.of(context);
    if (r == null || r.settings.name != name) {
      Future.delayed(Duration.zero, () async {
        if (!context.mounted) {
          return;
        }
        await Navigator.pushNamedAndRemoveUntil(
          context,
          name,
          (route) => false,
          arguments: arguments,
        );
      });
    }
  }
}

Future<void> launchUrl(
  String url, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async => await launchUrlString(url, mode: mode);

void closeDrawer(BuildContext context) => Scaffold.of(context).openEndDrawer();
