import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  
  // Basic Info Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Patient-specific Controllers
  final _emergencyContactController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _currentMedicationsController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  
  // Doctor-specific Controllers
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _educationController = TextEditingController();
  final _languagesController = TextEditingController();
  final _certificationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<HymedCareAuthProvider>().currentUser;
      if (user != null) {
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _phoneController.text = user.phoneNumber;
        _addressController.text = user.address ?? '';
        _bioController.text = user.bio ?? '';
        
        if (user.role == 'Patient') {
          _emergencyContactController.text = user.emergencyContact ?? '';
          _bloodTypeController.text = user.bloodType ?? '';
          _allergiesController.text = user.allergies ?? '';
          _currentMedicationsController.text = user.currentMedications ?? '';
          _medicalHistoryController.text = user.medicalHistory ?? '';
          _insuranceProviderController.text = user.insuranceProvider ?? '';
          _insuranceNumberController.text = user.insuranceNumber ?? '';
        } else if (user.role == 'Doctor') {
          _specializationController.text = user.specialization ?? '';
          _licenseNumberController.text = user.licenseNumber ?? '';
          _experienceYearsController.text = user.experienceYears?.toString() ?? '';
          _educationController.text = user.education ?? '';
          _languagesController.text = user.languages?.join(', ') ?? '';
          _certificationsController.text = user.certifications?.join('\n') ?? '';
        }
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _emergencyContactController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _currentMedicationsController.dispose();
    _medicalHistoryController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _experienceYearsController.dispose();
    _educationController.dispose();
    _languagesController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool multiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          padding: const EdgeInsets.all(12),
          maxLines: multiline ? 3 : 1,
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField('First Name', _firstNameController),
        _buildTextField('Last Name', _lastNameController),
        _buildTextField('Phone Number', _phoneController),
        _buildTextField('Address', _addressController),
        _buildTextField('Bio', _bioController, multiline: true),
      ],
    );
  }

  Widget _buildPatientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medical Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField('Emergency Contact', _emergencyContactController),
        _buildTextField('Blood Type', _bloodTypeController),
        _buildTextField('Allergies', _allergiesController, multiline: true),
        _buildTextField('Current Medications', _currentMedicationsController, multiline: true),
        _buildTextField('Medical History', _medicalHistoryController, multiline: true),
        const Text(
          'Insurance Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField('Insurance Provider', _insuranceProviderController),
        _buildTextField('Insurance Number', _insuranceNumberController),
      ],
    );
  }

  Widget _buildDoctorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Professional Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField('Specialization', _specializationController),
        _buildTextField('License Number', _licenseNumberController),
        _buildTextField('Years of Experience', _experienceYearsController),
        _buildTextField('Education', _educationController, multiline: true),
        _buildTextField('Languages (comma separated)', _languagesController),
        _buildTextField('Certifications (one per line)', _certificationsController, multiline: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<HymedCareAuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final isDoctor = currentUser?.role == 'Doctor';

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Edit Profile'),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Picture Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.systemGrey5,
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : currentUser?.profilePicture != null
                              ? DecorationImage(
                                  image: NetworkImage(currentUser!.profilePicture!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: _imageFile == null && currentUser?.profilePicture == null
                        ? const Icon(
                            CupertinoIcons.camera,
                            size: 40,
                            color: CupertinoColors.systemGrey,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form Sections
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              
              if (isDoctor)
                _buildDoctorSection()
              else
                _buildPatientSection(),
              
              const SizedBox(height: 32),

              // Save Button
              CupertinoButton.filled(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final authProvider = Provider.of<HymedCareAuthProvider>(context, listen: false);
                      Map<String, dynamic> updatedData = {
                        'firstName': _firstNameController.text,
                        'lastName': _lastNameController.text,
                        'phoneNumber': _phoneController.text,
                        'address': _addressController.text,
                        'bio': _bioController.text,
                      };

                      if (isDoctor) {
                        int? expYears = int.tryParse(_experienceYearsController.text);
                        if (expYears == null && _experienceYearsController.text.isNotEmpty) {
                          throw Exception('Years of experience must be a valid number');
                        }
                        
                        updatedData.addAll({
                          'specialization': _specializationController.text,
                          'licenseNumber': _licenseNumberController.text,
                          'experienceYears': expYears,
                          'education': _educationController.text,
                          'languages': _languagesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                          'certifications': _certificationsController.text.split('\n').where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList(),
                        });
                      } else {
                        updatedData.addAll({
                          'emergencyContact': _emergencyContactController.text,
                          'bloodType': _bloodTypeController.text,
                          'allergies': _allergiesController.text,
                          'currentMedications': _currentMedicationsController.text,
                          'medicalHistory': _medicalHistoryController.text,
                          'insuranceProvider': _insuranceProviderController.text,
                          'insuranceNumber': _insuranceNumberController.text,
                        });
                      }

                      await authProvider.updateUserProfile(
                        imageFile: _imageFile,
                        data: updatedData,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('Error'),
                          content: Text(e.toString()),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
