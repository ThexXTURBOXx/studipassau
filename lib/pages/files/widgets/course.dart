import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CourseWidget extends StatelessWidget {
  const CourseWidget({required this.course, super.key, this.onTap});

  final Course course;
  final void Function()? onTap;

  String get sortKey => course.title.trim();

  String get title =>
      course.number.isEmpty || course.number == 'null'
          ? course.title.trim()
          : '${course.number.trim()} ${course.title.trim()}';

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
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.import_contacts),
    title: Text(title),
    subtitle: course.subtitle.isNotEmpty ? Text(course.subtitle) : null,
    onTap: onTap,
    onLongPress:
        () async => showDialog<void>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(title),
                content: Text(
                  '${course.subtitle}\n'
                  '${course.description}',
                ),
              ),
        ),
  );
}

class Course extends Equatable {
  const Course({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.description,
  });

  factory Course.fromJson(json) => Course(
    id: json['id'].toString(),
    number: json['attributes']['course-number'].toString(),
    title: json['attributes']['title'].toString(),
    subtitle: (json['attributes']['subtitle'] ?? '').toString(),
    type: json['attributes']['course-type'].toString(),
    description: json['attributes']['description'].toString(),
  );

  final String id;
  final String number;
  final String title;
  final String subtitle;
  final String type;
  final String description;

  @override
  List<Object> get props => [id, number, title, subtitle, type, description];
}
