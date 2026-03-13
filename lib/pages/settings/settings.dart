import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/pages/files/files.dart';
import 'package:studipassau/pages/mensa/mensa.dart';
import 'package:studipassau/pages/news/news.dart';
import 'package:studipassau/pages/roomfinder/roomfinder.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:studipassau/pages/settings/widgets/color_pref.dart';

const routeSettings = '/settings';

const uiThemePref = 'ui_theme';
const startRoutePref = 'start_route';
const autoLoginPref = 'auto_login';
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
  startRoutePref: routeSchedule,
  autoLoginPref: true,
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
    appBar: AppBar(title: Text(context.i18n.settingsTitle)),
    drawer: const StudiPassauDrawer(DrawerItem.settings),
    body: PrefPage(
      children: [
        PrefPageButton(
          leading: const Icon(Icons.tune),
          pageTitle: Text(context.i18n.generalPrefCatLongTitle),
          title: Text(context.i18n.generalPrefCatShortTitle),
          subtitle: Text(context.i18n.generalPrefCatDesc),
          page: PrefPage(
            children: [
              PrefTitle(title: Text(context.i18n.themePref)),
              PrefDialogButton(
                title: Text(context.i18n.uiThemePrefTitle),
                subtitle: Text(context.i18n.uiThemePrefDesc),
                dialog: PrefDialog(
                  title: Text(context.i18n.uiThemePrefTitle),
                  children: [
                    PrefRadio(
                      title: Text(context.i18n.uiThemePrefDefault),
                      value: uiThemePrefDefault,
                      pref: uiThemePref,
                    ),
                    PrefRadio(
                      title: Text(context.i18n.uiThemePrefLight),
                      value: uiThemePrefLight,
                      pref: uiThemePref,
                    ),
                    PrefRadio(
                      title: Text(context.i18n.uiThemePrefDark),
                      value: uiThemePrefDark,
                      pref: uiThemePref,
                    ),
                  ],
                ),
              ),
              PrefTitle(title: Text(context.i18n.othersPref)),
              PrefDropdown(
                title: Text(context.i18n.startRoutePrefTitle),
                subtitle: Text(context.i18n.startRoutePrefDesc),
                fullWidth: false,
                pref: startRoutePref,
                items: [
                  DropdownMenuItem(
                    value: routeSchedule,
                    child: Text(context.i18n.schedulePrefCatShortTitle),
                  ),
                  DropdownMenuItem(
                    value: routeMensa,
                    child: Text(context.i18n.mensaPrefCatShortTitle),
                  ),
                  DropdownMenuItem(
                    value: routeFiles,
                    child: Text(context.i18n.filesPrefCatShortTitle),
                  ),
                  DropdownMenuItem(
                    value: routeRoomFinder,
                    child: Text(context.i18n.roomFinderPrefCatShortTitle),
                  ),
                  DropdownMenuItem(
                    value: routeNews,
                    child: Text(context.i18n.newsPrefCatShortTitle),
                  ),
                ],
              ),
              PrefSwitch(
                title: Text(context.i18n.autoLoginPrefTitle),
                subtitle: Text(context.i18n.autoLoginPrefDesc),
                pref: autoLoginPref,
              ),
            ],
          ),
        ),
        PrefPageButton(
          leading: const Icon(Icons.event_note),
          pageTitle: Text(context.i18n.schedulePrefCatLongTitle),
          title: Text(context.i18n.schedulePrefCatShortTitle),
          subtitle: Text(context.i18n.schedulePrefCatDesc),
          page: PrefPage(
            children: [
              PrefTitle(title: Text(context.i18n.syncPref)),
              PrefSwitch(
                title: Text(context.i18n.autoSyncPrefTitle),
                subtitle: Text(context.i18n.autoSyncPrefDesc),
                pref: scheduleAutoSyncPref,
              ),
              PrefTitle(title: Text(context.i18n.colorsPref)),
              PrefColor(
                title: Text(context.i18n.nonRegularColorPrefTitle),
                subtitle: Text(context.i18n.nonRegularColorPrefDesc),
                pref: nonRegularColorPref,
              ),
              PrefColor(
                title: Text(context.i18n.lectureNotFoundColorPrefTitle),
                subtitle: Text(context.i18n.lectureNotFoundColorPrefDesc),
                pref: notFoundColorPref,
              ),
              PrefColor(
                title: Text(context.i18n.lectureCanceledColorPrefTitle),
                subtitle: Text(context.i18n.lectureCanceledColorPrefDesc),
                pref: canceledColorPref,
              ),
              PrefTitle(title: Text(context.i18n.categoriesPref)),
              PrefSwitch(
                title: Text(context.i18n.showScheduleOnlyPrefTitle),
                subtitle: Text(context.i18n.showScheduleOnlyPrefDesc),
                pref: showScheduleOnlyPref,
              ),
            ],
          ),
        ),
        PrefPageButton(
          leading: const Icon(Icons.restaurant),
          pageTitle: Text(context.i18n.mensaPrefCatLongTitle),
          title: Text(context.i18n.mensaPrefCatShortTitle),
          subtitle: Text(context.i18n.mensaPrefCatDesc),
          page: PrefPage(
            children: [
              PrefTitle(title: Text(context.i18n.syncPref)),
              PrefSwitch(
                title: Text(context.i18n.autoSyncPrefTitle),
                subtitle: Text(context.i18n.autoSyncPrefDesc),
                pref: mensaAutoSyncPref,
              ),
              PrefDialogButton(
                title: Text(context.i18n.mensaSourcePrefTitle),
                subtitle: Text(context.i18n.mensaSourcePrefDesc),
                dialog: PrefDialog(
                  title: Text(context.i18n.mensaSourcePrefTitle),
                  children: [
                    PrefRadio(
                      title: Text(context.i18n.mensaSourcePrefStwno),
                      value: mensaSourcePrefStwno,
                      pref: mensaSourcePref,
                    ),
                    PrefRadio(
                      title: Text(context.i18n.mensaSourcePrefOM),
                      value: mensaSourcePrefOM,
                      pref: mensaSourcePref,
                    ),
                  ],
                ),
              ),
              PrefTitle(title: Text(context.i18n.miscPref)),
              PrefDialogButton(
                title: Text(context.i18n.mensaTypePrefTitle),
                subtitle: Text(context.i18n.mensaTypePrefDesc),
                dialog: PrefDialog(
                  title: Text(context.i18n.mensaTypePrefTitle),
                  children: [
                    PrefRadio(
                      title: Text(context.i18n.mensaTypePrefStudent),
                      value: mensaTypePrefStudent,
                      pref: mensaTypePref,
                    ),
                    PrefRadio(
                      title: Text(context.i18n.mensaTypePrefEmployee),
                      value: mensaTypePrefEmployee,
                      pref: mensaTypePref,
                    ),
                    PrefRadio(
                      title: Text(context.i18n.mensaTypePrefGuest),
                      value: mensaTypePrefGuest,
                      pref: mensaTypePref,
                    ),
                    PrefRadio(
                      title: Text(context.i18n.mensaTypePrefPupil),
                      value: mensaTypePrefPupil,
                      pref: mensaTypePref,
                    ),
                  ],
                ),
              ),
              PrefTitle(title: Text(context.i18n.colorsPref)),
              PrefColor(
                title: Text(context.i18n.soupColorPrefTitle),
                subtitle: Text(context.i18n.soupColorPrefDesc),
                pref: soupColorPref,
              ),
              PrefColor(
                title: Text(context.i18n.mainDishColorPrefTitle),
                subtitle: Text(context.i18n.mainDishColorPrefDesc),
                pref: mainDishColorPref,
              ),
              PrefColor(
                title: Text(context.i18n.garnishColorPrefTitle),
                subtitle: Text(context.i18n.garnishColorPrefDesc),
                pref: garnishColorPref,
              ),
              PrefColor(
                title: Text(context.i18n.dessertColorPrefTitle),
                subtitle: Text(context.i18n.dessertColorPrefDesc),
                pref: dessertColorPref,
              ),
            ],
          ),
        ),
        PrefPageButton(
          leading: const Icon(Icons.newspaper),
          pageTitle: Text(context.i18n.newsPrefCatLongTitle),
          title: Text(context.i18n.newsPrefCatShortTitle),
          subtitle: Text(context.i18n.newsPrefCatDesc),
          page: PrefPage(
            children: [
              PrefTitle(title: Text(context.i18n.syncPref)),
              PrefSwitch(
                title: Text(context.i18n.autoSyncPrefTitle),
                subtitle: Text(context.i18n.autoSyncPrefDesc),
                pref: newsAutoSyncPref,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
