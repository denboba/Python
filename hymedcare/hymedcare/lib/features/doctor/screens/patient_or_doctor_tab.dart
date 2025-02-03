import 'package:flutter/cupertino.dart';
import 'package:hymedcare/model/userModel.dart';
import 'package:hymedcare/widgets/avatar.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';

class PatientsTab extends StatefulWidget {
  const PatientsTab({super.key});

  @override
  PatientsTabState createState() => PatientsTabState();
}

class PatientsTabState extends State<PatientsTab> {
  List<UserModel> usersList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final authProvider = Provider.of<HymedCareAuthProvider>(context, listen: false);
      final users = await authProvider.fetchAllUsers();
      final currentUser = authProvider.currentUser;
      setState(() {
        usersList = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<HymedCareAuthProvider>(context, listen: false);
    final role = authProvider.currentUser?.role;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle:role == 'Doctor' ? const Text('Users') : const Text('Doctors '),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : usersList.isEmpty
                    ? const Center(child: Text('No patients found'))
                    : ListView.builder(
                  itemCount: usersList.length,
                  itemBuilder: (context, index) {
                    final patient = usersList[index];
                    return _PatientTile(
                      firstName: patient.firstName,
                      lastName: patient.lastName,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => PatientDetailsPage(patient: patient),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  final String firstName;
  final String lastName;
  //final String condition;
  final VoidCallback onTap;

  const _PatientTile({
    required this.firstName,
    required this.lastName,
    //required this.condition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1,
          ),
        ),
        child: Row(
          children: [
           CupertinoAvatar(name: "assets/images/d1.png", size: 50),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$firstName $lastName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age: ',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Condition: ',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientDetailsPage extends StatelessWidget {
  final UserModel patient;

  const PatientDetailsPage({required this.patient, super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("${patient.firstName} ${patient.lastName}"),
        previousPageTitle: 'Patients',
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Name: ${patient.firstName} ${patient.lastName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Condition: ',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Additional Notes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No additional notes available.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
