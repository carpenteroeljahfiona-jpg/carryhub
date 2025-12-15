import 'package:carryhub/commission.dart';
import 'package:carryhub/post.dart';
import 'package:carryhub/profile_posts.dart';
import 'package:carryhub/about.dart';
import 'package:carryhub/search.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carryhub/feed_profile.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "User";
  String? userImageUrl;
  String? currentUserId;
  String selectedCategory = "All";
  bool _isLoadingUser = true;

  final List<String> categories = [
    "All",
    "📖Academics",
    "💻Coding",
    "🎨Art",
    "📈Business",
    "💵Marketing",
    "🎬Film",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        currentUserId = user.uid;

        // First, try to get data from Firestore
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          // User document exists in Firestore
          final data = docSnapshot.data()!;
          setState(() {
            username = data['username'] ?? user.displayName ?? 'User';
            userImageUrl = data['photoUrl'] ?? user.photoURL;
            _isLoadingUser = false;
          });
        } else {
          // User document doesn't exist, use Firebase Auth data
          // and optionally create/update Firestore document
          setState(() {
            username = user.displayName ?? 'User';
            userImageUrl = user.photoURL;
            _isLoadingUser = false;
          });

          // Optional: Create/update user document in Firestore
          // This ensures Google sign-in users have a Firestore profile
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'username': user.displayName ?? 'User',
                'photoUrl': user.photoURL,
                'email': user.email,
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        }
      } else {
        setState(() {
          username = 'User';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');

      // Fallback to Firebase Auth data if Firestore fails
      final User? user = FirebaseAuth.instance.currentUser;
      setState(() {
        if (user != null) {
          currentUserId = user.uid;
          username = user.displayName ?? 'User';
          userImageUrl = user.photoURL;
        } else {
          username = 'User';
        }
        _isLoadingUser = false;
      });
    }
  }

  void _showNotifications() {
    if (currentUserId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Mark all as read
                        final notifications = await FirebaseFirestore.instance
                            .collection('notifications')
                            .where('userId', isEqualTo: currentUserId)
                            .where('read', isEqualTo: false)
                            .get();

                        for (var doc in notifications.docs) {
                          await doc.reference.update({'read': true});
                        }
                      },
                      child: Text(
                        'Mark all read',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              // Notifications list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('userId', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('Notification error: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error loading notifications',
                              style: TextStyle(fontFamily: 'Urbanist'),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50),
                        ),
                      );
                    }

                    final notifications = snapshot.data?.docs ?? [];

                    // Sort notifications manually (newest first)
                    notifications.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['createdAt'] as Timestamp?;
                      final bTime = bData['createdAt'] as Timestamp?;

                      // Handle null timestamps (put them at the end)
                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;

                      return bTime.compareTo(aTime); // Descending order
                    });

                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final doc = notifications[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildNotificationItem(doc.id, data);
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

  Widget _buildNotificationItem(
    String notificationId,
    Map<String, dynamic> data,
  ) {
    final bool isRead = data['read'] ?? false;
    final String message = data['message'] ?? '';
    final String type = data['type'] ?? '';
    final Timestamp? createdAt = data['createdAt'];
    final String? commenterId = data['commenterId'];
    final String? commenterName = data['commenterName'];
    final String? commenterImage = data['commenterImage'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Color(0xFFE8F5E9),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              type == 'comment_accepted'
                  ? Icons.check_circle
                  : Icons.notifications,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          // Message and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (createdAt != null) ...[
                  SizedBox(height: 4),
                  Text(
                    _formatTimestamp(createdAt),
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                // Action buttons for comment_accepted notifications
                if (type == 'comment_accepted' && !isRead) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      // Accept button
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Mark as read
                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .doc(notificationId)
                              .update({'read': true});

                          // Navigate to commenter's profile
                          if (commenterId != null) {
                            Navigator.pop(context); // Close notification sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedProfile(
                                  username: commenterName ?? 'User',
                                  userImageUrl: commenterImage,
                                  userId: commenterId,
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.check, size: 16),
                        label: Text(
                          'View Profile',
                          style: TextStyle(fontFamily: 'Urbanist'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          textStyle: TextStyle(fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Decline button
                      OutlinedButton.icon(
                        onPressed: () async {
                          // Delete the notification
                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .doc(notificationId)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Notification removed'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(Icons.close, size: 16),
                        label: Text(
                          'Dismiss',
                          style: TextStyle(fontFamily: 'Urbanist'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          textStyle: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Unread indicator
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/carryhublogo.png',
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Icon(Icons.image, color: Colors.grey[600]),
              );
            },
          ),
        ),
        title: const Text(
          'CarryHub',
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
        actions: [
          // Notification icon with badge
          if (currentUserId != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: currentUserId)
                  .where('read', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data?.docs.length ?? 0;

                return Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _showNotifications,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDDE5B6),
                  Color(0xFFA3C97B),
                  Color(0xFF5FA153),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              children: [
                // Profile section
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 110, 0, 25),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        backgroundImage: userImageUrl != null
                            ? NetworkImage(userImageUrl!)
                            : null,
                        child: userImageUrl == null
                            ? Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[700],
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePosts(
                                username: username,
                                userImageUrl: userImageUrl,
                                userId: currentUserId ?? '',
                              ),
                            ),
                          );
                        },
                        child: _isLoadingUser
                            ? SizedBox(
                                width: 80,
                                height: 18,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )
                            : Text(
                                'Hi $username',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1.5),
                                      blurRadius: 3,
                                      color: Colors.black38,
                                    ),
                                  ],
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                // White container with content
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
                        // Top categories text
                        const Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 20),
                          child: Text(
                            'Top categories',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Horizontal category scroll
                        Container(
                          height: 30,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  ),
                                  child: Text(categories[index]),
                                ),
                              );
                            },
                          ),
                        ),

                        // Posts list - StreamBuilder to fetch from Firestore
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading posts',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4CAF50),
                                  ),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No posts yet',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              // Filter posts based on category
                              var posts = snapshot.data!.docs;
                              if (selectedCategory != 'All') {
                                String categoryWithoutEmoji = selectedCategory
                                    .replaceAll(RegExp(r'[^\w\s]'), '')
                                    .trim();

                                posts = posts.where((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  List<dynamic> postTags = data['tags'] ?? [];

                                  return postTags.any((tag) {
                                    String tagStr = tag.toString();
                                    return tagStr == selectedCategory ||
                                        tagStr == categoryWithoutEmoji;
                                  });
                                }).toList();
                              }

                              if (posts.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No posts in this category',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 100,
                                ),
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final doc = posts[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  return _buildPostCard(context, data, doc.id);
                                },
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

          // Floating bottom navbar
          Positioned(
            bottom: 13,
            left: 20,
            right: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.home, size: 28),
                          color: const Color(0xFF4CAF50),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, size: 28),
                          color: Colors.grey[600],
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 28),
                          color: Colors.grey[600],
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => About()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostCommissionPage(),
                          ),
                        );
                      },
                      backgroundColor: const Color(0xFF4CAF50),
                      child: const Icon(Icons.add, size: 32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    Map<String, dynamic> post,
    String postId,
  ) {
    List<dynamic> tags = post['tags'] ?? [];
    String displayTags = tags.isNotEmpty ? tags.join(', ') : '';

    // Debug: Print the commission rate to see what we're getting
    print('Post ID: $postId');
    print('Commission Rate from Firestore: ${post['commissionRate']}');
    print('Commission Rate Type: ${post['commissionRate'].runtimeType}');

    // Get commission rate - simplified approach
    String rateDisplay = '';
    final commissionRate = post['commissionRate'];

    if (commissionRate != null) {
      try {
        double rateValue = 0.0;

        if (commissionRate is num) {
          rateValue = commissionRate.toDouble();
        } else if (commissionRate is String) {
          rateValue = double.parse(commissionRate);
        }

        if (rateValue > 0) {
          rateDisplay = '₱${rateValue.toStringAsFixed(2)}';
        }

        print('Rate Display: $rateDisplay');
      } catch (e) {
        print('Error parsing commission rate: $e');
      }
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: post['userImageUrl'] != null
                    ? NetworkImage(post['userImageUrl'])
                    : null,
                child: post['userImageUrl'] == null
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['subject'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayTags,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              // COMMISSION RATE BADGE
              if (rateDisplay.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    rateDisplay,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                color: Colors.grey[700],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommissionPage(
                        postId: postId,
                        postData: {
                          'subject': post['subject'] ?? '',
                          'description': post['description'] ?? '',
                          'tags': post['tags'] ?? [],
                          'username': post['username'] ?? 'User',
                          'userImageUrl': post['userImageUrl'],
                          'uploadedFile': post['uploadedFile'],
                          'userId': post['userId'] ?? '',
                          'createdAt': post['createdAt'],
                          'commissionRate': post['commissionRate'],
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post['description'] ?? '',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
