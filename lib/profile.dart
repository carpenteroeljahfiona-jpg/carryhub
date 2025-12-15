import 'package:carryhub/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage();
  }
}

class ProfilePage extends StatefulWidget {
  final bool isInitialSetup;
  final String? initialUsername;
  final String? initialEmail;

  const ProfilePage({
    super.key,
    this.isInitialSetup = false,
    this.initialUsername,
    this.initialEmail,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messengerController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _userId;

  // Store original username and email to preserve them
  String _originalUsername = '';
  String _originalEmail = '';

  // Form field focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _departmentFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _messengerFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      _userId = user.uid;
      _emailController.text = user.email ?? '';
      _originalEmail = user.email ?? '';

      // Fetch user profile from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        _nameController.text = data['name'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _originalUsername = data['username'] ?? '';
        _departmentController.text = data['department'] ?? '';
        _yearController.text = data['year']?.toString() ?? '';
        _phoneController.text = data['phone'] ?? '';
        _messengerController.text = data['messenger'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _descriptionController.text = data['description'] ?? '';
      } else {
        // If document doesn't exist yet, use initial values if provided
        _usernameController.text = widget.initialUsername ?? '';
        _originalUsername = widget.initialUsername ?? '';
        _emailController.text = widget.initialEmail ?? user.email ?? '';
        _originalEmail = widget.initialEmail ?? user.email ?? '';
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showCenterDialog(
          'Failed to load profile: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  // Name validation
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Username validation (read-only, just display)
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.trim().length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  // Department validation
  String? _validateDepartment(String? value) {
    if (widget.isInitialSetup) {
      if (value == null || value.trim().isEmpty) {
        return 'Department is required';
      }
    }
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'Department name too short';
    }
    return null;
  }

  // Year validation
  String? _validateYear(String? value) {
    if (widget.isInitialSetup) {
      if (value == null || value.trim().isEmpty) {
        return 'Year is required';
      }
    }
    if (value != null && value.trim().isNotEmpty) {
      final year = int.tryParse(value.trim());
      if (year == null) {
        return 'Please enter a valid number';
      }
      if (year < 1 || year > 10) {
        return 'Year must be between 1 and 10';
      }
    }
    return null;
  }

  // Email validation (read-only but still validate format)
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Phone validation
  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      // Basic phone validation - adjust regex based on your requirements
      if (value.trim().length < 10) {
        return 'Phone number must be at least 10 digits';
      }
    }
    return null;
  }

  // Messenger validation
  String? _validateMessenger(String? value) {
    // Messenger is optional, so only validate if not empty
    if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
      return 'Messenger account must be at least 3 characters';
    }
    return null;
  }

  // Bio validation
  String? _validateBio(String? value) {
    if (value != null && value.trim().length > 150) {
      return 'Bio must be less than 150 characters';
    }
    return null;
  }

  // Description validation
  String? _validateDescription(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  // Reset form - UPDATED to preserve username and email
  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _departmentController.clear();
    _yearController.clear();
    _phoneController.clear();
    _messengerController.clear();
    _bioController.clear();
    _descriptionController.clear();

    // Preserve username and email with original values
    _usernameController.text = _originalUsername;
    _emailController.text = _originalEmail;
  }

  // Clear all fields
  void _clearAllFields() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Fields'),
        content: const Text(
          'Are you sure you want to clear all fields? Username and email will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    // Unfocus any focused text field
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showCenterDialog('Please fix the errors in the form', isError: true);
      return;
    }

