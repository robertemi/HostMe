import 'package:latlong2/latlong.dart';

class LocationModel {
  final String id;
  final String name;
  final LatLng position;

  LocationModel({
    required this.id,
    required this.name,
    required this.position,
  });
}
