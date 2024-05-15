import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/icons/studi_passau_icons.dart';
import 'package:studipassau/util/navigation.dart';

Future<void> showStudiPassauAbout(BuildContext context) async {
  showAboutDialog(
    context: context,
    applicationName: S.of(context).applicationTitle,
    applicationVersion: appVersion,
    applicationLegalese:
        sprintf(S.of(context).copyright, [DateTime.now().year]),
    applicationIcon: const CircleAvatar(
      foregroundImage: AssetImage(
        'assets/icons/studipassau_icon_with_bg.png',
      ),
    ),
    children: [
      const SizedBox(
        height: 20,
      ),
      Text(
        S.of(context).aboutText,
        textAlign: TextAlign.justify,
      ),
      const SizedBox(
        height: 20,
      ),
      ElevatedButton.icon(
        icon: const Icon(Icons.mail_outline),
        label: Text(
          S.of(context).email,
        ),
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(35)),
        ),
        onPressed: () async {
          await launchUrl(aboutEmailUrl);
        },
      ),
      ElevatedButton.icon(
        icon: const Icon(Icons.translate),
        label: Text(
          S.of(context).translation,
        ),
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(35)),
        ),
        onPressed: () async {
          await launchUrl(translationUrl);
        },
      ),
      ElevatedButton.icon(
        icon: const Icon(StudiPassauIcons.github),
        label: Text(
          S.of(context).viewSource,
        ),
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(35)),
        ),
        onPressed: () async {
          await launchUrl(githubUrl);
        },
      ),
    ],
  );
}
