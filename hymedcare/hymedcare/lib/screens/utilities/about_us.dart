import 'package:flutter/cupertino.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('About Us'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // About Us Section
            _buildSection(
              'About Us',
              'assets/images/about_us.png', // Replace with your image asset
              'HymedCare is the trusted provider of 24/7 virtual healthcare for the mind and body, including urgent care, mental health, preventative, primary and chronic care, with access to Qualified physicians and famous psychologists through a smartphone, tablet, or computer. We are a global network of a qualified and trusted Doctors. Providing 3 type of visits ( clinic, home or video). Beyond this we provide Tele health service, Homecare service , and Medical Travel consultancy. Video Consultation in over 5 languages. ( English, Amharic, Afaan Oromoo, Turkish, Arabic etc.) Founded in 2019, our mission is to improve the world’s health through compassionate care and innovation. We believe that everyone should have instant and affordable access to a doctor, whenever and wherever needed',
            ),
            // Mission Section
            _buildSection(
                'Our Mission',
                'assets/images/our_mission.png', // Replace with your image asset
                '''
              Our mission is to raise the standard of healthcare for everyone. We provide a unique combination of virtual care, navigation, and communities-based healthcare to help organizations and individuals of all types deliver a radically improved healthcare experience to millions of people across the country. Our transformative model is designed to treat people better.

We keep members at the core of every move we make, with our solitary focus on making every interaction with HymedCare feel better. Members will find the HymedCare Health experience to be simpler, more accessible, and of the highest quality. We support every healthcare need with deep expertise and advocacy that elevates the standard of care for all.

For our clients, HymedCare’s integrated and data-driven approach enables higher levels of engagement with industry-leading clinical and financial outcomes.
'''
            ),
            // Vision Section
            _buildSection(
                'Our Vision',
                'assets/images/our_vision.png', // Replace with your image asset
                '''
Our Vision is to provide accessible, cost-effective, and high-quality healthcare services to all individuals, regardless of their location or physical ability. By leveraging technology, healthcare providers from HyMedCare can improve access to care, reduce hospital visits, and enhance the quality of care provided to patients. 

To serve the community from urgent to everyday healthcare, for complex and unique needs, online and in-person. To provide quality clinical expertise nationwide: Access to fully on-staff clinicians, specialists, and in-network doctors no matter where members live. 

Industry-leading outcomes: Driven by integrated delivery models, our services are proven to actually make a positive difference, clinically and financially.
'''
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each section with a title, image, and description
  Widget _buildSection(String title, String imagePath, String description) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath), // Displaying the image
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: CupertinoColors.black,
                fontSize: 16,
              ),
              children: _buildDescription(description),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the description with RichText
  List<TextSpan> _buildDescription(String description) {
    return description.split('\n').map((line) {
      return TextSpan(
        text: '$line\n',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      );
    }).toList();
  }
}