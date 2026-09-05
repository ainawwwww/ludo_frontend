import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/profile/widgets/profile_dialogs.dart';

import 'package:ludo_vibe/core/services/sound_service.dart';

// Main App Settings Popup (iPhone 16 - 156)
class MainSettingsDialog extends ConsumerStatefulWidget {
  const MainSettingsDialog({super.key});

  @override
  ConsumerState<MainSettingsDialog> createState() => _MainSettingsDialogState();
}

class _MainSettingsDialogState extends ConsumerState<MainSettingsDialog> {
  late bool _soundEnabled;
  late bool _musicEnabled;
  String _selectedLanguage = 'English';
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    final soundService = ref.read(soundServiceProvider);
    _soundEnabled = soundService.isSoundEnabled;
    _musicEnabled = soundService.isMusicEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final soundService = ref.watch(soundServiceProvider);

    return PurplePopupDialog(
      title: 'Settings',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          children: [
            // Top 4 Action Buttons Row: Support, Home, Share, Mail
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderIconButton(
                  icon: Icons.help_outline,
                  label: 'Support',
                  onTap: () {
                    soundService.playButtonClick();
                    Navigator.pop(context);
                    context.push(AppConstants.supportRoute);
                  },
                ),
                _buildHeaderIconButton(
                  icon: Icons.home,
                  label: 'Home',
                  onTap: () {
                    soundService.playButtonClick();
                    Navigator.pop(context);
                    context.go(AppConstants.homeRoute);
                  },
                ),
                _buildHeaderIconButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {
                    soundService.playButtonClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Sharing LudoVibe with friends!')),
                    );
                  },
                ),
                _buildHeaderIconButton(
                  icon: Icons.email,
                  label: 'Mail',
                  onTap: () {
                    soundService.playButtonClick();
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => const MailDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sound & Music Toggles Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEADBFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Text('Sound',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF260D5C))),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _soundEnabled,
                      activeColor: const Color(0xFF7C4DFF),
                      onChanged: (val) {
                        setState(() => _soundEnabled = val);
                        soundService.setSoundEnabled(val);
                        if (val) soundService.playButtonClick();
                      },
                    ),
                  ),
                  const Spacer(),
                  const Text('Music',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF260D5C))),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _musicEnabled,
                      activeColor: const Color(0xFF7C4DFF),
                      onChanged: (val) {
                        setState(() => _musicEnabled = val);
                        soundService.setMusicEnabled(val);
                        if (_soundEnabled) soundService.playButtonClick();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Language Selector Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEADBFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Language',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF260D5C))),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ChooseLanguageDialog(
                          currentLang: _selectedLanguage,
                          onConfirm: (lang) =>
                              setState(() => _selectedLanguage = lang),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Text(_selectedLanguage,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 12, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Privacy Settings Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                context.push(AppConstants.privacySettingsRoute);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEADBFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Privacy Settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF260D5C),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Log Out & Account Centre Buttons Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoggingOut
                        ? null
                        : () async {
                            setState(() => _isLoggingOut = true);
                            await ref.read(authProvider.notifier).logout();
                            if (mounted) {
                              Navigator.pop(context);
                              context.go(AppConstants.splashRoute);
                            }
                          },
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D1CA8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _isLoggingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppConstants.accountCentreRoute);
                    },
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Account Centre',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Footer Links: Privacy Policy | Terms of Service | Version 1.5.0.0
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Privacy Policy',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        decoration: TextDecoration.underline)),
                const SizedBox(width: 12),
                const Text('Terms of Service',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        decoration: TextDecoration.underline)),
                const SizedBox(width: 12),
                Text('Version 1.5.0.0',
                    style: TextStyle(
                        fontSize: 10, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Choose Language Dialog (iPhone 16 - 154)
class ChooseLanguageDialog extends StatefulWidget {
  final String currentLang;
  final ValueChanged<String> onConfirm;

  const ChooseLanguageDialog({
    super.key,
    required this.currentLang,
    required this.onConfirm,
  });

  @override
  State<ChooseLanguageDialog> createState() => _ChooseLanguageDialogState();
}

class _ChooseLanguageDialogState extends State<ChooseLanguageDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentLang;
  }

  @override
  Widget build(BuildContext context) {
    return PurplePopupDialog(
      title: 'Choose Language',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEADBFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('English',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF260D5C))),
                    trailing: _selected == 'English'
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF7C4DFF))
                        : null,
                    onTap: () => setState(() => _selected = 'English'),
                  ),
                  const Divider(height: 1, color: Color(0xFFC7B3FF)),
                  ListTile(
                    title: const Text('العربية',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF260D5C))),
                    trailing: _selected == 'العربية'
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF7C4DFF))
                        : null,
                    onTap: () => setState(() => _selected = 'العربية'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Orange Confirm Button
            GestureDetector(
              onTap: () {
                widget.onConfirm(_selected);
                Navigator.pop(context);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFF57C00)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Confirm',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mail Dialog (iPhone 16 - 155)
class MailDialog extends StatelessWidget {
  const MailDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PurplePopupDialog(
      title: 'Mail (0/99)',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFEADBFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment,
                size: 40,
                color: Color(0xFFB388FF),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'NO MAILS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Visitor History Dialog (iPhone 16 - 157)
class VisitorHistoryDialog extends StatelessWidget {
  const VisitorHistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final visitors = [
      {'name': 'Boy', 'time': '10:29 PM', 'date': '02.08.2026'},
      {'name': 'J.M.oor', 'time': '10:00 PM', 'date': '02.08.2026'},
    ];

    return PurplePopupDialog(
      title: 'Visitor History',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          children: [
            // Royal Users Note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEADBFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Royal users can view more visitors',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C4DFF))),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF7C4DFF)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Visits 0",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text('02.08.2026',
                    style: TextStyle(
                        fontSize: 11, color: Colors.white.withOpacity(0.8))),
              ],
            ),
            const SizedBox(height: 10),

            // Visitor list
            Column(
              children: visitors
                  .map((v) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEADBFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFF7C4DFF),
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v['name']!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF260D5C))),
                                  Text('visited your profile at ${v['time']!}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF7565A4))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8F00),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Add',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),

            Text(
              'Only visitor records from the past 7 days are kept.',
              style:
                  TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
