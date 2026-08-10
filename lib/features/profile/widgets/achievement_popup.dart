import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class AchievementPopup extends StatefulWidget {
  const AchievementPopup({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        child: AchievementPopup(),
      ),
    );
  }

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_AchievementItem> _badges = const [
    _AchievementItem(name: 'First Victory', desc: 'Win 1 Ludo match', icon: Icons.emoji_events, isUnlocked: true),
    _AchievementItem(name: 'Dice Master', desc: 'Roll 6 ten times', icon: Icons.casino, isUnlocked: true),
    _AchievementItem(name: 'High Roller', desc: 'Win 10,000 coins in a match', icon: Icons.monetization_on, isUnlocked: false),
    _AchievementItem(name: 'Voice Host', desc: 'Host a room for 1 hour', icon: Icons.mic, isUnlocked: false),
  ];

  final List<_AchievementItem> _diceSkins = const [
    _AchievementItem(name: 'Classic Ruby', desc: 'Default Dice Skin', icon: Icons.square, isUnlocked: true),
    _AchievementItem(name: 'Golden Dragon', desc: 'Baron VIP Exclusive', icon: Icons.auto_awesome, isUnlocked: false),
    _AchievementItem(name: 'Neon Cyber', desc: 'Achievement Reward', icon: Icons.lightbulb, isUnlocked: false),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Container(
      width: double.infinity,
      height: 480 * scale,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        gradient: AppColors.modalGradient,
        borderRadius: BorderRadius.circular(28 * scale),
        border: Border.all(color: const Color(0xFFFFD369), width: 2 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20 * scale,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: const Color(0xFFFFD369), size: 24 * scale),
              SizedBox(width: 8 * scale),
              Text(
                'ACHIEVEMENTS & SKINS',
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 16 * scale,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),

          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFFD369),
            labelColor: const Color(0xFFFFD369),
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Badges'),
              Tab(text: 'Dice Skins'),
            ],
          ),
          SizedBox(height: 12 * scale),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGrid(_badges, scale),
                _buildGrid(_diceSkins, scale),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),

          OrangeButton(
            text: 'CLOSE',
            onPressed: () => Navigator.of(context).pop(),
            width: double.infinity,
            height: 40 * scale,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_AchievementItem> items, double scale) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10 * scale,
        mainAxisSpacing: 10 * scale,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF0C073E).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: item.isUnlocked ? const Color(0xFFFFD369) : Colors.white12,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: item.isUnlocked ? const Color(0xFFFFD369) : Colors.white30,
                size: 28 * scale,
              ),
              SizedBox(height: 6 * scale),
              Text(
                item.name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.bold,
                  color: item.isUnlocked ? Colors.white : Colors.white38,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                item.desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9 * scale,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AchievementItem {
  final String name;
  final String desc;
  final IconData icon;
  final bool isUnlocked;

  const _AchievementItem({
    required this.name,
    required this.desc,
    required this.icon,
    required this.isUnlocked,
  });
}
