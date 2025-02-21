import 'package:equatable/equatable.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';

class FileWidget extends StatelessWidget {
  const FileWidget({
    required this.file,
    super.key,
    this.onTap,
    this.showDownloads = false,
  });

  final File file;
  final void Function()? onTap;
  final bool showDownloads;

  String get sortKey => title;

  String get title => file.name;

  String formatDesc(String cat, String desc) =>
      desc.isNotEmpty ? '\n${sprintf(cat, [file.description])}' : '';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<File>('file', file))
      ..add(ObjectFlagProperty<void Function()?>.has('onTap', onTap))
      ..add(DiagnosticsProperty<bool>('showDownloads', showDownloads))
      ..add(StringProperty('sortKey', sortKey))
      ..add(StringProperty('title', title));
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.insert_drive_file_outlined),
    title: Text(title),
    subtitle: file.description.isNotEmpty ? Text(file.description) : null,
    trailing:
        showDownloads
            ? Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${file.downloads} ',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Icon(Icons.download, color: Colors.grey),
              ],
            )
            : null,
    onTap: onTap,
    onLongPress: () async {
      final s = S.of(context);
      await showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(title),
              content: Text(
                '${sprintf(s.downloads, [file.downloads])}\n'
                '${sprintf(s.changeDate, [formatDateTime(file.changeDate)])}\n'
                '${sprintf(s.createDate, [formatDateTime(file.makeDate)])}\n'
                '${sprintf(s.fileSize, [filesize(file.size)])}'
                '${formatDesc(s.fileDescription, file.description)}',
              ),
            ),
      );
    },
  );
}

class File extends Equatable {
  const File({
    required this.id,
    required this.name,
    required this.description,
    required this.makeDate,
    required this.changeDate,
    required this.downloads,
    required this.size,
    required this.mimeType,
  });

  factory File.fromJson(json) => File(
    id: json['id'].toString(),
    name: json['attributes']['name'].toString(),
    description: (json['attributes']['description'] ?? '').toString(),
    makeDate: parseInLocalZone(json['attributes']['mkdate']),
    changeDate: parseInLocalZone(json['attributes']['chdate']),
    downloads: int.parse(json['attributes']['downloads'].toString()),
    size: int.parse(json['attributes']['filesize'].toString()),
    mimeType: json['attributes']['mime_type'].toString(),
  );

  final String id;
  final String name;
  final String description;
  final DateTime makeDate;
  final DateTime changeDate;
  final int downloads;
  final int size;
  final String mimeType;

  @override
  List<Object> get props => [
    id,
    name,
    description,
    makeDate,
    changeDate,
    downloads,
    size,
    mimeType,
  ];
}
