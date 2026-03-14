import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/util/json.dart';
import 'package:studipassau/models/jsonapi.dart';

part 'user.freezed.dart';
part 'user.g.dart';

typedef User = JsonApiResource<UserAttributes>;

@freezed
sealed class UserAttributes with _$UserAttributes {
  const UserAttributes._();

  @StringConverter()
  const factory UserAttributes({
    required String username,
    @JsonKey(name: 'formatted-name') required String formattedName,
    @JsonKey(name: 'family-name') required String familyName,
    @JsonKey(name: 'given-name') required String givenName,
    @JsonKey(name: 'name-prefix') required String namePrefix,
    @JsonKey(name: 'name-suffix') required String nameSuffix,
    required String permission,
    required String email,
    String? phone,
    String? homepage,
    String? address,
  }) = _UserAttributes;

  factory UserAttributes.fromJson(Map<String, dynamic> json) =>
      _$UserAttributesFromJson(json);
}
