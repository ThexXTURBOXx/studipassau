import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CourseWidget extends StatelessWidget {
  final Course course;
  final void Function()? onTap;

  const CourseWidget({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = course.number.isEmpty || course.number == 'null'
        ? course.title.trim()
        : '${course.number.trim()} ${course.title.trim()}';
    return ListTile(
      leading: const Icon(Icons.folder_open),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class Course extends Equatable {
  final String id;
  final String number;
  final String title;
  final String subtitle;
  final String type;
  final String description;
  final Map<String, String> modules;

  const Course({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.description,
    required this.modules,
  });

  factory Course.fromJson(json) => Course(
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
