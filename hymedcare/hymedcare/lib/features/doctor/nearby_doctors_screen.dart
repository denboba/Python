import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../model/userModel.dart';
import '../../services/location_service.dart';

class NearbyDoctorsScreen extends StatefulWidget {
  const NearbyDoctorsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyDoctorsScreen> createState() => _NearbyDoctorsScreenState();
}

class _NearbyDoctorsScreenState extends State<NearbyDoctorsScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();
  final Set<Marker> _markers = {};
  LatLng? _currentLocation;
  List<UserModel> _nearbyDoctors = [];
  double _searchRadius = 5000; // 5km in meters

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadNearbyDoctors();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _animateToCurrentLocation();
    }
  }

  Future<void> _animateToCurrentLocation() async {
    if (_currentLocation == null) return;
    
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _currentLocation!,
        zoom: 14.0,
      ),
    ));
  }

  Future<void> _loadNearbyDoctors() async {
    if (_currentLocation == null) return;

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('isAvailable', isEqualTo: true)
        .get();

    _nearbyDoctors.clear();
    _markers.clear();

    for (var doc in snapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;
      final UserModel doctor = UserModel.fromMap(userData);

      if (doctor.latitude != null && doctor.longitude != null) {
        final distance = _locationService.calculateDistance(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          doctor.latitude!,
          doctor.longitude!,
        );

        if (distance <= _searchRadius) {
          _nearbyDoctors.add(doctor);
          _markers.add(
            Marker(
              markerId: MarkerId(doctor.uid),
              position: LatLng(doctor.latitude!, doctor.longitude!),
              infoWindow: InfoWindow(
                title: '${doctor.firstName} ${doctor.lastName}',
                snippet: doctor.specialization ?? 'General Practitioner',
              ),
              onTap: () => _showDoctorDetails(doctor),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showDoctorDetails(UserModel doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: doctor.profilePicture != null
                          ? NetworkImage(doctor.profilePicture!)
                          : null,
                      child: doctor.profilePicture == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${doctor.firstName} ${doctor.lastName}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            doctor.specialization ?? 'General Practitioner',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (doctor.rating != null)
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${doctor.rating!.toStringAsFixed(1)} (${doctor.reviewCount ?? 0} reviews)',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                if (doctor.consultationFee != null)
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Consultation Fee: \$${doctor.consultationFee!.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to appointment booking screen
                    Navigator.pop(context);
                    // Add your navigation logic here
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Book Appointment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Doctors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyDoctors,
          ),
        ],
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 14.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Search Radius: ${(_searchRadius / 1000).toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Slider(
                            value: _searchRadius,
                            min: 1000,
                            max: 20000,
                            divisions: 19,
                            label: '${(_searchRadius / 1000).toStringAsFixed(1)} km',
                            onChanged: (value) {
                              setState(() {
                                _searchRadius = value;
                              });
                              _loadNearbyDoctors();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
