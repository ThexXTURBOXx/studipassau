import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/roomfinder/widgets/buildings.dart';

const routeRoomFinder = '/roomfinder';

class RoomFinderPage extends StatefulWidget {
  const RoomFinderPage({super.key});

  @override
  State<StatefulWidget> createState() => _RoomFinderPagePageState();
}

class _RoomFinderPagePageState extends State<RoomFinderPage>
    with TickerProviderStateMixin {
  MapController controller = MapControllerImpl();

  //print(ModalRoute.of(context)!.settings.arguments);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).roomFinderTitle),
        ),
        drawer: const StudiPassauDrawer(DrawerItem.roomFinder),
        body: FlutterMap(
          mapController: controller,
          options: MapOptions(
            center: LatLng(48.567952, 13.457591),
            zoom: 15.5,
            maxZoom: 18,
            onTap: (pos, point) {
              for (final building in buildings) {
                if (LatLngBounds.fromPoints(building.polygon.points)
                    .contains(point)) {
                  debugPrint(building.name);
                  break;
                }
              }
            },
          ),
          nonRotatedChildren: [
            AttributionWidget.defaultWidget(
              source: 'OpenStreetMap contributors',
              onSourceTapped: null,
            ),
          ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: packageInfo.packageName,
            ),
            PolygonLayer(
              polygonCulling: false,
              polygons: polygons,
            ),
          ],
        ),
      );
}
