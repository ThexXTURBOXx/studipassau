import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/util/json.dart';
import 'package:studipassau/util/jsonapi.dart';

part 'folder.freezed.dart';
part 'folder.g.dart';

const goUpType = 'StudiPassau.GoUp';

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
        final s = S.of(context);
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

typedef Folder = JsonApiResource<FolderAttributes>;

Folder goUpFolder() => JsonApiResource<FolderAttributes>(
  type: 'folders',
  id: '0',
  attributes: FolderAttributes.goUp(),
  relationships: {},
);

@freezed
sealed class FolderAttributes with _$FolderAttributes {
  const FolderAttributes._();

  @StringConverter()
  @DateTimeInLocalZoneConverter()
  const factory FolderAttributes({
    @JsonKey(name: 'folder-type') required String folderType,
    required String name,
    String? description,
    @JsonKey(name: 'mkdate') required DateTime makeDate,
    @JsonKey(name: 'chdate') required DateTime changeDate,
    @JsonKey(name: 'is-visible') required bool isVisible,
    @JsonKey(name: 'is-readable') required bool isReadable,
    @JsonKey(name: 'is-writable') required bool isWritable,
    @JsonKey(name: 'is-editable') required bool isEditable,
    @JsonKey(name: 'is-subfolder-allowed') required bool isSubfolderAllowed,
  }) = _FolderAttributes;

  factory FolderAttributes.goUp() => FolderAttributes(
    folderType: goUpType,
    name: '..',
    makeDate: DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true),
    changeDate: DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true),
    isVisible: true,
    isReadable: true,
    isWritable: false,
    isEditable: false,
    isSubfolderAllowed: false,
  );

  factory FolderAttributes.fromJson(Map<String, dynamic> json) =>
      _$FolderAttributesFromJson(json);

  bool get isGoUpFolder => folderType == goUpType;
}
