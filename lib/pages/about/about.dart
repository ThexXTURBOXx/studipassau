import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/icons/studi_passau_icons.dart';
import 'package:studipassau/util/navigation.dart';

Future<void> showStudiPassauAbout(
  BuildContext context,
  LoginState state,
) async {
  showAboutDialog(
    context: context,
    applicationName: context.i18n.applicationTitle,
    applicationVersion: appVersion,
    applicationLegalese: sprintf(context.i18n.copyright, [DateTime.now().year]),
    applicationIcon: const CircleAvatar(
      foregroundImage: AssetImage('assets/icons/studipassau_icon_with_bg.png'),
    ),
    children: [
      const SizedBox(height: 20),
      Text(
        sprintf(context.i18n.aboutText, [
          state.formattedName ?? context.i18n.stranger,
        ]),
        textAlign: TextAlign.justify,
      ),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        icon: const Icon(Icons.mail_outline),
        label: Text(context.i18n.email),
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(35)),
        ),
        onPressed: () async {
          await launchUriString(aboutEmailUrl);
        },
      ),
      ElevatedButton.icon(
        icon: const Icon(Icons.translate),
        label: Text(context.i18n.translation),
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(35)),
        ),
        onPressed: () async {
          await launchUriString(translationUrl);
        },
      ),
      ElevatedButton.icon(
        icon: const Icon(StudiPassauIcons.github),
        label: Text(context.i18n.viewSource),
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(35)),
        ),
        onPressed: () async {
          await launchUriString(githubUrl);
        },
      ),
    ],
  );
}
