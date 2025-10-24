import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/location_model.dart';

class LocationMarker {
  static Marker buildMarker(LocationModel location) {
    return Marker(
      point: location.position,
      width: 60,
      height: 60,
      child: Column(
        children: [
          const Icon(Icons.location_on, color: Colors.red, size: 36),
          Text(
            location.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
