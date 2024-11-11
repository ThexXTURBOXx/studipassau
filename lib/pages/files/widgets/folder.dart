import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';

const goUpType = 'StudiPassau.GoUp';

class FolderWidget extends StatelessWidget {
  const FolderWidget({required this.folder, super.key, this.onTap});

  final Folder folder;
  final void Function()? onTap;

  String get sortKey => title;

  String get title => folder.name;

  String formatDesc(String cat, String desc) =>
      desc.isNotEmpty ? '\n${sprintf(cat, [folder.description])}' : '';

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
  Widget build(BuildContext context) => ListTile(
        leading: folder.isGoUpFolder
            ? const Icon(Icons.arrow_upward)
            : const Icon(Icons.folder_open),
        title: Text(title),
        subtitle:
            folder.description.isNotEmpty ? Text(folder.description) : null,
        onTap: onTap,
        onLongPress: () async {
          if (folder.isGoUpFolder) {
            return;
          }
          final s = S.of(context);
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(
                '${sprintf(s.changeDate, [
                      formatDateTime(folder.changeDate),
                    ])}\n'
                '${sprintf(s.createDate, [
                      formatDateTime(folder.makeDate),
                    ])}'
                '${formatDesc(s.fileDescription, folder.description)}',
              ),
            ),
          );
        },
      );
}

class Folder extends Equatable {
  const Folder({
    required this.id,
    required this.folderType,
    required this.name,
    required this.description,
    required this.makeDate,
    required this.changeDate,
    required this.parentId,
  });

  factory Folder.fromJson(json) => Folder(
        id: json['id'].toString(),
        folderType: json['attributes']['folder-type'].toString(),
        name: json['attributes']['name'].toString(),
        description: (json['attributes']['description'] ?? '').toString(),
        makeDate: parseInLocalZone(json['attributes']['mkdate']),
        changeDate: parseInLocalZone(json['attributes']['chdate']),
        parentId: json['parent'].toString(),
      );

  factory Folder.goUp() => Folder(
        id: '0',
        folderType: goUpType,
        name: '..',
        description: '',
        makeDate: DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true),
        changeDate: DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true),
        parentId: '0',
      );

  final String id;
  final String folderType;
  final String name;
  final String description;
  final DateTime makeDate;
  final DateTime changeDate;
  final String parentId;

  bool get isGoUpFolder => folderType == goUpType;

  @override
  List<Object> get props => [
        id,
        folderType,
        name,
        description,
        makeDate,
        changeDate,
        parentId,
      ];
}
