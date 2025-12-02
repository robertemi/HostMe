import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final imageController = TextEditingController();

  bool hasElevator = false;
  bool hasPersonalHeating = false;

  // For image handling
  File? _selectedImageFile;       // mobile
  Uint8List? _webImageBytes;      // web

  // ------------------------------
  // IMAGE PICKER (WEB + MOBILE)
  // ------------------------------
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);

    if (picked == null) return;

    if (kIsWeb) {
      // ---- WEB ----
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
        _selectedImageFile = null;
      });
      await _uploadToSupabaseWeb(bytes, picked.name);

    } else {
      // ---- MOBILE ----
      final file = File(picked.path);
      setState(() {
        _selectedImageFile = file;
        _webImageBytes = null;
      });
      await _uploadToSupabaseMobile(file);
    }
  }

  // ------------------------------
  // UPLOAD WEB
  // ------------------------------
  Future<void> _uploadToSupabaseWeb(Uint8List bytes, String filename) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final ext = filename.split('.').last;
      final fileName = "house_${DateTime.now().millisecondsSinceEpoch}.$ext";
      final filePath = "${user.id}/$fileName";

      await supabase.storage.from('HousePhotos').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl =
          supabase.storage.from('HousePhotos').getPublicUrl(filePath);

      setState(() => imageController.text = publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully (Web)")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  // ------------------------------
  // UPLOAD MOBILE
  // ------------------------------
  Future<void> _uploadToSupabaseMobile(File file) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final ext = file.path.split('.').last;
      final fileName = "house_${DateTime.now().millisecondsSinceEpoch}.$ext";
      final filePath = "${user.id}/$fileName";

      await supabase.storage.from('HousePhotos').upload(
        filePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl =
          supabase.storage.from('HousePhotos').getPublicUrl(filePath);

      setState(() => imageController.text = publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully (Mobile)")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  // ------------------------------
  // SAVE HOUSE INFO
  // ------------------------------
  Future<void> _saveHouse() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = supabase.auth.currentUser;

      await supabase.from('houses').insert({
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
        'image': imageController.text.isNotEmpty ? imageController.text : null,
        'number_of_current_roomates': 0,
        if (user != null) 'user_id': user.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error saving property: $e")));
    }
  }

  // ------------------------------
  // UI
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Your Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(addressController, "Address"),
              _buildTextField(roomsController, "Number of Rooms",
                  keyboardType: TextInputType.number),
              _buildTextField(balconiesController, "Number of Balconies",
                  keyboardType: TextInputType.number),
              _buildTextField(bedroomsController, "Number of Bedrooms",
                  keyboardType: TextInputType.number),
              _buildTextField(bathroomsController, "Number of Bathrooms",
                  keyboardType: TextInputType.number),
              _buildTextField(rentController, "Rent",
                  keyboardType: TextInputType.number),
              _buildTextField(areaController, "Living Area (m²)",
                  keyboardType: TextInputType.number),
              _buildTextField(floorController, "Floor Number",
                  keyboardType: TextInputType.number),
              _buildTextField(typeController, "Type"),

              const SizedBox(height: 20),

              // IMAGE PREVIEW
              if (_webImageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(_webImageBytes!,
                      height: 180, fit: BoxFit.cover),
                )
              else if (_selectedImageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_selectedImageFile!,
                      height: 180, fit: BoxFit.cover),
                ),

              const SizedBox(height: 12),

              // CAMERA + GALLERY BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text('Has Elevator'),
                value: hasElevator,
                onChanged: (val) => setState(() => hasElevator = val),
              ),
              SwitchListTile(
                title: const Text('Has Personal Heating'),
                value: hasPersonalHeating,
                onChanged: (val) => setState(() => hasPersonalHeating = val),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if ((value == null || value.isEmpty) &&
              controller != imageController) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
