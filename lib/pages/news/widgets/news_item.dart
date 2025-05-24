import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';

class NewsWidget extends StatelessWidget {
  const NewsWidget({required this.news, super.key});

  final News news;

  String get title => news.title;

  String subtitle(BuildContext context) => news.edited
      ? '${formatDateTime(makeDate)} (${S.of(context).edited}: '
            '${formatDateTime(changeDate)})'
      : formatDateTime(makeDate);

  DateTime get makeDate => news.makeDate;

  DateTime get changeDate => news.changeDate;

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
                news.content,
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

class News extends Equatable {
  const News({
    required this.id,
    required this.title,
    required this.content,
    required this.makeDate,
    required this.changeDate,
  });

  factory News.fromJson(json) => News(
    id: json['id'].toString(),
    title: json['attributes']['title'].toString(),
    content: json['attributes']['content'].toString(),
    makeDate: parseInLocalZone(json['attributes']['mkdate']),
    changeDate: parseInLocalZone(json['attributes']['chdate']),
  );

  final String id;
  final String title;
  final String content;
  final DateTime makeDate;
  final DateTime changeDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'attributes': {
      'title': title,
      'content': content,
      'mkdate': makeDate.toString(),
      'chdate': changeDate.toString(),
    },
  };

  bool get edited => makeDate != changeDate;

  @override
  List<Object> get props => [id, title, content, makeDate, changeDate];
}
