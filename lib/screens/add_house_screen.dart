import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AddHouseScreen extends StatefulWidget {
  const AddHouseScreen({super.key});

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  // Controllers
  final addressController = TextEditingController();
  final roomsController = TextEditingController();
  final balconiesController = TextEditingController();
  final bedroomsController = TextEditingController();
  final bathroomsController = TextEditingController();
  final rentController = TextEditingController();
  final areaController = TextEditingController();
  final floorController = TextEditingController();
  final typeController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  // Location
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};

  bool hasElevator = false;
  bool hasPersonalHeating = false;

  // MULTI IMAGE STORAGE (local until save)
  List<File> mobileImages = [];
  List<Uint8List> webImages = [];
  List<String> webImageNames = [];

  static const int maxPhotos = 5;

  // Consent keys & cached values
  static const String _kCameraConsentKey = 'consent_camera';
  static const String _kGalleryConsentKey = 'consent_gallery';
  bool _cameraConsent = false;
  bool _galleryConsent = false;

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  Future<void> _loadConsents() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cameraConsent = prefs.getBool(_kCameraConsentKey) ?? false;
      _galleryConsent = prefs.getBool(_kGalleryConsentKey) ?? false;
    });
  }

  Future<void> _saveConsent(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (key == _kCameraConsentKey) _cameraConsent = value;
    if (key == _kGalleryConsentKey) _galleryConsent = value;
  }

  // ------------------------------
  // LOCATION LOGIC
  // ------------------------------
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location services are disabled. Please enable the services')));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    final latLng = LatLng(position.latitude, position.longitude);
    
    setState(() {
      _selectedLocation = latLng;
      latController.text = position.latitude.toString();
      longController.text = position.longitude.toString();
      _markers = {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: latLng,
        )
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
  }

  void _onMapTap(LatLng pos) {
    setState(() {
      _selectedLocation = pos;
      latController.text = pos.latitude.toString();
      longController.text = pos.longitude.toString();
      _markers = {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: pos,
        )
      };
    });
  }

  // ------------------------------
  // PICK IMAGE (1 AT A TIME) -- NO UPLOAD HERE
  // ------------------------------
  Future<void> _pickImage(ImageSource source) async {
    final currentCount = kIsWeb ? webImages.length : mobileImages.length;
    if (currentCount >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can upload max 5 photos.")),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);

    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        webImages.add(bytes);
        webImageNames.add(picked.name);
      });
    } else {
      final file = File(picked.path);
      setState(() => mobileImages.add(file));
    }
  }

  // ------------------------------
  // Ask for user consent before opening camera/gallery
  // remembers choice if requested
  // ------------------------------
  Future<bool> _confirmMediaAccess(BuildContext ctx, String target) async {
    // Check cached stored consent first
    if (target == 'camera' && _cameraConsent) return true;
    if (target == 'gallery' && _galleryConsent) return true;

    bool remember = false;
    final result = await showDialog<bool>(
      context: ctx,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text('Permission required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Allow the app to access your $target to pick a photo?'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: remember,
                      onChanged: (v) => setStateSB(() => remember = v ?? false),
                    ),
                    const Expanded(child: Text('Remember my choice')),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Allow'),
              ),
            ],
          );
        });
      },
    );

    final allowed = result ?? false;
    if (remember && allowed) {
      final key = target == 'camera' ? _kCameraConsentKey : _kGalleryConsentKey;
      await _saveConsent(key, true);
    } else if (remember && !allowed) {
      final key = target == 'camera' ? _kCameraConsentKey : _kGalleryConsentKey;
      await _saveConsent(key, false);
    }
    return allowed;
  }

  // ------------------------------
  // UPLOAD HELPER (used only during save)
  // ------------------------------
  Future<String> _uploadSingleImage({
    File? file,
    Uint8List? bytes,
    String? name,
  }) async {
    final user = supabase.auth.currentUser!;
    final ext = (name != null && name.contains('.'))
        ? name.split('.').last
        : (file != null ? file.path.split('.').last : 'jpg');
    final filePath =
        "${user.id}/house_${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().hashCode}.$ext";

    if (kIsWeb) {
      await supabase.storage.from('HousePhotos').uploadBinary(
            filePath,
            bytes!,
            fileOptions: const FileOptions(upsert: true),
          );
    } else {
      await supabase.storage.from('HousePhotos').upload(
            filePath,
            file!,
            fileOptions: const FileOptions(upsert: true),
          );
    }

    // getPublicUrl returns a String (public url)
    final url = supabase.storage.from('HousePhotos').getPublicUrl(filePath);
    return url;
  }

  // ------------------------------
  // SAVE LISTING (uploads images now)
  // ------------------------------
  Future<void> _saveHouse() async {
    if (!_formKey.currentState!.validate()) return;

    final totalLocalImages = kIsWeb ? webImages.length : mobileImages.length;
    if (totalLocalImages == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one photo.")),
      );
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be signed in to create a listing.")),
        );
        return;
      }

      debugPrint('DEBUG: currentUser = ${user.id}');
      debugPrint('DEBUG: currentUser.email = ${user.email}');

      // On web, refresh session to ensure auth.uid() is available in RLS
      if (kIsWeb) {
        await supabase.auth.refreshSession();
        debugPrint('DEBUG: Session refreshed on web');
      }

      // Upload local images and collect URLs
      final List<String> imageUrls = [];
      for (var i = 0; i < totalLocalImages; i++) {
        if (kIsWeb) {
          final bytes = webImages[i];
          final name = webImageNames.length > i ? webImageNames[i] : 'house_$i.jpg';
          final url = await _uploadSingleImage(bytes: bytes, name: name);
          imageUrls.add(url);
        } else {
          final file = mobileImages[i];
          final url = await _uploadSingleImage(file: file);
          imageUrls.add(url);
        }
      }

      debugPrint('DEBUG: About to insert house with user_id = ${user.id}');
      debugPrint('DEBUG: Images to insert: ${imageUrls.length} URLs');

      // Insert house and return id
      final insertResp = await supabase
          .from('houses')
          .insert({
            'user_id': user.id,
            'address': addressController.text,
            'number_of_rooms': int.tryParse(roomsController.text),
            'number_of_balconies': int.tryParse(balconiesController.text),
            'number_of_bedrooms': int.tryParse(bedroomsController.text),
            'number_of_bathrooms': int.tryParse(bathroomsController.text),
            'rent': double.tryParse(rentController.text),
            'living_area': double.tryParse(areaController.text),
            'floor_number': int.tryParse(floorController.text),
            'type': typeController.text,
            'has_elevator': hasElevator,
            'has_personal_heating': hasPersonalHeating,
            'image': imageUrls,
            'number_of_current_roomates': 0,
            'latitude': double.tryParse(latController.text),
            'longitude': double.tryParse(longController.text),
          })
          .select('id')
          .single();

      debugPrint('DEBUG: Insert response = $insertResp');

      // Extract new house id robustly
      dynamic newHouseId;
      if (insertResp.containsKey('id')) {
        newHouseId = insertResp['id'];
      } else if (insertResp['data'] != null && insertResp['data'] is Map && insertResp['data'].containsKey('id')) {
        newHouseId = insertResp['data']['id'];
      } else if (insertResp is List && insertResp.isNotEmpty && insertResp[0] is Map && insertResp[0].containsKey('id')) {
        newHouseId = insertResp[0]['id'];
      }

      // Update profile to save house id
      if (newHouseId != null) {
        await supabase.from('profiles').update({'house_id': newHouseId}).eq('id', user.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Property added successfully!")),
      );

      // Redirect to home screen
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      debugPrint('DEBUG: Error caught = $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error saving: $e")));
      }
    }
  }

  // ------------------------------
  // UI
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    final currentCount = kIsWeb ? webImages.length : mobileImages.length;
    return Scaffold(
      appBar: AppBar(title: const Text('List Your Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(addressController, "Address"),
              _buildNumField(roomsController, "Number of Rooms"),
              _buildNumField(balconiesController, "Number of Balconies"),
              _buildNumField(bedroomsController, "Number of Bedrooms"),
              _buildNumField(bathroomsController, "Number of Bathrooms"),
              _buildNumField(rentController, "Rent"),
              _buildNumField(areaController, "Living Area (m²)"),
              _buildNumField(floorController, "Floor Number"),
              _buildTextField(typeController, "Type"),

              const SizedBox(height: 20),

              // MAP
              const Text("Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(44.4268, 26.1025), // Default to Bucharest
                    zoom: 12,
                  ),
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: _onMapTap,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // We use custom button
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text("Use My Current Location"),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildTextField(latController, "Latitude")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(longController, "Longitude")),
                ],
              ),

              const SizedBox(height: 20),

              // MULTI IMAGE GRID
              _buildImageGrid(),

              const SizedBox(height: 12),

              // PICKERS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: currentCount < maxPhotos
                        ? () async {
                            final ok = await _confirmMediaAccess(context, 'camera');
                            if (ok) await _pickImage(ImageSource.camera);
                          }
                        : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: currentCount < maxPhotos
                        ? () async {
                            final ok = await _confirmMediaAccess(context, 'gallery');
                            if (ok) await _pickImage(ImageSource.gallery);
                          }
                        : null,
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                value: hasElevator,
                onChanged: (val) => setState(() => hasElevator = val),
                title: const Text("Has Elevator"),
              ),
              SwitchListTile(
                value: hasPersonalHeating,
                onChanged: (val) => setState(() => hasPersonalHeating = val),
                title: const Text("Has Personal Heating"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveHouse,
                child: const Text("Save Property"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------
  // IMAGE GRID (show local previews, allow delete)
  // ------------------------------
  Widget _buildImageGrid() {
    final int count = kIsWeb ? webImages.length : mobileImages.length;
    if (count == 0) {
      return SizedBox(
        height: 120,
        child: Center(child: Text('No photos yet (add up to $maxPhotos)')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1, // force square tiles so image always fills the area
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, index) {
        final Widget imageWidget = kIsWeb
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.grey[200],
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.memory(
                    webImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.grey[200],
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.file(
                    mobileImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              );

        return _HoverDeleteImage(
          image: imageWidget,
          onDelete: () {
            setState(() {
              if (kIsWeb) {
                if (webImages.length > index) {
                  webImages.removeAt(index);
                  if (webImageNames.length > index) webImageNames.removeAt(index);
                }
              } else {
                if (mobileImages.length > index) mobileImages.removeAt(index);
              }
            });
          },
        );
      },
    );
  }

  // ------------------------------
  // INPUT HELPERS
  // ------------------------------
  Widget _buildTextField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        decoration: _decor(label),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildNumField(TextEditingController c, String label) =>
      _buildTextField(c, label);

  InputDecoration _decor(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );

  @override
  void dispose() {
    addressController.dispose();
    roomsController.dispose();
    balconiesController.dispose();
    bedroomsController.dispose();
    bathroomsController.dispose();
    rentController.dispose();
    areaController.dispose();
    floorController.dispose();
    typeController.dispose();
    latController.dispose();
    longController.dispose();
    // _mapController?.dispose(); // Removed to prevent web error
    super.dispose();
  }
}

class _HoverDeleteImage extends StatefulWidget {
  final Widget image;
  final VoidCallback onDelete;

  const _HoverDeleteImage({
    required this.image,
    required this.onDelete,
  });

  @override
  State<_HoverDeleteImage> createState() => _HoverDeleteImageState();
}

class _HoverDeleteImageState extends State<_HoverDeleteImage> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.image,
          ),

          // Show X on hover (desktop/web) OR always show on mobile
          if (_hovering || !kIsWeb)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}