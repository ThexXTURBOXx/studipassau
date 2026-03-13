import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/util/json.dart';
import 'package:studipassau/util/jsonapi.dart';

part 'news_item.freezed.dart';
part 'news_item.g.dart';

class NewsWidget extends StatelessWidget {
  const NewsWidget({required this.news, super.key});

  final News news;

  String get title => news.attributes.title;

  String subtitle(BuildContext context) => news.attributes.edited
      ? '${formatDateTime(makeDate)} (${S.of(context).edited}: '
            '${formatDateTime(changeDate)})'
      : formatDateTime(makeDate);

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
    leading: const Icon(Icons.newspaper),
    title: Text(title),
    subtitle: Text(subtitle(context)),
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
}
