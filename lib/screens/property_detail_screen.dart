import 'package:flutter/material.dart';
import '../models/house_model.dart';
import '../models/match_result.dart';
import '/models/profile_model.dart';

class PropertyDetailScreen extends StatefulWidget {
  final House house;
  final MatchResult host;
  final bool hidePropertyTab;
  final ProfileModel? hostProfile;

  const PropertyDetailScreen({
    super.key,
    required this.house,
    this.hostProfile,
    required this.host,
    this.hidePropertyTab = false,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late House house;
  late MatchResult host;
  ProfileModel? hostProfile;

  @override
  void initState() {
    super.initState();
    house = widget.house;
    host = widget.host;
    hostProfile = widget.hostProfile;
    // Only create 1 tab if hiding property tab, otherwise 2
    final tabCount = widget.hidePropertyTab ? 1 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hidePropertyTab 
            ? (hostProfile?.fullName ?? host.fullName ?? "Profile")
            : (house.address ?? "Property")),
        bottom: widget.hidePropertyTab
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Property"),
                  Tab(text: "Host Profile"),
                ],
              ),
      ),
      body: widget.hidePropertyTab
          ? _buildHostProfileTab()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPropertyTab(),
                _buildHostProfileTab(),
              ],
            ),
    );
  }

  // ------------------------------------------------------------------------
  // PROPERTY TAB
  // ------------------------------------------------------------------------
  Widget _buildPropertyTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _photoCarousel(),
          const SizedBox(height: 20),
          _infoSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _photoCarousel() {
    final List<String> photos =
        house.imagePaths ?? (house.image != null ? [house.image!] : []);

    if (photos.isEmpty) {
      return Container(
        height: 260,
        color: Colors.grey.shade300,
        child: const Center(child: Text("No photos available")),
      );
    }

    return SizedBox(
      height: 260,
      child: PageView.builder(
        itemCount: photos.length,
        itemBuilder: (_, index) => Image.network(
          photos[index],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _infoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            house.address ?? "Unknown Address",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (house.rent != null)
            Text(
              "Rent: €${house.rent!.toStringAsFixed(0)} / month",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

          if (house.livingArea != null)
            Text("Living Area: ${house.livingArea} m²"),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoChip("Rooms", house.numberOfRooms),
              _infoChip("Bedrooms", house.numberOfBedrooms),
              _infoChip("Bathrooms", house.numberOfBathrooms),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoChip("Balconies", house.numberOfBalconies),
              _infoChip("Floor", house.floorNumber),
              _infoChip("Type", house.type),
            ],
          ),

          const SizedBox(height: 20),
          _booleanInfo("Has Elevator", house.hasElevator),
          _booleanInfo("Personal Heating", house.hasPersonalHeating),
          const SizedBox(height: 20),

          if (house.numberOfCurrentRoommates != null)
            Text(
              "Current roommates: ${house.numberOfCurrentRoommates}",
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, dynamic value) {
    return Chip(label: Text("$label: ${value ?? '-'}"));
  }

  Widget _booleanInfo(String label, bool? value) {
    if (value == null) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  // ------------------------------------------------------------------------
  // HOST PROFILE TAB
  // ------------------------------------------------------------------------
  Widget _buildHostProfileTab() {
    // Use hostProfile if available, fall back to host (MatchResult)
    final profile = hostProfile;
    final name = profile?.fullName ?? host.fullName ?? "Unknown";
    final avatar = profile?.avatarUrl ?? host.avatarUrl;
    final bio = profile?.bio ?? host.bio;
    final gender = profile?.gender ?? host.gender;
    final occupation = profile?.occupation ?? host.occupation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null ? const Icon(Icons.person, size: 50) : null,
          ),

          const SizedBox(height: 16),

          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          if (profile?.dateOfBirth != null)
            Text(
              "${_calculateAge(profile!.dateOfBirth!)} years old",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

          const SizedBox(height: 16),

          if (bio != null && bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                bio,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),

          const SizedBox(height: 24),

          _buildSectionTitle("About"),
          _profileTag("Gender", gender),
          _profileTag("Occupation", occupation),
          if (profile?.university != null)
            _profileTag("University", profile!.university),

          const SizedBox(height: 20),

          if (profile?.budgetMin != null || profile?.budgetMax != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Budget"),
                _profileTag(
                  "Budget Range",
                  _formatBudgetRange(profile?.budgetMin, profile?.budgetMax),
                ),
                const SizedBox(height: 20),
              ],
            ),

          _buildSectionTitle("Lifestyle"),
          _booleanTag("Smoking", profile?.smokingPreference),
          _booleanTag("Pets", profile?.petsPreference),
          if (profile?.cleanlinessLevel != null)
            _profileTag("Cleanliness", _levelToLabel(profile!.cleanlinessLevel!)),
          if (profile?.noiseLevel != null)
            _profileTag("Noise Level", _levelToLabel(profile!.noiseLevel!)),

          const SizedBox(height: 20),

          _buildSectionTitle("Compatibility"),
          _profileTag("Budget Score", "${host.budgetScore}%"),
          _profileTag("Lifestyle Score", "${host.lifestyleScore}%"),
          _profileTag("Overall Match", "${host.matchScore}%"),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // Helper: Section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper: Format budget range
  String _formatBudgetRange(int? min, int? max) {
    if (min == null && max == null) return 'Not set';
    if (min != null && max != null) return '\$${min}–\$${max}';
    if (min != null) return '\$${min}+';
    if (max != null) return 'Up to \$${max}';
    return 'Not set';
  }

  // Helper: Level (1-5) to label
  String _levelToLabel(int level) {
    const labels = ['', 'Very Low', 'Low', 'Medium', 'High', 'Very High'];
    return labels.length > level ? labels[level] : 'Level $level';
  }

  // Helper: Boolean tag
  Widget _booleanTag(String label, bool? value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  // Helper: Generic profile tag
  Widget _profileTag(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Chip(label: Text("$label: $value")),
    );
  }
}
