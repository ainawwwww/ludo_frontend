import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/home/providers/home_provider.dart';
import 'package:ludo_vibe/shared/widgets/bottom_nav_bar.dart';

class BattleLobbyScreen extends ConsumerStatefulWidget {
  const BattleLobbyScreen({super.key});

  @override
  ConsumerState<BattleLobbyScreen> createState() => _BattleLobbyScreenState();
}

class _BattleLobbyScreenState extends ConsumerState<BattleLobbyScreen> {
  int _selectedTabIndex = 0; // 0 = Explore, 1 = Hot, 2 = My
  int _selectedSubTabIndex = 0; // For 'My' tab: 0 = Recently, 1 = Joined, 2 = Following, 3 = Friends

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).setBottomNav(BottomNavItem.chat);
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
          // Cover background
          Image.asset(
            'assets/graphics/bg_home.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Main content column
          Column(
            children: [
              // Header Tabs
              SafeArea(
                bottom: false,
                child: Container(
                  height: 62 * scale, // Increased from 52
                  padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                  child: Row(
                    children: [
                      // Header Navigation
                      Row(
                        children: [
                          _buildHeaderTab(0, 'Explore', scale),
                          _buildHeaderTab(1, 'Hot', scale),
                          _buildHeaderTab(2, 'My', scale),
                        ],
                      ),
                      const Spacer(),
                      // Search button Q
                      IconButton(
                        onPressed: () {
                          context.push(AppConstants.countrySelectRoute);
                        },
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24 * scale,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab contents
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                  child: _buildActiveTabContent(scale),
                ),
              ),

              // Bottom Nav Bar docked
              const BottomNavBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTab(int index, String label, double scale) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        height: 44 * scale, // Increased from 36
        padding: EdgeInsets.symmetric(horizontal: 18 * scale), // Increased from 14
        alignment: Alignment.center,
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(22 * scale), // Updated border radius
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E2DE2).withOpacity(0.4),
                    blurRadius: 8 * scale,
                  ),
                ],
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18 * scale, // Increased from 14
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(double scale) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildExploreContent(scale);
      case 1:
        return _buildHotContent(scale);
      case 2:
        return _buildMyContent(scale);
      default:
        return const SizedBox.shrink();
    }
  }

  // Explore Tab Content
  Widget _buildExploreContent(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Entry Title
        Text(
          'Quick Entry',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * scale),

        // Quick Entry Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8 * scale,
          crossAxisSpacing: 8 * scale,
          childAspectRatio: 1.8,
          children: [
            _buildQuickEntryCard(
              'New here',
              'assets/graphics/card_private.png',
              const [Color(0xFF00B2FF), Color(0xFF0072BC)],
              scale,
            ),
            _buildQuickEntryCard(
              'Find Friends',
              'assets/graphics/card_team.png',
              const [Color(0xFF56AB2F), Color(0xFF1D976C)],
              scale,
            ),
            _buildQuickEntryCard(
              'Small talk',
              'assets/graphics/card_domino_1v1.png',
              const [Color(0xFF00D2FF), Color(0xFF0072BC)],
              scale,
            ),
            _buildQuickEntryCard(
              'Enjoy Music',
              'assets/graphics/card_vip.png',
              const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              scale,
            ),
          ],
        ),
        SizedBox(height: 16 * scale),

        // Country Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Country',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push(AppConstants.countrySelectRoute);
              },
              child: Text(
                'More >',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB173FF),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),

        // Country Grid Box
        Container(
          padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 14 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF1C135C).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.3), width: 1 * scale),
          ),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.0, // Adjusted from 2.2
            mainAxisSpacing: 10 * scale,
            crossAxisSpacing: 10 * scale,
            children: [
              _buildCountryChip('🇵🇰', 'Pakistan', scale),
              _buildCountryChip('🇮🇳', 'India', scale),
              _buildCountryChip('🇸🇦', 'KSA', scale),
              _buildCountryChip('🇧🇩', 'Bangladesh', scale),
              _buildCountryChip('🇦🇪', 'UAE', scale),
              _buildCountryChip('🇩🇿', 'Algeria', scale),
            ],
          ),
        ),
        SizedBox(height: 16 * scale),

        // Recommend Title
        Text(
          'Recommend',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * scale),

        // 3 Chat rooms in list
        _buildRecommendRoom('Friendly Chats & Ludo Vibe', 'assets/graphics/card_2v4_players.png', '142', ['Ludo', 'Social'], scale),
        SizedBox(height: 8 * scale),
        _buildRecommendRoom('Chill Beats & Domino Lounge', 'assets/graphics/card_domino_1v1.png', '89', ['Music', 'Domino'], scale),
        SizedBox(height: 8 * scale),
        _buildRecommendRoom('Jackaroo Elite Club', 'assets/graphics/card_jackaroo_basic.png', '54', ['Jackaroo', 'Elite'], scale),
        SizedBox(height: 10 * scale),
      ],
    );
  }

  Widget _buildQuickEntryCard(String title, String bgAsset, List<Color> colors, double scale) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * scale),
        image: DecorationImage(
          image: AssetImage(bgAsset),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            colors.first.withOpacity(0.65), // Rich colored overlay
            BlendMode.srcOver,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 6 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glassmorphic shimmer reflection overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * scale),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12 * scale,
            bottom: 12 * scale,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14 * scale, // Increased font size to 14
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black87,
                    offset: Offset(0, 1.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryChip(String flag, String name, double scale) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: TextStyle(fontSize: 26 * scale)), // Increased flag size from 18 to 26
          SizedBox(width: 6 * scale),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14 * scale, // Increased text size from 11 to 14
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendRoom(String name, String imageAsset, String members, List<String> tags, double scale) {
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C135C).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.3), width: 1 * scale),
      ),
      child: Row(
        children: [
          // Circular room avatar
          Container(
            width: 44 * scale,
            height: 44 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD200), width: 1.5 * scale),
              color: Colors.white24,
            ),
            child: Icon(Icons.meeting_room_rounded, color: Colors.white.withOpacity(0.9), size: 24 * scale),
          ),
          SizedBox(width: 10 * scale),
          
          // Room Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Row(
                  children: [
                    Icon(Icons.person, color: const Color(0xFFB173FF), size: 12 * scale),
                    SizedBox(width: 2 * scale),
                    Text(
                      members,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10 * scale,
                        color: const Color(0xFFB173FF),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    ...tags.map((tag) => Container(
                      margin: EdgeInsets.only(right: 4 * scale),
                      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C3EC8).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4 * scale),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.5 * scale,
                          color: const Color(0xFFB173FF),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          
          // Join Button
          Container(
            width: 54 * scale,
            height: 26 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6 * scale),
              gradient: const LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(6 * scale),
                child: Center(
                  child: Text(
                    'Join',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hot Tab Content
  Widget _buildHotContent(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Hosts Title
        Text(
          'Popular Hosts',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * scale),

        // Horizontal Hosts List
        SizedBox(
          height: 70 * scale,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildHostAvatar('Ali 🔥', const Color(0xFFFFD200), scale),
              SizedBox(width: 10 * scale),
              _buildHostAvatar('Sara ✨', const Color(0xFFE31E24), scale),
              SizedBox(width: 10 * scale),
              _buildHostAvatar('Ahmed ⚔️', const Color(0xFF00D2FF), scale),
              SizedBox(width: 10 * scale),
              _buildHostAvatar('Zain 👑', const Color(0xFF8E2DE2), scale),
              SizedBox(width: 10 * scale),
              _buildHostAvatar('Nida 🎙️', const Color(0xFF56AB2F), scale),
            ],
          ),
        ),
        SizedBox(height: 16 * scale),

        // Trending Rooms Title
        Text(
          'Trending Live Rooms',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * scale),

        // Live rooms list
        _buildRecommendRoom('🔴 Ludo Master Championship live', 'assets/graphics/card_tournament.png', '342', ['Ludo', 'Live'], scale),
        SizedBox(height: 8 * scale),
        _buildRecommendRoom('🎧 Request your songs here!', 'assets/graphics/card_vip.png', '224', ['Music', 'Party'], scale),
        SizedBox(height: 8 * scale),
        _buildRecommendRoom('Talk Room: Meet New Friends', 'assets/graphics/card_private.png', '175', ['Social', 'Chills'], scale),
        SizedBox(height: 10 * scale),
      ],
    );
  }

  Widget _buildHostAvatar(String name, Color border, double scale) {
    return Column(
      children: [
        Container(
          width: 48 * scale,
          height: 48 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 2.0 * scale),
            color: Colors.white24,
          ),
          child: Icon(Icons.person, color: Colors.white, size: 28 * scale),
        ),
        SizedBox(height: 4 * scale),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9.5 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // My Tab Content
  Widget _buildMyContent(double scale) {
    return Column(
      children: [
        // Create My Room Card
        SizedBox(height: 16 * scale),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: double.infinity,
              height: 110 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF), // Light grey/purple card background
                borderRadius: BorderRadius.circular(16 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Create My Room',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C198E), // Bold purple color
                  ),
                ),
              ),
            ),
            // Floating + icon container overlapping top border
            Positioned(
              top: -20 * scale,
              child: Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C3EC8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C3EC8).withOpacity(0.4),
                      blurRadius: 6 * scale,
                      offset: Offset(0, 3 * scale),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 26 * scale,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24 * scale),

        // Sub-tabs row (Recently, Joined, Following, Friends)
        Container(
          height: 38 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFF1B0F69).withOpacity(0.4),
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Row(
            children: [
              _buildSubTab(0, 'Recently', scale),
              _buildSubTab(1, 'Joined', scale),
              _buildSubTab(2, 'Following', scale),
              _buildSubTab(3, 'Friends', scale),
            ],
          ),
        ),
        
        // Empty placeholder space
        SizedBox(height: 32 * scale),
        
        // House/Village silhouette icon
        Icon(
          Icons.home_work_rounded,
          size: 90 * scale,
          color: const Color(0xFF2C198E).withOpacity(0.35),
        ),
        SizedBox(height: 12 * scale),
        
        Text(
          "You have'nt visited any rooms",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24 * scale),

        // Go Find Rooms Button
        Container(
          width: 220 * scale,
          height: 44 * scale,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22 * scale),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9000), Color(0xFFF05A00)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 6 * scale,
                offset: Offset(0, 3 * scale),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0; // Switches directly to Explore tab!
                });
              },
              borderRadius: BorderRadius.circular(22 * scale),
              child: Center(
                child: Text(
                  'Go Find Rooms',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: 24 * scale),
      ],
    );
  }

  Widget _buildSubTab(int index, String label, double scale) {
    final isSelected = _selectedSubTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSubTabIndex = index;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4C3EC8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11 * scale,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFFB173FF),
            ),
          ),
        ),
      ),
    );
  }
}
