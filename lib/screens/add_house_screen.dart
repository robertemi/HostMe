import 'package:flutter/material.dart';
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

  Future<void> _saveHouse() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // ✅ Access the user inside the method (not at field declaration)
      final user = supabase.auth.currentUser;

      final response = await supabase.from('houses').insert({
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
        'number_of_current_roomates': 0, // ✅ matches your DB column
        if (user != null) 'user_id': user.id,
      });

      // Optional: check response if you’re on an older SDK
      // if (response.error != null) throw response.error!;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving property: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Property'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(addressController, 'Address'),
              _buildTextField(roomsController, 'Number of Rooms', keyboardType: TextInputType.number),
              _buildTextField(balconiesController, 'Number of Balconies', keyboardType: TextInputType.number),
              _buildTextField(bedroomsController, 'Number of Bedrooms', keyboardType: TextInputType.number),
              _buildTextField(bathroomsController, 'Number of Bathrooms', keyboardType: TextInputType.number),
              _buildTextField(rentController, 'Rent', keyboardType: TextInputType.number),
              _buildTextField(areaController, 'Living Area (m²)', keyboardType: TextInputType.number),
              _buildTextField(floorController, 'Floor Number', keyboardType: TextInputType.number),
              _buildTextField(typeController, 'Type (e.g. Apartment, Studio)'),
              const SizedBox(height: 10),
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
              _buildTextField(imageController, 'Image URL'),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveHouse,
                  child: const Text('Save Property'),
                ),
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
          if ((value == null || value.isEmpty) && value != imageController.text){
            return 'Please enter $label';
          }
        },
      ),
    );
  }
}
