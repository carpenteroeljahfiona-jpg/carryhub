import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carryhub/feed_profile.dart'; // ADD THIS IMPORT

class CommissionOwner extends StatelessWidget {
  const CommissionOwner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const CommissionOwnerPage(),
    );
  }
}

class CommissionOwnerPage extends StatefulWidget {
  final String? postId;
  final Map<String, dynamic>? postData;
  final String? username;
  final String? userImageUrl;
  final String? currentUserId;

  const CommissionOwnerPage({
    super.key,
    this.postId,
    this.postData,
    this.username,
    this.userImageUrl,
    this.currentUserId,
  });

  @override
  State<CommissionOwnerPage> createState() => _CommissionOwnerPageState();
}

class _CommissionOwnerPageState extends State<CommissionOwnerPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _acceptComment(
    String commentId,
    String commenterId,
    String commenterName,
    String commenterImageUrl,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .update({'status': 'accepted'});

      final postOwnerId = widget.postData?['userId'];
      if (postOwnerId != null && postOwnerId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance.collection('notifications').add({
            'userId': postOwnerId,
            'type': 'comment_accepted',
            'message': 'Your post received a comment from $commenterName',
            'postId': widget.postId,
            'commentId': commentId,
            'commenterId': commenterId,
            'commenterName': commenterName,
            'commenterImage': commenterImageUrl,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (notifError) {
          print('Error sending notification to post owner: $notifError');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accepted comment from $commenterName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ADD THIS NEW METHOD
  void _navigateToProfile(String userId, String username, String? imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedProfile(
          username: username,
          userImageUrl: imageUrl,
          userId: userId,
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final subject = widget.postData?['subject'] ?? 'No Subject';
    final description =
        widget.postData?['description'] ?? 'No description available';
    final tags = (widget.postData?['tags'] as List<dynamic>?)?.join(', ') ?? '';
    // ignore: unused_local_variable
    final uploadedFile = widget.postData?['uploadedFile'];
    final createdAt = widget.postData?['createdAt'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDDE5B6),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Commission',
          style: TextStyle(fontFamily: 'Urbanist', fontSize: 20),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to post owner's profile
                            final postOwnerId = widget.postData?['userId'];
                            if (postOwnerId != null) {
                              _navigateToProfile(
                                postOwnerId,
                                widget.username ?? 'Unknown User',
                                widget.userImageUrl,
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                              ),
                              child:
                                  widget.userImageUrl != null &&
                                      widget.userImageUrl!.isNotEmpty
                                  ? Image.network(
                                      widget.userImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                size: 30,
                                              ),
                                    )
                                  : const Icon(Icons.person, size: 30),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigate to post owner's profile
                                  final postOwnerId =
                                      widget.postData?['userId'];
                                  if (postOwnerId != null) {
                                    _navigateToProfile(
                                      postOwnerId,
                                      widget.username ?? 'Unknown User',
                                      widget.userImageUrl,
                                    );
                                  }
                                },
                                child: Text(
                                  widget.username ?? 'Unknown User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    fontFamily: 'Urbanist',
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1.5),
                                        blurRadius: 3,
                                        color: Colors.black38,
                                      ),
                                    ],
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tags.isNotEmpty ? '#$tags' : '#general',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 161, 3),
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      subject,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    if (createdAt != null)
                      Text(
                        _formatTimestamp(createdAt),
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    SizedBox(height: screenHeight * 0.01),

                    Divider(color: Colors.grey[600], thickness: 1),
                    SizedBox(height: screenHeight * 0.01),

                    if (widget.postId != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.postId)
                            .collection('comments')
                            .orderBy('createdAt', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Error loading comments: ${snapshot.error}',
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final comments = snapshot.data?.docs ?? [];

                          if (comments.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: comments.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return _buildComment(screenWidth, doc.id, data);
                            }).toList(),
                          );
                        },
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

  Widget _buildComment(
    double screenWidth,
    String commentId,
    Map<String, dynamic> commentData,
  ) {
    final username = commentData['username'] ?? 'Anonymous';
    final text = commentData['comment'] ?? '';
    final userImageUrl = commentData['userImageUrl'] ?? '';
    final userId = commentData['userId'] ?? '';
    final status = commentData['status'] ?? 'pending';
    final createdAt = commentData['createdAt'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: status == 'accepted'
                ? [
                    Color.fromARGB(255, 233, 255, 233),
                    Color.fromARGB(255, 215, 255, 215),
                  ]
                : [
                    Color.fromARGB(255, 251, 255, 233),
                    Color.fromARGB(255, 236, 255, 215),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: status == 'accepted'
                ? Color(0xFF5FA153).withOpacity(0.6)
                : Color(0xFF2C2C2C).withOpacity(0.4),
            width: status == 'accepted' ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2C2C2C).withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(4, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image - Clickable
            GestureDetector(
              onTap: () {
                if (userId.isNotEmpty) {
                  _navigateToProfile(userId, username, userImageUrl);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[400],
                  child: userImageUrl.isNotEmpty
                      ? Image.network(
                          userImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 22),
                        )
                      : const Icon(Icons.person, size: 22),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  if (userId.isNotEmpty) {
                                    _navigateToProfile(
                                      userId,
                                      username,
                                      userImageUrl,
                                    );
                                  }
                                },
                                child: Text(
                                  username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (status == 'accepted') ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF5FA153),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Accepted',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (status != 'accepted')
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_horiz,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          onSelected: (value) {
                            if (value == 'accept') {
                              _acceptComment(
                                commentId,
                                userId,
                                username,
                                userImageUrl,
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'accept',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Accept',
                                    style: TextStyle(fontFamily: 'Urbanist'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  SizedBox(height: 6),
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),

                  if (createdAt != null) ...[
                    SizedBox(height: 6),
                    Text(
                      _formatTimestamp(createdAt),
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
