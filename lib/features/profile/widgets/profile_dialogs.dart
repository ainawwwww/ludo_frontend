import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF9D84F7), // Soft purple outer border/gradient frame
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
              child,
            ],
          ),
        ),
      ),
    );
  }
}

void showProfileFeedbackSnackBar(BuildContext context, {required bool isSuccess, String? message}) {
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
              message ?? (isSuccess ? 'Saved successfully' : 'Failed to save — check your connection'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
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
  State<GenderInformationDialog> createState() => _GenderInformationDialogState();
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
                  onTap: _isSaving ? null : () => setState(() => _selected = label),
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
                          color: isSelected ? const Color(0xFF7C53F6) : Colors.white,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
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
                        ? const Icon(Icons.check_circle, color: Color(0xFF7C53F6), size: 20)
                        : null,
                    onTap: _isSaving ? null : () => setState(() => _selected = c['name']!),
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
  State<BirthdaySelectionDialog> createState() => _BirthdaySelectionDialogState();
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
            title: Text('Day ${days[index]}', style: const TextStyle(color: Colors.white)),
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D0F64),
      builder: (context) => SizedBox(
        height: 240,
        child: ListView.builder(
          itemCount: months.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(months[index], style: const TextStyle(color: Colors.white)),
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

// 5. Basic Info Avatar Customizer Dialog (iPhone 16 - 147)
class BasicInfoAvatarDialog extends ConsumerWidget {
  const BasicInfoAvatarDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarIdx = ref.watch(profileProvider).avatarIndex;

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
                  avatarIndex: avatarIdx,
                  size: 72,
                  borderWidth: 3,
                  avatarUrl: ref.watch(profileProvider).avatarUrl ?? ref.watch(authProvider).user?.avatarUrl,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8F00),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tabs: Profile Frame | Profile Photo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Profile Frame',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD54F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Grid of 12 Profile Photos / Avatars
            SizedBox(
              height: 180,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final isSelected = (avatarIdx % 4) == (index % 4);

                  return GestureDetector(
                    onTap: () {
                      ref.read(profileProvider.notifier).setAvatar(index % 4);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFFD54F) : Colors.white54,
                          width: isSelected ? 3 : 1.5,
                        ),
                      ),
                      child: AvatarDisplay(
                        avatarIndex: index % 4,
                        size: 40,
                        borderWidth: 1.5,
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

// 6. Cloth Menu Popover (iPhone 16 - 135)
void showClothMenuPopover(BuildContext context, WidgetRef ref) {
  final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;

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
        child: Text('Set ornament', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF260D5C))),
      ),
      PopupMenuItem(
        value: 'theme',
        child: Text('Set profile theme', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF260D5C))),
      ),
      PopupMenuItem(
        value: 'card',
        child: Text('Set profile card', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF260D5C))),
      ),
      PopupMenuItem(
        value: 'frame',
        child: Text('Set profile frame', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF260D5C))),
      ),
    ],
  ).then((selected) {
    if (selected != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => const BasicInfoAvatarDialog(),
      );
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
