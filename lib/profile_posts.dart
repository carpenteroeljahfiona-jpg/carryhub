import 'package:carryhub/home.dart';
import 'package:carryhub/profile.dart';
import 'package:carryhub/login.dart';
import 'package:carryhub/commission_owner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePosts extends StatefulWidget {
  final String username;
  final String? userImageUrl;
  final String userId;

  const ProfilePosts({
    Key? key,
    required this.username,
    this.userImageUrl,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfilePosts> createState() => _ProfilePostsState();
}

class _ProfilePostsState extends State<ProfilePosts> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;
  bool _isLoading = true;

  // User details
  String displayName = '';
  String department = '';
  String year = '';
  String bio = '';

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _loadUserDetails();
  }

  Future<void> _initializeUser() async {
    setState(() {
      currentUser = _auth.currentUser;
      _isLoading = false;
    });

    if (currentUser != null) {
      print('Current User ID: ${currentUser!.uid}');
      print('Current User Email: ${currentUser!.email}');
    }
  }

  Future<void> _loadUserDetails() async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Debug: Print all user data to see what fields exist
        print('User Data: $userData');

        setState(() {
          displayName = userData['name'] ?? widget.username;
          department = userData['department'] ?? '';

          // Handle year field - it might be a number or string
          var yearData = userData['year'];
          if (yearData != null) {
            if (yearData is int) {
              year = _formatYear(yearData);
            } else {
              year = yearData.toString();
            }
          } else {
            year = '';
          }

          bio = userData['bio'] ?? '';

          print(
            'Loaded - Name: $displayName, Dept: $department, Year: $year, Bio: ${bio.length > 20 ? bio.substring(0, 20) : bio}...',
          );
        });
      } else {
        print('User document does not exist');
        setState(() {
          displayName = widget.username;
        });
      }
    } catch (e) {
      print('Error loading user details: $e');
      setState(() {
        displayName = widget.username;
      });
    }
  }

  String _formatYear(int yearNum) {
    switch (yearNum) {
      case 1:
        return '1st Year';
      case 2:
        return '2nd Year';
      case 3:
        return '3rd Year';
      case 4:
        return '4th Year';
      default:
        return '${yearNum}th Year';
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('posts').doc(postId).delete();

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  const Text('Success'),
                ],
              ),
              content: const Text('Post deleted successfully'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  const Text('Error'),
                ],
              ),
              content: Text('Failed to delete post: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  void _navigateToCommissionOwner(
    String postId,
    Map<String, dynamic> postData,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommissionOwnerPage(
          postId: postId,
          postData: postData,
          username: widget.username,
          userImageUrl: widget.userImageUrl,
          currentUserId: currentUser?.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('No user logged in'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              } else if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [Color(0xFFA3C97B), Color(0xFFDDE5B6), Color(0xFF5FA153)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 70),
            // Profile Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: widget.userImageUrl != null
                            ? NetworkImage(widget.userImageUrl!)
                            : null,
                        child: widget.userImageUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display Name
                            Text(
                              displayName.isNotEmpty
                                  ? displayName
                                  : widget.username,
                              style: const TextStyle(
                                fontSize: 22,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold,
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
                            const SizedBox(height: 4),
                            // Department and Year
                            if (department.isNotEmpty || year.isNotEmpty)
                              Text(
                                [
                                  if (department.isNotEmpty) department,
                                  if (year.isNotEmpty) year,
                                ].join(' • '),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 6),
                            // Bio
                            if (bio.isNotEmpty)
                              Text(
                                bio,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.85),
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tabs for Posts & More
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: const TabBar(
                        labelColor: Colors.green,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.green,
                        tabs: [
                          Tab(text: 'Posts'),
                          Tab(text: 'More'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildPostsTab(),
                          MoreTab(
                            username: widget.username,
                            userImageUrl: widget.userImageUrl,
                            userId: widget.userId,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        print('Connection State: ${snapshot.connectionState}');
        print('Has Data: ${snapshot.hasData}');
        print('Has Error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          print('Number of posts: ${snapshot.data!.docs.length}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading posts',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.post_add,
                  size: 64,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'No posts yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your posts will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final postData = posts[index].data() as Map<String, dynamic>;
            final postId = posts[index].id;
            print('Post $index: $postId - ${postData['subject']}');
            return _buildPostCard(postData, postId);
          },
        );
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, String postId) {
    // Get tags
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

    return GestureDetector(
      onTap: () => _navigateToCommissionOwner(postId, post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 251, 255, 233),
              Color.fromARGB(255, 236, 255, 215),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2C2C2C).withOpacity(0.4),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C2C2C).withOpacity(0.15),
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
                  backgroundColor: Colors.grey[300],
                  backgroundImage: widget.userImageUrl != null
                      ? NetworkImage(widget.userImageUrl!)
                      : null,
                  child: widget.userImageUrl == null
                      ? const Icon(Icons.person, color: Colors.grey, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the actual name
                      Text(
                        displayName.isNotEmpty ? displayName : widget.username,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Subject
                      Text(
                        post['subject'] ?? 'No Subject',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Tags
                      Text(
                        displayTags.isEmpty ? 'No tags' : displayTags,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                // Commission Rate Badge
                if (rateDisplay.isNotEmpty) ...[
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rateDisplay,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  tooltip: 'Delete post',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    _deletePost(postId);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              post['description'] ?? 'No description',
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color.fromARGB(255, 75, 55, 20),
              ),
            ),
            // Timestamp
            if (post['createdAt'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _formatTimestamp(post['createdAt']),
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return '';
    }

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
}

class MoreTab extends StatelessWidget {
  final String username;
  final String? userImageUrl;
  final String userId;

  const MoreTab({
    Key? key,
    required this.username,
    this.userImageUrl,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDE5B6), Color(0xFFA3C97B), Color(0xFF5FA153)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Unable to load user details',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final bio = userData['bio'] ?? 'No bio available';
          final phone = userData['phone'] ?? 'Not provided';
          final messenger = userData['messenger'] ?? 'Not provided';
          final joinedAt = userData['createdAt'] as Timestamp?;

          String formattedDate = 'Unknown';
          if (joinedAt != null) {
            final date = joinedAt.toDate();
            formattedDate =
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Me',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bio,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: Color(0xFF4A4A4A),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Please Contact me at:',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 18,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Phone: $phone',
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 13,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.message,
                            size: 18,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Messenger: $messenger',
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 13,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Joined at:',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 13,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
