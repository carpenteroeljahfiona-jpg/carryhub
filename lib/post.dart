import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostCommissionPage extends StatefulWidget {
  const PostCommissionPage({Key? key}) : super(key: key);

  @override
  State<PostCommissionPage> createState() => _PostCommissionPageState();
}

class _PostCommissionPageState extends State<PostCommissionPage> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController commissionRateController =
      TextEditingController();

  final List<String> selectedTags = [];
  final List<String> availableTags = [
    'Academics',
    'Coding',
    'Art',
    'Business',
    'Marketing',
    'Film',
  ];

  bool _isLoading = false;

  // Default placeholder image
  final String defaultImage =
      'https://via.placeholder.com/800x600/E0E0E0/757575?text=No+Image';

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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Commission',
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
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDDE5B6), // soft light green
                  Color(0xFFA3C97B), // medium green
                  Color(0xFF5FA153), // darker green
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              children: [
                // Top spacing for AppBar
                SizedBox(height: 100),

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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // Subject Field
                          _buildSectionTitle('Subject'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: subjectController,
                            hint: 'What is your request about?',
                            maxLines: 1,
                          ),
                          const SizedBox(height: 20),

                          // Tags Field
                          _buildSectionTitle('Tags'),
                          const SizedBox(height: 8),
                          _buildTagsField(),
                          const SizedBox(height: 20),

                          // Commission Rate Field (NEW)
                          _buildSectionTitle('Commission Rate'),
                          const SizedBox(height: 8),
                          _buildCommissionRateField(),
                          const SizedBox(height: 20),

                          // Description Field
                          _buildSectionTitle('Description'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: descriptionController,
                            hint: 'Add details about your commission...',
                            maxLines: 5,
                          ),
                          const SizedBox(height: 30),

                          // Post Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handlePost,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                disabledBackgroundColor: Colors.grey[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                shadowColor: Colors.black.withOpacity(0.2),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Post Commission',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Urbanist', fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Urbanist',
            color: Colors.grey[600],
            fontSize: 15,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF4CAF50), width: 2),
          ),
        ),
      ),
    );
  }

  // NEW: Commission Rate Field with PHP currency
  Widget _buildCommissionRateField() {
    return Container(
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
      child: TextField(
        controller: commissionRateController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        style: const TextStyle(fontFamily: 'Urbanist', fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₱',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          hintText: 'Enter amount (e.g., 500.00)',
          hintStyle: TextStyle(
            fontFamily: 'Urbanist',
            color: Colors.grey[600],
            fontSize: 15,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF4CAF50), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsField() {
    return InkWell(
      onTap: _showTagsDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          children: [
            Icon(Icons.label_outline, color: const Color(0xFF4CAF50), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedTags.isEmpty
                    ? 'What Category? (Max 2)'
                    : selectedTags.join(', '),
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  color: selectedTags.isEmpty
                      ? Colors.grey[600]
                      : Colors.black87,
                  fontSize: 15,
                  fontWeight: selectedTags.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  void _showTagsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFFFFFDF5),
              title: const Text(
                'Select Tags (Max 2)',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: availableTags.map((tag) {
                    return CheckboxListTile(
                      title: Text(
                        tag,
                        style: const TextStyle(fontFamily: 'Urbanist'),
                      ),
                      value: selectedTags.contains(tag),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (selectedTags.length < 2) {
                              selectedTags.add(tag);
                            } else {
                              _showCenterDialog(
                                'Maximum 2 tags allowed',
                                isError: true,
                              );
                            }
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                      activeColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handlePost() async {
    final user = FirebaseAuth.instance.currentUser;

    // Validation
    if (user == null) {
      _showCenterDialog('Please log in to post', isError: true);
      return;
    }

    if (subjectController.text.trim().isEmpty) {
      _showCenterDialog('Please enter a subject', isError: true);
      return;
    }

    if (selectedTags.isEmpty) {
      _showCenterDialog('Please select at least one tag', isError: true);
      return;
    }

    if (commissionRateController.text.trim().isEmpty) {
      _showCenterDialog('Please enter a commission rate', isError: true);
      return;
    }

    // Validate commission rate is a valid number
    final rateText = commissionRateController.text.trim();
    final rate = double.tryParse(rateText);
    if (rate == null || rate <= 0) {
      _showCenterDialog('Please enter a valid commission rate', isError: true);
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      _showCenterDialog('Please enter a description', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Starting post creation...');

      // Prepare post data with commission rate
      final postData = {
        'userId': user.uid,
        'username': user.displayName ?? 'User',
        'userImageUrl': user.photoURL,
        'subject': subjectController.text.trim(),
        'tags': selectedTags,
        'commissionRate': rate, // Store as number for easy filtering/sorting
        'description': descriptionController.text.trim(),
        'uploadedFile': defaultImage, // Default placeholder image
        'createdAt': FieldValue.serverTimestamp(),
      };

      print('Saving to Firestore...');

      // Save to global collection
      await FirebaseFirestore.instance.collection('posts').add(postData);
      print('Saved to global posts collection');

      // Save to user profile collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('posts')
          .add(postData);
      print('Saved to user posts collection');

      // Show success message
      if (mounted) {
        await _showCenterDialog(
          'Your post has been successfully uploaded!',
          isError: false,
        );
      }

      // Navigate to home page
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Error in _handlePost: $e');
      if (mounted) {
        await _showCenterDialog(
          'Error creating post: ${e.toString().replaceAll('Exception: ', '')}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCenterDialog(
    String message, {
    required bool isError,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Auto dismiss after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isError
                    ? [Color(0xFFFF6B6B), Color(0xFFEE5A6F)]
                    : [Color(0xFF4CAF50), Color(0xFF45A049)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isError ? Colors.red : const Color(0xFF4CAF50))
                      .withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isError ? 'Oops!' : 'Success!',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    subjectController.dispose();
    descriptionController.dispose();
    commissionRateController.dispose();
    super.dispose();
  }
}
