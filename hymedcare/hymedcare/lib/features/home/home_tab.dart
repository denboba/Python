import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:hymedcare/screens/services.dart';
import 'package:hymedcare/widgets/avatar.dart';
import 'package:provider/provider.dart';
import '../../constants/services.dart';
import '../articles/screens/article_list_screen.dart';
import '../../model/userModel.dart';
import '../../provider/auth_provider.dart';
import '../doctor/rate_doctor_screen.dart';
import '../articles/provider/article_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool isLoading = true;
  List<Map<String, String>> services = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ArticleProvider>().loadArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);
    final authProvider = Provider.of<HymedCareAuthProvider>(context);
    final currentUser = authProvider.currentUser;
    services = ourServices;

    // TODO REMOVE
    final random = Random();

    return CupertinoPageScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        currentUser != null
                            ? 'Welcome, ${currentUser.role == 'Doctor' ? 'Dr. ' : ''}${currentUser.firstName} ${currentUser.lastName}'
                            : 'Welcome to HymedCare',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        currentUser != null && currentUser.role == 'Doctor'
                            ? "Reach out to your patients"
                            : "Find your desired service",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    CupertinoSearchTextField(
                      placeholder: 'Search for doctors, articles...',
                      style: const TextStyle(fontSize: 16),
                      onChanged: (value) {
                        // TODO: Implement search functionality
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 100,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ServicesCard(service: service),
                      );
                    }),
              ), // Top Rated Articles Section
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Rated Articles',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Text('View All'),
                          onPressed: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ArticleListScreen()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: articleProvider.articles.length,
                  itemBuilder: (context, index) {
                    final article = articleProvider.articles[index];
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          //TODO: Fix this
                          // image: article.imageUrl != null
                          //     ? NetworkImage(article.imageUrl)
                          //     : const AssetImage('assets/images/hymedcare-logo.png') as ImageProvider,
                          image: const AssetImage(
                              'assets/images/hymedcare-logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            // check the theme color for the gradient
                            colors: [
                              // use theme colors
                              // TODO: Fix this
                              CupertinoColors.systemBackground.withOpacity(0.1),
                              CupertinoColors.systemBackground.withOpacity(0.8),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CupertinoAvatar(
                                  name: "assets/images/hymedcare-logo.png",
                                  //TODO: Fix this
                                  //  name: article.authorImageUrl,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    article.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Top Rated Doctors Section
              _buildTopDoctorsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopDoctorsSection() {
    final authProvider = Provider.of<HymedCareAuthProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Top Doctors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: StreamBuilder<List<UserModel>>(
            stream: authProvider.getTopDoctors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final doctors = snapshot.data ?? [];
              if (doctors.isEmpty) {
                return const Center(child: Text('No doctors available'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return GestureDetector(
                    onTap: () {
                      final currentUser = authProvider.currentUser;
                      if (currentUser != null &&
                          currentUser.role == 'Patient') {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                RateDoctorScreen(doctor: doctor),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              image: DecorationImage(
                                // TODO: Fix this
                                // image: doctor.profilePicture != null
                                //     ? NetworkImage(doctor.profilePicture!)
                                //     : const AssetImage('assets/images/hymedcare-logo.png')
                                //         as ImageProvider,
                                image: AssetImage(
                                    'assets/images/d${(index + 1) % 4 + 1}.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. ${doctor.firstName} ${doctor.lastName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.specialization ??
                                      'General Practitioner',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.star_fill,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      doctor.rating?.toStringAsFixed(1) ??
                                          'New',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (doctor.reviewCount != null) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${doctor.reviewCount})',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ServicesCard extends StatelessWidget {
  final Map<String, String> service;
  const ServicesCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>  ServicesPage()
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemBlue.withOpacity(0.8),
                      CupertinoColors.systemBlue,
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.white,
                    image: DecorationImage(
                      //TODO: Fix this
                      image:
                          const AssetImage('assets/images/hymedcare-logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service["name"]!.length > 14
                    ? "${service["name"]!.substring(0, 11)}..."
                    : service["name"]!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ));
  }
}
