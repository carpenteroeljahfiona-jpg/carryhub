import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'commission.dart'; // Import your commission page

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Academics",
    "Coding",
    "Art",
    "Business",
    "Marketing",
    "Film",
  ];

  // Cache for usernames to avoid repeated queries
  final Map<String, String> _usernameCache = {};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Search',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content container
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
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search posts, tags, or users...',
                            hintStyle: TextStyle(
                              fontFamily: 'Urbanist',
                              color: Colors.grey[400],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        searchController.clear();
                                        searchQuery = "";
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: Color.fromARGB(74, 71, 49, 35),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color(0xFF473123),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      // Category filter
                      Container(
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final isSelected =
                                selectedCategory == categories[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedCategory = categories[index];
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey[200],
                                  foregroundColor: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  categories[index],
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Search results from Firestore
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 80,
                                      color: Colors.red[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error loading posts',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF4CAF50),
                                ),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 80,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No posts yet',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 18,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Filter posts based on search query and category
                            final allPosts = snapshot.data!.docs;
                            final filteredPosts = allPosts.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              // Category filter
                              if (selectedCategory != 'All') {
                                final tags =
                                    data['tags'] as List<dynamic>? ?? [];
                                final hasCategory = tags.any(
                                  (tag) =>
                                      tag.toString().toLowerCase() ==
                                      selectedCategory.toLowerCase(),
                                );
                                if (!hasCategory) return false;
                              }

                              // Search query filter
                              if (searchQuery.isNotEmpty) {
                                final subject = (data['subject'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final description = (data['description'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final tags =
                                    data['tags'] as List<dynamic>? ?? [];
                                final tagsString = tags.join(' ').toLowerCase();
                                final query = searchQuery.toLowerCase();

                                return subject.contains(query) ||
                                    description.contains(query) ||
                                    tagsString.contains(query);
                              }

                              return true;
                            }).toList();

                            // Show initial state or results
                            if (searchQuery.isEmpty &&
                                selectedCategory == 'All') {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 80,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Start searching...',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 18,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Find posts, tags, or users',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (filteredPosts.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 80,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No results found',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 18,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try a different search',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              children: [
                                // Results count
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${filteredPosts.length} results found',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                // Results list
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    itemCount: filteredPosts.length,
                                    itemBuilder: (context, index) {
                                      final doc = filteredPosts[index];
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      return _buildSearchResultCard(
                                        context,
                                        doc.id,
                                        data,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
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

  Widget _buildSearchResultCard(
    BuildContext context,
    String postId,
    Map<String, dynamic> data,
  ) {
    // Get all tags
    final tags = data['tags'] as List<dynamic>? ?? [];
    final userId = data['userId'] as String?;

    return GestureDetector(
      onTap: () {
        // Navigate to CommissionPage with post data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CommissionPage(postId: postId, postData: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              color: Color(0xFF2C2C2C).withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User avatar - fetch from user document
                FutureBuilder<DocumentSnapshot>(
                  future: userId != null
                      ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get()
                      : null,
                  builder: (context, userSnapshot) {
                    String? imageUrl;
                    if (userSnapshot.hasData && userSnapshot.data != null) {
                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>?;
                      imageUrl = userData?['imageUrl'];
                    }
                    return CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl == null
                          ? Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 20,
                            )
                          : null,
                    );
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['subject'] ?? 'No subject',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Fetch username from user document
                      FutureBuilder<String>(
                        future: _fetchUsername(userId),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? 'Loading...',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Display all tags
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag.toString(),
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              data['description'] ?? 'No description',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to fetch username from Firestore
  Future<String> _fetchUsername(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return 'Anonymous';
    }

    // Check cache first
    if (_usernameCache.containsKey(userId)) {
      return _usernameCache[userId]!;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // ignore: unnecessary_cast
        final userData = userDoc.data() as Map<String, dynamic>?;
        final username = userData?['username'] as String? ?? 'Anonymous';

        // Cache the username
        _usernameCache[userId] = username;
        return username;
      }
      return 'Anonymous';
    } catch (e) {
      print('Error fetching username: $e');
      return 'Anonymous';
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
