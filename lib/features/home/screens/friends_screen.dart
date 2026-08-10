import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/home/providers/home_provider.dart';
import 'package:ludo_vibe/shared/widgets/bottom_nav_bar.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  int _selectedTabIndex = 0; // 0 = Facebook Friends, 1 = Game Friends, 2 = Messages, 3 = Recent

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).setBottomNav(BottomNavItem.social);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background main image
          Image.asset(
            'assets/graphics/bg_home.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Social Background Image Overlay
          Image.asset(
            'assets/graphics/Backgroundofsocial.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Main layout Column
          Column(
            children: [
              // Tabs navigation row at the top
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 12 * scale),
                  child: Container(
                    height: 46 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0F69).withOpacity(0.4), // Dark background container
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Row(
                      children: [
                        _buildTab(0, 'Facebook\nFriends', scale),
                        _buildTab(1, 'Game\nFriends', scale),
                        _buildTab(2, 'Messages', scale, hasDot: true),
                        _buildTab(3, 'Recent', scale, hasDot: true),
                      ],
                    ),
                  ),
                ),
              ),

              // Scrollable Tab View area
              Expanded(
                child: _buildTabContent(scale),
              ),

              // Fixed Bottom Navigation docked at the bottom of the screen
              const BottomNavBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, double scale, {bool hasDot = false}) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4C3EC8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10 * scale),
            border: isSelected 
                ? Border.all(color: const Color(0xFF8C7DF5), width: 1.0 * scale) 
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10 * scale,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFFB173FF),
                  height: 1.1,
                ),
              ),
              if (hasDot)
                Positioned(
                  top: -2 * scale,
                  right: -6 * scale,
                  child: Container(
                    width: 8 * scale,
                    height: 8 * scale,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.6),
                          blurRadius: 4 * scale,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(double scale) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildFacebookTab(scale);
      case 1:
        return _buildGameFriendsTab(scale);
      case 2:
        return _buildMessagesTab(scale);
      case 3:
        return _buildRecentTab(scale);
      default:
        return const SizedBox.shrink();
    }
  }

  // Tab 0 - Facebook Friends
  Widget _buildFacebookTab(double scale) {
    return Column(
      children: [
        const Spacer(flex: 3),
        
        // Silhouette No Friends Image Asset
        Image.asset(
          'assets/graphics/NoFriends.png',
          width: 130 * scale,
          height: 90 * scale,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 12 * scale),
        Text(
          'No Friends',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20 * scale,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF150B42),
          ),
        ),
        
        const Spacer(flex: 4),
        
        // Row of 3 Buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: Row(
            children: [
              Expanded(
                child: _buildFooterButton(
                  'Join\nGroup', 
                  scale, 
                  icon: Icons.facebook, 
                  onTap: () {}
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _buildFooterButton(
                  'Official\nPage', 
                  scale, 
                  icon: Icons.home_outlined, 
                  onTap: () {}
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _buildFooterButton(
                  'Add\nFriends', 
                  scale, 
                  onTap: () {}
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20 * scale),
      ],
    );
  }

  // Tab 1 - Game Friends
  Widget _buildGameFriendsTab(double scale) {
    return Column(
      children: [
        const Spacer(flex: 3),
        
        // Silhouette No Friends Image Asset
        Image.asset(
          'assets/graphics/NoFriends.png',
          width: 130 * scale,
          height: 90 * scale,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 12 * scale),
        Text(
          'No Friends',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20 * scale,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF150B42),
          ),
        ),
        
        const Spacer(flex: 4),
        
        // Large Add Game Friend Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: SizedBox(
            width: double.infinity,
            height: 48 * scale,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C3EC8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * scale),
                  side: BorderSide(color: const Color(0xFF8C7DF5), width: 1.0 * scale),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18 * scale),
                  SizedBox(width: 8 * scale),
                  Text(
                    'Add a game friend',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(height: 20 * scale),
      ],
    );
  }

  // Tab 2 - Messages
  Widget _buildMessagesTab(double scale) {
    return Column(
      children: [
        SizedBox(height: 8 * scale),
        
        // Semi-transparent message list card
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1054).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.4), width: 1.5 * scale),
            ),
            child: Column(
              children: [
                _buildMessageItem(
                  'System',
                  'The monthly free.....',
                  '06-01 02:22',
                  scale,
                  icon: Icons.notifications_rounded,
                  color: const Color(0xFFFFD200),
                ),
                _buildDivider(scale),
                _buildMessageItem(
                  'Activity',
                  'Send diamond gifts....',
                  '17:22',
                  scale,
                  icon: Icons.card_giftcard_rounded,
                  color: const Color(0xFFFF7A00),
                ),
                _buildDivider(scale),
                _buildMessageItem(
                  'Friend Request',
                  'Click to view friend requests',
                  '',
                  scale,
                  icon: Icons.group_add_rounded,
                  color: const Color(0xFF00B2FF),
                ),
              ],
            ),
          ),
        ),
        
        const Spacer(),
      ],
    );
  }

  // Tab 3 - Recent
  Widget _buildRecentTab(double scale) {
    return Column(
      children: [
        SizedBox(height: 8 * scale),
        
        // Semi-transparent recent players list card
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1054).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.4), width: 1.5 * scale),
            ),
            child: Column(
              children: [
                _buildRecentPlayerItem(scale),
                _buildDivider(scale),
                _buildRecentPlayerItem(scale),
                _buildDivider(scale),
                _buildRecentPlayerItem(scale),
              ],
            ),
          ),
        ),
        
        const Spacer(),
      ],
    );
  }

  Widget _buildMessageItem(
    String title,
    String subtitle,
    String time,
    double scale, {
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44 * scale,
            height: 44 * scale,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6 * scale,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24 * scale),
          ),
          Positioned(
            top: -2 * scale,
            right: -2 * scale,
            child: Container(
              width: 14 * scale,
              height: 14 * scale,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '1',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 8.5 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11 * scale,
          color: const Color(0xFFB173FF),
        ),
      ),
      trailing: time.isNotEmpty
          ? Text(
              time,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10 * scale,
                color: const Color(0xFFB173FF),
              ),
            )
          : null,
    );
  }

  Widget _buildRecentPlayerItem(double scale) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
      leading: Container(
        width: 44 * scale,
        height: 44 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFD200), width: 2.0 * scale), // Gold border avatar
          color: Colors.white12,
        ),
        child: Icon(
          Icons.person,
          color: Colors.white.withOpacity(0.8),
          size: 28 * scale,
        ),
      ),
      title: const SizedBox.shrink(), // No title/name text in Figma reference
      trailing: Container(
        width: 80 * scale,
        height: 30 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8 * scale),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF9000), Color(0xFFF05A00)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 4 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8 * scale),
            child: Center(
              child: Text(
                'Add',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(double scale) {
    return Divider(
      color: const Color(0xFF5D48E8).withOpacity(0.2),
      height: 1,
      thickness: 1,
      indent: 14 * scale,
      endIndent: 14 * scale,
    );
  }

  Widget _buildFooterButton(String text, double scale, {IconData? icon, required VoidCallback onTap}) {
    return Container(
      height: 42 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF4C3EC8),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: const Color(0xFF8C7DF5), width: 1.0 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10 * scale),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 16 * scale),
                  SizedBox(width: 4 * scale),
                ],
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
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
