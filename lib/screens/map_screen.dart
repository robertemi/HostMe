import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/location_model.dart';
import '../widgets/map_screen_widgets/map_widget.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Example data
    // request list of available properties from Database

    final List<LocationModel> locations = [
      LocationModel(
        id: '1',
        name: 'Downtown',
        position: const LatLng(37.7749, -122.4194),
      ),
      LocationModel(
        id: '2',
        name: 'Golden Gate Park',
        position: const LatLng(37.7694, -122.4862),
      ),
      LocationModel(
        id: '3',
        name: 'Pier 39',
        position: const LatLng(37.8087, -122.4098),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap Demo'),
        centerTitle: true,
      ),
      body: MapWidget(
        locations: locations,
        initialPosition: const LatLng(46.76004, 23.56044),
      ),
    );
  }
}
