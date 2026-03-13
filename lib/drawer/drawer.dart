import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/icons/studi_passau_icons.dart';
import 'package:studipassau/pages/about/about.dart';
import 'package:studipassau/pages/files/files.dart';
import 'package:studipassau/pages/mensa/mensa.dart';
import 'package:studipassau/pages/news/news.dart';
import 'package:studipassau/pages/roomfinder/roomfinder.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:studipassau/util/images.dart';
import 'package:studipassau/util/navigation.dart';

class StudiPassauDrawer extends StatelessWidget {
  const StudiPassauDrawer(this.selected, {super.key});

  final DrawerItem selected;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<DrawerItem>('selected', selected));
  }

  @override
  Widget build(BuildContext context) => Drawer(
    child: BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                state.formattedName ?? context.i18n.notLoggedIn,
              ),
              accountEmail: Text(state.username ?? context.i18n.notLoggedIn),
              decoration: const BoxDecoration(
                color: iconBgColor,
                image: DecorationImage(
                  image: AssetImage('assets/icons/studipassau_icon.png'),
                ),
              ),
              currentAccountPicture: ClipRRect(
                borderRadius: BorderRadius.circular(110),
                child: state.userData == null || state.avatarNormal == null
                    ? const Icon(Icons.error)
                    : CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: state.avatarNormal!,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        cacheManager: StudIPCacheManager.instance,
                      ),
              ),
            ),
            for (final DrawerItem item in DrawerItem.values)
              item.isDivider
                  ? const Divider()
                  : item.isSubTitle
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ),
                      child: Text(
                        item.title(context),
                        style: TextStyle(color: context.theme.hintColor),
                      ),
                    )
                  : ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title(context)),
                      onTap: () async => selected == item
                          ? closeDrawer(context)
                          : item.onTap(context, state),
                      selected: selected == item,
                      selectedTileColor: context.theme.highlightColor,
                    ),
          ],
        ),
      ),
    ),
  );
}

enum DrawerItem {
  schedule(icon: Icons.event_note, route: routeSchedule),
  mensaPlan(icon: Icons.restaurant, route: routeMensa),
  files(icon: Icons.folder_open, route: routeFiles),
  roomFinder(icon: Icons.explore_outlined, route: routeRoomFinder),
  news(icon: Icons.newspaper, route: routeNews),
  divider1(isDivider: true),
  misc(isSubTitle: true),
  browser(icon: Icons.insert_link),
  settings(icon: Icons.build, route: routeSettings),
  bugReport(icon: Icons.bug_report),
  share(icon: Icons.share),
  about(icon: Icons.info_outline),
  divider2(isDivider: true),
  tools(isSubTitle: true),
  campusPortal(icon: Icons.dataset_outlined), // TODO(Nico): Better icon?
  telegramBot(icon: StudiPassauIcons.telegramPlane);

  const DrawerItem({
    this.icon,
    this.route,
    this.isDivider = false,
    this.isSubTitle = false,
  });

  final IconData? icon;
  final String? route;
  final bool isDivider;
  final bool isSubTitle;

  String title(BuildContext context) {
    switch (this) {
      case DrawerItem.schedule:
        return context.i18n.drawerSchedule;
      case DrawerItem.mensaPlan:
        return context.i18n.drawerMensaPlan;
      case DrawerItem.files:
        return context.i18n.drawerFiles;
      case DrawerItem.roomFinder:
        return context.i18n.drawerRoomFinder;
      case DrawerItem.news:
        return context.i18n.drawerNews;
      case DrawerItem.misc:
        return context.i18n.drawerMisc;
      case DrawerItem.browser:
        return context.i18n.drawerOpenInBrowser;
      case DrawerItem.settings:
        return context.i18n.drawerSettings;
      case DrawerItem.bugReport:
        return context.i18n.drawerBugs;
      case DrawerItem.share:
        return context.i18n.drawerShare;
      case DrawerItem.about:
        return context.i18n.drawerAbout;
      case DrawerItem.tools:
        return context.i18n.drawerTools;
      case DrawerItem.campusPortal:
        return context.i18n.drawerCampusPortal;
      case DrawerItem.telegramBot:
        return context.i18n.drawerTelegramBot;
      default:
        return '';
    }
  }

  Future<void> Function(BuildContext context, LoginState state) get onTap {
    switch (this) {
      case DrawerItem.about:
        return showStudiPassauAbout;
      case DrawerItem.browser:
        return (context, state) async {
          closeDrawer(context);
          await launchUrl(studIpProviderUrl);
        };
      case DrawerItem.bugReport:
        return (context, state) async {
          closeDrawer(context);
          await launchUrl(bugReportUrl);
        };
      case DrawerItem.share:
        return (context, state) async {
          closeDrawer(context);
          await SharePlus.instance.share(
            ShareParams(
              text: context.i18n.shareBody,
              subject: context.i18n.shareSubject,
            ),
          );
        };
      case DrawerItem.campusPortal:
        return (context, state) async {
          closeDrawer(context);
          await launchUrl(campusPortalUrl);
        };
      case DrawerItem.telegramBot:
        return (context, state) async {
          closeDrawer(context);
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(context.i18n.telegramBotTitle),
              content: Text(context.i18n.telegramBotBody),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: Text(context.i18n.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Okay');
                    launchUrl(telegramBotUrl);
                  },
                  child: Text(context.i18n.okay),
                ),
              ],
            ),
          );
        };
      default:
        return route == null
            ? (context, state) async {
                closeDrawer(context);
                context.scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text(context.i18n.wip)),
                );
              }
            : (context, state) async => navigateTo(context, route);
    }
  }
}
