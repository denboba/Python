import 'package:flutter/cupertino.dart';

class DoctorInformationScreen extends StatefulWidget {
  const DoctorInformationScreen({super.key});

  @override
  State<DoctorInformationScreen> createState() => _DoctorInformationScreenState();
}

class _DoctorInformationScreenState extends State<DoctorInformationScreen> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _profileImageUrlController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _yearsOfExperienceController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _totalReviewsController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _cityController.dispose();
    _profileImageUrlController.dispose();
    _qualificationController.dispose();
    _phoneNumberController.dispose();
    _yearsOfExperienceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _totalReviewsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Doctor Information"),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                controller: _cityController,
                placeholder: "City",
                padding: const EdgeInsets.all(12.0),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _profileImageUrlController,
                placeholder: "Profile Image URL",
                padding: const EdgeInsets.all(12.0),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _qualificationController,
                placeholder: "Qualification",
                padding: const EdgeInsets.all(12.0),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _phoneNumberController,
                placeholder: "Phone Number",
                padding: const EdgeInsets.all(12.0),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _yearsOfExperienceController,
                placeholder: "Years of Experience",
                padding: const EdgeInsets.all(12.0),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _latitudeController,
                placeholder: "Latitude",
                padding: const EdgeInsets.all(12.0),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _longitudeController,
                placeholder: "Longitude",
                padding: const EdgeInsets.all(12.0),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _totalReviewsController,
                placeholder: "Total Reviews",
                padding: const EdgeInsets.all(12.0),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: () {
                  // Handle saving or submission logic
                  print("City: ${_cityController.text}");
                  print("Profile Image URL: ${_profileImageUrlController.text}");
                  print("Qualification: ${_qualificationController.text}");
                  print("Phone Number: ${_phoneNumberController.text}");
                  print("Years of Experience: ${_yearsOfExperienceController.text}");
                  print("Latitude: ${_latitudeController.text}");
                  print("Longitude: ${_longitudeController.text}");
                  print("Total Reviews: ${_totalReviewsController.text}");
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
