import 'package:flutter/material.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/icons/studi_passau_icons.dart';
import 'package:studipassau/util/navigation.dart';

const routeAbout = '/about';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).aboutTitle),
        ),
        drawer: StudiPassauDrawer(DrawerItem.about),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  'assets/img/nico.jpg',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                S.of(context).aboutText,
                textAlign: TextAlign.justify,
                textScaleFactor: 1.2,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.mail_outline),
                label: Text(
                  S.of(context).email,
                  textScaleFactor: 1.2,
                ),
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(const Size.fromHeight(35)),
                ),
                onPressed: () async {
                  await launchUrl(aboutEmailUrl);
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.translate),
                label: Text(
                  S.of(context).translation,
                  textScaleFactor: 1.2,
                ),
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(const Size.fromHeight(35)),
                ),
                onPressed: () async {
                  await launchUrl(translationUrl);
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(StudiPassauIcons.github),
                label: Text(
                  S.of(context).viewSource,
                  textScaleFactor: 1.2,
                ),
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(const Size.fromHeight(35)),
                ),
                onPressed: () async {
                  await launchUrl(githubUrl);
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.library_books_outlined),
                label: Text(
                  S.of(context).showLicenses,
                  textScaleFactor: 1.2,
                ),
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(const Size.fromHeight(35)),
                ),
                onPressed: () {
                  showLicensePage(
                    context: context,
                    applicationVersion: appVersion,
                    applicationIcon: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        'assets/icons/studipassau_icon_with_bg.png',
                      ),
                    ),
                  );
                },
              ),
              Text(
                '$appName $appVersion',
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
              ),
            ],
          ),
        ),
      );
}
