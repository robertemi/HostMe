import 'package:flutter/material.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_header.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_avatar_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/interests_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/activity_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/preferences_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/edit_profile_modal.dart';
import 'package:host_me/widgets/profile_screen_widgets/about_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Values displayed in PreferencesSection (initialized from Supabase profile)
  double budget = 3; // 1..5 category derived from budgetMin/Max
  double cleanliness = 3;
  double noise = 3;
  bool smoking = false;
  bool pets = false;
  String? occupation;
  ProfileModel? _profile;
  String bio="";
  bool _loadingProfile = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final fetched = await ProfileService().fetchProfile(user.id);
      setState(() {
        _profile = fetched;
        // Map DB values to UI
        cleanliness = (fetched?.cleanlinessLevel ?? 3).toDouble();
        noise = (fetched?.noiseLevel ?? 3).toDouble();
        smoking = fetched?.smokingPreference ?? false;
        pets = fetched?.petsPreference ?? false;
        budget = _computeBudgetLevel(fetched?.budgetMin, fetched?.budgetMax);
        _loadingProfile = false;
      });
    } else {
      setState(() => _loadingProfile = false);
    }
  }

  // Map UI budget level (1..5) to (min,max) range values for storage
  (int? min, int? max) _budgetRangeForLevel(double level) {
    switch (level.toInt()) {
      case 1:
        return (0, 150);
      case 2:
        return (150, 200);
      case 3:
        return (200, 250);
      case 4:
        return (250, 300);
      case 5:
        return (300, 350);
      case 6: 
        return (350, 400);
      case 7: 
        return (400, 450);
      case 8: 
        return (450, 500);
      case 9: 
        return (500, 550);
      case 10: 
        return (550, 600);
      case 11: 
        return (600, 650);
      case 12: 
        return (650, 700);
      case 13: 
        return (700, 750);
      case 14: 
        return (750, 800);
      case 15: 
        return (800, 850);
      case 16: 
        return (850, 900);
      case 17: 
        return (900, 950);
      case 18: 
        return (950, 1000);
      case 19: 
        return (1000, null);
      default:
        return (null, null);
    }
  }

  void _openEditModal() {
    if (_loadingProfile) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Profile',
      barrierColor: Colors.black54,
      pageBuilder: (ctx, anim1, anim2) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: EditProfileModal(
          initialName: _profile?.fullName ?? '',
          initialBio: _profile?.bio ?? '',
          initialOccupation: _profile?.occupation,
          initialBudgetLevel: budget,
          initialCleanliness: cleanliness,
          initialNoise: noise,
          initialSmoking: smoking,
          initialPets: pets,
          onSave: ({
            required String name,
            required String bio,
            required String? occupation,
            required double budgetLevel,
            required double cleanlinessLevel,
            required double noiseLevel,
            required bool smoking,
            required bool pets,
          }) {
            _handleSave(
              name: name,
              bio: bio,
              occupation: occupation,
              budgetLevel: budgetLevel,
              cleanlinessLevel: cleanlinessLevel,
              noiseLevel: noiseLevel,
              smoking: smoking,
              pets: pets,
            );
          },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave({
    required String name,
    required String bio,
    required String? occupation,
    required double budgetLevel,
    required double cleanlinessLevel,
    required double noiseLevel,
    required bool smoking,
    required bool pets,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return; // no user logged in
    setState(() => _saving = true);
    try {
      final (min, max) = _budgetRangeForLevel(budgetLevel);
      final existing = _profile;
      final updated = (existing != null)
          ? existing.copyWith(
              fullName: name.isEmpty ? existing.fullName : name,
              bio: bio.isNotEmpty ? bio : existing.bio,
              occupation: occupation ?? existing.occupation,
              budgetMin: min,
              budgetMax: max,
              cleanlinessLevel: cleanlinessLevel.toInt(),
              noiseLevel: noiseLevel.toInt(),
              smokingPreference: smoking,
              petsPreference: pets,
              updatedAt: DateTime.now(),
            )
          : ProfileModel(
              id: user.id,
              fullName: name,
              bio: bio.isEmpty ? null : bio,
              occupation: occupation,
              budgetMin: min,
              budgetMax: max,
              cleanlinessLevel: cleanlinessLevel.toInt(),
              noiseLevel: noiseLevel.toInt(),
              smokingPreference: smoking,
              petsPreference: pets,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

      await ProfileService().upsertProfile(updated);
      setState(() {
        _profile = updated;
        budget = budgetLevel;
        cleanliness = cleanlinessLevel;
        noise = noiseLevel;
        this.smoking = smoking;
        this.pets = pets;
        this.occupation = occupation;
        _saving = false;
      });
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    }
  }

  double _computeBudgetLevel(int? min, int? max) {
    if (min == null && max == null) return 3;
    final values = [
      if (min != null) min.toDouble(),
      if (max != null) max.toDouble(),
    ];
    final v = values.isEmpty ? 0 : (values.reduce((a, b) => a + b) / values.length);
    
    // Map to 19-level scale to match _budgetRangeForLevel
    if (v < 75) return 1;       // 0–150
    if (v < 175) return 2;      // 150–200
    if (v < 225) return 3;      // 200–250
    if (v < 275) return 4;      // 250–300
    if (v < 325) return 5;      // 300–350
    if (v < 375) return 6;      // 350–400
    if (v < 425) return 7;      // 400–450
    if (v < 475) return 8;      // 450–500
    if (v < 525) return 9;      // 500–550
    if (v < 575) return 10;     // 550–600
    if (v < 625) return 11;     // 600–650
    if (v < 675) return 12;     // 650–700
    if (v < 725) return 13;     // 700–750
    if (v < 775) return 14;     // 750–800
    if (v < 825) return 15;     // 800–850
    if (v < 875) return 16;     // 850–900
    if (v < 925) return 17;     // 900–950
    if (v < 975) return 18;     // 950–1000
    return 19;                  // 1000+
  }

  // persists user avatars to supabase bucket
  Future<String?> _uploadAvatar(User user, XFile file) async {
    final supabase = Supabase.instance.client;
    final fileBytes = await file.readAsBytes();
    final fileExt = file.name.split('.').last;
    final filePath = '${user.id}/avatar.$fileExt';

    try {
      await supabase.storage.from('UserPhotos').uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );
      final publicUrl =
          supabase.storage.from('UserPhotos').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          setState(() => _saving = true);
          try {
            final url = await _uploadAvatar(user, picked);
            if (url != null) {
              // Update profile
              final existing = _profile;
              if (existing != null) {
                final updated = existing.copyWith(
                  avatarUrl: url,
                  updatedAt: DateTime.now(),
                );
                await ProfileService().upsertProfile(updated);
                if (mounted) {
                  setState(() {
                    _profile = updated;
                  });
                }
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error uploading avatar: $e')),
              );
            }
          } finally {
            if (mounted) setState(() => _saving = false);
          }
        }
      }
    } catch (e) {
      // Handle permission errors or picker errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: ProfileHeader(onEdit: _openEditModal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_saving)
              const LinearProgressIndicator(minHeight: 3),
            // --- Avatar + Bio ---
            if (_loadingProfile)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: ProfileAvatarSection(
                  imageUrl: _profile?.avatarUrl ?? "",
                  name: _profile?.fullName ?? 'Your Name',
                  bio: _profile != null
                      ? (_profile!.bio ?? 'Complete your bio below.')
                      : 'Complete your profile to personalize this section.',
                  onEditAvatar: _showAvatarPicker,
                ),
              ),
            const SizedBox(height: 20),
            // About Section ---
            AboutSection(
              occupation: _profile?.occupation,
            ),
            const SizedBox(height: 24),
            // --- Interests ---
            InterestsSection(
              interests: _profile?.interests ?? [],
              onChanged: (newInterests) {
                if (_profile != null) {
                  setState(() {
                    _profile = _profile!.copyWith(interests: newInterests);
                  });
                  // Auto-save interests when changed
                  ProfileService().upsertProfile(_profile!).catchError((e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save interests: $e')),
                      );
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // --- Preferences ---
            PreferencesSection(
              budgetLevel: budget,
              onBudgetChanged: (v) => setState(() => budget = v),
              cleanlinessLevel: cleanliness,
              onCleanlinessChanged: (v) => setState(() => cleanliness = v),
              noiseLevel: noise,
              onNoiseChanged: (v) => setState(() => noise = v),
              smoking: smoking,
              onSmokingChanged: (v) => setState(() => smoking = v),
              pets: pets,
              onPetsChanged: (v) => setState(() => pets = v)
            ),

            const SizedBox(height: 28),

            // --- Activity Section ---
            const ActivitySection(),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}
