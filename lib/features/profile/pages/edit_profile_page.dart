import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/data/auth_service_manager.dart';
import '../../detection/presentation/widgets/detection_bottom_nav.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isSaving = false;
  String? _avatarPath;

  // Color Palette accurately sampled from your images
  static const Color scaffoldBg = Color(0xFF0F172A);
  static const Color tealPrimary = Color(0xFF3D9889);
  static const Color textSecondary = Colors.white;

  @override
  void initState() {
    super.initState();
    final auth = AuthServiceManager();
    _fullNameController.text = auth.userName ?? '';
    _emailController.text = auth.userEmail ?? '';
    _phoneController.text = auth.userPhone ?? '';
    _usernameController.text = auth.username ?? '';
    _avatarPath = auth.userAvatarPath;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final auth = AuthServiceManager();
      await auth.tokenStorage.saveUserProfile(
        email: _emailController.text,
        fullName: _fullNameController.text,
      );
      await auth.tokenStorage.saveExtendedUserProfile(
        phone: _phoneController.text,
        username: _usernameController.text,
      );
      await auth.tokenStorage.saveUserAvatarPath(_avatarPath);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return;

    // Copy to app documents directory so it remains accessible.
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory('${dir.path}/avatars');
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    final ext = path.split('.').last;
    final targetPath =
        '${avatarsDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final saved = await File(path).copy(targetPath);

    if (!mounted) return;
    setState(() => _avatarPath = saved.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy500,
      bottomNavigationBar:BottomNav(activePage: 'profile',) ,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.navy500,
        //elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.workSans(
            // Updated to Inter to match Save button
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              _isSaving ? 'Saving...' : 'Save',
              style: GoogleFonts.inter(
                color: tealPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Fix: Use bottomNavigationBar to keep buttons at the bottom regardless of scroll
    //  bottomNavigationBar: _buildBottomActionButtons(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileImagePicker(),
            const SizedBox(height: 32),

            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 16),
            _buildTextField('Full Name', controller: _fullNameController),
            const SizedBox(height: 16),
            _buildTextField(
              'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              subLabel: ' (Optional)',
            ),
            const SizedBox(height: 16),
            _buildTextField('Username', controller: _usernameController),

            const SizedBox(height: 32),
            _buildSectionHeader('Account Status'),
            const SizedBox(height: 16),
            _buildVerifiedCard(),

            const SizedBox(height: 32),
            _buildSectionHeader('Security', hasDividers: true),
            const SizedBox(height: 16),
            _buildSecurityTile(
              imagePath: 'assets/images/Vector (8).png',
              title: 'Change Password',
              subtitle: 'Update your password',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            _buildSecurityTile(
              imagePath: 'assets/images/Vector (9).png',
              title: 'Two-Factor Authentication',
              subtitle: 'Enabled',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusBadge('Active'),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // Bottom padding for scroll
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _avatarPath != null && _avatarPath!.isNotEmpty
                    ? Image.file(
                        File(_avatarPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, size: 88, color: Colors.grey),
                      )
                    : const Icon(Icons.person, size: 88, color: Colors.grey),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: tealPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ), // Match bg color
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickProfileImage,
          child: Text(
            'Change Profile Photo',
            style: GoogleFonts.inter(
              color: tealPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {bool hasDividers = false}) {
    if (!hasDividers) {
      return Center(
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFF3D9889).withOpacity(0.3), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFF3D9889).withOpacity(0.3), thickness: 1)),
      ],
    );
  }

  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    String? subLabel,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: tealPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subLabel != null)
              Text(
                subLabel,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: controller,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildVerifiedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified Account',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Your account is verified',
                  style: GoogleFonts.inter(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.help_outline_rounded,
            color: Color(0xFF22C55E),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile({
    required String imagePath, // Changed from IconData icon to String imagePath
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF101B2F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3D9889).withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tealPrimary.withOpacity(0.8), scaffoldBg],
              ),
            ),
            child: Image.asset(
              imagePath, // Now uses the dynamic path passed to the function
              width: 14,
              height: 16,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(color: textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFF16A34A),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }



}