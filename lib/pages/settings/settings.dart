import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/files/files.dart';
import 'package:studipassau/pages/mensa/mensa.dart';
import 'package:studipassau/pages/news/news.dart';
import 'package:studipassau/pages/roomfinder/roomfinder.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:studipassau/pages/settings/widgets/color_pref.dart';

const routeSettings = '/settings';

const uiThemePref = 'ui_theme';
const material3Pref = 'material3';
const startRoutePref = 'start_route';
const scheduleAutoSyncPref = 'schedule_auto_sync';
const nonRegularColorPref = 'non_regular_color';
const notFoundColorPref = 'not_found_color';
const canceledColorPref = 'canceled_color';
const showScheduleOnlyPref = 'show_schedule_only';
const mensaAutoSyncPref = 'mensa_auto_sync';
const mensaSourcePref = 'mensa_source';
const mensaTypePref = 'mensa_type';
const soupColorPref = 'soup_color';
const mainDishColorPref = 'main_dish_color';
const garnishColorPref = 'garnish_color';
const dessertColorPref = 'dessert_color';
const newsAutoSyncPref = 'news_auto_sync';

const uiThemePrefDefault = 'default';
const uiThemePrefLight = 'light';
const uiThemePrefDark = 'dark';

const mensaSourcePrefStwno = 'STWNO';
const mensaSourcePrefOM = 'OpenMensa';

const mensaTypePrefStudent = 'student';
const mensaTypePrefEmployee = 'employee';
const mensaTypePrefGuest = 'guest';
const mensaTypePrefPupil = 'pupil';

const Map<String, dynamic> defaults = {
  uiThemePref: uiThemePrefDefault,
  material3Pref: true,
  startRoutePref: routeSchedule,
  scheduleAutoSyncPref: true,
  nonRegularColorPref: 0xff339966,
  notFoundColorPref: 0xffea3838,
  canceledColorPref: 0xff636363,
  showScheduleOnlyPref: true,
  mensaAutoSyncPref: true,
  mensaSourcePref: mensaSourcePrefStwno,
  mensaTypePref: mensaTypePrefStudent,
  soupColorPref: 0xff7bad41,
  mainDishColorPref: 0xffea3838,
  garnishColorPref: 0xff61dfed,
  dessertColorPref: 0xffbaac18,
  newsAutoSyncPref: true,
};

T getPref<T>(String key) => prefService.get(key) ?? defaults[key] as T;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).settingsTitle),
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
                  PrefSwitch(
                    title: Text(S.of(context).material3PrefTitle),
                    subtitle: Text(S.of(context).material3PrefDesc),
                    pref: material3Pref,
                  ),
                  PrefTitle(title: Text(S.of(context).othersPref)),
                  PrefDropdown(
                    title: Text(S.of(context).startRoutePrefTitle),
                    subtitle: Text(S.of(context).startRoutePrefDesc),
                    fullWidth: false,
                    pref: startRoutePref,
                    items: [
                      DropdownMenuItem(
                        value: routeSchedule,
                        child: Text(S.of(context).schedulePrefCatShortTitle),
                      ),
                      DropdownMenuItem(
                        value: routeMensa,
                        child: Text(S.of(context).mensaPrefCatShortTitle),
                      ),
                      DropdownMenuItem(
                        value: routeFiles,
                        child: Text(S.of(context).filesPrefCatShortTitle),
                      ),
                      DropdownMenuItem(
                        value: routeRoomFinder,
                        child: Text(S.of(context).roomFinderPrefCatShortTitle),
                      ),
                      DropdownMenuItem(
                        value: routeNews,
                        child: Text(S.of(context).newsPrefCatShortTitle),
                      ),
                    ],
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
                  PrefColor(
                    title: Text(S.of(context).lectureCanceledColorPrefTitle),
                    subtitle: Text(S.of(context).lectureCanceledColorPrefDesc),
                    pref: canceledColorPref,
                  ),
                  PrefTitle(title: Text(S.of(context).categoriesPref)),
                  PrefSwitch(
                    title: Text(S.of(context).showScheduleOnlyPrefTitle),
                    subtitle: Text(S.of(context).showScheduleOnlyPrefDesc),
                    pref: showScheduleOnlyPref,
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
                  PrefTitle(title: Text(S.of(context).miscPref)),
                  PrefDialogButton(
                    title: Text(S.of(context).mensaTypePrefTitle),
                    subtitle: Text(S.of(context).mensaTypePrefDesc),
                    dialog: PrefDialog(
                      title: Text(S.of(context).mensaTypePrefTitle),
                      children: [
                        PrefRadio(
                          title: Text(S.of(context).mensaTypePrefStudent),
                          value: mensaTypePrefStudent,
                          pref: mensaTypePref,
                        ),
                        PrefRadio(
                          title: Text(S.of(context).mensaTypePrefEmployee),
                          value: mensaTypePrefEmployee,
                          pref: mensaTypePref,
                        ),
                        PrefRadio(
                          title: Text(S.of(context).mensaTypePrefGuest),
                          value: mensaTypePrefGuest,
                          pref: mensaTypePref,
                        ),
                        PrefRadio(
                          title: Text(S.of(context).mensaTypePrefPupil),
                          value: mensaTypePrefPupil,
                          pref: mensaTypePref,
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
            PrefPageButton(
              leading: const Icon(Icons.newspaper),
              pageTitle: Text(S.of(context).newsPrefCatLongTitle),
              title: Text(S.of(context).newsPrefCatShortTitle),
              subtitle: Text(S.of(context).newsPrefCatDesc),
              page: PrefPage(
                children: [
                  PrefTitle(title: Text(S.of(context).syncPref)),
                  PrefSwitch(
                    title: Text(S.of(context).autoSyncPrefTitle),
                    subtitle: Text(S.of(context).autoSyncPrefDesc),
                    pref: newsAutoSyncPref,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
