import 'package:freezed_annotation/freezed_annotation.dart';

part 'jsonapi.freezed.dart';
part 'jsonapi.g.dart';

List<JsonApiResource<A>> parseCollection<A>(
  Map<String, dynamic> json,
  A Function(Object?) fromJsonA,
) {
  final doc = JsonApiDocument.fromJson(
    json,
    (item) => JsonApiResource.fromJson(item as Map<String, dynamic>, fromJsonA),
  );
  return doc.data;
}

@Freezed(genericArgumentFactories: true)
abstract class JsonApiDocument<T> with _$JsonApiDocument<T> {
  const JsonApiDocument._();

  const factory JsonApiDocument({required List<T> data, JsonApiMeta? meta}) =
      _JsonApiDocument<T>;

  factory JsonApiDocument.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$JsonApiDocumentFromJson(json, fromJsonT);

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$JsonApiDocumentToJson(this as _JsonApiDocument<T>, toJsonT);
}

@freezed
abstract class JsonApiMeta with _$JsonApiMeta {
  const JsonApiMeta._();

  const factory JsonApiMeta({JsonApiPageMeta? page}) = _JsonApiMeta;

  factory JsonApiMeta.fromJson(Map<String, dynamic> json) =>
      _$JsonApiMetaFromJson(json);
}

@freezed
abstract class JsonApiPageMeta with _$JsonApiPageMeta {
  const JsonApiPageMeta._();

  const factory JsonApiPageMeta({
    required int offset,
    required int limit,
    required int total,
  }) = _JsonApiPageMeta;

  factory JsonApiPageMeta.fromJson(Map<String, dynamic> json) =>
      _$JsonApiPageMetaFromJson(json);
}

@Freezed(genericArgumentFactories: true)
abstract class JsonApiResource<A> with _$JsonApiResource<A> {
  const JsonApiResource._();

  const factory JsonApiResource({
    required String id,
    required String type,
    required A attributes,
    required Map<String, JsonApiRelationship> relationships,
  }) = _JsonApiResource<A>;

  factory JsonApiResource.fromJson(
    Map<String, dynamic> json,
    A Function(Object?) fromJsonA,
  ) => _$JsonApiResourceFromJson(json, fromJsonA);

  @override
  Map<String, dynamic> toJson(Object? Function(A) toJsonA) =>
      _$JsonApiResourceToJson(this as _JsonApiResource<A>, toJsonA);

  JsonApiRelationship relationship(String id) => relationships[id]!;
}

@freezed
abstract class JsonApiRelationship with _$JsonApiRelationship {
  const JsonApiRelationship._();

  const factory JsonApiRelationship({
    @JsonApiRelationshipDataConverter() JsonApiRelationshipData? data,
  }) = _JsonApiRelationship;

  factory JsonApiRelationship.fromJson(Map<String, dynamic> json) =>
      _$JsonApiRelationshipFromJson(json);

  List<JsonApiResourceLinkage> get all => data?.all ?? [];

  JsonApiResourceLinkage? get firstOrNull => data?.firstOrNull;

  JsonApiResourceLinkage get first => data!.first;
}

@freezed
sealed class JsonApiRelationshipData with _$JsonApiRelationshipData {
  const JsonApiRelationshipData._();

  const factory JsonApiRelationshipData.one(JsonApiResourceLinkage data) =
      JsonApiRelationshipDataOne;

  const factory JsonApiRelationshipData.many(
    List<JsonApiResourceLinkage> data,
  ) = JsonApiRelationshipDataMany;

  List<JsonApiResourceLinkage> get all => switch (this) {
    JsonApiRelationshipDataOne(:final data) => [data],
    JsonApiRelationshipDataMany(:final data) => data,
  };

  JsonApiResourceLinkage? get firstOrNull => switch (this) {
    JsonApiRelationshipDataOne(:final data) => data,
    JsonApiRelationshipDataMany(:final data) => data.firstOrNull,
  };

  JsonApiResourceLinkage get first => switch (this) {
    JsonApiRelationshipDataOne(:final data) => data,
    JsonApiRelationshipDataMany(:final data) => data.first,
  };
}

class JsonApiRelationshipDataConverter
    implements JsonConverter<JsonApiRelationshipData?, Object?> {
  const JsonApiRelationshipDataConverter();

  @override
  JsonApiRelationshipData? fromJson(Object? json) {
    if (json == null) return null;
    if (json is List) {
      return JsonApiRelationshipData.many(
        json
            .map(
              (e) => JsonApiResourceLinkage.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    }
    return JsonApiRelationshipData.one(
      JsonApiResourceLinkage.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Object? toJson(JsonApiRelationshipData? data) => switch (data) {
    JsonApiRelationshipDataOne(:final data) => data.toJson(),
    JsonApiRelationshipDataMany(:final data) =>
      data.map((e) => e.toJson()).toList(),
    null => null,
  };
}

@freezed
abstract class JsonApiResourceLinkage with _$JsonApiResourceLinkage {
  const JsonApiResourceLinkage._();

  const factory JsonApiResourceLinkage({
    required String id,
    required String type,
  }) = _JsonApiResourceLinkage;

  factory JsonApiResourceLinkage.fromJson(Map<String, dynamic> json) =>
      _$JsonApiResourceLinkageFromJson(json);
}
