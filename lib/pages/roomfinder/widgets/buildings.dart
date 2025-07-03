import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:supercharged/supercharged.dart';

/*
Useful for constructing Polygons:
http://www.birdtheme.org/useful/v3tool.html

Links/Sources:
Campusplan Passau (Die Universität auf einen Blick, physische Karte)
https://www.uni-passau.de/fileadmin/dokumente/beschaeftigte/Formulare/Liegenschaften/Verzeichnis_Universitaetsgebaeude.pdf
https://www.uni-passau.de/fileadmin/dokumente/Lageplan/Stadtplan_Universitaet.pdf
https://www.uni-passau.de/kontakt/anreise-und-lageplaene
https://www.uni-passau.de/fileadmin/dokumente/beschaeftigte/Formulare/Arbeitssicherheit/Karlsbader_Strasse_Objektplan_Layout1__1_.pdf
https://www.centouris.de/
https://stwno.de/de/kultur/kultur-in-passau/kultursalon
https://www.uni-passau.de/fileadmin/dokumente/beschaeftigte/Formulare/Liegenschaften/Gebaeudeoeffnungszeiten.pdf
https://ampel.zim.uni-passau.de/v2
*/

final buildings = [
  Building(
    name: 'Nikolakloster',
    abbrev: 'NK',
    address: 'Innstraße 40, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.570434, 13.455940),
      const LatLng(48.570559, 13.456262),
      const LatLng(48.570459, 13.456354),
      const LatLng(48.570502, 13.456450),
      const LatLng(48.570445, 13.456498),
      const LatLng(48.570402, 13.456407),
      const LatLng(48.569991, 13.456810),
      const LatLng(48.569870, 13.456268),
      const LatLng(48.569909, 13.456246),
      const LatLng(48.569909, 13.455973),
    ],
    holePoints: [
      [
        const LatLng(48.570405, 13.456193),
        const LatLng(48.570274, 13.456322),
        const LatLng(48.570228, 13.456134),
        const LatLng(48.570377, 13.456129),
      ],
    ],
    markerPos: const LatLng(48.570117, 13.456325),
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Innsteg-Aula',
    abbrev: 'ISA',
    address: 'Innstraße 23, 94032 Passau',
    points: [
      const LatLng(48.570005, 13.457416),
      const LatLng(48.570303, 13.458194),
      const LatLng(48.570175, 13.458301),
      const LatLng(48.569884, 13.457523),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Philosophicum',
    abbrev: 'PHIL',
    address: 'Innstraße 25, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.569627, 13.455806),
      const LatLng(48.569723, 13.456305),
      const LatLng(48.569382, 13.456316),
      const LatLng(48.569173, 13.455919),
      const LatLng(48.569293, 13.455871),
      const LatLng(48.569322, 13.455919),
      const LatLng(48.569464, 13.455747),
      const LatLng(48.569510, 13.455801),
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Wirtschaftswissenschaften',
    abbrev: 'WIWI',
    address: 'Innstraße 27, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.569230, 13.454933),
      const LatLng(48.569152, 13.455030),
      const LatLng(48.569084, 13.454901),
      const LatLng(48.569020, 13.454971),
      const LatLng(48.568797, 13.454584),
      const LatLng(48.568750, 13.454649),
      const LatLng(48.568772, 13.454692),
      const LatLng(48.568683, 13.454804),
      const LatLng(48.568385, 13.454279),
      const LatLng(48.568420, 13.454225),
      const LatLng(48.568337, 13.454072),
      const LatLng(48.568394, 13.453991),
      const LatLng(48.568575, 13.454313),
      const LatLng(48.568649, 13.454217),
      const LatLng(48.568589, 13.454104),
      const LatLng(48.568734, 13.453927),
      const LatLng(48.568986, 13.454388),
      const LatLng(48.568949, 13.454426),
      const LatLng(48.568963, 13.454458),
      const LatLng(48.568981, 13.454442),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Zentralbibliothek',
    abbrev: 'ZB',
    address: 'Innstraße 29, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.568509, 13.453440),
      const LatLng(48.568363, 13.453671),
      const LatLng(48.568321, 13.453612),
      const LatLng(48.568267, 13.453687),
      const LatLng(48.568200, 13.453585),
      const LatLng(48.568271, 13.453472),
      const LatLng(48.568150, 13.453295),
      const LatLng(48.568076, 13.453419),
      const LatLng(48.567994, 13.453301),
      const LatLng(48.568019, 13.453258),
      const LatLng(48.567664, 13.452716),
      const LatLng(48.567699, 13.452662),
      const LatLng(48.567682, 13.452635),
      const LatLng(48.567728, 13.452560),
      const LatLng(48.567987, 13.452930),
      const LatLng(48.568093, 13.452769),
      const LatLng(48.568218, 13.452952),
      const LatLng(48.568203, 13.452973),
    ],
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Mensa',
    abbrev: 'M',
    address: 'Innstraße 29, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.567848, 13.453349),
      const LatLng(48.567795, 13.453424),
      const LatLng(48.567731, 13.453327),
      const LatLng(48.567657, 13.453445),
      const LatLng(48.567554, 13.453290),
      const LatLng(48.567529, 13.453322),
      const LatLng(48.567252, 13.452893),
      const LatLng(48.567358, 13.452742),
      const LatLng(48.567366, 13.452753),
      const LatLng(48.567500, 13.452555),
      const LatLng(48.567579, 13.452673),
      const LatLng(48.567543, 13.452732),
      const LatLng(48.567650, 13.452898),
      const LatLng(48.567596, 13.452973),
    ],
    markerPos: const LatLng(48.567470, 13.452929),
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Zentrum für Medien und Kommunikation',
    abbrev: 'ZMK',
    address: 'Innstraße 33a, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.567120, 13.452162),
      const LatLng(48.566786, 13.452639),
      const LatLng(48.566705, 13.452516),
      const LatLng(48.567038, 13.452027),
    ],
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Audimax',
    abbrev: 'AM',
    address: 'Innstraße 31, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.567871, 13.452242),
      const LatLng(48.567796, 13.452371),
      const LatLng(48.567747, 13.452301),
      const LatLng(48.567661, 13.452419),
      const LatLng(48.567473, 13.452156),
      const LatLng(48.567502, 13.452097),
      const LatLng(48.567413, 13.451765),
      const LatLng(48.567537, 13.451797),
      const LatLng(48.567583, 13.451545),
      const LatLng(48.567715, 13.451545),
      const LatLng(48.567711, 13.451523),
      const LatLng(48.567754, 13.451491),
      const LatLng(48.567771, 13.451555),
      const LatLng(48.567732, 13.451582),
      const LatLng(48.567818, 13.452076),
      const LatLng(48.567846, 13.452076),
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Fakultät für Informatik und Mathematik',
    abbrev: 'FIM',
    address: 'Innstraße 33, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.567185, 13.451642),
      const LatLng(48.567096, 13.451797),
      const LatLng(48.567128, 13.451840),
      const LatLng(48.567093, 13.451888),
      const LatLng(48.567061, 13.451845),
      const LatLng(48.566855, 13.452151),
      const LatLng(48.566812, 13.451931),
      const LatLng(48.566883, 13.451829),
      const LatLng(48.566727, 13.451577),
      const LatLng(48.566571, 13.451642),
      const LatLng(48.566571, 13.451685),
      const LatLng(48.566305, 13.451792),
      const LatLng(48.566283, 13.451760),
      const LatLng(48.566230, 13.451781),
      const LatLng(48.566131, 13.451609),
      const LatLng(48.566770, 13.451384),
      const LatLng(48.566805, 13.451330),
      const LatLng(48.566936, 13.451245),
    ],
    markerPos: const LatLng(48.566912, 13.451594),
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Zentrum für Informationstechnologie und Medienmanagement',
    abbrev: 'ZIM',
    address: 'Innstraße 33, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.566805, 13.451330),
      const LatLng(48.566936, 13.451245),
      const LatLng(48.566883, 13.450950),
      const LatLng(48.566748, 13.450976),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Kunsterziehung',
    abbrev: 'KE',
    address: 'Innstraße 35, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.567555, 13.450938),
      const LatLng(48.567633, 13.451239),
      const LatLng(48.567452, 13.451352),
      const LatLng(48.567427, 13.451250),
      const LatLng(48.567519, 13.451191),
      const LatLng(48.567470, 13.450992),
    ],
    markerPos: const LatLng(48.567573, 13.451177),
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Juridicum',
    abbrev: 'JUR',
    address: 'Innstraße 39, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.567237, 13.450332),
      const LatLng(48.566953, 13.450723),
      const LatLng(48.566850, 13.450557),
      const LatLng(48.566843, 13.450568),
      const LatLng(48.566715, 13.450353),
      const LatLng(48.566900, 13.450085),
      const LatLng(48.566921, 13.450117),
      const LatLng(48.566960, 13.450064),
      const LatLng(48.566760, 13.449718),
      const LatLng(48.566852, 13.449578),
      const LatLng(48.567175, 13.450120),
      const LatLng(48.567143, 13.450163),
    ],
    markerPos: const LatLng(48.567039, 13.450238),
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Verwaltung',
    abbrev: 'VW',
    address: 'Innstraße 41, 94032 Passau',
    points: [
      const LatLng(48.566760, 13.449718),
      const LatLng(48.566234, 13.449686),
      const LatLng(48.566238, 13.449610),
      const LatLng(48.566203, 13.449605),
      const LatLng(48.566206, 13.449568),
      const LatLng(48.566224, 13.449546),
      const LatLng(48.566213, 13.449530),
      const LatLng(48.566213, 13.449514),
      const LatLng(48.566873, 13.449551),
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'IT-Zentrum/International House',
    abbrev: 'ITZ/IH',
    address: 'Innstraße 43, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.566092, 13.450673),
      const LatLng(48.565907, 13.450823),
      const LatLng(48.565882, 13.450780),
      const LatLng(48.565751, 13.450893),
      const LatLng(48.565474, 13.450533),
      const LatLng(48.565559, 13.450383),
      const LatLng(48.565783, 13.450657),
      const LatLng(48.565801, 13.450646),
      const LatLng(48.565367, 13.450013),
      const LatLng(48.565662, 13.449342),
      const LatLng(48.565680, 13.449358),
      const LatLng(48.565705, 13.449315),
      const LatLng(48.565726, 13.449332),
      const LatLng(48.565691, 13.449407),
      const LatLng(48.565698, 13.449433),
      const LatLng(48.565712, 13.449428),
      const LatLng(48.565737, 13.449358),
      const LatLng(48.565801, 13.449423),
      const LatLng(48.565588, 13.449916),
      const LatLng(48.566010, 13.450657),
      const LatLng(48.566067, 13.450614),
    ],
    markerPos: const LatLng(48.565659, 13.450200),
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Sportzentrum',
    abbrev: 'SP',
    address: 'Innstraße 45, 94032 Passau',
    points: [
      const LatLng(48.566781, 13.449131),
      const LatLng(48.566714, 13.449233),
      const LatLng(48.566625, 13.449104),
      const LatLng(48.566621, 13.449077),
      const LatLng(48.566596, 13.449072),
      const LatLng(48.566593, 13.449200),
      const LatLng(48.566348, 13.449184),
      const LatLng(48.566298, 13.449249),
      const LatLng(48.565986, 13.448798),
      const LatLng(48.566135, 13.448557),
      const LatLng(48.565826, 13.448101),
      const LatLng(48.565883, 13.448020),
      const LatLng(48.565865, 13.447988),
      const LatLng(48.565936, 13.447870),
    ],
    markerPos: const LatLng(48.566309, 13.448831),
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Rudolf-Guby-Straße 3',
    abbrev: 'RG3',
    address: 'Rudolf-Guby-Straße 3, 94032 Passau',
    points: [
      const LatLng(48.567514, 13.448448),
      const LatLng(48.567397, 13.448642),
      const LatLng(48.567372, 13.448609),
      const LatLng(48.567357, 13.448631),
      const LatLng(48.567141, 13.448325),
      const LatLng(48.567155, 13.448304),
      const LatLng(48.567123, 13.448255),
      const LatLng(48.567244, 13.448062),
    ],
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Krabbelstube',
    abbrev: 'KS',
    address: 'Innstraße 47, 94032 Passau',
    points: [
      const LatLng(48.565395, 13.447319),
      const LatLng(48.565299, 13.447351),
      const LatLng(48.565129, 13.447163),
      const LatLng(48.565015, 13.447346),
      const LatLng(48.564990, 13.447324),
      const LatLng(48.565015, 13.447249),
      const LatLng(48.564994, 13.447217),
      const LatLng(48.565129, 13.446986),
    ],
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Innstraße 71',
    abbrev: 'IS71',
    address: 'Innstraße 71, 94036 Passau',
    points: [
      const LatLng(48.562347, 13.444038),
      const LatLng(48.562127, 13.444344),
      const LatLng(48.562088, 13.444280),
      const LatLng(48.562049, 13.444328),
      const LatLng(48.562070, 13.444360),
      const LatLng(48.561978, 13.444489),
      const LatLng(48.561836, 13.444269),
      const LatLng(48.561932, 13.444135),
      const LatLng(48.562006, 13.444263),
      const LatLng(48.562045, 13.444210),
      const LatLng(48.562031, 13.444188),
      const LatLng(48.562255, 13.443883),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Leopoldstraße 4',
    abbrev: 'LS',
    address: 'Leopoldstraße 4, 94032 Passau',
    points: [
      const LatLng(48.572601, 13.450795),
      const LatLng(48.572598, 13.451175),
      const LatLng(48.572512, 13.451170),
      const LatLng(48.572516, 13.450789),
    ],
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Dr.-Hans-Kapfinger-Straße 14',
    abbrev: 'HK14',
    address: 'Dr.-Hans-Kapfinger-Straße 14, 94032 Passau',
    points: [
      const LatLng(48.572603, 13.454767),
      const LatLng(48.572585, 13.454869),
      const LatLng(48.572401, 13.454805),
      const LatLng(48.572418, 13.454703),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Dr.-Hans-Kapfinger-Straße 14b',
    abbrev: 'HK14b',
    address: 'Dr.-Hans-Kapfinger-Straße 14b, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.572820, 13.454531),
      const LatLng(48.572738, 13.455062),
      const LatLng(48.572639, 13.455025),
      const LatLng(48.572692, 13.454660),
      const LatLng(48.572536, 13.454595),
      const LatLng(48.572557, 13.454440),
    ],
    markerPos: const LatLng(48.572731, 13.454757),
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Dr.-Hans-Kapfinger-Straße 14c',
    abbrev: 'HK14c',
    address: 'Dr.-Hans-Kapfinger-Straße 14c, 94032 Passau',
    points: [
      const LatLng(48.572858, 13.454248),
      const LatLng(48.572830, 13.454409),
      const LatLng(48.572432, 13.454270),
      const LatLng(48.572454, 13.454118),
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Dr.-Hans-Kapfinger-Straße 14d',
    abbrev: 'HK14d',
    address: 'Dr.-Hans-Kapfinger-Straße 14d, 94032 Passau',
    points: [
      const LatLng(48.572454, 13.454118),
      const LatLng(48.572408, 13.454392),
      const LatLng(48.572248, 13.454333),
      const LatLng(48.572291, 13.454064),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Dr.-Hans-Kapfinger-Straße 12',
    abbrev: 'HK12',
    address: 'Dr.-Hans-Kapfinger-Straße 12, 94032 Passau',
    points: [
      const LatLng(48.572703, 13.455173),
      const LatLng(48.572465, 13.455522),
      const LatLng(48.572380, 13.455490),
      const LatLng(48.572444, 13.455066),
    ],
    holePoints: [
      [
        const LatLng(48.572576, 13.455229),
        const LatLng(48.572473, 13.455374),
        const LatLng(48.572495, 13.455208),
      ],
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Nikolastraße 12',
    abbrev: 'N12',
    address: 'Nikolastraße 12, 94032 Passau',
    points: [
      const LatLng(48.572256, 13.459827),
      const LatLng(48.572161, 13.460036),
      const LatLng(48.571877, 13.459752),
      const LatLng(48.571983, 13.459548),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Institutsgebäude',
    abbrev: 'IG',
    address: 'Gottfried-Schäffer-Straße 20, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.572519, 13.461292),
      const LatLng(48.572391, 13.461475),
      const LatLng(48.572135, 13.461110),
      const LatLng(48.572174, 13.461035),
      const LatLng(48.572231, 13.461121),
      const LatLng(48.572267, 13.461105),
      const LatLng(48.572380, 13.461271),
      const LatLng(48.572448, 13.461191),
    ],
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Department für Katholische Theologie',
    abbrev: 'KT',
    address: 'Michaeligasse 13, 94032 Passau',
    points: [
      const LatLng(48.574101, 13.470351),
      const LatLng(48.574130, 13.471060),
      const LatLng(48.573935, 13.471081),
      const LatLng(48.573935, 13.470899),
      const LatLng(48.574020, 13.470893),
      const LatLng(48.574006, 13.470507),
      const LatLng(48.573942, 13.470507),
      const LatLng(48.573935, 13.470351),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Dr.-Hans-Kapfinger-Straße 16',
    abbrev: 'HK16',
    address: 'Dr.-Hans-Kapfinger-Straße 16, 94032 Passau',
    points: [
      const LatLng(48.572408, 13.454477),
      const LatLng(48.572344, 13.454890),
      const LatLng(48.572181, 13.454831),
      const LatLng(48.572234, 13.454424),
    ],
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Betriebstechnik',
    abbrev: 'BT',
    address: 'Innstraße 37, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.567361, 13.450440),
      const LatLng(48.567482, 13.450746),
      const LatLng(48.567418, 13.450815),
      const LatLng(48.567340, 13.450617),
      const LatLng(48.567265, 13.450740),
      const LatLng(48.567215, 13.450660),
    ],
    markerPos: const LatLng(48.567370, 13.450576),
    color: Colors.black.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Bahnhofstraße 10',
    // TODO(Nico): BH10? According to https://www.uni-passau.de/fileadmin/dokumente/Lageplan/Stadtplan_Universitaet.pdf
    abbrev: 'BA10',
    address: 'Bahnhofstraße 10, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.574436, 13.455271),
      const LatLng(48.574425, 13.455448),
      const LatLng(48.574298, 13.455416),
      const LatLng(48.574315, 13.455244),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Dr.-Hans-Kapfinger-Straße 28',
    abbrev: 'HK28',
    address: 'Dr.-Hans-Kapfinger-Straße 28, 94032 Passau',
    points: [
      const LatLng(48.571982, 13.454272),
      const LatLng(48.571879, 13.454883),
      const LatLng(48.571840, 13.454878),
      const LatLng(48.571822, 13.454991),
      const LatLng(48.571776, 13.455120),
      const LatLng(48.571755, 13.455093),
      const LatLng(48.571748, 13.454621),
      const LatLng(48.571794, 13.454229),
      const LatLng(48.571893, 13.454267),
    ],
    color: Colors.red.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Dr.-Hans-Kapfinger-Straße 30',
    abbrev: 'HK30',
    address: 'Dr.-Hans-Kapfinger-Straße 30, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.571893, 13.454267),
      const LatLng(48.571897, 13.454127),
      const LatLng(48.571946, 13.454132),
      const LatLng(48.571943, 13.454159),
      const LatLng(48.572032, 13.454175),
      const LatLng(48.572042, 13.454031),
      const LatLng(48.571957, 13.454020),
      const LatLng(48.571964, 13.453934),
      const LatLng(48.571922, 13.453923),
      const LatLng(48.571925, 13.453875),
      const LatLng(48.571975, 13.453886),
      const LatLng(48.572007, 13.453473),
      const LatLng(48.571953, 13.453467),
      const LatLng(48.571961, 13.453322),
      const LatLng(48.572010, 13.453328),
      const LatLng(48.572017, 13.453156),
      const LatLng(48.571854, 13.453140),
      const LatLng(48.571847, 13.453263),
      const LatLng(48.571836, 13.453263),
      const LatLng(48.571797, 13.453864),
      const LatLng(48.571783, 13.453864),
      const LatLng(48.571758, 13.454229),
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Ruder- und Kanuanlage Sportzentrum',
    abbrev: 'RUKA',
    address: 'Innstraße 125, 94036 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.548466, 13.436836),
      const LatLng(48.548491, 13.436927),
      const LatLng(48.548211, 13.437104),
      const LatLng(48.548182, 13.437013),
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Gebäude Karlsbader Straße',
    abbrev: 'KB',
    address: 'Karlsbader Straße 11a, 94036 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.559856, 13.420208),
      const LatLng(48.560097, 13.420916),
      const LatLng(48.559863, 13.421098),
      const LatLng(48.559618, 13.420390),
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Franz Stockbauer Weg 3',
    abbrev: 'FSW3',
    address: 'Franz Stockbauer Weg 3, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.571031, 13.455681),
      const LatLng(48.570977, 13.455761),
      const LatLng(48.570917, 13.455670),
      const LatLng(48.570952, 13.455611),
      const LatLng(48.570977, 13.455649),
      const LatLng(48.570991, 13.455627),
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Schloss Neuburg',
    abbrev: 'SN',
    address: 'Am Burgberg 8, 94127 Neuburg am Inn',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.506523, 13.450616),
      const LatLng(48.506484, 13.450858),
      const LatLng(48.506292, 13.450766),
      const LatLng(48.506321, 13.450691),
      const LatLng(48.506317, 13.450632),
      const LatLng(48.506346, 13.450611),
      const LatLng(48.506367, 13.450622),
      const LatLng(48.506403, 13.450546),
    ],
    color: Colors.blue.withAlpha(128),
  ),
  Building(
    name: 'Ludwigstraße 8',
    abbrev: 'LU8',
    address: 'Ludwigstraße 8, 94032 Passau',
    labelPlacement: PolygonLabelPlacement.polylabel,
    points: [
      const LatLng(48.574641, 13.459200),
      const LatLng(48.574804, 13.459522),
      const LatLng(48.574644, 13.459715),
      const LatLng(48.574471, 13.459377),
    ],
    color: Colors.blue.withAlpha(128),
  ),
];

