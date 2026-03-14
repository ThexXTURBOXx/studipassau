import 'package:flutter/foundation.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/util/json.dart';

part 'news.freezed.dart';
part 'news.g.dart';

class NewsWidgetFactory extends WidgetFactory with UrlLauncherFactory {}

typedef News = JsonApiResource<NewsAttributes>;

@freezed
sealed class NewsAttributes with _$NewsAttributes {
  const NewsAttributes._();

  @StringConverter()
  @DateTimeInLocalZoneConverter()
  const factory NewsAttributes({
    required String title,
    required String content,
    @JsonKey(name: 'mkdate') required DateTime makeDate,
    @JsonKey(name: 'chdate') required DateTime changeDate,
    @JsonKey(name: 'publication-start') required DateTime publicationStart,
    @JsonKey(name: 'publication-end') required DateTime publicationEnd,
    @JsonKey(name: 'comments-allowed') required bool commentsAllowed,
  }) = _NewsAttributes;

  factory NewsAttributes.fromJson(Map<String, dynamic> json) =>
      _$NewsAttributesFromJson(json);

  bool get edited => makeDate != changeDate;

  bool get isPublic => isPublicAt(DateTime.now().copyWith(isUtc: true));

  bool isPublicAt(DateTime at) => at.isBefore(publicationEnd);
}

extension CourseNews on News {
  bool get isCourseNews =>
      relationship('ranges').firstOrNull?.type == 'courses';

  String? get courseId => relationship('ranges').firstOrNull?.id;
}
