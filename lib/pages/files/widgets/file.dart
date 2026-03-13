import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/util/json.dart';
import 'package:studipassau/util/jsonapi.dart';

part 'file.freezed.dart';
part 'file.g.dart';

class FileWidget extends StatelessWidget {
  const FileWidget({
    required this.file,
    super.key,
    this.onTap,
    this.showDownloads = false,
  });

  final FileRef file;
  final void Function()? onTap;
  final bool showDownloads;

  String get sortKey => title;

  String get title => file.attributes.name;

  String formatDesc(String cat) {
    final description = file.attributes.description;
    return description?.isEmpty ?? true
        ? ''
        : '\n${sprintf(cat, [description])}';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<FileRef>('file', file))
      ..add(ObjectFlagProperty<void Function()?>.has('onTap', onTap))
      ..add(DiagnosticsProperty<bool>('showDownloads', showDownloads))
      ..add(StringProperty('sortKey', sortKey))
      ..add(StringProperty('title', title));
  }

  @override
  Widget build(BuildContext context) {
    final description = file.attributes.description;

    return ListTile(
      leading: const Icon(Icons.insert_drive_file_outlined),
      title: Text(title),
      subtitle: description?.isEmpty ?? true ? null : Text(description!),
      trailing: showDownloads
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${file.attributes.downloads} ',
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
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(
              '${sprintf(s.downloads, [file.attributes.downloads])}\n'
              '${sprintf(s.changeDate, [formatDateTime(file.attributes.changeDate)])}\n'
              '${sprintf(s.createDate, [formatDateTime(file.attributes.makeDate)])}\n'
              '${sprintf(s.fileSize, [filesize(file.attributes.filesize)])}'
              '${formatDesc(s.fileDescription)}',
            ),
          ),
        );
      },
    );
  }
}

typedef FileRef = JsonApiResource<FileRefAttributes>;

@freezed
sealed class FileRefAttributes with _$FileRefAttributes {
  const FileRefAttributes._();

  @StringConverter()
  @DateTimeInLocalZoneConverter()
  const factory FileRefAttributes({
    required String name,
    String? description,
    @JsonKey(name: 'mkdate') required DateTime makeDate,
    @JsonKey(name: 'chdate') required DateTime changeDate,
    required int downloads,
    required int filesize,
    @JsonKey(name: 'mime-type') required String mimeType,
    @JsonKey(name: 'is-readable') required bool isReadable,
    @JsonKey(name: 'is-downloadable') required bool isDownloadable,
    @JsonKey(name: 'is-editable') required bool isEditable,
    @JsonKey(name: 'is-writable') required bool isWritable,
  }) = _FileRefAttributes;

  factory FileRefAttributes.fromJson(Map<String, dynamic> json) =>
      _$FileRefAttributesFromJson(json);
}
