import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';

class StudiPassauEvent extends Event implements Equatable {
  final String id;
  final String title;
  final String course;
  final String description;
  final String categories;
  final String room;
  final bool canceled;
  final Color backgroundColor;

  const StudiPassauEvent({
    required this.id,
    required this.title,
    required this.course,
    required this.description,
    required this.categories,
    required this.room,
    required this.canceled,
    required this.backgroundColor,
    required DateTime start,
    required DateTime end,
  }) : super(start: start, end: end);

  StudiPassauEvent copyWith({
    String? id,
    String? title,
    String? course,
    String? description,
    String? categories,
    String? room,
    bool? canceled,
    Color? backgroundColor,
    bool? showOnTop,
    DateTime? start,
    DateTime? end,
  }) =>
      StudiPassauEvent(
        id: id ?? this.id,
        title: title ?? this.title,
        course: course ?? this.course,
        description: description ?? this.description,
        categories: categories ?? this.categories,
        room: room ?? this.room,
        canceled: canceled ?? this.canceled,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        start: start ?? this.start,
        end: end ?? this.end,
      );

  @override
  List<Object> get props => [
        id,
        title,
        course,
        description,
        categories,
        room,
        canceled,
        backgroundColor,
        start,
        end,
      ];

  @override
  bool get stringify => true;
}

class StudiPassauEventWidget extends StatelessWidget {
  const StudiPassauEventWidget(
    this.event, {
    Key? key,
    this.onTap,
    this.margin = const EdgeInsets.only(right: 1),
  }) : super(key: key);

  final StudiPassauEvent event;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) => Padding(
        padding: margin,
        child: Material(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: context.theme.scaffoldBackgroundColor,
              width: 0.75,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.hardEdge,
          color: event.backgroundColor,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
              child: DefaultTextStyle(
                style: context.textTheme.bodyText2!.copyWith(
                  fontSize: 12,
                  color: event.backgroundColor.highEmphasisOnColor,
                ),
                child: Text(
                  '${event.title}${event.course}${event.description}'
                  '${event.categories}${event.room}${event.canceled}',
                ),
              ),
            ),
          ),
        ),
      );
}

class StudiPassauAllDayEventWidget extends StatelessWidget {
  const StudiPassauAllDayEventWidget(
    this.event, {
    Key? key,
    required this.info,
    this.onTap,
    this.style,
  }) : super(key: key);

  final StudiPassauEvent event;
  final AllDayEventLayoutInfo info;

  final VoidCallback? onTap;
  final BasicAllDayEventWidgetStyle? style;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(2),
        child: CustomPaint(
          painter: AllDayEventBackgroundPainter(
            info: info,
            color: event.backgroundColor,
            radii: AllDayEventBorderRadii(
              cornerRadius: BorderRadius.circular(4),
              leftTipRadius: 4,
              rightTipRadius: 4,
            ),
          ),
          child: Material(
            shape: AllDayEventBorder(
              info: info,
              side: BorderSide.none,
              radii: AllDayEventBorderRadii(
                cornerRadius: BorderRadius.circular(4),
                leftTipRadius: 4,
                rightTipRadius: 4,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 0, 2),
                child: Text(
                  event.title,
                  style: context.theme.textTheme.bodyText2!.copyWith(
                    fontSize: 14,
                    color: event.backgroundColor.highEmphasisOnColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
      );
}
