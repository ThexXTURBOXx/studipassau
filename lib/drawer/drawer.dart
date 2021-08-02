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
            ListTile(
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
}

extension DrawerItemExtension on DrawerItem {
  String name(BuildContext context) {
    switch (this) {
      case DrawerItem.SCHEDULE:
        return S.of(context).drawerSchedule;
      case DrawerItem.MENSA_PLAN:
        return S.of(context).drawerMensaPlan;
      default:
        return '';
    }
  }

  String? get route {
    switch (this) {
      case DrawerItem.SCHEDULE:
        return ROUTE_SCHEDULE;
      case DrawerItem.MENSA_PLAN:
      //return ROUTE_MENSA_PLAN;
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
      default:
        return null;
    }
  }
}
