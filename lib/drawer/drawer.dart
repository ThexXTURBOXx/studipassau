import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studipassau/bloc/repo.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/icons/studi_passau_icons.dart';
import 'package:studipassau/pages/mensa/mensa.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:studipassau/util/images.dart';
import 'package:studipassau/util/navigation.dart';

class StudiPassauDrawer extends StatelessWidget {
  final StudiPassauRepo _repo = StudiPassauRepo();
  final StudIPCacheManager _cacheManager = StudIPCacheManager();

  final DrawerItem selected;

  StudiPassauDrawer(this.selected, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_repo.formattedName),
              accountEmail: Text(_repo.username),
              currentAccountPicture: ClipRRect(
                borderRadius: BorderRadius.circular(110),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: _repo.avatarNormal,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                    value: downloadProgress.progress,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  cacheManager: _cacheManager,
                ),
              ),
            ),
            for (DrawerItem item in DrawerItem.values)
              item.isDivider
                  ? const Divider()
                  : item.isSubTitle
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 16,
                          ),
                          child: Text(
                            item.name(context),
                            style: TextStyle(color: context.theme.hintColor),
                          ),
                        )
                      : ListTile(
                          leading: Icon(item.icon),
                          title: Text(item.name(context)),
                          onTap: () async => selected == item
                              ? closeDrawer(context)
                              : item.onTap(context),
                          selected: selected == item,
                          selectedTileColor: context.theme.primaryColorLight,
                        ),
          ],
        ),
      );
}

enum DrawerItem {
  schedule,
  mensaPlan,
  files,
  divider1,
  misc,
  browser,
  settings,
  bugReport,
  share,
  about,
  divider2,
  tools,
  telegramBot,
}

extension DrawerItemExtension on DrawerItem {
  String name(BuildContext context) {
    switch (this) {
      case DrawerItem.schedule:
        return S.of(context).drawerSchedule;
      case DrawerItem.mensaPlan:
        return S.of(context).drawerMensaPlan;
      case DrawerItem.files:
        return S.of(context).drawerFiles;
      case DrawerItem.misc:
        return S.of(context).drawerMisc;
      case DrawerItem.browser:
        return S.of(context).drawerOpenInBrowser;
      case DrawerItem.settings:
        return S.of(context).drawerSettings;
      case DrawerItem.bugReport:
        return S.of(context).drawerBugs;
      case DrawerItem.share:
        return S.of(context).drawerShare;
      case DrawerItem.about:
        return S.of(context).drawerAbout;
      case DrawerItem.tools:
        return S.of(context).drawerTools;
      case DrawerItem.telegramBot:
        return S.of(context).drawerTelegramBot;
      default:
        return '';
    }
  }

  String? get route {
    switch (this) {
      case DrawerItem.schedule:
        return routeSchedule;
      case DrawerItem.mensaPlan:
        return routeMensa;
      default:
        return null;
    }
  }

  IconData? get icon {
    switch (this) {
      case DrawerItem.schedule:
        return Icons.event_note;
      case DrawerItem.mensaPlan:
        return Icons.restaurant;
      case DrawerItem.files:
        return Icons.folder_open;
      case DrawerItem.browser:
        return Icons.insert_link;
      case DrawerItem.settings:
        return Icons.build;
      case DrawerItem.bugReport:
        return Icons.bug_report;
      case DrawerItem.share:
        return Icons.share;
      case DrawerItem.about:
        return Icons.info_outline;
      case DrawerItem.telegramBot:
        return StudiPassauIcons.telegramPlane;
      default:
        return null;
    }
  }

  Future<void> Function(BuildContext context) get onTap {
    switch (this) {
      case DrawerItem.browser:
        return (context) async {
          closeDrawer(context);
          await launchUrl(studIpProviderUrl);
        };
      case DrawerItem.bugReport:
        return (context) async {
          closeDrawer(context);
          await launchUrl(bugReportUrl);
        };
      case DrawerItem.share:
        return (context) async {
          closeDrawer(context);
          await Share.share(
            S.of(context).shareBody,
            subject: S.of(context).shareSubject,
          );
        };
      case DrawerItem.telegramBot:
        return (context) async {
          closeDrawer(context);
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(S.of(context).telegramBotTitle),
              content: Text(S.of(context).telegramBotBody),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: Text(S.of(context).cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Okay');
                    launchUrl(telegramBotUrl);
                  },
                  child: Text(S.of(context).okay),
                ),
              ],
            ),
          );
        };
      default:
        return route == null
            ? (context) async {
                closeDrawer(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(S.of(context).wip)));
              }
            : (context) async => navigateTo(context, route);
    }
  }

  bool get isDivider =>
      this == DrawerItem.divider1 || this == DrawerItem.divider2;

  bool get isSubTitle => this == DrawerItem.misc || this == DrawerItem.tools;
}
