import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/util/json.dart';
import 'package:studipassau/util/jsonapi.dart';

part 'news_item.freezed.dart';
part 'news_item.g.dart';

class NewsWidget extends StatelessWidget {
  const NewsWidget({
    required this.news,
    required this.courseTitleGetter,
    super.key,
  });

  final News news;

  final String? Function(String?) courseTitleGetter;

  String get title => news.attributes.title;

  String subtitle(BuildContext context) =>
      (news.isCourseNews
          ? '${context.i18n.course}: ${courseTitleGetter(news.courseId) ?? context.i18n.loading}\n'
          : '') +
      (news.attributes.edited
          ? '${formatDateTime(makeDate)} (${context.i18n.edited}: '
                '${formatDateTime(changeDate)})'
          : formatDateTime(makeDate));

  DateTime get makeDate => news.attributes.makeDate;

  DateTime get changeDate => news.attributes.changeDate;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<News>('news', news))
      ..add(StringProperty('title', title))
      ..add(DiagnosticsProperty<DateTime>('makeDate', makeDate))
      ..add(DiagnosticsProperty<DateTime>('changeDate', changeDate));
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(
      news.isCourseNews ? Icons.menu_book_outlined : Icons.newspaper,
      color: news.attributes.isPublic ? null : context.theme.disabledColor,
    ),
    title: Text(
      title,
      style: TextStyle(
        color: news.attributes.isPublic ? null : context.theme.disabledColor,
      ),
    ),
    subtitle: Text(
      subtitle(context),
      style: TextStyle(
        color: news.attributes.isPublic ? null : context.theme.disabledColor,
      ),
    ),
    onTap: () async {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          insetPadding: const EdgeInsets.all(44),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: HtmlWidget(
                news.attributes.content,
                factoryBuilder: NewsWidgetFactory.new,
              ),
            ),
          ),
        ),
      );
    },
  );
}

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
