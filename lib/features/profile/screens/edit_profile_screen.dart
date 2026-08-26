import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/profile/providers/profile_provider.dart';
import 'package:ludo_vibe/features/profile/widgets/avatar_display.dart';
import 'package:ludo_vibe/features/profile/widgets/profile_dialogs.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _usernameController;
  final Map<String, bool> _savedStatus = {
    'username': true,
    'gender': true,
    'dob': true,
    'country': true,
    'bio': false,
  };

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _usernameController = TextEditingController(text: profile.username);
    _savedStatus['bio'] = profile.bio.trim().isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).fetchProfile().then((_) {
        if (mounted) {
          final p = ref.read(profileProvider);
          setState(() {
            _savedStatus['bio'] = p.bio.trim().isNotEmpty;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFDCD2FD), // Light purple background matching mockup
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Dark Purple Header with Title, Close Button & Avatar
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // Header Banner
                Container(
                  height: 165 * scale,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2D0F64), Color(0xFF4C1895), Color(0xFF5D1CA8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Tile pattern opacity overlay
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.12,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                            ),
                            itemCount: 30,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Top Row with Title & Close Button
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 10 * scale,
                        left: 16 * scale,
                        right: 16 * scale,
                        child: Row(
                          children: [
                            const Spacer(),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 20 * scale,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                padding: EdgeInsets.all(4 * scale),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 26 * scale,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Gold-Framed Profile Avatar Overlapping Header & Body (Tap opens BasicInfoAvatarDialog - 147)
                Padding(
                  padding: EdgeInsets.only(top: 105 * scale),
                  child: GestureDetector(
                    onTap: () => _showAvatarCustomizer(context),
                    child: AvatarDisplay(
                      avatarIndex: profileState.avatarIndex,
                      size: 96 * scale,
                      borderWidth: 3.5 * scale,
                      avatarUrl: profileState.avatarUrl ?? ref.watch(authProvider).user?.avatarUrl,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20 * scale),

            // Form Fields List Matching Image (iPhone 16 - 145)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: Username (0/3 times) per day
                    _buildFieldLabel('Username (0/3 times) per day', scale),
                    SizedBox(height: 6 * scale),
                    _buildSelectableField(
                      value: profileState.username,
                      scale: scale,
                      onTap: () => _showEditUsernameDialog(context, ref, profileState.username),
                    ),
                    SizedBox(height: 14 * scale),

                    // Field 2: Gender
                    _buildFieldLabel('Gender', scale),
                    SizedBox(height: 6 * scale),
                    _buildSelectableField(
                      value: profileState.gender,
                      scale: scale,
                      onTap: () => _showGenderInformationDialog(context, ref, profileState.gender),
                    ),
                    SizedBox(height: 14 * scale),

                    // Field 3: Date of birth (Side-by-side Day & Month)
                    _buildFieldLabel('Date of birth', scale),
                    SizedBox(height: 6 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectableField(
                            value: profileState.birthDay,
                            scale: scale,
                            onTap: () => _showBirthdayDialog(context, ref),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: _buildSelectableField(
                            value: profileState.birthMonth,
                            scale: scale,
                            onTap: () => _showBirthdayDialog(context, ref),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14 * scale),

                    // Field 4: Country
                    _buildFieldLabel('Country', scale),
                    SizedBox(height: 6 * scale),
                    _buildSelectableField(
                      value: profileState.country,
                      scale: scale,
                      onTap: () => _showCountrySelectionDialog(context, ref, profileState.country),
                    ),
                    SizedBox(height: 14 * scale),

                    // Field 5: Bio Text Area
                    _buildFieldLabel('Bio', scale),
                    SizedBox(height: 6 * scale),
                    _buildBioField(
                      value: profileState.bio.isEmpty
                          ? 'Add a bio to introduce yourself'
                          : profileState.bio,
                      isPlaceholder: profileState.bio.isEmpty,
                      scale: scale,
                      onTap: () => _showBioDialog(context, ref, profileState.bio),
                    ),
                    SizedBox(height: 30 * scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, double scale) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF7A68A5),
      ),
    );
  }

  // Input Field Container with solid right triangle arrow ▶ matching mockup
  Widget _buildSelectableField({
    required String value,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48 * scale,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFFE8DEFF),
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: const Color(0xFFC7B3FF), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF260D5C),
                ),
              ),
            ),
            Icon(
              Icons.play_arrow,
              color: const Color(0xFFB388FF),
              size: 16 * scale,
            ),
          ],
        ),
      ),
    );
  }

  // Large Bio Text Area Container matching mockup
  Widget _buildBioField({
    required String value,
    required bool isPlaceholder,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140 * scale,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFFE8DEFF),
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: const Color(0xFFC7B3FF), width: 1),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: isPlaceholder ? FontWeight.w500 : FontWeight.bold,
                  color: isPlaceholder ? const Color(0xFFA395C6) : const Color(0xFF260D5C),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.play_arrow,
                color: const Color(0xFFB388FF),
                size: 16 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Trigger Methods
  void _showAvatarCustomizer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const BasicInfoAvatarDialog(),
    );
  }

  void _showEditUsernameDialog(BuildContext context, WidgetRef ref, String current) {
    _usernameController.text = current;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF2D0F64),
          title: const Text('Edit Username', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _usernameController,
            enabled: !isSaving,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter username',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFB388FF))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD54F))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                disabledBackgroundColor: const Color(0xFF512DA8),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      final newName = _usernameController.text.trim();
                      if (newName.isNotEmpty) {
                        setDialogState(() => isSaving = true);
                        final success = await ref.read(profileProvider.notifier).updateUsername(newName);
                        if (context.mounted) {
                          Navigator.pop(dialogCtx);
                          setState(() => _savedStatus['username'] = success);
                          showProfileFeedbackSnackBar(context, isSuccess: success);
                        }
                      } else {
                        Navigator.pop(dialogCtx);
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderInformationDialog(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (context) => GenderInformationDialog(
        currentGender: current,
        onConfirm: (gender) async {
          final success = await ref.read(profileProvider.notifier).updateGender(gender);
          setState(() => _savedStatus['gender'] = success);
          return success;
        },
      ),
    );
  }

  void _showBirthdayDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(profileProvider);
    showDialog(
      context: context,
      builder: (context) => BirthdaySelectionDialog(
        day: state.birthDay,
        month: state.birthMonth,
        onConfirm: (day, month) async {
          final success = await ref.read(profileProvider.notifier).updateDateOfBirth(day, month);
          setState(() => _savedStatus['dob'] = success);
          return success;
        },
      ),
    );
  }

  void _showCountrySelectionDialog(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (context) => CountrySelectionDialog(
        currentCountry: current,
        onConfirm: (country) async {
          final success = await ref.read(profileProvider.notifier).updateCountry(country);
          setState(() => _savedStatus['country'] = success);
          return success;
        },
      ),
    );
  }

  void _showBioDialog(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (context) => BioDialog(
        initialBio: current,
        onSave: (bio) async {
          final success = await ref.read(profileProvider.notifier).updateBio(bio);
          setState(() => _savedStatus['bio'] = success && bio.trim().isNotEmpty);
          return success;
        },
      ),
    );
  }
}
