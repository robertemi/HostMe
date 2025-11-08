import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/location_model.dart';
import '../location_marker.dart';

class MapWidget extends StatelessWidget {
  final List<LocationModel> locations;
  final LatLng initialPosition;
  final double zoom;

  const MapWidget({
    super.key,
    required this.locations,
    required this.initialPosition,
    this.zoom = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialPosition,
        initialZoom: zoom,
      ),
      children: [
        // Base map layer (OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.host_me',
        ),

        // Marker layer
        MarkerLayer(
          markers: locations.map(LocationMarker.buildMarker).toList(),
        ),
      ],
    );
  }
}
