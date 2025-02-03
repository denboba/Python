import 'package:flutter/cupertino.dart';
import 'package:hymedcare/constants/services.dart';

class ServicesPage extends StatelessWidget {
  final List<Map<String, String>> services = ourServices;

  ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Our Services", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Section: Telehealth Services
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Telehealth Services",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Telehealth encompasses a wide range of medical specialties and services "
                          "delivered remotely through telecommunications technology. From diagnosing and treating "
                          "various conditions to providing surgical interventions and critical care, telehealth "
                          "revolutionizes healthcare delivery by enabling access to medical expertise and services "
                          "regardless of geographical barriers, enhancing patient outcomes and convenience.",
                      style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showServiceDetails(context, service),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          service["avatarPic"]!.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              service["avatarPic"]!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey5,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.doc_plaintext,
                              size: 28,
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service["name"]!,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  service["description"]!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(BuildContext context, Map<String, String> service) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(service["name"]!),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.clear, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                service["avatarPic"]!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(service["avatarPic"]!, width: 120, height: 120, fit: BoxFit.cover),
                )
                    : const Icon(CupertinoIcons.doc_plaintext, size: 80, color: CupertinoColors.systemBlue),
                const SizedBox(height: 16),
                Text(
                  service["name"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  service["description"]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
                ),
                const SizedBox(height: 30),
                CupertinoButton.filled(
                  child: const Text("Close"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
