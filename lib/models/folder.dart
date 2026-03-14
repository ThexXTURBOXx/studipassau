import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/util/json.dart';

part 'folder.freezed.dart';
part 'folder.g.dart';

const _goUpType = 'StudiPassau.GoUp';

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
    folderType: _goUpType,
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

  bool get isGoUpFolder => folderType == _goUpType;
}
