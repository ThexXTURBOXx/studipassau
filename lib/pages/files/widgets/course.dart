import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studipassau/models/course.dart';

class CourseWidget extends StatelessWidget {
  const CourseWidget({required this.course, super.key, this.onTap});

  final Course course;
  final void Function()? onTap;

  String get sortKey => course.attributes.title.trim();

  String get title => course.attributes.formattedTitle;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Course>('course', course))
      ..add(ObjectFlagProperty<void Function()?>.has('onTap', onTap))
      ..add(StringProperty('sortKey', sortKey))
      ..add(StringProperty('title', title));
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = course.attributes.subtitle;
    final description = course.attributes.description;

    return ListTile(
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(title),
      subtitle: subtitle?.isEmpty ?? true ? null : Text(subtitle!),
      onTap: onTap,
      onLongPress: () async => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(
            '${subtitle?.isEmpty ?? true ? "" : subtitle}\n'
            '${description?.isEmpty ?? true ? "" : description}',
          ),
        ),
      ),
    );
  }
}
