import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studipassau/bloc/repo.dart';
import 'package:studipassau/util/images.dart';

class StudiPassauDrawer extends StatelessWidget {
  final StudiPassauRepo _repo = StudiPassauRepo();
  final StudIPCacheManager _cacheManager = StudIPCacheManager();

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
          ListTile(
            title: const Text('Item 1'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
