import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/constants.dart';

class StringConverter implements JsonConverter<String, dynamic> {
  const StringConverter();

  @override
  String fromJson(dynamic json) {
    if (json == null) return '';
    return json.toString();
  }

  @override
  dynamic toJson(String object) => object;
}

class BoolConverter implements JsonConverter<bool, dynamic> {
  const BoolConverter();

  @override
  bool fromJson(dynamic json) {
    if (json is bool) return json;
    if (json is num) return json == 1;
    if (json is String) {
      final lower = json.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  @override
  dynamic toJson(bool object) => object;
}

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.intValue;
}

class DateTimeInLocalZoneConverter implements JsonConverter<DateTime, String> {
  const DateTimeInLocalZoneConverter();

  @override
  DateTime fromJson(String json) => parseInLocalZone(json);

  @override
  String toJson(DateTime object) => object.toString();
}

class DateTimeInSaveConverter implements JsonConverter<DateTime, String> {
  const DateTimeInSaveConverter();

  @override
  DateTime fromJson(String json) => dateTimeSaveFormat.parse(json, true);

  @override
  String toJson(DateTime object) => dateTimeSaveFormat.format(object);
}

class HHMMIntConverter implements JsonConverter<int, String> {
  const HHMMIntConverter();

  @override
  int fromJson(String object) => int.parse(object.replaceAll(':', ''));

  @override
  String toJson(int json) => '${json ~/ 100}:${json % 100}';
}
