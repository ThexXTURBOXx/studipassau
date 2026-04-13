import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studipassau/models/studipassau_event.dart';
import 'package:timetable/timetable.dart';

class StudiPassauEventWidget extends StatelessWidget {
  const StudiPassauEventWidget(
    this.event, {
    super.key,
    this.onTap,
    this.margin = const EdgeInsets.only(right: 1),
    required this.backgroundColorGetter,
  });

  final StudiPassauEvent event;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry margin;

  final Color? Function(String?) backgroundColorGetter;

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
      color: event.getBackgroundColor(backgroundColorGetter),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
          child: DefaultTextStyle(
            style: context.textTheme.bodyMedium!.copyWith(
              fontSize: 12,
              color: event
                  .getBackgroundColor(backgroundColorGetter)
                  .highEmphasisOnColor,
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
    required this.backgroundColorGetter,
  });

  final StudiPassauEvent event;
  final AllDayEventLayoutInfo info;

  final VoidCallback? onTap;
  final BasicAllDayEventWidgetStyle? style;

  final Color? Function(String?) backgroundColorGetter;

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
        color: event.getBackgroundColor(backgroundColorGetter),
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
                color: event
                    .getBackgroundColor(backgroundColorGetter)
                    .highEmphasisOnColor,
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
