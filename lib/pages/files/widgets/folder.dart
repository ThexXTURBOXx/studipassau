import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/models/folder.dart';

class FolderWidget extends StatelessWidget {
  const FolderWidget({required this.folder, super.key, this.onTap});

  final Folder folder;
  final void Function()? onTap;

  String get sortKey => title;

  String get title => folder.attributes.name;

  String formatDesc(String cat) {
    final description = folder.attributes.description;
    return description?.isEmpty ?? true
        ? ''
        : '\n${sprintf(cat, [description])}';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Folder>('folder', folder))
      ..add(ObjectFlagProperty<void Function()?>.has('onTap', onTap))
      ..add(StringProperty('sortKey', sortKey))
      ..add(StringProperty('title', title));
  }

  @override
  Widget build(BuildContext context) {
    final description = folder.attributes.description;

    return ListTile(
      leading: folder.attributes.isGoUpFolder
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.folder_open),
      title: Text(title),
      subtitle: description?.isEmpty ?? true ? null : Text(description!),
      onTap: onTap,
      onLongPress: () async {
        if (folder.attributes.isGoUpFolder) {
          return;
        }
        final s = context.i18n;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(
              '${sprintf(s.changeDate, [formatDateTime(folder.attributes.changeDate)])}'
              '\n'
              '${sprintf(s.createDate, [formatDateTime(folder.attributes.makeDate)])}'
              '${formatDesc(s.fileDescription)}',
            ),
          ),
        );
      },
    );
  }
}
