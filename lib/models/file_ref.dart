import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/util/json.dart';

part 'file_ref.freezed.dart';
part 'file_ref.g.dart';

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
