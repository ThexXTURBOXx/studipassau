import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void navigateTo(BuildContext context, String? name, {Object? arguments}) {
  if (name != null) {
    final r = context.getModalRoute();
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

Future<void> launchUriString(
  String url, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async => launchUri(Uri.parse(url));

Future<void> launchUri(
  Uri uri, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async => await supportsLaunchMode(mode)
    ? await canLaunchUrl(uri)
          ? await launchUrl(uri, mode: mode)
          : throw PlatformException(
              code: 'CANT_LAUNCH_URI',
              message: "Can't launch URI $uri",
            )
    : throw PlatformException(
        code: 'UNSUPPORTED_LAUNCH_MODE',
        message: "Can't launch URI $uri",
      );

void closeDrawer(BuildContext context) => context.scaffold.openEndDrawer();
