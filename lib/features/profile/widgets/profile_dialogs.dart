import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/profile/models/profile_customization_model.dart';
import 'package:ludo_vibe/features/profile/providers/profile_customization_provider.dart';
import 'package:ludo_vibe/features/profile/providers/profile_provider.dart';
import 'package:ludo_vibe/features/profile/widgets/avatar_display.dart';

// Helper for popup frame styling matching screenshots
class PurplePopupDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;

  const PurplePopupDialog({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(
                0xFF9D84F7), // Soft purple outer border/gradient frame
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC7B3FF), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFB5A1FC), // Light purple inner dialog card
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Header Title & Close Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 14, 10),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onClose ?? () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showProfileFeedbackSnackBar(BuildContext context,
    {required bool isSuccess, String? message}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message ??
                  (isSuccess
                      ? 'Saved successfully'
                      : 'Failed to save — check your connection'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor:
          isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(milliseconds: 1800),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}

// 1. Bio Dialog (iPhone 16 - 134)
class BioDialog extends StatefulWidget {
  final String initialBio;
  final Future<bool> Function(String bio) onSave;

  const BioDialog({
    super.key,
    required this.initialBio,
    required this.onSave,
  });

  @override
  State<BioDialog> createState() => _BioDialogState();
}

class _BioDialogState extends State<BioDialog> {
  late TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final success = await widget.onSave(_controller.text.trim());
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      showProfileFeedbackSnackBar(context, isSuccess: success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PurplePopupDialog(
      title: 'Bio',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          children: [
            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                style: const TextStyle(color: Color(0xFF260D5C), fontSize: 14),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Add a bio to introduce yourself',
                  hintStyle: TextStyle(color: Color(0xFFA395C6), fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            _buildActionButton(
              label: 'Save',
              isLoading: _isSaving,
              onTap: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Gender / Information Dialog (iPhone 16 - 136)
class GenderInformationDialog extends StatefulWidget {
  final String currentGender;
  final Future<bool> Function(String gender) onConfirm;

  const GenderInformationDialog({
    super.key,
    required this.currentGender,
    required this.onConfirm,
  });

  @override
  State<GenderInformationDialog> createState() =>
      _GenderInformationDialogState();
}

class _GenderInformationDialogState extends State<GenderInformationDialog> {
  late String _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentGender;
  }

  Future<void> _handleConfirm() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final success = await widget.onConfirm(_selected);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      showProfileFeedbackSnackBar(context, isSuccess: success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      {'label': 'Female', 'icon': Icons.face_3},
      {'label': 'Male', 'icon': Icons.face_6},
      {'label': 'Unspecified', 'icon': Icons.person},
    ];

    return PurplePopupDialog(
      title: 'Information',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: options.map((opt) {
                final label = opt['label'] as String;
                final isSelected = _selected == label;

                return GestureDetector(
                  onTap: _isSaving
                      ? null
                      : () => setState(() => _selected = label),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF7C53F6),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          opt['icon'] as IconData,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF7C53F6)
                              : Colors.white,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              label: 'Confirm',
              isLoading: _isSaving,
              onTap: _handleConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Country Selection Dialog (iPhone 16 - 144)
class CountrySelectionDialog extends StatefulWidget {
  final String currentCountry;
  final Future<bool> Function(String country) onConfirm;

  const CountrySelectionDialog({
    super.key,
    required this.currentCountry,
    required this.onConfirm,
  });

  @override
  State<CountrySelectionDialog> createState() => _CountrySelectionDialogState();
}

class _CountrySelectionDialogState extends State<CountrySelectionDialog> {
  late String _selected;
  bool _isSaving = false;

  static const countries = [
    {'name': 'Pakistan', 'flag': '🇵🇰'},
    {'name': 'India', 'flag': '🇮🇳'},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'name': 'Bangladesh', 'flag': '🇧🇩'},
    {'name': 'UAE', 'flag': '🇦🇪'},
    {'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'United States', 'flag': '🇺🇸'},
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentCountry;
  }

  Future<void> _handleConfirm() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final success = await widget.onConfirm(_selected);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      showProfileFeedbackSnackBar(context, isSuccess: success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PurplePopupDialog(
      title: 'Country',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFEADBFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: countries.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Color(0xFFC7B3FF),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final c = countries[index];
                  final isSel = _selected == c['name'];

                  return ListTile(
                    dense: true,
                    leading: Text(
                      c['flag']!,
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(
                      c['name']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        color: const Color(0xFF260D5C),
                      ),
                    ),
                    trailing: isSel
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF7C53F6), size: 20)
                        : null,
                    onTap: _isSaving
                        ? null
                        : () => setState(() => _selected = c['name']!),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              label: 'Confirm',
              isLoading: _isSaving,
              onTap: _handleConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Birthday Dialog (iPhone 16 - 146)
class BirthdaySelectionDialog extends StatefulWidget {
  final String day;
  final String month;
  final Future<bool> Function(String day, String month) onConfirm;

  const BirthdaySelectionDialog({
    super.key,
    required this.day,
    required this.month,
    required this.onConfirm,
  });

  @override
  State<BirthdaySelectionDialog> createState() =>
      _BirthdaySelectionDialogState();
}

class _BirthdaySelectionDialogState extends State<BirthdaySelectionDialog> {
  late String _selectedDay;
  late String _selectedMonth;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.day;
    _selectedMonth = widget.month;
  }

  Future<void> _handleConfirm() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final success = await widget.onConfirm(_selectedDay, _selectedMonth);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      showProfileFeedbackSnackBar(context, isSuccess: success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PurplePopupDialog(
      title: 'Birthday',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildPickerBox(
                    label: _selectedDay,
                    onTap: _isSaving ? () {} : _showDayPicker,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPickerBox(
                    label: _selectedMonth,
                    onTap: _isSaving ? () {} : _showMonthPicker,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              label: 'Confirm',
              isLoading: _isSaving,
              onTap: _handleConfirm,
            ),
            const SizedBox(height: 12),
            Text(
              'You can hide your birthday in settings -> Privacy settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerBox({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEADBFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF260D5C),
              ),
            ),
            const Icon(
              Icons.play_arrow,
              color: Color(0xFFB388FF),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showDayPicker() {
    final days = List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D0F64),
      builder: (context) => SizedBox(
        height: 240,
        child: ListView.builder(
          itemCount: days.length,
          itemBuilder: (context, index) => ListTile(
            title: Text('Day ${days[index]}',
                style: const TextStyle(color: Colors.white)),
            onTap: () {
              setState(() => _selectedDay = days[index]);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showMonthPicker() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D0F64),
      builder: (context) => SizedBox(
        height: 240,
        child: ListView.builder(
          itemCount: months.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(months[index],
                style: const TextStyle(color: Colors.white)),
            onTap: () {
              setState(() => _selectedMonth = months[index]);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}

// 5. Theme Selection Dialog
class ThemeSelectionDialog extends ConsumerWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customization = ref.watch(profileCustomizationProvider);
    final currentTheme = customization.currentTheme;

    return PurplePopupDialog(
      title: 'Set Theme',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a wallpaper to set as your app & profile background',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 380,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: ProfileThemeItem.allThemes.length,
                itemBuilder: (context, index) {
                  final theme = ProfileThemeItem.allThemes[index];
                  final isEquipped = currentTheme.id == theme.id;

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(profileCustomizationProvider.notifier)
                          .setTheme(theme);
                      showProfileFeedbackSnackBar(
                        context,
                        isSuccess: true,
                        message: '${theme.title} theme applied to background!',
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isEquipped
                              ? const Color(0xFFFFD54F)
                              : Colors.white24,
                          width: isEquipped ? 2.5 : 1,
                        ),
                        boxShadow: isEquipped
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFFD54F).withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              theme.assetPath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: theme.accentColor.withOpacity(0.4),
                                child: const Center(
                                  child: Icon(Icons.wallpaper,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            // Dark gradient overlay for text readability
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0x99000000),
                                    Color(0xEE000000),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Theme Title and Equipped Badge
                            Positioned(
                              left: 8,
                              right: 8,
                              bottom: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    theme.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isEquipped
                                          ? const Color(0xFFFFD54F)
                                          : Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isEquipped ? '✓ EQUIPPED' : 'APPLY',
                                        style: TextStyle(
                                          color: isEquipped
                                              ? const Color(0xFF260D5C)
                                              : Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (theme.isRoyal)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ROYAL',
                                    style: TextStyle(
                                      color: Color(0xFF260D5C),
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 6. Ornament Selection Dialog
class OrnamentSelectionDialog extends ConsumerWidget {
  const OrnamentSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customization = ref.watch(profileCustomizationProvider);
    final currentOrnament = customization.currentOrnament;

    return PurplePopupDialog(
      title: 'Set Ornament',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Equip aura ornaments to surround your profile and theme',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 380,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: ProfileOrnamentItem.allOrnaments.length,
                itemBuilder: (context, index) {
                  final ornament = ProfileOrnamentItem.allOrnaments[index];
                  final isEquipped = currentOrnament.id == ornament.id;

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(profileCustomizationProvider.notifier)
                          .setOrnament(ornament);
                      showProfileFeedbackSnackBar(
                        context,
                        isSuccess: true,
                        message: ornament.isNone
                            ? 'Ornament unequipped (Clean look)'
                            : '${ornament.title} ornament equipped!',
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D1CA8).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isEquipped
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFFC7B3FF).withOpacity(0.4),
                          width: isEquipped ? 2.5 : 1,
                        ),
                        boxShadow: isEquipped
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFFD54F).withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ornament.isNone
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white54, width: 2),
                                        ),
                                        child: const Icon(
                                          Icons.block_rounded,
                                          color: Colors.white70,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Default (Empty)',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  )
                                : Image.asset(
                                    ornament.assetPath!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFFFFD54F),
                                      size: 32,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ornament.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(
                              color: isEquipped
                                  ? const Color(0xFFFFD54F)
                                  : Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                isEquipped ? '✓ EQUIPPED' : 'EQUIP',
                                style: TextStyle(
                                  color: isEquipped
                                      ? const Color(0xFF260D5C)
                                      : Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 7. Basic Info Avatar Customizer Dialog (Profile Frame & Profile Photo Tabs)
class BasicInfoAvatarDialog extends ConsumerStatefulWidget {
  final int initialTab; // 0: Frame, 1: Photo

  const BasicInfoAvatarDialog({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<BasicInfoAvatarDialog> createState() =>
      _BasicInfoAvatarDialogState();
}

class _BasicInfoAvatarDialogState extends ConsumerState<BasicInfoAvatarDialog> {
  late int _selectedTab;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  Future<void> _handleImageUpload(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 88,
      );

      if (pickedFile != null && mounted) {
        final success = await ref
            .read(profileCustomizationProvider.notifier)
            .uploadCustomAvatarPath(pickedFile.path);

        if (mounted) {
          showProfileFeedbackSnackBar(
            context,
            isSuccess: success,
            message: success
                ? 'Profile photo uploaded and saved!'
                : 'Failed to save photo',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showProfileFeedbackSnackBar(
          context,
          isSuccess: false,
          message: 'Error selecting image: $e',
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D0F64),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload Profile Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: Color(0xFFFFD54F)),
                title: const Text('Choose from Gallery',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageUpload(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: Color(0xFFFFD54F)),
                title: const Text('Take a Photo',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageUpload(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customization = ref.watch(profileCustomizationProvider);
    final profile = ref.watch(profileProvider);

    final currentFrame = customization.currentFrame;
    final currentOrnament = customization.currentOrnament;
    final avatarUrl = profile.avatarUrl ??
        customization.customAvatarPath ??
        customization.presetAvatarAsset;

    return PurplePopupDialog(
      title: 'Basic Info',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
        child: Column(
          children: [
            // Top Avatar preview with camera upload button
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                AvatarDisplay(
                  avatarIndex: profile.avatarIndex,
                  size: 80,
                  borderWidth: 3.5,
                  avatarUrl: avatarUrl,
                  frameItem: currentFrame,
                  ornamentItem: currentOrnament,
                ),
                GestureDetector(
                  onTap: _showImageSourcePicker,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF8F00),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Selector: Profile Frame | Profile Photo
            Container(
              height: 36,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF5D1CA8).withOpacity(0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? const Color(0xFFFFD54F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Profile Frame',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: _selectedTab == 0
                                  ? const Color(0xFF260D5C)
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? const Color(0xFFFFD54F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Profile Photo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: _selectedTab == 1
                                  ? const Color(0xFF260D5C)
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab Content
            if (_selectedTab == 0)
              _buildFramesGrid(customization.currentFrame)
            else
              _buildPhotosGrid(avatarUrl),
          ],
        ),
      ),
    );
  }

  Widget _buildFramesGrid(ProfileFrameItem activeFrame) {
    return SizedBox(
      height: 240,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: ProfileFrameItem.allFrames.length,
        itemBuilder: (context, index) {
          final frame = ProfileFrameItem.allFrames[index];
          final isSelected = activeFrame.id == frame.id;

          return GestureDetector(
            onTap: () {
              ref.read(profileCustomizationProvider.notifier).setFrame(frame);
              showProfileFeedbackSnackBar(
                context,
                isSuccess: true,
                message: '${frame.title} frame equipped!',
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF5D1CA8).withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD54F) : Colors.white24,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: frame.gradientColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: frame.glowColor.withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        frame.badgeIcon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    frame.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.bold,
                      color:
                          isSelected ? const Color(0xFFFFD54F) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSelected ? '✓ EQUIPPED' : 'SELECT',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color:
                          isSelected ? const Color(0xFFFFD54F) : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotosGrid(String? currentAvatar) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom Upload Action Card
        GestureDetector(
          onTap: _showImageSourcePicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8F00), Color(0xFFFFB300)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Upload Custom Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Grid of Cartoon Avatars
        SizedBox(
          height: 195,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemCount: ProfileAvatarPreset.allPresets.length,
            itemBuilder: (context, index) {
              final preset = ProfileAvatarPreset.allPresets[index];
              final isSelected = currentAvatar == preset.assetPath;

              return GestureDetector(
                onTap: () {
                  ref
                      .read(profileCustomizationProvider.notifier)
                      .setPresetAvatar(preset);
                  showProfileFeedbackSnackBar(
                    context,
                    isSuccess: true,
                    message: '${preset.title} avatar selected!',
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D1CA8).withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isSelected ? const Color(0xFFFFD54F) : Colors.white24,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            preset.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF7E57C2),
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        preset.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFFFFD54F)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 8. Cloth Menu Popover (iPhone 16 - 135)
void showClothMenuPopover(BuildContext context, WidgetRef ref) {
  final RenderBox? overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox?;

  showMenu<String>(
    context: context,
    color: const Color(0xFFEADBFF),
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    position: RelativeRect.fromRect(
      const Rect.fromLTWH(60, 180, 180, 180),
      overlay != null ? Offset.zero & overlay.size : Rect.zero,
    ),
    items: const [
      PopupMenuItem(
        value: 'ornament',
        child: Row(
          children: [
            Icon(Icons.auto_awesome_rounded,
                color: Color(0xFF7C4DFF), size: 18),
            SizedBox(width: 8),
            Text('Set ornament',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF260D5C))),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'theme',
        child: Row(
          children: [
            Icon(Icons.wallpaper_rounded, color: Color(0xFF7C4DFF), size: 18),
            SizedBox(width: 8),
            Text('Set profile theme',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF260D5C))),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'frame',
        child: Row(
          children: [
            Icon(Icons.military_tech_rounded,
                color: Color(0xFF7C4DFF), size: 18),
            SizedBox(width: 8),
            Text('Set profile frame',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF260D5C))),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'photo',
        child: Row(
          children: [
            Icon(Icons.face_retouching_natural_rounded,
                color: Color(0xFF7C4DFF), size: 18),
            SizedBox(width: 8),
            Text('Set profile photo',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF260D5C))),
          ],
        ),
      ),
    ],
  ).then((selected) {
    if (selected != null && context.mounted) {
      if (selected == 'theme') {
        showDialog(
          context: context,
          builder: (context) => const ThemeSelectionDialog(),
        );
      } else if (selected == 'ornament') {
        showDialog(
          context: context,
          builder: (context) => const OrnamentSelectionDialog(),
        );
      } else if (selected == 'frame') {
        showDialog(
          context: context,
          builder: (context) => const BasicInfoAvatarDialog(initialTab: 0),
        );
      } else if (selected == 'photo') {
        showDialog(
          context: context,
          builder: (context) => const BasicInfoAvatarDialog(initialTab: 1),
        );
      }
    }
  });
}

// Action Button with silver/purple gradient matching mockup
Widget _buildActionButton({
  required String label,
  required VoidCallback? onTap,
  bool isLoading = false,
}) {
  return GestureDetector(
    onTap: isLoading ? null : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLoading
              ? [const Color(0xFFCCCCCC), const Color(0xFFB0B0B0)]
              : [const Color(0xFFE0E0E0), const Color(0xFFB0BEC5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF37474F)),
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF37474F),
              ),
            ),
    ),
  );
}
