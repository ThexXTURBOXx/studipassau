import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/roomfinder/widgets/buildings.dart';
import 'package:studipassau/util/geo.dart';
import 'package:studipassau/util/navigation.dart';

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
                if (isPointInPolygon(point, building.polygon)) {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('${building.name} (${building.abbrev})'),
                      content: Text(
                        '${formatEntry('Address', building.address)}',
                      ),
                    ),
                  );
                  break;
                }
              }
            },
          ),
          nonRotatedChildren: [
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl('https://openstreetmap.org/copyright'),
                ),
              ],
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
            MarkerLayer(
              markers: markers,
            )
          ],
        ),
      );

  String formatEntry(String category, String? detail) =>
      detail != null ? '$category: $detail\n' : '';
}
