import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String? userImageUrl;

  const HomeScreen({
    super.key,
    required this.userName,
    this.userImageUrl,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentImageUrl;
  bool _isUploadingImage = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.userImageUrl;
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0f0f1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Promijeni profilnu sliku',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe63946).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFFe63946),
                  ),
                ),
                title: const Text(
                  'Uslikaj novu',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe63946).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFFe63946),
                  ),
                ),
                title: const Text(
                  'Odaberi iz galerije',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_currentImageUrl != null) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),
                  title: const Text(
                    'Ukloni sliku',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteImage();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl = await UserProfileService.uploadProfilePicture(imageFile);
      if (mounted) {
        setState(() {
          _currentImageUrl = imageUrl;
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Slika uspjesno promijenjena'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greska: ${e.toString()}'),
            backgroundColor: const Color(0xFFe63946),
          ),
        );
      }
    }
  }

  Future<void> _deleteImage() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      await UserProfileService.deleteProfilePicture();
      if (mounted) {
        setState(() {
          _currentImageUrl = null;
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Slika uspjesno uklonjena'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greska: ${e.toString()}'),
            backgroundColor: const Color(0xFFe63946),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greska prilikom odjave: ${e.toString()}'),
            backgroundColor: const Color(0xFFe63946),
          ),
        );
      }
    }
  }

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${ApiConfig.baseUrl}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f0f1a),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFe63946).withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting text
                      Text(
                        'Dobrodosao,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // User info row
                      Row(
                        children: [
                          // User avatar - tappable
                          GestureDetector(
                            onTap: _isUploadingImage ? null : _showImagePickerOptions,
                            child: Stack(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFe63946),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFe63946).withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _isUploadingImage
                                        ? Container(
                                            color: const Color(0xFF1a1a2e),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color(0xFFe63946),
                                                ),
                                              ),
                                            ),
                                          )
                                        : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                            ? Image.network(
                                                _getFullImageUrl(_currentImageUrl),
                                                fit: BoxFit.cover,
                                                width: 70,
                                                height: 70,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return _buildDefaultAvatar();
                                                },
                                              )
                                            : _buildDefaultAvatar(),
                                  ),
                                ),
                                // Camera icon overlay
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFe63946),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // User name and status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.userName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Aktivan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Settings button
                          IconButton(
                            onPressed: () {
                              // TODO: Navigate to settings
                            },
                            icon: Icon(
                              Icons.settings_outlined,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Navigation options placeholder
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0f0f1a).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Brzi pristup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Placeholder for navigation options
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.widgets_outlined,
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Navigacijske opcije ce biti dodane ovdje',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Logout button
                        GestureDetector(
                          onTap: _isLoggingOut ? null : _handleLogout,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0f0f1a),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFe63946).withValues(alpha: 0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: _isLoggingOut
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFe63946),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.logout,
                                        color: Color(0xFFe63946),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'ODJAVI SE',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                          color: Colors.white.withValues(alpha: 0.8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    // Get initials from name
    final nameParts = widget.userName.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials = nameParts[0][0].toUpperCase();
      if (nameParts.length > 1) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    return Container(
      color: const Color(0xFF1a1a2e),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '?',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFFe63946),
          ),
        ),
      ),
    );
  }
}
