import 'package:flutter/material.dart';
import '../models/house_model.dart';
import '../models/match_result.dart';

class PropertyDetailScreen extends StatefulWidget {
  final House house;
  final MatchResult host;

  const PropertyDetailScreen({
    super.key,
    required this.house,
    required this.host,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late House house;
  late MatchResult host;

  @override
  void initState() {
    super.initState();
    house = widget.house;
    host = widget.host;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(house.address ?? "Property"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Property"),
            Tab(text: "Host Profile"),
          ],
        ),
      ),

      body: TabBarView(
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                host.avatarUrl != null ? NetworkImage(host.avatarUrl!) : null,
            child: host.avatarUrl == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),

          const SizedBox(height: 16),

          Text(
            host.fullName ?? "Unknown",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          if (host.age != null)
            Text(
              "${host.age} years old",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

          const SizedBox(height: 16),

          if (host.bio != null)
            Text(
              host.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),

          const SizedBox(height: 20),

          _profileTag("Gender", host.gender),
          _profileTag("Occupation", host.occupation),
          _profileTag("Budget Score", "${host.budgetScore}%"),
          _profileTag("Lifestyle Score", "${host.lifestyleScore}%"),
        ],
      ),
    );
  }

  Widget _profileTag(String label, String? value) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Chip(label: Text("$label: $value")),
    );
  }
}
