import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/settings/widgets/color_pref.dart';

const routeSettings = '/settings';

const uiThemePref = 'ui_theme';
const scheduleAutoSyncPref = 'schedule_auto_sync';
const nonRegularColorPref = 'non_regular_color';
const notFoundColorPref = 'not_found_color';
const mensaAutoSyncPref = 'mensa_auto_sync';
const mensaSourcePref = 'mensa_source';
const soupColorPref = 'soup_color';
const mainDishColorPref = 'main_dish_color';
const garnishColorPref = 'garnish_color';
const dessertColorPref = 'dessert_color';

const uiThemePrefDefault = 'default';
const uiThemePrefLight = 'light';
const uiThemePrefDark = 'dark';

const mensaSourcePrefStwno = 'STWNO';
const mensaSourcePrefOM = 'OpenMensa';

const Map<String, dynamic> defaults = {
  uiThemePref: uiThemePrefDefault,
  scheduleAutoSyncPref: true,
  nonRegularColorPref: 0xff339966,
  notFoundColorPref: 0xffea3838,
  mensaAutoSyncPref: true,
  mensaSourcePref: mensaSourcePrefStwno,
  soupColorPref: 0xff7bad41,
  mainDishColorPref: 0xffea3838,
  garnishColorPref: 0xff61dfed,
  dessertColorPref: 0xffbaac18,
};

T getPref<T>(String key) => prefService.get(key) ?? defaults[key] as T;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).aboutTitle),
        ),
        drawer: const StudiPassauDrawer(DrawerItem.settings),
        body: PrefPage(
          children: [
            PrefPageButton(
              leading: const Icon(Icons.tune),
              pageTitle: Text(S.of(context).generalPrefCatLongTitle),
              title: Text(S.of(context).generalPrefCatShortTitle),
              subtitle: Text(S.of(context).generalPrefCatDesc),
              page: PrefPage(
                children: [
                  PrefTitle(title: Text(S.of(context).themePref)),
                  PrefDialogButton(
                    title: Text(S.of(context).uiThemePrefTitle),
                    subtitle: Text(S.of(context).uiThemePrefDesc),
                    dialog: PrefDialog(
                      title: Text(S.of(context).uiThemePrefTitle),
                      children: [
                        PrefRadio(
                          title: Text(S.of(context).uiThemePrefDefault),
                          value: uiThemePrefDefault,
                          pref: uiThemePref,
                        ),
                        PrefRadio(
                          title: Text(S.of(context).uiThemePrefLight),
                          value: uiThemePrefLight,
                          pref: uiThemePref,
                        ),
                        PrefRadio(
                          title: Text(S.of(context).uiThemePrefDark),
                          value: uiThemePrefDark,
                          pref: uiThemePref,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PrefPageButton(
              leading: const Icon(Icons.event_note),
              pageTitle: Text(S.of(context).schedulePrefCatLongTitle),
              title: Text(S.of(context).schedulePrefCatShortTitle),
              subtitle: Text(S.of(context).schedulePrefCatDesc),
              page: PrefPage(
                children: [
                  PrefTitle(title: Text(S.of(context).syncPref)),
                  PrefSwitch(
                    title: Text(S.of(context).autoSyncPrefTitle),
                    subtitle: Text(S.of(context).autoSyncPrefDesc),
                    pref: scheduleAutoSyncPref,
                  ),
                  PrefTitle(title: Text(S.of(context).colorsPref)),
                  PrefColor(
                    title: Text(S.of(context).nonRegularColorPrefTitle),
                    subtitle: Text(S.of(context).nonRegularColorPrefDesc),
                    pref: nonRegularColorPref,
                  ),
                  PrefColor(
                    title: Text(S.of(context).lectureNotFoundColorPrefTitle),
                    subtitle: Text(S.of(context).lectureNotFoundColorPrefDesc),
                    pref: notFoundColorPref,
                  ),
                ],
              ),
            ),
            PrefPageButton(
              leading: const Icon(Icons.restaurant),
              pageTitle: Text(S.of(context).mensaPrefCatLongTitle),
              title: Text(S.of(context).mensaPrefCatShortTitle),
              subtitle: Text(S.of(context).mensaPrefCatDesc),
              page: PrefPage(
                children: [
                  PrefTitle(title: Text(S.of(context).syncPref)),
                  PrefSwitch(
                    title: Text(S.of(context).autoSyncPrefTitle),
                    subtitle: Text(S.of(context).autoSyncPrefDesc),
                    pref: mensaAutoSyncPref,
                  ),
                  PrefDialogButton(
                    title: Text(S.of(context).mensaSourcePrefTitle),
                    subtitle: Text(S.of(context).mensaSourcePrefDesc),
                    dialog: PrefDialog(
                      title: Text(S.of(context).mensaSourcePrefTitle),
                      children: [
                        PrefRadio(
                          title: Text(S.of(context).mensaSourcePrefStwno),
                          value: mensaSourcePrefStwno,
                          pref: mensaSourcePref,
                        ),
                        PrefRadio(
                          title: Text(S.of(context).mensaSourcePrefOM),
                          value: mensaSourcePrefOM,
                          pref: mensaSourcePref,
                        ),
                      ],
                    ),
                  ),
                  PrefTitle(title: Text(S.of(context).colorsPref)),
                  PrefColor(
                    title: Text(S.of(context).soupColorPrefTitle),
                    subtitle: Text(S.of(context).soupColorPrefDesc),
                    pref: soupColorPref,
                  ),
                  PrefColor(
                    title: Text(S.of(context).mainDishColorPrefTitle),
                    subtitle: Text(S.of(context).mainDishColorPrefDesc),
                    pref: mainDishColorPref,
                  ),
                  PrefColor(
                    title: Text(S.of(context).garnishColorPrefTitle),
                    subtitle: Text(S.of(context).garnishColorPrefDesc),
                    pref: garnishColorPref,
                  ),
                  PrefColor(
                    title: Text(S.of(context).dessertColorPrefTitle),
                    subtitle: Text(S.of(context).dessertColorPrefDesc),
                    pref: dessertColorPref,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
