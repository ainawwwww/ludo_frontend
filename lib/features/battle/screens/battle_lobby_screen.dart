import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/battle/models/lobby_model.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';
import 'package:ludo_vibe/features/battle/providers/battle_provider.dart';
import 'package:ludo_vibe/features/home/providers/home_provider.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/social/providers/chat_flow_provider.dart';
import 'package:ludo_vibe/features/social/widgets/user_profile_modal.dart';
import 'package:ludo_vibe/shared/widgets/bottom_nav_bar.dart';

class BattleLobbyScreen extends ConsumerStatefulWidget {
  const BattleLobbyScreen({super.key});

  @override
  ConsumerState<BattleLobbyScreen> createState() => _BattleLobbyScreenState();
}

class _BattleLobbyScreenState extends ConsumerState<BattleLobbyScreen> {
  final TextEditingController _roomIdSearchController = TextEditingController();
  String _selectedHotCountry = 'PK';
  String _selectedHotLanguage = 'English';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).setBottomNav(BottomNavItem.chat);
      ref.read(battleLobbyProvider.notifier).setTab(0); // Always default to Explore tab
      // Trigger initial load
      ref.read(battleLobbyProvider.notifier).loadExploreData();
    });
  }

  @override
  void dispose() {
    _roomIdSearchController.dispose();
    super.dispose();
  }

  String _normalizeCountryCode(String input) {
    final upper = input.trim().toUpperCase();
    const map = {
      'PAKISTAN': 'PK',
      'INDIA': 'IN',
      'SAUDI ARABIA': 'SA',
      'KSA': 'SA',
      'BANGLADESH': 'BD',
      'UAE': 'AE',
      'UNITED ARAB EMIRATES': 'AE',
      'ALGERIA': 'DZ',
      'UNITED KINGDOM': 'GB',
      'UK': 'GB',
      'UNITED STATES': 'US',
      'USA': 'US',
    };
    return map[upper] ?? (upper.length == 2 ? upper : input);
  }

  String _getCountryDisplayName(String? code) {
    if (code == null || code.isEmpty) return '';
    final upper = code.trim().toUpperCase();
    const map = {
      'PK': 'Pakistan',
      'IN': 'India',
      'SA': 'KSA',
      'BD': 'Bangladesh',
      'AE': 'UAE',
      'DZ': 'Algeria',
      'GB': 'United Kingdom',
      'US': 'United States',
    };
    return map[upper] ?? code;
  }

  bool _isCountrySelected(String? current, String code) {
    if (current == null) return false;
    return current.toUpperCase() == code.toUpperCase() ||
           _normalizeCountryCode(current) == code.toUpperCase();
  }

  Future<void> _handleCountrySearch() async {
    final selected = await context.push<String?>(AppConstants.countrySelectRoute);
    if (selected != null && mounted) {
      final code = _normalizeCountryCode(selected);
      ref.read(battleLobbyProvider.notifier).selectCountry(code);
      ref.read(chatFlowProvider.notifier).selectCountry(code);
    }
  }

  void _handleJoinRoom(RoomModel room) {
    ref.read(chatFlowProvider.notifier).visitRoom(room);
    ref.read(battleLobbyProvider.notifier).joinRoomAsListener(room.roomId);
    context.push(
      AppConstants.roomDetailRoute,
      extra: {
        'title': room.title,
        'id': room.roomId.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;
    final lobbyState = ref.watch(battleLobbyProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Cover background (cosmic dark theme matching explore and my)
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
                  height: 62 * scale,
                  padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                  child: Row(
                    children: [
                      // User Avatar with Level Badge (matching screenshot)
                      _buildHeaderUserAvatar(scale),
                      SizedBox(width: 8 * scale),

                      // Header Navigation
                      Row(
                        children: [
                          _buildHeaderTab(0, 'Explore', lobbyState.selectedTab == 0, scale),
                          _buildHeaderTab(1, 'Hot', lobbyState.selectedTab == 1, scale),
                          _buildHeaderTab(2, 'My', lobbyState.selectedTab == 2, scale),
                        ],
                      ),
                      const Spacer(),
                      // Friend Requests button
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => context.push(AppConstants.friendRequestRoute),
                        icon: Icon(
                          Icons.person_add_alt_1_rounded,
                          color: const Color(0xFFFFD200),
                          size: 20 * scale,
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      // Search button
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _handleCountrySearch,
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 22 * scale,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab contents with Pull-to-Refresh
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF8E2DE2),
                  onRefresh: () async {
                    if (lobbyState.selectedTab == 0) {
                      await ref.read(battleLobbyProvider.notifier).loadExploreData();
                    } else if (lobbyState.selectedTab == 1) {
                      await ref.read(battleLobbyProvider.notifier).loadHotData();
                    } else {
                      final filter = BattleLobbyState.mySubTabFilters[lobbyState.selectedMySubTab];
                      await ref.read(battleLobbyProvider.notifier).loadMyRoomsData(filter);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                    child: _buildActiveTabContent(lobbyState, scale),
                  ),
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

  Widget _buildHeaderUserAvatar(double scale) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36 * scale,
          height: 36 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB173FF), width: 1.8 * scale),
            color: const Color(0xFF1B0F69),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/graphics/profile/avatars/avatar_golden_sheikh.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.person, color: Colors.white70, size: 20 * scale),
            ),
          ),
        ),
        Positioned(
          bottom: -2 * scale,
          right: -2 * scale,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.5 * scale, vertical: 0.5 * scale),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD200), Color(0xFFFF9000)],
              ),
              borderRadius: BorderRadius.circular(5 * scale),
              border: Border.all(color: Colors.white, width: 0.8 * scale),
            ),
            child: Text(
              '1',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 7.5 * scale,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTab(int index, String label, bool isSelected, double scale) {
    return GestureDetector(
      onTap: () {
        ref.read(battleLobbyProvider.notifier).setTab(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 36 * scale,
            padding: EdgeInsets.symmetric(horizontal: 14 * scale),
            alignment: Alignment.center,
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(18 * scale),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E2DE2).withOpacity(0.45),
                        blurRadius: 8 * scale,
                      ),
                    ],
                  )
                : null,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15 * scale,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(BattleLobbyState state, double scale) {
    switch (state.selectedTab) {
      case 0:
        return _buildExploreContent(state, scale);
      case 1:
        return _buildHotContent(state, scale);
      case 2:
        return _buildMyContent(state, scale);
      default:
        return const SizedBox.shrink();
    }
  }

  // ======================== Explore Tab Content ========================
  Widget _buildExploreContent(BattleLobbyState state, double scale) {
    // Use API data from battleLobbyProvider instead of hardcoded chatFlowProvider
    final exploreData = state.exploreData;
    final exploreRooms = exploreData?.recommendedRooms ?? [];

    final cards = [
      QuickEntryCardModel(
        id: 'new_here',
        title: 'New Here',
        description: 'Random live chat room entry',
        bgAsset: 'assets/graphics/card_quick_new_here.png',
        gradient: const [Color(0xFF00B2FF), Color(0xFF0072BC)],
        filterCategory: 'social',
        tags: ['Beginner', 'Casual'],
      ),
      QuickEntryCardModel(
        id: 'find_friends',
        title: 'Find Friends',
        description: 'Make new gaming buddies',
        bgAsset: 'assets/graphics/card_quick_find_friends.png',
        gradient: const [Color(0xFF56AB2F), Color(0xFF1D976C)],
        filterCategory: 'friends',
        tags: ['Social', 'Chat'],
      ),
    ];

    final currentSelectedCountry = state.selectedCountry;

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
          children: cards.map((card) => _buildQuickEntryCard(card, scale)).toList(),
        ),
        SizedBox(height: 16 * scale),

        // Country Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                if (currentSelectedCountry != null) ...[
                  SizedBox(width: 8 * scale),
                  GestureDetector(
                    onTap: () {
                      ref.read(battleLobbyProvider.notifier).selectCountry(null);
                      ref.read(battleLobbyProvider.notifier).selectCountry(null);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E2DE2).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(color: const Color(0xFFFFD200), width: 1 * scale),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _getCountryDisplayName(currentSelectedCountry),
                            style: TextStyle(fontSize: 10 * scale, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4 * scale),
                          Icon(Icons.close, size: 12 * scale, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            GestureDetector(
              onTap: _handleCountrySearch,
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
            childAspectRatio: 2.0,
            mainAxisSpacing: 10 * scale,
            crossAxisSpacing: 10 * scale,
            children: [
              _buildCountryChip('🇵🇰', 'Pakistan', 'PK', _isCountrySelected(currentSelectedCountry, 'PK'), scale),
              _buildCountryChip('🇮🇳', 'India', 'IN', _isCountrySelected(currentSelectedCountry, 'IN'), scale),
              _buildCountryChip('🇸🇦', 'KSA', 'SA', _isCountrySelected(currentSelectedCountry, 'SA'), scale),
              _buildCountryChip('🇧🇩', 'Bangladesh', 'BD', _isCountrySelected(currentSelectedCountry, 'BD'), scale),
              _buildCountryChip('🇦🇪', 'UAE', 'AE', _isCountrySelected(currentSelectedCountry, 'AE'), scale),
              _buildCountryChip('🇩🇿', 'Algeria', 'DZ', _isCountrySelected(currentSelectedCountry, 'DZ'), scale),
            ],
          ),
        ),
        SizedBox(height: 16 * scale),

        // Recommend Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommend Rooms',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),

        // Dynamic Recommended Rooms Grid (2 Columns)
        // Loading state
        if (state.isLoading && exploreRooms.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24 * scale),
              child: const CircularProgressIndicator(color: Color(0xFF8E2DE2)),
            ),
          )
        else if (exploreRooms.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10 * scale,
              mainAxisSpacing: 10 * scale,
              childAspectRatio: 0.82,
            ),
            itemCount: exploreRooms.length,
            itemBuilder: (context, index) => _buildGridRoomCard(exploreRooms[index], scale),
          )
        else
          // Polished Empty State for Filter
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 28 * scale, horizontal: 16 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF1C135C).withOpacity(0.3),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.travel_explore_rounded,
                  size: 54 * scale,
                  color: const Color(0xFFB173FF).withOpacity(0.5),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  'No rooms found for this selection',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 14 * scale),
                GestureDetector(
                   onTap: () {
                    ref.read(battleLobbyProvider.notifier).selectCountry(null);
                    ref.read(battleLobbyProvider.notifier).loadExploreData();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16 * scale),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      ),
                    ),
                    child: Text(
                      'Show All Rooms',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 10 * scale),
      ],
    );
  }

  Widget _buildQuickEntryCard(QuickEntryCardModel card, double scale) {
    final activeCat = ref.watch(chatFlowProvider).activeCategory;
    final isSelected = activeCat != null && activeCat.toLowerCase() == card.filterCategory.toLowerCase();

    return GestureDetector(
      onTap: () {
        if (card.id == 'find_friends') {
          context.push(AppConstants.friendRequestRoute);
        } else if (card.id == 'new_here') {
          final recommended = ref.read(battleLobbyProvider).exploreData?.recommendedRooms ?? [];
          if (recommended.isNotEmpty) {
            final randomRoom = recommended[math.Random().nextInt(recommended.length)];
            _handleJoinRoom(randomRoom);
          } else {
            final all = ref.read(chatFlowProvider).allRooms;
            if (all.isNotEmpty) {
              final randomRoom = all[math.Random().nextInt(all.length)];
              _handleJoinRoom(randomRoom);
            }
          }
        } else {
          ref.read(chatFlowProvider.notifier).setFilterCategory(card.filterCategory);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * scale),
          border: isSelected ? Border.all(color: const Color(0xFFFFD200), width: 2 * scale) : null,
          image: DecorationImage(
            image: AssetImage(card.bgAsset),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              card.gradient.first.withOpacity(0.65),
              BlendMode.srcOver,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: card.gradient.first.withOpacity(0.3),
              blurRadius: 6 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Stack(
          children: [
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
                card.title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14 * scale,
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
      ),
    );
  }

  Widget _buildCountryChip(String flag, String name, String code, bool isSelected, double scale) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          ref.read(battleLobbyProvider.notifier).selectCountry(null);
          ref.read(chatFlowProvider.notifier).selectCountry(null);
        } else {
          ref.read(battleLobbyProvider.notifier).selectCountry(code);
          ref.read(chatFlowProvider.notifier).selectCountry(code);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 4 * scale),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8 * scale),
                border: Border.all(color: const Color(0xFFFFD200), width: 1.5 * scale),
                color: const Color(0xFF8E2DE2).withOpacity(0.4),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: TextStyle(fontSize: 22 * scale)),
            SizedBox(width: 5 * scale),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFFFFD200) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCountryFlag(String? code) {
    switch (code?.toUpperCase()) {
      case 'PK': return '🇵🇰';
      case 'IN': return '🇮🇳';
      case 'SA': case 'KSA': return '🇸🇦';
      case 'AE': case 'UAE': return '🇦🇪';
      case 'BD': return '🇧🇩';
      case 'KW': return '🇰🇼';
      case 'QA': return '🇶🇦';
      case 'TR': return '🇹🇷';
      case 'EG': return '🇪🇬';
      case 'GB': case 'UK': return '🇬🇧';
      case 'DZ': return '🇩🇿';
      case 'DE': return '🇩🇪';
      case 'US': return '🇺🇸';
      default: return '🌐';
    }
  }

  Widget _buildGridRoomCard(RoomModel room, double scale) {
    final flag = _getCountryFlag(room.countryCode);
    final subtitle = room.tags.isNotEmpty ? '☆•${room.tags.join(' • ')}' : '☆•Welcome everyone ❤️';

    return GestureDetector(
      onTap: () => _handleJoinRoom(room),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Cover Artwork with Listener Badge
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (room.coverImage != null && room.coverImage!.isNotEmpty)
                      Image.asset(
                        room.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1B0F69),
                          child: Icon(Icons.meeting_room_rounded, color: Colors.white54, size: 36 * scale),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFF1B0F69),
                        child: Icon(Icons.meeting_room_rounded, color: Colors.white54, size: 36 * scale),
                      ),

                    // Top-right Listener count badge: 📶 17
                    Positioned(
                      top: 6 * scale,
                      right: 6 * scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(8 * scale),
                          border: Border.all(color: Colors.white24, width: 0.5 * scale),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.signal_cellular_alt_rounded, color: const Color(0xFF00FFCC), size: 11 * scale),
                            SizedBox(width: 3 * scale),
                            Text(
                              '${room.memberCount}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9.5 * scale,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom White Plaque
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 6 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(flag, style: TextStyle(fontSize: 12 * scale)),
                        SizedBox(width: 4 * scale),
                        Expanded(
                          child: Text(
                            room.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5 * scale,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9 * scale,
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ======================== Hot Tab Content ========================
  Widget _buildHotContent(BattleLobbyState state, double scale) {
    final hotRoomsList = state.hotData?.trendingRooms ?? [];
    var hotRooms = hotRoomsList;
    if (_roomIdSearchController.text.isNotEmpty) {
      final q = _roomIdSearchController.text.trim().toLowerCase();
      hotRooms = hotRooms.where((r) =>
        r.title.toLowerCase().contains(q) ||
        (r.roomCode != null && r.roomCode!.toLowerCase().contains(q)) ||
        r.roomId.toString().contains(q)
      ).toList();
    }
    if (_selectedHotCountry != 'ALL') {
      hotRooms = hotRooms.where((r) => (r.countryCode ?? '').toUpperCase() == _selectedHotCountry.toUpperCase()).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Decorative garland lights
        _buildFairyLightsGarland(scale),
        SizedBox(height: 6 * scale),

        // Top 2 Gift Cards: Room Gifts & Gifts Received
        _buildTopGiftCards(scale),
        SizedBox(height: 10 * scale),

        // Live Gift Ticker
        _buildLiveGiftTicker(scale),
        SizedBox(height: 10 * scale),

        // Find with Room ID or Link box
        _buildRoomIdSearchBox(scale),
        SizedBox(height: 10 * scale),

        // Country & Language Filter Row (Pakistan ⌵, English ⌵)
        _buildFilterRow(scale),
        SizedBox(height: 12 * scale),

        // 3-Column Rooms Grid
        if (state.isLoading && hotRooms.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 36 * scale),
              child: const CircularProgressIndicator(color: Color(0xFF8E2DE2)),
            ),
          )
        else if (hotRooms.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8 * scale,
              mainAxisSpacing: 10 * scale,
              childAspectRatio: 0.68,
            ),
            itemCount: hotRooms.length,
            itemBuilder: (context, index) => _buildHotGridRoomCard(hotRooms[index], scale),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(vertical: 36 * scale, horizontal: 16 * scale),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  size: 48 * scale,
                  color: const Color(0xFFB173FF).withOpacity(0.5),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  _roomIdSearchController.text.isNotEmpty
                      ? 'No room found matching "${_roomIdSearchController.text}"'
                      : 'No rooms found in ${_getCountryName(_selectedHotCountry)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 12 * scale),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _roomIdSearchController.clear();
                      _selectedHotCountry = 'ALL';
                    });
                    ref.read(chatFlowProvider.notifier).selectCountry(null);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 7 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14 * scale),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      ),
                    ),
                    child: Text(
                      'Show All Rooms',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 16 * scale),
      ],
    );
  }

  Widget _buildFairyLightsGarland(double scale) {
    return SizedBox(
      height: 12 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(14, (i) {
          final isBig = i % 3 == 0;
          return Container(
            width: (isBig ? 4.5 : 3.0) * scale,
            height: (isBig ? 4.5 : 3.0) * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBig ? const Color(0xFFFFD200) : const Color(0xFF00FFCC),
              boxShadow: [
                BoxShadow(
                  color: (isBig ? const Color(0xFFFFD200) : const Color(0xFF8E2DE2)).withOpacity(0.8),
                  blurRadius: 4 * scale,
                  spreadRadius: 1 * scale,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopGiftCards(double scale) {
    return Row(
      children: [
        // Room Gifts card
        Expanded(
          child: Container(
            height: 56 * scale,
            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.4), width: 1.2 * scale),
              gradient: const LinearGradient(
                colors: [Color(0xFF281366), Color(0xFF140838)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 6 * scale,
                  offset: Offset(0, 3 * scale),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 30 * scale,
                  height: 30 * scale,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                    ),
                  ),
                  child: Icon(Icons.military_tech_rounded, color: const Color(0xFFB71C1C), size: 20 * scale),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Room',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Gifts',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 32 * scale,
                      height: 32 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5 * scale),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/graphics/rooms/room_madrid.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.black45),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2 * scale,
                      right: -2 * scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 0.5 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(6 * scale),
                          border: Border.all(color: Colors.white, width: 0.8 * scale),
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 7 * scale,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10 * scale),
        // Gifts Received card
        Expanded(
          child: Container(
            height: 56 * scale,
            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.4), width: 1.2 * scale),
              gradient: const LinearGradient(
                colors: [Color(0xFF281366), Color(0xFF140838)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 6 * scale,
                  offset: Offset(0, 3 * scale),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 30 * scale,
                  height: 30 * scale,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                    ),
                  ),
                  child: Icon(Icons.military_tech_rounded, color: const Color(0xFFB71C1C), size: 20 * scale),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Gifts',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Received',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 32 * scale,
                      height: 32 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5 * scale),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/graphics/wealthy_avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.black45),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2 * scale,
                      right: -2 * scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 0.5 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(6 * scale),
                          border: Border.all(color: Colors.white, width: 0.8 * scale),
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 7 * scale,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveGiftTicker(double scale) {
    return Container(
      height: 40 * scale,
      padding: EdgeInsets.symmetric(horizontal: 10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0E52).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.55), width: 1.2 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E2DE2).withOpacity(0.18),
            blurRadius: 8 * scale,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 26 * scale,
            height: 26 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD200), width: 1.2 * scale),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/graphics/profile/avatars/avatar_fox_magician.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black38),
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontFamily: 'Poppins', fontSize: 10.5 * scale),
                children: const [
                  TextSpan(
                    text: 'ASHU_GO... ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'sent UP ',
                    style: TextStyle(color: Color(0xFF00FFCC), fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: '|| OXYGEN♡  ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Text('🦊', style: TextStyle(fontSize: 13)),
                  ),
                  TextSpan(
                    text: ' x 1',
                    style: TextStyle(color: Color(0xFFFFD200), fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: const Color(0xFFB173FF), size: 20 * scale),
        ],
      ),
    );
  }

  Widget _buildRoomIdSearchBox(double scale) {
    return Container(
      height: 42 * scale,
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF170B3B).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.4), width: 1.2 * scale),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: const Color(0xFFB173FF), size: 20 * scale),
          SizedBox(width: 8 * scale),
          Expanded(
            child: TextField(
              controller: _roomIdSearchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5 * scale,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: const Color(0xFF8E2DE2),
              decoration: InputDecoration(
                hintText: 'Find with room id or link...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  color: Colors.white54,
                ),
                border: InputBorder.none,
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_roomIdSearchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _roomIdSearchController.clear();
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.all(4 * scale),
                child: Icon(Icons.close_rounded, color: Colors.white70, size: 18 * scale),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(double scale) {
    final flag = _getCountryFlag(_selectedHotCountry);
    final countryName = _getCountryName(_selectedHotCountry);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Country Dropdown Pill
        GestureDetector(
          onTap: () => _showHotCountrySelector(context, scale),
          child: Container(
            height: 34 * scale,
            padding: EdgeInsets.symmetric(horizontal: 10 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF1E0E52).withOpacity(0.8),
              borderRadius: BorderRadius.circular(17 * scale),
              border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.4), width: 1 * scale),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: TextStyle(fontSize: 15 * scale)),
                SizedBox(width: 6 * scale),
                Text(
                  countryName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4 * scale),
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18 * scale),
              ],
            ),
          ),
        ),

        // Right Language Dropdown Pill
        GestureDetector(
          onTap: () => _showHotLanguageSelector(context, scale),
          child: Container(
            height: 34 * scale,
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF1E0E52).withOpacity(0.8),
              borderRadius: BorderRadius.circular(17 * scale),
              border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.4), width: 1 * scale),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedHotLanguage,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4 * scale),
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18 * scale),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotGridRoomCard(RoomModel room, double scale) {
    final flag = _getCountryFlag(room.countryCode);
    final subtitle = room.tags.isNotEmpty ? room.tags.first : 'Welcome everyone ❤️';

    return GestureDetector(
      onTap: () => _handleJoinRoom(room),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10 * scale),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover Artwork
              if (room.coverImage != null && room.coverImage!.isNotEmpty)
                Image.asset(
                  room.coverImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1B0F69),
                    child: Icon(Icons.meeting_room_rounded, color: Colors.white54, size: 28 * scale),
                  ),
                )
              else
                Container(
                  color: const Color(0xFF1B0F69),
                  child: Icon(Icons.meeting_room_rounded, color: Colors.white54, size: 28 * scale),
                ),

              // Gradient vignette to ensure bottom text readable
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Top-left: Blue TOP diagonal ribbon badge
              Positioned(
                top: 0,
                left: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10 * scale),
                    bottomRight: Radius.circular(8 * scale),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00B0FF), Color(0xFF0072BC)],
                      ),
                    ),
                    child: Text(
                      'TOP',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8 * scale,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Top-right: Signal & member count badge: 📶 32
              Positioned(
                top: 5 * scale,
                right: 5 * scale,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.5 * scale, vertical: 1.5 * scale),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6 * scale),
                    border: Border.all(color: Colors.white24, width: 0.5 * scale),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.signal_cellular_alt_rounded, color: const Color(0xFF00FFCC), size: 10 * scale),
                      SizedBox(width: 2 * scale),
                      Text(
                        '${room.memberCount}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.5 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom White Plaque
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10 * scale),
                      bottomRight: Radius.circular(10 * scale),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(flag, style: TextStyle(fontSize: 9.5 * scale)),
                          SizedBox(width: 3 * scale),
                          Expanded(
                            child: Text(
                              room.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9 * scale,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111111),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1 * scale),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 7.5 * scale,
                          color: const Color(0xFF555555),
                          fontWeight: FontWeight.w500,
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
    );
  }

  String _getCountryName(String? code) {
    switch (code?.toUpperCase()) {
      case 'PK': return 'Pakistan';
      case 'IN': return 'India';
      case 'SA': case 'KSA': return 'Saudi Arabia';
      case 'AE': case 'UAE': return 'United Arab Emirates';
      case 'BD': return 'Bangladesh';
      case 'KW': return 'Kuwait';
      case 'QA': return 'Qatar';
      case 'TR': return 'Turkey';
      case 'EG': return 'Egypt';
      case 'GB': case 'UK': return 'United Kingdom';
      case 'US': case 'USA': return 'United States';
      case 'ALL': default: return 'All Countries';
    }
  }

  void _showHotCountrySelector(BuildContext context, double scale) {
    final countries = [
      {'name': 'Pakistan', 'code': 'PK', 'flag': '🇵🇰'},
      {'name': 'India', 'code': 'IN', 'flag': '🇮🇳'},
      {'name': 'Saudi Arabia', 'code': 'SA', 'flag': '🇸🇦'},
      {'name': 'United Arab Emirates', 'code': 'AE', 'flag': '🇦🇪'},
      {'name': 'Bangladesh', 'code': 'BD', 'flag': '🇧🇩'},
      {'name': 'Kuwait', 'code': 'KW', 'flag': '🇰🇼'},
      {'name': 'Qatar', 'code': 'QA', 'flag': '🇶🇦'},
      {'name': 'Turkey', 'code': 'TR', 'flag': '🇹🇷'},
      {'name': 'Egypt', 'code': 'EG', 'flag': '🇪🇬'},
      {'name': 'United Kingdom', 'code': 'GB', 'flag': '🇬🇧'},
      {'name': 'United States', 'code': 'US', 'flag': '🇺🇸'},
      {'name': 'All Countries', 'code': 'ALL', 'flag': '🌐'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = countries.where((c) {
              if (filter.isEmpty) return true;
              return c['name']!.toLowerCase().contains(filter.toLowerCase()) ||
                     c['code']!.toLowerCase().contains(filter.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: const Color(0xFF1B0F4C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
                border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.4), width: 1.5 * scale),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10 * scale),
                    width: 40 * scale,
                    height: 4 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2 * scale),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 4 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Country',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white70, size: 20 * scale),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 6 * scale),
                    child: Container(
                      height: 40 * scale,
                      padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(color: Colors.white24, width: 1 * scale),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.white54, size: 18 * scale),
                          SizedBox(width: 8 * scale),
                          Expanded(
                            child: TextField(
                              onChanged: (val) => setModalState(() => filter = val),
                              style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 13 * scale),
                              decoration: const InputDecoration(
                                hintText: 'Search country...',
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                                border: InputBorder.none,
                                isDense: true,
                                filled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        final isSel = _selectedHotCountry == c['code'];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                          leading: Text(c['flag']!, style: TextStyle(fontSize: 24 * scale)),
                          title: Text(
                            c['name']!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5 * scale,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              color: isSel ? const Color(0xFFFFD200) : Colors.white,
                            ),
                          ),
                          trailing: isSel
                              ? Icon(Icons.check_circle_rounded, color: const Color(0xFFFFD200), size: 20 * scale)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedHotCountry = c['code']!;
                            });
                            ref.read(chatFlowProvider.notifier).selectCountry(c['code'] == 'ALL' ? null : c['code']);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHotLanguageSelector(BuildContext context, double scale) {
    final languages = ['English', 'Urdu', 'Hindi', 'Arabic', 'All Languages'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B0F4C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
            border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.4), width: 1.5 * scale),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10 * scale),
                  width: 40 * scale,
                  height: 4 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2 * scale),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 4 * scale),
                  child: Text(
                    'Select Language',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ...languages.map((lang) {
                  final isSel = _selectedHotLanguage == lang;
                  return ListTile(
                    title: Text(
                      lang,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5 * scale,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        color: isSel ? const Color(0xFFFFD200) : Colors.white,
                      ),
                    ),
                    trailing: isSel
                        ? Icon(Icons.check_circle_rounded, color: const Color(0xFFFFD200), size: 20 * scale)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedHotLanguage = lang;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
                SizedBox(height: 10 * scale),
              ],
            ),
          ),
        );
      },
    );
  }

  // ======================== My Tab Content ========================
  Widget _buildMyContent(BattleLobbyState state, double scale) {
    final chatFlow = ref.watch(chatFlowProvider);

    final filterKey = BattleLobbyState.mySubTabFilters[state.selectedMySubTab.clamp(0, 3)];
    final myData = state.myDataByFilter[filterKey];
    final currentRooms = myData?.rooms ?? [];

    return Column(
      children: [
        // Create My Room Card
        SizedBox(height: 16 * scale),
        GestureDetector(
          onTap: () {
            context.push(AppConstants.createRoomRoute);
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                height: 110 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
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
                      color: const Color(0xFF2C198E),
                    ),
                  ),
                ),
              ),
              // Floating + icon container
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
              _buildSubTab(0, 'Recently', state.selectedMySubTab == 0, scale),
              _buildSubTab(1, 'Joined', state.selectedMySubTab == 1, scale),
              _buildSubTab(2, 'Following', state.selectedMySubTab == 2, scale),
              _buildSubTab(3, 'Friends', state.selectedMySubTab == 3, scale),
            ],
          ),
        ),
        SizedBox(height: 16 * scale),

        // SubTab Content: Friends List or Rooms List
        if (state.selectedMySubTab == 3)
          _buildFriendsList(chatFlow.friends, scale)
        else if (state.isLoading && currentRooms.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 36 * scale),
              child: const CircularProgressIndicator(color: Color(0xFF8E2DE2)),
            ),
          )
        else if (currentRooms.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10 * scale,
              mainAxisSpacing: 10 * scale,
              childAspectRatio: 0.82,
            ),
            itemCount: currentRooms.length,
            itemBuilder: (context, index) => _buildGridRoomCard(currentRooms[index], scale),
          )
        else ...[
          SizedBox(height: 20 * scale),
          Icon(
            Icons.home_work_rounded,
            size: 80 * scale,
            color: const Color(0xFF2C198E).withOpacity(0.35),
          ),
          SizedBox(height: 12 * scale),
          Text(
            state.selectedMySubTab == 0
                ? "You haven't visited any rooms yet"
                : state.selectedMySubTab == 1
                    ? "You haven't joined any rooms yet"
                    : "No rooms from hosts you follow",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20 * scale),

          // Go Find Rooms Button
          Container(
            width: 200 * scale,
            height: 42 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21 * scale),
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
                  ref.read(battleLobbyProvider.notifier).setTab(0); // Switch to Explore
                },
                borderRadius: BorderRadius.circular(21 * scale),
                child: Center(
                  child: Text(
                    'Go Find Rooms',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: 24 * scale),
      ],
    );
  }

  Widget _buildFriendsList(List<ChatFriendModel> friends, double scale) {
    final addFriendBtn = GestureDetector(
      onTap: () => context.push(AppConstants.friendRequestRoute),
      child: Container(
        margin: EdgeInsets.only(bottom: 14 * scale),
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 11 * scale),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          ),
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E2DE2).withOpacity(0.35),
              blurRadius: 8 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: const Color(0xFFFFD200), size: 19 * scale),
            SizedBox(width: 8 * scale),
            Text(
              'Add Friends & Manage Requests',
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
    );

    if (friends.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16 * scale),
        child: Column(
          children: [
            addFriendBtn,
            SizedBox(height: 16 * scale),
            Icon(Icons.people_outline_rounded, size: 70 * scale, color: Colors.white24),
            SizedBox(height: 8 * scale),
            Text(
              'No friends connected yet',
              style: TextStyle(color: Colors.white70, fontSize: 13 * scale, fontFamily: 'Poppins'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        addFriendBtn,
        ...friends.map((friend) {
        return Container(
          margin: EdgeInsets.only(bottom: 8 * scale),
          padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF1C135C).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.3), width: 1 * scale),
          ),
          child: Row(
            children: [
              // Friend avatar + online dot
              Stack(
                children: [
                  Container(
                    width: 44 * scale,
                    height: 44 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: friend.isOnline ? const Color(0xFF56AB2F) : Colors.white24,
                        width: 1.5 * scale,
                      ),
                    ),
                    child: ClipOval(
                      child: friend.avatarUrl != null
                          ? Image.asset(friend.avatarUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12 * scale,
                      height: 12 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: friend.isOnline ? const Color(0xFF56AB2F) : Colors.grey,
                        border: Border.all(color: const Color(0xFF1C135C), width: 2 * scale),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12 * scale),

              // Name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    if (friend.isOnline && friend.currentRoomTitle != null)
                      Row(
                        children: [
                          Container(
                            width: 6 * scale,
                            height: 6 * scale,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          Expanded(
                            child: Text(
                              'Live in: ${friend.currentRoomTitle}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10 * scale,
                                color: const Color(0xFFFFD200),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        friend.isOnline ? 'Online • In Lobby' : 'Offline',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10 * scale,
                          color: friend.isOnline ? const Color(0xFF56AB2F) : Colors.white38,
                        ),
                      ),
                  ],
                ),
              ),

              // Enter Room button if live or Profile action
              if (friend.isOnline && friend.currentRoomId != null)
                Container(
                  height: 28 * scale,
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14 * scale),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.push(
                          AppConstants.roomDetailRoute,
                          extra: {
                            'title': friend.currentRoomTitle ?? 'Live Room',
                            'id': friend.currentRoomId.toString(),
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(14 * scale),
                      child: Center(
                        child: Text(
                          'Join Room',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.5 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(Icons.person_outline_rounded, color: const Color(0xFFB173FF), size: 20 * scale),
                  onPressed: () {
                    UserProfileModal.show(
                      context,
                      userId: friend.id,
                      username: friend.name,
                      avatarUrl: friend.avatarUrl,
                      isHost: false,
                    );
                  },
                ),
            ],
          ),
        );
      }),
    ],
  );
}

  Widget _buildSubTab(int index, String label, bool isSelected, double scale) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(battleLobbyProvider.notifier).setMySubTab(index);
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
