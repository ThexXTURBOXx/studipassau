import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';

class FolderWidget extends StatelessWidget {
  final Folder folder;
  final void Function()? onTap;

  const FolderWidget({super.key, required this.folder, this.onTap});

  String get sortKey => title;

  String get title => folder.name;

  String formatDesc(String cat, String desc) =>
      desc.isNotEmpty ? '\n${sprintf(cat, [folder.description])}' : '';

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.folder_open),
        title: Text(title),
        subtitle:
            folder.description.isNotEmpty ? Text(folder.description) : null,
        onTap: onTap,
        onLongPress: () {
          final s = S.of(context);
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(
                '${sprintf(s.changeDate, [
                      formatDateTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          folder.changeDate * 1000,
                        ),
                      ),
                    ])}\n'
                '${sprintf(s.createDate, [
                      formatDateTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          folder.makeDate * 1000,
                        ),
                      ),
                    ])}'
                '${formatDesc(s.fileDescription, folder.description)}',
              ),
            ),
          );
        },
      );
}

class Folder extends Equatable {
  final String id;
  final String userId;
  final String parentId;
  final String rangeId;
  final String rangeType;
  final String folderType;
  final String name;
  final String description;
  final int makeDate;
  final int changeDate;
  final bool isVisible;
  final bool isReadable;
  final bool isWritable;

  const Folder({
    required this.id,
    required this.userId,
    required this.parentId,
    required this.rangeId,
    required this.rangeType,
    required this.folderType,
    required this.name,
    required this.description,
    required this.makeDate,
    required this.changeDate,
    required this.isVisible,
    required this.isReadable,
    required this.isWritable,
  });

  factory Folder.fromJson(json) => Folder(
        id: json['id'].toString(),
        userId: json['user_id'].toString(),
        parentId: json['parent_id'].toString(),
        rangeId: json['range_id'].toString(),
        rangeType: json['range_type'].toString(),
        folderType: json['folder_type'].toString(),
        name: json['name'].toString(),
        description: json['description'].toString(),
        makeDate: int.parse(json['mkdate'].toString()),
        changeDate: int.parse(json['chdate'].toString()),
        isVisible: json['is_visible'].toString().parseBool(),
        isReadable: json['is_readable'].toString().parseBool(),
        isWritable: json['is_writable'].toString().parseBool(),
      );

  @override
  List<Object> get props => [
        id,
        userId,
        parentId,
        rangeId,
        rangeType,
        folderType,
        name,
        description,
        makeDate,
        changeDate,
        isVisible,
        isReadable,
        isWritable,
      ];
}
