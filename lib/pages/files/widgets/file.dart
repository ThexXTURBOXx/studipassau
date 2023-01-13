import 'package:equatable/equatable.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';

class FileWidget extends StatelessWidget {
  final File file;
  final void Function()? onTap;
  final bool showDownloads;

  const FileWidget({
    super.key,
    required this.file,
    this.onTap,
    this.showDownloads = false,
  });

  String formatDesc(String cat, String desc) =>
      desc.isNotEmpty ? '\n${sprintf(cat, [file.description])}' : '';

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.insert_drive_file_outlined),
        title: Text(file.name),
        subtitle: file.description.isNotEmpty ? Text(file.description) : null,
        trailing: showDownloads
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${file.downloads}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Icon(Icons.download, color: Colors.grey),
                ],
              )
            : null,
        onTap: onTap,
        onLongPress: () {
          final s = S.of(context);
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(file.name),
              content: Text(
                '${sprintf(s.downloads, [file.downloads])}\n'
                '${sprintf(s.changeDate, [
                      formatDateTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          file.changeDate * 1000,
                        ),
                      )
                    ])}\n'
                '${sprintf(s.createDate, [
                      formatDateTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          file.makeDate * 1000,
                        ),
                      )
                    ])}\n'
                '${sprintf(s.fileSize, [filesize(file.size)])}'
                '${formatDesc(s.fileDescription, file.description)}',
              ),
            ),
          );
        },
      );
}

class File extends Equatable {
  final String id;
  final String fileId;
  final String folderId;
  final int downloads;
  final String description;
  final String contentTermsOfUseId;
  final String userId;
  final String name;
  final int makeDate;
  final int changeDate;
  final int size;
  final String mimeType;
  final String storage;
  final bool isReadable;
  final bool isDownloadable;
  final bool isEditable;
  final bool isWritable;

  const File({
    required this.id,
    required this.fileId,
    required this.folderId,
    required this.downloads,
    required this.description,
    required this.contentTermsOfUseId,
    required this.userId,
    required this.name,
    required this.makeDate,
    required this.changeDate,
    required this.size,
    required this.mimeType,
    required this.storage,
    required this.isReadable,
    required this.isDownloadable,
    required this.isEditable,
    required this.isWritable,
  });

  factory File.fromJson(json) => File(
        id: json['id'].toString(),
        fileId: json['file_id'].toString(),
        folderId: json['folder_id'].toString(),
        downloads: int.parse(json['downloads'].toString()),
        description: json['description'].toString(),
        contentTermsOfUseId: json['content_terms_of_use_id'].toString(),
        userId: json['user_id'].toString(),
        name: json['name'].toString(),
        makeDate: int.parse(json['mkdate'].toString()),
        changeDate: int.parse(json['chdate'].toString()),
        size: int.parse(json['size'].toString()),
        mimeType: json['mime_type'].toString(),
        storage: json['storage'].toString(),
        isReadable: json['is_readable'].toString().parseBool(),
        isDownloadable: json['is_downloadable'].toString().parseBool(),
        isEditable: json['is_editable'].toString().parseBool(),
        isWritable: json['is_writable'].toString().parseBool(),
      );

  @override
  List<Object> get props => [
        id,
        fileId,
        folderId,
        downloads,
        description,
        contentTermsOfUseId,
        userId,
        name,
        makeDate,
        changeDate,
        size,
        mimeType,
        storage,
        isReadable,
        isDownloadable,
        isEditable,
        isWritable,
      ];
}
