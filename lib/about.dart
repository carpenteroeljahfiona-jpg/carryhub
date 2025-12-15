import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AboutCreatorsPage();
  }
}

class AboutCreatorsPage extends StatelessWidget {
  const AboutCreatorsPage({Key? key}) : super(key: key);

  final List<Map<String, String>> creators = const [
    {
      'firstName': 'Eljah Fiona',
      'lastName': 'P. Carpentero',
      'role': 'Frontend Developer',
      'image': '', // Add actual image URLs here if available
    },
    {
      'firstName': 'Mer Antoneth',
      'lastName': 'G. Gripo',
      'role': 'Backend Developer',
      'image': '',
    },
    {
      'firstName': 'Crystel Joyce',
      'lastName': 'S. Acino',
      'role': 'Backend Developer',
      'image': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            // Pop back to home page
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'About the Creators',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1.5),
                blurRadius: 3,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDDE5B6), Color(0xFFA3C97B), Color(0xFF5FA153)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Main content container
              Expanded(
                child: Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFFDF5),
                        Color.fromARGB(255, 231, 237, 225),
                        Color.fromARGB(255, 255, 253, 248),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(80),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title section
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 24.0,
                          top: 30,
                          bottom: 10,
                        ),
                        child: Text(
                          'Meet the Team',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          bottom: 20,
                        ),
                        child: Text(
                          '3rd Year in Bachelor of Science in Information Technology',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      // Creators list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: creators.length,
                          itemBuilder: (context, index) {
                            final creator = creators[index];
                            return _buildCreatorCard(creator);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorCard(Map<String, String> creator) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 235, 243, 197),
            Color.fromARGB(255, 204, 233, 172),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF2C2C2C).withOpacity(0.4),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2C2C2C).withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF4CAF50).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: creator['image']!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      creator['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey[600],
                        );
                      },
                    ),
                  )
                : Icon(Icons.person, size: 40, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),

          // Creator information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Full name
                Text(
                  '${creator['firstName']} ${creator['lastName']}',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Role with badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    creator['role']!,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
