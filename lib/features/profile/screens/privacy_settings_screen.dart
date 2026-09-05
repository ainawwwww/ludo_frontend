import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final Map<String, bool> _switchValues = {
    'Do Not Disturb': false,
    'Do Not Spectate': false,
    'Do Not Follow': false,
    'Hide Nationality': false,
    'Hide Birthday': false,
    'Block Friend Requests': false,
    'Hide Dice Quantity': false,
  };

  final List<Map<String, String>> _options = const [
    {
      'title': 'Do Not Disturb',
      'subtitle':
          "Hide game invitations, room sharings, and friends' online notifications",
    },
    {
      'title': 'Do Not Spectate',
      'subtitle': "Don't allow your friends to spectate your games",
    },
    {
      'title': 'Do Not Follow',
      'subtitle':
          "Don't allow your friend to follow you into the chatrooms, and you can't follow your friends to enter the chatrooms",
    },
    {
      'title': 'Hide Nationality',
      'subtitle': "Hide your nationality to any visitor to yourself",
    },
    {
      'title': 'Hide Birthday',
      'subtitle':
          "Others can't see your birthday but you can still receive birthday gifts from Yalla Ludo",
    },
    {
      'title': 'Block Friend Requests',
      'subtitle': "You will no longer receive friend requests within 7 days",
    },
    {
      'title': 'Hide Dice Quantity',
      'subtitle':
          'The "My Favorite Dice" page will no longer display the number of dice you own',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFDCD2FD),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Dark Purple Top Banner Header
            Container(
              height: 70 * scale + MediaQuery.paddingOf(context).top,
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 10 * scale,
                left: 16 * scale,
                right: 16 * scale,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2D0F64),
                    Color(0xFF4C1895),
                    Color(0xFF5D1CA8)
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    'Privacy Settings',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24 * scale,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(18 * scale),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale, vertical: 8 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DEFF),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border:
                        Border.all(color: const Color(0xFFC7B3FF), width: 1),
                  ),
                  child: Column(
                    children: _options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final title = item['title']!;
                      final subtitle = item['subtitle']!;
                      final isVal = _switchValues[title] ?? false;

                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12 * scale),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 14 * scale,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF260D5C),
                                        ),
                                      ),
                                      SizedBox(height: 3 * scale),
                                      Text(
                                        subtitle,
                                        style: TextStyle(
                                          fontSize: 11 * scale,
                                          color: const Color(0xFF7565A4),
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                Transform.scale(
                                  scale: scale * 0.85,
                                  child: Switch(
                                    value: isVal,
                                    activeColor: const Color(0xFF7C4DFF),
                                    activeTrackColor: const Color(0xFFB388FF),
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: const Color(0xFFC7B3FF),
                                    onChanged: (val) {
                                      setState(
                                          () => _switchValues[title] = val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index < _options.length - 1)
                            const Divider(color: Color(0xFFC7B3FF), height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
