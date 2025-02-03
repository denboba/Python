import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';
import '../../provider/auth_provider.dart';
import '../../model/appointment_model.dart';
import '../../features/doctor/screens/doctors_list_screen.dart';
import 'package:intl/intl.dart';

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  final _dateFormat = DateFormat('MMM d, y');
  final _timeFormat = DateFormat('h:mm a');
  String _selectedFilter = 'Upcoming';
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final user = Provider.of<HymedCareAuthProvider>(context, listen: false).currentUser!;
    final userRole = Provider.of<HymedCareAuthProvider>(context, listen: false).userRole;
    
    await Provider.of<AppointmentProvider>(context, listen: false)
        .loadAppointments(user.uid, userRole);
  }

  List<AppointmentModel> _getFilteredAppointments(List<AppointmentModel> appointments) {
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case 'Upcoming':
        return appointments.where((apt) {
          final isUpcoming = apt.dateTime.isAfter(now);
          final status = apt.status.toLowerCase();

          return isUpcoming && (
            status == 'upcoming' ||
            status == 'accepted' ||
            status == 'rescheduled'
          );
        }).toList();
        
      case 'Past':
        return appointments.where((apt) {
          final isPast = apt.dateTime.isBefore(now);
          final status = apt.status.toLowerCase();
          
          // Show in past if:
          // 1. Time is in the past OR
          // 2. Status is completed/cancelled/rejected (regardless of time)
          return isPast || [
            'completed',
            'cancelled',
            'rejected'
          ].contains(status);
        }).toList();
        
      default:
        return appointments;
    }
  }

  Future<void> _updateAppointmentStatus(AppointmentModel appointment, String status) async {
    try {
      await Provider.of<AppointmentProvider>(context, listen: false)
          .updateAppointmentStatus(appointment.id, status);
      
      _showSuccess('Appointment ${status.toLowerCase()}');
    } catch (e) {
      _showError('Failed to update appointment status');
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return CupertinoColors.systemOrange;
      case 'accepted':
        return CupertinoColors.activeBlue;
      case 'rejected':
        return CupertinoColors.systemRed;
      case 'rescheduled':
        return CupertinoColors.systemYellow;
      case 'completed':
        return CupertinoColors.systemGreen;
      case 'cancelled':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  Future<void> _editAppointment(AppointmentModel appointment) async {
    final isDoctor = Provider.of<HymedCareAuthProvider>(context, listen: false).userRole == 'Doctor';
    DateTime selectedDate;
    DateTime selectedTime;
    
    final now = DateTime.now();
    final minimumDate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    
    selectedDate = appointment.dateTime.isBefore(minimumDate) ? minimumDate : appointment.dateTime;
    selectedTime = selectedDate;

    final DateTime? newDateTime = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.pop(context, DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  )),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: selectedDate,
                minimumDate: minimumDate,
                maximumDate: DateTime.now().add(const Duration(days: 30)),
                onDateTimeChanged: (DateTime newDateTime) {
                  selectedDate = newDateTime;
                  selectedTime = newDateTime;
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (newDateTime != null) {
      try {
        await Provider.of<AppointmentProvider>(context, listen: false)
            .editAppointment(
              appointmentId: appointment.id,
              newDateTime: newDateTime,
              reasonForChange: isDoctor ? 'Reappointed by doctor' : 'Rescheduled by patient',
            );
        _showSuccess(isDoctor ? 'Appointment reappointed successfully' : 'Appointment rescheduled successfully');
      } catch (e) {
        _showError(isDoctor ? 'Failed to reappoint' : 'Failed to reschedule appointment');
      }
    }
  }

  Future<void> _addFiles(AppointmentModel appointment, bool isDoctor) async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Add Files'),
        content: const Text('File upload functionality will be implemented soon.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentActions(AppointmentModel appointment, bool isDoctor) {
    if (_selectedFilter != 'Upcoming' || 
        ['cancelled', 'completed', 'rejected'].contains(appointment.status.toLowerCase())) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isDoctor && appointment.status == 'upcoming')
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Accept'),
                  onPressed: () => _updateAppointmentStatus(
                    appointment,
                    'accepted',
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Reject'),
                  onPressed: () => _updateAppointmentStatus(
                    appointment,
                    'rejected',
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Reappoint'),
                  onPressed: () => _editAppointment(appointment),
                ),
                const SizedBox(width: 8),
              ],
            ),
          if (!isDoctor && appointment.status == 'upcoming')
            Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Edit'),
                  onPressed: () => _editAppointment(appointment),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Add Files'),
                  onPressed: () => _addFiles(appointment, false),
                ),
                const SizedBox(width: 8),
              ],
            ),
          if (appointment.status == 'accepted')
            Row(
              children: [
                if (isDoctor) ...[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Add Files'),
                    onPressed: () => _addFiles(appointment, true),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Complete'),
                    onPressed: () => _updateAppointmentStatus(
                      appointment,
                      'completed',
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Reappoint'),
                    onPressed: () => _editAppointment(appointment),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          if (appointment.status != 'cancelled' && appointment.status != 'completed')
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: CupertinoColors.systemRed,
                ),
              ),
              onPressed: () => _updateAppointmentStatus(
                appointment,
                'cancelled',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentFiles(AppointmentModel appointment) {
    final hasFiles = appointment.patientFiles.isNotEmpty || appointment.doctorFiles.isNotEmpty;
    
    if (!hasFiles) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (appointment.patientFiles.isNotEmpty) ...[
            const Text(
              'Patient Files:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: appointment.patientFiles
                  .map((file) => CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          file.split('/').last,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onPressed: () {
                          // TODO: Implement file viewing
                        },
                      ))
                  .toList(),
            ),
          ],
          if (appointment.doctorFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Doctor Files:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: appointment.doctorFiles
                  .map((file) => CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          file.split('/').last,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onPressed: () {
                          // TODO: Implement file viewing
                        },
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = Provider.of<HymedCareAuthProvider>(context).userRole == 'Doctor';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Appointments'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDoctor)
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const DoctorsListScreen(),
                    ),
                  );
                },
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _loadAppointments,
              child: const Icon(CupertinoIcons.refresh),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoSlidingSegmentedControl<String>(
                groupValue: _selectedFilter,
                children: const {
                  'Upcoming': Text('Upcoming'),
                  'Past': Text('Past'),
                },
                onValueChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFilter = value);
                  }
                },
              ),
            ),
            if (!isDoctor && _selectedFilter == 'Upcoming')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.info_circle_fill,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap the + button to book an appointment with a doctor',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Consumer<AppointmentProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.error!,
                            style: const TextStyle(color: CupertinoColors.systemRed),
                          ),
                          const SizedBox(height: 16),
                          CupertinoButton(
                            onPressed: _loadAppointments,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredAppointments = _getFilteredAppointments(provider.appointments);

                  if (filteredAppointments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No ${_selectedFilter.toLowerCase()} appointments',
                            style: const TextStyle(color: CupertinoColors.systemGrey),
                          ),
                          if (!isDoctor && _selectedFilter == 'Upcoming')
                            CupertinoButton(
                              child: const Text('Book an Appointment'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => const DoctorsListScreen(),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = filteredAppointments[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          isDoctor
                                              ? appointment.patientImageUrl
                                              : appointment.doctorImageUrl,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isDoctor
                                              ? appointment.patientName
                                              : appointment.doctorName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _dateFormat.format(appointment.dateTime),
                                          style: const TextStyle(
                                            color: CupertinoColors.systemGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _timeFormat.format(appointment.dateTime),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(appointment.status),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _getStatusColor(appointment.status),
                                          ),
                                        ),
                                        child: Text(
                                          appointment.status,
                                          style: const TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (appointment.notes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  appointment.notes,
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ),
                            _buildAppointmentFiles(appointment),
                            _buildAppointmentActions(appointment, isDoctor),
                          ],
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
    );
  }
}
