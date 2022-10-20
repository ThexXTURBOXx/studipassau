import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/icons/studi_passau_icons.dart';
import 'package:studipassau/pages/about/about.dart';
import 'package:studipassau/pages/files/files.dart';
import 'package:studipassau/pages/mensa/mensa.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:studipassau/util/images.dart';
import 'package:studipassau/util/navigation.dart';

class StudiPassauDrawer extends StatelessWidget {
  final DrawerItem selected;

  const StudiPassauDrawer(this.selected, {super.key});

  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) => UserAccountsDrawerHeader(
                accountName: Text(state.formattedName),
                accountEmail: Text(state.username),
                decoration: const BoxDecoration(
                  color: iconBgColor,
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/icons/studipassau_icon.png',
                    ),
                  ),
                ),
                currentAccountPicture: ClipRRect(
                  borderRadius: BorderRadius.circular(110),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: state.avatarNormal,
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
                            item.title(context),
                            style: TextStyle(color: context.theme.hintColor),
                          ),
                        )
                      : ListTile(
                          leading: Icon(item.icon),
                          title: Text(item.title(context)),
                          onTap: () async => selected == item
                              ? closeDrawer(context)
                              : item.onTap(context),
                          selected: selected == item,
                          selectedTileColor: context.theme.highlightColor,
                        ),
          ],
        ),
      );
}

enum DrawerItem {
  schedule(icon: Icons.event_note, route: routeSchedule),
  mensaPlan(icon: Icons.restaurant, route: routeMensa),
  files(icon: Icons.folder_open, route: routeFiles),
  divider1(isDivider: true),
  misc(isSubTitle: true),
  browser(icon: Icons.insert_link),
  settings(icon: Icons.build, route: routeSettings),
  bugReport(icon: Icons.bug_report),
  share(icon: Icons.share),
  about(icon: Icons.info_outline),
  divider2(isDivider: true),
  tools(isSubTitle: true),
  telegramBot(icon: StudiPassauIcons.telegramPlane);

  final IconData? icon;
  final String? route;
  final bool isDivider;
  final bool isSubTitle;

  const DrawerItem({
    this.icon,
    this.route,
    this.isDivider = false,
    this.isSubTitle = false,
  });

  String title(BuildContext context) {
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

  Future<void> Function(BuildContext context) get onTap {
    switch (this) {
      case DrawerItem.about:
        return showStudiPassauAbout;
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
}
