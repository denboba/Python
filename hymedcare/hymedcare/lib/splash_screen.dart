import 'package:flutter/cupertino.dart';
import 'package:hymedcare/auth/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _splashData = [
    {
      "image": "assets/images/hymedcare-logo.png",
      "title": "Welcome to HymedCare",
      "subtitle": "Your health, our priority. Access top doctors instantly."
    },
    {
      "image": "assets/images/sp1.png",
      "title": "Telemedicine Services",
      "subtitle": "Get consultations from anywhere, anytime."
    },
    {
      "image": "assets/images/sp2.png",
      "title": "Monitor Your Health",
      "subtitle": "Track your vitals and medical records in one place."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // PageView for splash screens
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _splashData.length,
            itemBuilder: (context, index) {
              return _buildSplashPage(
                image: _splashData[index]['image']!,
                title: _splashData[index]['title']!,
                subtitle: _splashData[index]['subtitle']!,
              );
            },
          ),
          // Page Indicator and Get Started Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildPageIndicator(),
                const SizedBox(height: 16),
                if (_currentPage == _splashData.length - 1)
                  CupertinoButton.filled(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                          const TelemedLoginPage(),
                        ),
                      );
                    },
                    child: const Text("Get Started"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashPage(
      {required String image, required String title, required String subtitle}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(image, height: 200),
        const SizedBox(height: 40),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            // use theme color
            color: CupertinoColors.systemGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _splashData.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 20 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey4,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
