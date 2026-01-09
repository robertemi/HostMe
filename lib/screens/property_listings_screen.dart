import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/house_service.dart';
import '../services/matching_service.dart';
import '../services/profile_service.dart';
import '../utils/notifications.dart';
import '../models/house_model.dart';
import '../models/match_result.dart';
import 'property_detail_screen.dart';

class PropertyListingsScreen extends StatefulWidget {
  const PropertyListingsScreen({super.key});

  @override
  State<PropertyListingsScreen> createState() => _PropertyListingsScreenState();
}

class _PropertyListingsScreenState extends State<PropertyListingsScreen> {
  // Toggle for the native "Blue Dot" layer (Mobile only)
  bool _myLocationEnabled = false;

  static const CameraPosition _kDefaultPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12.0,
  );

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final HouseService _houseService = HouseService();

  @override
  void initState() {
    super.initState();
    _fetchHouses();
  }
// Fetch houses from the backend and add markers to the map
  Future<void> _fetchHouses() async {
    try {
      final houses = await _houseService.getAllHouses();
      final Set<Marker> newMarkers = {};

      for (var house in houses) {
        if (house.latitude != null && house.longitude != null) {
          newMarkers.add(
            Marker(
              markerId: MarkerId(house.id),
              position: LatLng(house.latitude!, house.longitude!),
              infoWindow: InfoWindow(
                title: house.address ?? 'House Listing',
                snippet: '${house.rent != null ? '€${house.rent!.toStringAsFixed(0)}/mo' : 'Price on request'} • ${kIsWeb ? "Click" : "Tap"} for details',
                onTap: () => _onMarkerTapped(house),
              ),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _markers.addAll(newMarkers);
        });
      }
    } catch (e) {
      debugPrint('Error fetching houses: $e');
      if (mounted) await showAppDetailedError(context, e, title: 'Error fetching houses');
    }
  }
// Handle marker tap: fetch match score and host profile, then navigate to detail screen
  Future<void> _onMarkerTapped(House house) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final matchingService = MatchingService();
      final profileService = ProfileService();

      // 1. Fetch all matches to find the score for this specific host
      // We assume 'find_place' because we are browsing properties
      final matches = await matchingService.getSmartMatches('find_place');

      // 2. Find the match result for this house's owner
      // If not found (e.g. filtered out by RPC), create a default result with 0 score
      final match = matches.firstWhere(
        (m) => m.userId == house.userId,
        orElse: () => MatchResult(
          userId: house.userId,
          matchScore: 0,
          budgetScore: 0,
          lifestyleScore: 0,
          fullName: 'Host',
        ),
      );

      // 3. Fetch the full profile of the host for details
      final hostProfile = await profileService.fetchProfile(house.userId);

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      // 4. Navigate to detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyDetailScreen(
            house: house,
            host: match,
            hostProfile: hostProfile,
            hidePropertyTab: false,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        await showAppDetailedError(context, e, title: 'Error loading details');
      }
    }
  }

  Future<void> _checkPermissionsAndLocate() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Permissions granted: Enable the native Blue Dot on mobile
    if (mounted) {
      setState(() {
        _myLocationEnabled = true;
      });
    }

    // Center the camera on the user
    await _centerOnUser();
  }

  Future<void> _centerOnUser() async {
    try {
      final position = await Geolocator.getCurrentPosition();

      // WEB SPECIFIC: The "My Location" layer is not supported on Flutter Web.
      // We must manually add a marker and handle the UI.
      if (kIsWeb && mounted) {
        setState(() {
          _markers.removeWhere((m) => m.markerId.value == 'user_location');
          _markers.add(
            Marker(
              markerId: const MarkerId('user_location'),
              position: LatLng(position.latitude, position.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
          );
        });
      }

      // Animate camera to user position
      if (mounted && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) await showAppDetailedError(context, e, title: 'Location error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Listings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
      ),
      // Add a floating button for Web users (since they don't get the native blue button)
      floatingActionButton: kIsWeb
          ? FloatingActionButton(
              onPressed: _centerOnUser,
              child: const Icon(Icons.my_location),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kDefaultPosition,
        // 1. Enable the Native Blue Dot (Android/iOS only)
        myLocationEnabled: _myLocationEnabled,
        // 2. Enable the Native "Center" Button (Android/iOS only)
        myLocationButtonEnabled: _myLocationEnabled,
        zoomControlsEnabled: false,
        markers: _markers,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          // Check permissions and center map once map is ready
          _checkPermissionsAndLocate();
        },
      ),
    );
  }
}