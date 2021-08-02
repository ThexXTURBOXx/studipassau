import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studipassau/bloc/repo.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:studipassau/util/images.dart';
import 'package:studipassau/util/navigation.dart';

class StudiPassauDrawer extends StatelessWidget {
  final StudiPassauRepo _repo = StudiPassauRepo();
  final StudIPCacheManager _cacheManager = StudIPCacheManager();

  final DrawerItem selected;

  StudiPassauDrawer(this.selected);

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                    CircularProgressIndicator(value: downloadProgress.progress),
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
                          vertical: 4.0,
                          horizontal: 16.0,
                        ),
                        child: Text(
                          item.name(context),
                          style: TextStyle(color: context.theme.hintColor),
                        ),
                      )
                    : ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.name(context)),
                        onTap: () => selected == item
                            ? Scaffold.of(context).openEndDrawer()
                            : navigateTo(context, item.route),
                        selected: selected == item,
                        selectedTileColor: context.theme.primaryColorLight,
                      ),
        ],
      ),
    );
  }
}

enum DrawerItem {
  SCHEDULE,
  MENSA_PLAN,
  FILES,
  DIVIDER1,
  MISC,
  BROWSER,
  SETTINGS,
  BUG_REPORT,
  SHARE,
  ABOUT,
  DIVIDER2,
  TOOLS,
  TELEGRAM_BOT,
}

extension DrawerItemExtension on DrawerItem {
  String name(BuildContext context) {
    switch (this) {
      case DrawerItem.SCHEDULE:
        return S.of(context).drawerSchedule;
      case DrawerItem.MENSA_PLAN:
        return S.of(context).drawerMensaPlan;
      case DrawerItem.FILES:
        return S.of(context).drawerFiles;
      case DrawerItem.MISC:
        return S.of(context).drawerMisc;
      case DrawerItem.BROWSER:
        return S.of(context).drawerOpenInBrowser;
      case DrawerItem.SETTINGS:
        return S.of(context).drawerSettings;
      case DrawerItem.BUG_REPORT:
        return S.of(context).drawerBugs;
      case DrawerItem.SHARE:
        return S.of(context).drawerShare;
      case DrawerItem.ABOUT:
        return S.of(context).drawerAbout;
      case DrawerItem.TOOLS:
        return S.of(context).drawerTools;
      case DrawerItem.TELEGRAM_BOT:
        return S.of(context).drawerTelegramBot;
      default:
        return '';
    }
  }

  String? get route {
    switch (this) {
      case DrawerItem.SCHEDULE:
        return ROUTE_SCHEDULE;
      default:
        return null;
    }
  }

  IconData? get icon {
    switch (this) {
      case DrawerItem.SCHEDULE:
        return Icons.event_note;
      case DrawerItem.MENSA_PLAN:
        return Icons.restaurant;
      case DrawerItem.FILES:
        return Icons.folder_open;
      case DrawerItem.BROWSER:
        return Icons.insert_link;
      case DrawerItem.SETTINGS:
        return Icons.build;
      case DrawerItem.BUG_REPORT:
        return Icons.bug_report;
      case DrawerItem.SHARE:
        return Icons.share;
      case DrawerItem.ABOUT:
        return Icons.info_outline;
      case DrawerItem.TELEGRAM_BOT:
        // TODO(HyperSpeeed): Add real Telegram icon? Licensing?
        return Icons.send;
      default:
        return null;
    }
  }

  bool get isDivider =>
      this == DrawerItem.DIVIDER1 || this == DrawerItem.DIVIDER2;

  bool get isSubTitle => this == DrawerItem.MISC || this == DrawerItem.TOOLS;
}
