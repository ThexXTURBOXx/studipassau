import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CourseWidget extends StatelessWidget {
  const CourseWidget({required this.course, super.key, this.onTap});

  final Course course;
  final void Function()? onTap;

  String get sortKey => course.title.trim();

  String get title => course.number.isEmpty || course.number == 'null'
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
        leading: const Icon(Icons.folder_open),
        title: Text(title),
        subtitle: course.subtitle.isNotEmpty ? Text(course.subtitle) : null,
        onTap: onTap,
        onLongPress: () async => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
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
    required this.modules,
  });

  factory Course.fromJson(dynamic json) => Course(
        id: json['course_id'].toString(),
        number: json['number'].toString(),
        title: json['title'].toString(),
        subtitle: json['subtitle'].toString(),
        type: json['type'].toString(),
        description: json['description'].toString(),
        modules: json['modules'] is Map<String, dynamic>
            ? (json['modules'] as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, value.toString()))
            : <String, String>{},
      );

  final String id;
  final String number;
  final String title;
  final String subtitle;
  final String type;
  final String description;
  final Map<String, String> modules;

  @override
  List<Object> get props => [
        id,
        number,
        title,
        subtitle,
        type,
        description,
        modules,
      ];
}
