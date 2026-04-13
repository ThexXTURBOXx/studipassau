import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/models/course.dart';
import 'package:studipassau/models/course_membership.dart';
import 'package:studipassau/models/jsonapi.dart';

class CoursesRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<List<Course>> getCourses(String userId) async {
    final json = await _studIPProvider.apiGetJson(
      'users/$userId/courses?page[limit]=10000',
    );
    return parseCollection(
      json,
      (item) => CourseAttributes.fromJson(item as Map<String, dynamic>),
    );
  }

  Future<List<CourseMembership>> getCourseMemberships(String userId) async {
    final json = await _studIPProvider.apiGetJson(
      'users/$userId/course-memberships?page[limit]=10000',
    );
    return parseCollection(
      json,
      (item) =>
          CourseMembershipAttributes.fromJson(item as Map<String, dynamic>),
    );
  }

  Future<Course> getCourse(String id) async {
    final json = await _studIPProvider.apiGetJson('courses/$id');
    return parseObject(
      json,
      (item) => CourseAttributes.fromJson(item as Map<String, dynamic>),
    );
  }

  Future<CourseMembership> getCourseMembership(
    String userId,
    String courseId,
  ) async {
    final json = await _studIPProvider.apiGetJson(
      'course-memberships/${courseId}_$userId',
    );
    return parseObject(
      json,
      (item) =>
          CourseMembershipAttributes.fromJson(item as Map<String, dynamic>),
    );
  }
}