    if (_userId == null) {
      _showCenterDialog('User not logged in', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Prepare data to save
      final profileData = {
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'department': _departmentController.text.trim(),
        'year': _yearController.text.trim().isNotEmpty
            ? int.parse(_yearController.text.trim())
            : null,
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'messenger': _messengerController.text.trim(),
        'bio': _bioController.text.trim(),
        'description': _descriptionController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Check if this is a new user document
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (!docSnapshot.exists) {
        // Add createdAt timestamp for new documents
        profileData['createdAt'] = FieldValue.serverTimestamp();
        profileData['userId'] = _userId;
      }

      // Save to Firestore (merge: true will update existing or create new)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .set(profileData, SetOptions(merge: true));

      setState(() => _isSaving = false);

      if (mounted) {
        await _showCenterDialog('Profile saved successfully!', isError: false);

        // Navigate to home after successful save if initial setup
        if (widget.isInitialSetup) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showCenterDialog(
        'Failed to save profile: ${e.toString()}',
        isError: true,
      );
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

  // ignore: unused_element
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messengerController.dispose();
    _bioController.dispose();
    _descriptionController.dispose();
    _nameFocus.dispose();
    _departmentFocus.dispose();
    _yearFocus.dispose();
    _phoneFocus.dispose();
    _messengerFocus.dispose();
    _bioFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.15;
    final fieldWidth = screenWidth - 2 * horizontalPadding;

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFDF5),
                Color.fromARGB(255, 231, 237, 225),
                Color.fromARGB(255, 255, 253, 248),
              ],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF473023)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFDF5),
                  Color.fromARGB(255, 231, 237, 225),
                  Color.fromARGB(255, 255, 253, 248),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: screenHeight * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.08), // Space for AppBar
                    Center(
                      child: Text(
                        widget.isInitialSetup
                            ? 'Complete Your Profile'
                            : 'Profile',
                        style: TextStyle(
                          color: const Color(0xFF473023),
                          fontSize: screenWidth * 0.06,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    Text(
                      'Info',
                      style: TextStyle(
                        color: const Color(0xFF473023),
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Name field
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        validator: _validateName,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          color: Color(0xFF473023),
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_departmentFocus);
                        },
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.035,
                            vertical: screenHeight * 0.015,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Username (read-only)
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _usernameController,
                        enabled: false,
                        validator: _validateUsername,
                        style: const TextStyle(
                          color: Color(0xFF473023),
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.035,
                            vertical: screenHeight * 0.015,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Department + Year Row with validation
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _departmentController,
                            focusNode: _departmentFocus,
                            validator: _validateDepartment,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(
                              color: Color(0xFF473023),
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w500,
                            ),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_yearFocus);
                            },
                            decoration: InputDecoration(
                              hintText: 'Department',
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.3),
                                fontSize: screenWidth * 0.035,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.035,
                                vertical: screenHeight * 0.015,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),

                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _yearController,
                            focusNode: _yearFocus,
                            keyboardType: TextInputType.number,
                            validator: _validateYear,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(
                              color: Color(0xFF473023),
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w500,
                            ),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_phoneFocus);
                            },
                            decoration: InputDecoration(
                              hintText: 'Year',
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.3),
                                fontSize: screenWidth * 0.035,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.035,
                                vertical: screenHeight * 0.015,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Contact Details Section
                    Text(
                      'Contact Details',
                      style: TextStyle(
                        color: const Color(0xFF473023),
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Phone Number
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          color: Color(0xFF473023),
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_messengerFocus);
                        },
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.035,
                            vertical: screenHeight * 0.015,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Messenger Account
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _messengerController,
                        focusNode: _messengerFocus,
                        validator: _validateMessenger,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          color: Color(0xFF473023),
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_bioFocus);
                        },
                        decoration: InputDecoration(
                          hintText: 'Messenger Account',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.035,
                            vertical: screenHeight * 0.015,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Email (read-only)
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _emailController,
                        enabled: false,
                        validator: _validateEmail,
                        style: const TextStyle(
                          color: Color(0xFF473023),
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.035,
                            vertical: screenHeight * 0.015,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Bio
                    Text(
                      'Bio',
                      style: TextStyle(
                        color: const Color(0xFF473023),
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _bioController,
                        focusNode: _bioFocus,
                        maxLines: 2,
                        validator: _validateBio,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_descriptionFocus);
                        },
                        style: const TextStyle(
                          color: Color(0xFF473023),
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Short Bio (max 150 chars)',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.035,
                            vertical: screenHeight * 0.02,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        color: const Color(0xFF473023),
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocus,
                        maxLines: 6,
                        validator: _validateDescription,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(
                          color: Color(0xFF473023),
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Describe yourself (max 500 chars)',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.035,
                            vertical: screenHeight * 0.02,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Clear Button
                        ElevatedButton(
                          onPressed: _clearAllFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade300,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Save Button
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF473023),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: screenHeight * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