List<Polygon> get polygons =>
    buildings.map((e) => e.polygon).toList(growable: false);

List<Marker> get markers =>
    buildings.map((e) => e.marker).toList(growable: false);

List<Building> searchBuildings(String search) {
  final searchLC = search.toLowerCase();
  return buildings
      .filter(
        (e) =>
            e.name.toLowerCase().contains(searchLC) ||
            e.abbrev.toLowerCase().contains(searchLC) ||
            e.address.toLowerCase().contains(searchLC),
      )
      .sorted((e1, e2) => searchCompare(searchLC, e1, e2))
      .toList(growable: false);
}

int searchCompare(String search, Building e1, Building e2) {
  var ret = _compareProps(search, e1.abbrev, e2.abbrev);
  if (ret != 0) {
    return ret;
  }
  ret = _compareProps(search, e1.name, e2.name);
  if (ret != 0) {
    return ret;
  }
  return _compareProps(search, e1.address, e2.address);
}

int _compareProps(String search, String e1, String e2) {
  final e1LC = e1.toLowerCase();
  final e2LC = e2.toLowerCase();
  final e1Match = e1LC.contains(search);
  final e2Match = e2LC.contains(search);
  if (e1Match && e2Match) {
    final e1Sim = search.similarityTo(e1LC);
    final e2Sim = search.similarityTo(e2LC);
    return (e1Sim - e2Sim).sign.toInt();
  } else if (e1Match && !e2Match) {
    return -1;
  } else if (!e1Match && e2Match) {
    return 1;
  }
  return 0;
}

class Building {
  Building({
    required this.name,
    required this.abbrev,
    required this.address,
    required List<LatLng> points,
    List<List<LatLng>>? holePoints,
    LatLng? markerPos,
    Color color = const Color(0xFF00FF00),
    PolygonLabelPlacement labelPlacement = PolygonLabelPlacement.centroid,
  }) : polygon = Polygon(
         points: points,
         holePointsList: holePoints,
         color: color,
         label: abbrev,
         labelPlacement: labelPlacement,
       ),
       marker = Marker(
         point: markerPos ?? LatLngBounds.fromPoints(points).center,
         rotate: true,
         child: const Icon(Icons.circle, color: Colors.red, size: 20),
       );

  final String name;
  final String abbrev;
  final String address;
  final Polygon polygon;
  final Marker marker;
}
