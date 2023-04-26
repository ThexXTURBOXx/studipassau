import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// From https://github.com/fleaflet/flutter_map/issues/385#issuecomment-1268885872
/// But with additional improvements...
bool isPointInPolygon(LatLng point, Polygon polygon) {
  // Quick check using simple bounding box
  if (!polygon.boundingBox.contains(point)) {
    return false;
  }

  final x = point.latitude;
  final y = point.longitude;
  final nPoints = polygon.points.length;
  var inside = false;

  for (var i = 0, j = nPoints - 1; i < nPoints; j = i++) {
    final xi = polygon.points[i].latitude;
    final yi = polygon.points[i].longitude;
    final xj = polygon.points[j].latitude;
    final yj = polygon.points[j].longitude;

    final intersect =
        ((yi > y) != (yj > y)) && (x < ((xj - xi) * (y - yi)) / (yj - yi) + xi);

    inside = intersect ? !inside : inside;
  }

  return inside;
}
