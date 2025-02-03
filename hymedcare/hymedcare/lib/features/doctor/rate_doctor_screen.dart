import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../model/userModel.dart';

class RateDoctorScreen extends StatefulWidget {
  final UserModel doctor;

  const RateDoctorScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<RateDoctorScreen> createState() => _RateDoctorScreenState();
}

class _RateDoctorScreenState extends State<RateDoctorScreen> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<HymedCareAuthProvider>(context, listen: false);
      await authProvider.rateDoctorAndUpdateAverage(
        doctorId: widget.doctor.uid,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to submit rating: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Rate Dr. ${widget.doctor.firstName}'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Doctor Info
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: widget.doctor.profilePicture != null
                        ? DecorationImage(
                            image: NetworkImage(widget.doctor.profilePicture!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.doctor.profilePicture == null
                      ? const Icon(
                          CupertinoIcons.person_fill,
                          size: 40,
                          color: CupertinoColors.systemGrey,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${widget.doctor.firstName} ${widget.doctor.lastName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.doctor.specialization ?? 'General Practitioner',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      if (widget.doctor.rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.star_fill,
                              size: 16,
                              color: CupertinoColors.systemYellow,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.doctor.rating!.toStringAsFixed(1)} (${widget.doctor.reviewCount ?? 0} reviews)',
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Rating Section
            const Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starValue.toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      _rating >= starValue
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      size: 40,
                      color: _rating >= starValue
                          ? CupertinoColors.systemYellow
                          : CupertinoColors.systemGrey,
                      weight:  2.0,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Comment Section
            const Text(
              'Your Comment (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _commentController,
              placeholder: 'Write your experience with the doctor...',
              maxLines: 4,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            CupertinoButton.filled(
              onPressed: _isSubmitting ? null : _submitRating,
              child: _isSubmitting
                  ? const CupertinoActivityIndicator()
                  : const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
