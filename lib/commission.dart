import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carryhub/feed_profile.dart';

class Commission extends StatelessWidget {
  const Commission({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
    );
  }
}

class CommissionPage extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const CommissionPage({Key? key, required this.postId, required this.postData})
    : super(key: key);

  @override
  State<CommissionPage> createState() => _CommissionPageState();
}

class _CommissionPageState extends State<CommissionPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSendingComment = false;
  String? _pendingCommentId;
  String? _postAuthorUsername;
  String? _postAuthorImageUrl;
  String? _postAuthorUserId;
  bool _isLoadingPostAuthor = true;

  @override
  void initState() {
    super.initState();
    _fetchPostAuthorInfo();
  }

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

  Future<void> _fetchPostAuthorInfo() async {
    try {
      final String? postUserId = widget.postData['userId'];

      if (postUserId == null || postUserId.isEmpty) {
        setState(() {
          _postAuthorUsername = widget.postData['username'] ?? 'Anonymous User';
          _postAuthorImageUrl = widget.postData['userImageUrl'];
          _postAuthorUserId = null;
          _isLoadingPostAuthor = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(postUserId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          _postAuthorUsername =
              userData?['username']?.toString().trim().isNotEmpty == true
              ? userData!['username']
              : (userData?['name']?.toString().trim().isNotEmpty == true
                    ? userData!['name']
                    : widget.postData['username'] ?? 'Anonymous User');

          _postAuthorImageUrl =
              userData?['photoUrl'] ?? widget.postData['userImageUrl'];
          _postAuthorUserId = postUserId;
          _isLoadingPostAuthor = false;
        });
      } else {
        setState(() {
          _postAuthorUsername = widget.postData['username'] ?? 'Anonymous User';
          _postAuthorImageUrl = widget.postData['userImageUrl'];
          _postAuthorUserId = postUserId;
          _isLoadingPostAuthor = false;
        });
      }
    } catch (e) {
      print('Error fetching post author info: $e');
      setState(() {
        _postAuthorUsername = widget.postData['username'] ?? 'Anonymous User';
        _postAuthorImageUrl = widget.postData['userImageUrl'];
        _postAuthorUserId = widget.postData['userId'];
        _isLoadingPostAuthor = false;
      });
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Please log in to comment', isError: true);
      return;
    }

    setState(() => _isSendingComment = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final username = userDoc.exists && userData != null
          ? (userData['username']?.toString().trim().isNotEmpty == true
                ? userData['username']
                : (userData['name']?.toString().trim().isNotEmpty == true
                      ? userData['name']
                      : (user.displayName?.trim().isNotEmpty == true
                            ? user.displayName
                            : user.email?.split('@')[0] ?? 'Anonymous User')))
          : (user.displayName?.trim().isNotEmpty == true
                ? user.displayName
                : user.email?.split('@')[0] ?? 'Anonymous User');

      final String? userImageUrl = userDoc.exists && userData != null
          ? (userData['photoUrl'] as String?)
          : user.photoURL;

      final docRef = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
            'userId': user.uid,
            'username': username,
            'userImageUrl': userImageUrl,
            'comment': _commentController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      setState(() {
        _pendingCommentId = docRef.id;
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      print('Error posting comment: $e');
      _showMessage('Failed to post comment', isError: true);
      setState(() => _isSendingComment = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Urbanist')),
        backgroundColor: isError ? Colors.red[600] : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    List<dynamic> tags = widget.postData['tags'] ?? [];
    String displayTags = tags.isNotEmpty
        ? tags.map((tag) => '#$tag').join(' ')
        : '';

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
                    // Post header - CLICKABLE
                    _isLoadingPostAuthor
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[300],
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 80,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CLICKABLE PROFILE IMAGE
                              GestureDetector(
                                onTap: () {
                                  if (_postAuthorUserId != null) {
                                    _navigateToProfile(
                                      _postAuthorUserId!,
                                      _postAuthorUsername ?? 'Anonymous User',
                                      _postAuthorImageUrl,
                                    );
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    backgroundImage: _postAuthorImageUrl != null
                                        ? NetworkImage(_postAuthorImageUrl!)
                                        : null,
                                    child: _postAuthorImageUrl == null
                                        ? Icon(
                                            Icons.person,
                                            size: 30,
                                            color: Colors.grey[600],
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // CLICKABLE USERNAME
                                    GestureDetector(
                                      onTap: () {
                                        if (_postAuthorUserId != null) {
                                          _navigateToProfile(
                                            _postAuthorUserId!,
                                            _postAuthorUsername ??
                                                'Anonymous User',
                                            _postAuthorImageUrl,
                                          );
                                        }
                                      },
                                      child: Text(
                                        _postAuthorUsername ?? 'Anonymous User',
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
                                      displayTags,
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          0,
                                          161,
                                          3,
                                        ),
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      widget.postData['subject'] ?? '',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 18,
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
                      widget.postData['description'] ?? '',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Divider(color: Colors.grey[600], thickness: 1),
                    SizedBox(height: screenHeight * 0.01),

                    Text(
                      'Comments',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
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

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.postId)
                          .collection('comments')
                          .orderBy('createdAt', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading comments',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                color: Colors.red,
                              ),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          );
                        }

                        if (_pendingCommentId != null && snapshot.hasData) {
                          final commentExists = snapshot.data!.docs.any(
                            (doc) => doc.id == _pendingCommentId,
                          );

                          if (commentExists) {
                            Future.delayed(Duration.zero, () {
                              if (mounted && _pendingCommentId != null) {
                                _showMessage(
                                  'Comment posted successfully!',
                                  isError: false,
                                );
                                setState(() {
                                  _pendingCommentId = null;
                                  _isSendingComment = false;
                                });
                              }
                            });
                          }
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No comments yet. Be the first to comment!',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            final commentData =
                                doc.data() as Map<String, dynamic>;
                            return _buildComment(screenWidth, commentData);
                          }).toList(),
                        );
                      },
                    ),

                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        enabled: !_isSendingComment,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(
                            fontFamily: 'Urbanist',
                            color: Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontFamily: 'Urbanist',
                        ),
                        maxLines: 3,
                        minLines: 1,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    _isSendingComment
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: Icon(Icons.send, color: Color(0xFF4CAF50)),
                            onPressed: _sendComment,
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

  Widget _buildComment(double screenWidth, Map<String, dynamic> commentData) {
    final String userId = commentData['userId'] ?? '';
    final String username = commentData['username'] ?? 'Anonymous User';
    final String? userImageUrl = commentData['userImageUrl'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
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
            color: Color(0xFF2C2C2C).withOpacity(0.4),
            width: 0.5,
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
            // CLICKABLE PROFILE IMAGE
            GestureDetector(
              onTap: () {
                if (userId.isNotEmpty) {
                  _navigateToProfile(userId, username, userImageUrl);
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: userImageUrl != null
                    ? NetworkImage(userImageUrl)
                    : null,
                child: userImageUrl == null
                    ? Icon(Icons.person, size: 22, color: Colors.grey[600])
                    : null,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CLICKABLE USERNAME
                  GestureDetector(
                    onTap: () {
                      if (userId.isNotEmpty) {
                        _navigateToProfile(userId, username, userImageUrl);
                      }
                    },
                    child: Text(
                      username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Urbanist',
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    commentData['comment'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Urbanist',
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
