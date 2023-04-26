import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sprintf/sprintf.dart';
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
        appBar: EasySearchBar<Building>(
          title: Text(S.of(context).roomFinderTitle),
          onSearch: (value) {},
          searchHintText: S.of(context).searchBuildings,
          asyncSuggestions: (searchValue) async => searchBuildings(searchValue),
          suggestionToString: (value) => '${value.name} (${value.abbrev})',
          onSuggestionTap: (value) =>
              controller.move(value.polygon.boundingBox.center, 18),
        ),
        drawer: const StudiPassauDrawer(DrawerItem.roomFinder),
        body: FlutterMap(
          mapController: controller,
          options: MapOptions(
            center: LatLng(48.567369, 13.451903),
            zoom: 15.5,
            maxZoom: 18,
            onTap: (pos, point) {
              for (final building in buildings) {
                if (isPointInPolygon(point, building.polygon)) {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('${building.name} (${building.abbrev})'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatEntry(
                              S.of(context).address,
                              building.address,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: Text(
                              S.of(context).openInMaps,
                            ),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                const Size.fromHeight(35),
                              ),
                            ),
                            onPressed: () async {
                              await MapsLauncher.launchQuery(building.address);
                            },
                          ),
                        ],
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
      detail != null ? '${sprintf(category, [detail])}\n' : '';
}
