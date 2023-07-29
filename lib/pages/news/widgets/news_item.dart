import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';

class NewsWidget extends StatelessWidget {
  final News news;

  const NewsWidget({
    super.key,
    required this.news,
  });

  String get title => news.topic;

  String subtitle(BuildContext context) => news.edited
      ? '${formatDateTime(makeDate)} (${S.of(context).edited}: '
          '${formatDateTime(changeDate)})'
      : formatDateTime(makeDate);

  DateTime get makeDate =>
      DateTime.fromMillisecondsSinceEpoch(news.makeDate * 1000, isUtc: true);

  DateTime get changeDate =>
      DateTime.fromMillisecondsSinceEpoch(news.changeDate * 1000, isUtc: true);

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.newspaper),
        title: Text(title),
        subtitle: Text(subtitle(context)),
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: HtmlWidget(
                  news.bodyHtml,
                  factoryBuilder: NewsWidgetFactory.new,
                ),
              ),
            ),
          );
        },
      );
}

class NewsWidgetFactory extends WidgetFactory with UrlLauncherFactory {}

class News extends Equatable {
  final String newsId;
  final String topic;
  final String body;
  final int date;
  final String userId;
  final int expire;
  final int allowComments;
  final int changeDate;
  final String changeDateUid;
  final int makeDate;
  final String bodyHtml;

  const News({
    required this.newsId,
    required this.topic,
    required this.body,
    required this.date,
    required this.userId,
    required this.expire,
    required this.allowComments,
    required this.changeDate,
    required this.changeDateUid,
    required this.makeDate,
    required this.bodyHtml,
  });

  factory News.fromJson(json) => News(
        newsId: json['news_id'].toString(),
        topic: json['topic'].toString(),
        body: json['body'].toString(),
        date: int.parse(json['date'].toString()),
        userId: json['user_id'].toString(),
        expire: int.parse(json['expire'].toString()),
        allowComments: int.parse(json['allow_comments'].toString()),
        changeDate: int.parse(json['chdate'].toString()),
        changeDateUid: json['chdate_uid'].toString(),
        makeDate: int.parse(json['mkdate'].toString()),
        bodyHtml: json['body_html'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'news_id': newsId,
        'topic': topic,
        'body': body,
        'date': date,
        'user_id': userId,
        'expire': expire,
        'allow_comments': allowComments,
        'chdate': changeDate,
        'chdate_uid': changeDateUid,
        'mkdate': makeDate,
        'body_html': bodyHtml,
      };

  bool get edited => makeDate != changeDate;

  @override
  List<Object> get props => [
        newsId,
        topic,
        body,
        date,
        userId,
        expire,
        allowComments,
        changeDate,
        changeDateUid,
        makeDate,
        bodyHtml,
      ];
}
