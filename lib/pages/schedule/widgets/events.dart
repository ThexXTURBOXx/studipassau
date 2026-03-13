import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/util/json.dart';
import 'package:timetable/timetable.dart';

part 'events.freezed.dart';
part 'events.g.dart';

@freezed
sealed class StudiPassauEvent with _$StudiPassauEvent implements Event {
  const StudiPassauEvent._();

  @StringConverter()
  const factory StudiPassauEvent({
    required String id,
    required String title,
    required String course,
    required String? description,
    required List<String> categories,
    required String room,
    @BoolConverter() required bool canceled,
    @ColorConverter() required Color backgroundColor,
    @DateTimeInSaveConverter() required DateTime start,
    @DateTimeInSaveConverter() required DateTime end,
  }) = _StudiPassauEvent;

  factory StudiPassauEvent.fromJson(Map<String, dynamic> json) =>
      _$StudiPassauEventFromJson(json);

  @override
  bool get isAllDay => end.difference(start).inDays >= 1;
}

class StudiPassauEventWidget extends StatelessWidget {
  const StudiPassauEventWidget(
    this.event, {
    super.key,
    this.onTap,
    this.margin = const EdgeInsets.only(right: 1),
  });

  final StudiPassauEvent event;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry margin;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<StudiPassauEvent>('event', event))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin));
  }

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
            style: context.textTheme.bodyMedium!.copyWith(
              fontSize: 12,
              color: event.backgroundColor.highEmphasisOnColor,
            ),
            child: Column(
              children: [
                Text(event.room),
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
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
    required this.info,
    super.key,
    this.onTap,
    this.style,
  });

  final StudiPassauEvent event;
  final AllDayEventLayoutInfo info;

  final VoidCallback? onTap;
  final BasicAllDayEventWidgetStyle? style;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<StudiPassauEvent>('event', event))
      ..add(DiagnosticsProperty<AllDayEventLayoutInfo>('info', info))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(DiagnosticsProperty<BasicAllDayEventWidgetStyle?>('style', style));
  }

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
              style: context.theme.textTheme.bodyMedium!.copyWith(
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
