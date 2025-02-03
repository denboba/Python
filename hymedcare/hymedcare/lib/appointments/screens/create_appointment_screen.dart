import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';
import '../../provider/auth_provider.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorImageUrl;

  const CreateAppointmentScreen({
    required this.doctorId,
    required this.doctorName,
    required this.doctorImageUrl,
    super.key,
  });

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  late DateTime _selectedDate;
  DateTime? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  List<DateTime> _availableTimeSlots = [];
  bool _isLoading = false;
  final List<String> _selectedFiles = []; // URLs of selected files

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    _loadAvailableTimeSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableTimeSlots() async {
    setState(() => _isLoading = true);
    
    final slots = await Provider.of<AppointmentProvider>(context, listen: false)
        .getAvailableTimeSlots(widget.doctorId, _selectedDate);
    
    setState(() {
      _availableTimeSlots = slots;
      _selectedTime = null;
      _isLoading = false;
    });
  }

  void _showDatePicker() {
    final now = DateTime.now();
    final minimumDate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate.isBefore(minimumDate) ? minimumDate : _selectedDate,
                minimumDate: minimumDate,
                maximumDate: DateTime.now().add(const Duration(days: 30)),
                onDateTimeChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.pop(context);
                _loadAvailableTimeSlots();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    // TODO: Implement file picker
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

  Future<void> _createAppointment() async {
    if (_selectedTime == null) {
      _showError('Please select an appointment time');
      return;
    }

    final currentUser = Provider.of<HymedCareAuthProvider>(context, listen: false).currentUser!;
    
    try {
      setState(() => _isLoading = true);
      
      await Provider.of<AppointmentProvider>(context, listen: false)
          .createAppointment(
            doctorId: widget.doctorId,
            doctorName: widget.doctorName,
            doctorImageUrl: widget.doctorImageUrl,
            patientId: currentUser.uid,
            patientName: '${currentUser.firstName} ${currentUser.lastName}',
            patientImageUrl: currentUser.profilePicture ?? '',
            dateTime: _selectedTime!,
            notes: _notesController.text,
            patientFiles: _selectedFiles,
          );

      if (mounted) {
        Navigator.pop(context);
        _showSuccess('Appointment request sent successfully');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to create appointment: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Book Appointment'),
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _createAppointment,
                child: const Text('Book'),
              ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Doctor Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(widget.doctorImageUrl),
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
                          widget.doctorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Select a date and time for your appointment',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time Slots
            const Text(
              'Available Time Slots',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CupertinoActivityIndicator())
            else if (_availableTimeSlots.isEmpty)
              const Center(
                child: Text(
                  'No available time slots for this date',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTimeSlots.map((time) {
                  final isSelected = _selectedTime == time;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTime = time);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: isSelected
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Notes
            CupertinoTextField(
              controller: _notesController,
              placeholder: 'Add notes (optional)',
              maxLines: 4,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // File Attachments
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add any relevant medical documents or test results',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedFiles.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedFiles
                        .map((file) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    file.split('/').last,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedFiles.remove(file);
                                      });
                                    },
                                    child: const Icon(
                                      CupertinoIcons.xmark_circle_fill,
                                      color: CupertinoColors.systemGrey,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 16),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _pickFiles,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: CupertinoColors.activeBlue,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          CupertinoIcons.doc_fill,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text('Add Files'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
