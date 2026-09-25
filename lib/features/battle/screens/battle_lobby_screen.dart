import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/battle/models/lobby_model.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';
import 'package:ludo_vibe/features/battle/providers/battle_provider.dart';
import 'package:ludo_vibe/features/home/providers/home_provider.dart';
import 'package:ludo_vibe/features/social/widgets/user_profile_modal.dart';
import 'package:ludo_vibe/shared/widgets/bottom_nav_bar.dart';

class BattleLobbyScreen extends ConsumerStatefulWidget {
  const BattleLobbyScreen({super.key});

  @override
  ConsumerState<BattleLobbyScreen> createState() => _BattleLobbyScreenState();
}

class _BattleLobbyScreenState extends ConsumerState<BattleLobbyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).setBottomNav(BottomNavItem.chat);
      // Trigger initial load
      ref.read(battleLobbyProvider.notifier).loadExploreData();
    });
  }

  Future<void> _handleCountrySearch() async {
    final selected = await context.push<String?>(AppConstants.countrySelectRoute);
    if (selected != null && mounted) {
      // Find country code if possible or pass country string
      ref.read(battleLobbyProvider.notifier).selectCountry(selected);
    }
  }

  void _handleJoinRoom(RoomModel room) {
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
                  height: 62 * scale,
                  padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                  child: Row(
                    children: [
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
                        onPressed: () => context.push(AppConstants.friendRequestRoute),
                        icon: Icon(
                          Icons.person_add_alt_1_rounded,
                          color: const Color(0xFFFFD200),
                          size: 22 * scale,
                        ),
                      ),
                      // Search button
                      IconButton(
                        onPressed: _handleCountrySearch,
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

  Widget _buildHeaderTab(int index, String label, bool isSelected, double scale) {
    return GestureDetector(
      onTap: () {
        ref.read(battleLobbyProvider.notifier).setTab(index);
      },
      child: Container(
        height: 44 * scale,
        padding: EdgeInsets.symmetric(horizontal: 18 * scale),
        alignment: Alignment.center,
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(22 * scale),
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
            fontSize: 18 * scale,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
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
    final explore = state.exploreData;
    final cards = explore?.quickEntryCards.isNotEmpty == true
        ? explore!.quickEntryCards
        : [
            QuickEntryCardModel(
              id: 'new_here',
              title: 'New here',
              description: 'Casual hangout for newcomers',
              bgAsset: 'assets/graphics/card_private.png',
              gradient: const [Color(0xFF00B2FF), Color(0xFF0072BC)],
              filterCategory: 'social',
              tags: ['Beginner', 'Casual'],
            ),
            QuickEntryCardModel(
              id: 'find_friends',
              title: 'Find Friends',
              description: 'Make new gaming buddies',
              bgAsset: 'assets/graphics/card_team.png',
              gradient: const [Color(0xFF56AB2F), Color(0xFF1D976C)],
              filterCategory: 'friends',
              tags: ['Social', 'Chat'],
            ),
            QuickEntryCardModel(
              id: 'small_talk',
              title: 'Small talk',
              description: 'Casual conversation & chill games',
              bgAsset: 'assets/graphics/card_domino_1v1.png',
              gradient: const [Color(0xFF00D2FF), Color(0xFF0072BC)],
              filterCategory: 'chat',
              tags: ['Chills', 'Talk'],
            ),
            QuickEntryCardModel(
              id: 'enjoy_music',
              title: 'Enjoy Music',
              description: 'Listen to beats & play together',
              bgAsset: 'assets/graphics/card_vip.png',
              gradient: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              filterCategory: 'music',
              tags: ['Music', 'Party'],
            ),
          ];

    final rooms = explore?.recommendedRooms ?? [];

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
                if (state.selectedCountry != null) ...[
                  SizedBox(width: 8 * scale),
                  GestureDetector(
                    onTap: () => ref.read(battleLobbyProvider.notifier).selectCountry(null),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E2DE2).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                      child: Row(
                        children: [
                          Text(
                            state.selectedCountry!,
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
              _buildCountryChip('🇵🇰', 'Pakistan', 'PK', state.selectedCountry == 'PK', scale),
              _buildCountryChip('🇮🇳', 'India', 'IN', state.selectedCountry == 'IN', scale),
              _buildCountryChip('🇸🇦', 'KSA', 'SA', state.selectedCountry == 'SA', scale),
              _buildCountryChip('🇧🇩', 'Bangladesh', 'BD', state.selectedCountry == 'BD', scale),
              _buildCountryChip('🇦🇪', 'UAE', 'AE', state.selectedCountry == 'AE', scale),
              _buildCountryChip('🇩🇿', 'Algeria', 'DZ', state.selectedCountry == 'DZ', scale),
            ],
          ),
        ),
        SizedBox(height: 16 * scale),

        // Recommend Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommend',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (state.isLoading)
              SizedBox(
                width: 16 * scale,
                height: 16 * scale,
                child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB173FF)),
              ),
          ],
        ),
        SizedBox(height: 8 * scale),

        // Dynamic Recommended Rooms
        if (rooms.isNotEmpty)
          ...rooms.map((room) => Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: _buildRoomCard(room, scale),
              ))
        else if (!state.isLoading)
          // Default fallbacks if backend is completely fresh
          Column(
            children: [
              _buildDummyRecommendRoom('Friendly Chats & Ludo Vibe', 'assets/graphics/card_2v4_players.png', '142', ['Ludo', 'Social'], scale),
              SizedBox(height: 8 * scale),
              _buildDummyRecommendRoom('Chill Beats & Domino Lounge', 'assets/graphics/card_domino_1v1.png', '89', ['Music', 'Domino'], scale),
              SizedBox(height: 8 * scale),
              _buildDummyRecommendRoom('Jackaroo Elite Club', 'assets/graphics/card_jackaroo_basic.png', '54', ['Jackaroo', 'Elite'], scale),
            ],
          ),
        SizedBox(height: 10 * scale),
      ],
    );
  }

  Widget _buildQuickEntryCard(QuickEntryCardModel card, double scale) {
    return GestureDetector(
      onTap: () {
        // Quick Entry action - Filter or create/find match
        ref.read(battleLobbyProvider.notifier).loadExploreData();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * scale),
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
        ref.read(battleLobbyProvider.notifier).selectCountry(code);
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
            Text(flag, style: TextStyle(fontSize: 24 * scale)),
            SizedBox(width: 6 * scale),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13 * scale,
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

  Widget _buildRoomCard(RoomModel room, double scale) {
    return GestureDetector(
      onTap: () => _handleJoinRoom(room),
      child: Container(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (room.isMine) ...[
                        SizedBox(width: 4 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 1.5 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD200).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4 * scale),
                            border: Border.all(color: const Color(0xFFFFD200), width: 0.8 * scale),
                          ),
                          child: Text(
                            '👑 Host',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 8 * scale,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFD200),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4 * scale),
                  Row(
                    children: [
                      Icon(Icons.person, color: const Color(0xFFB173FF), size: 12 * scale),
                      SizedBox(width: 2 * scale),
                      Text(
                        room.memberCount.toString(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10 * scale,
                          color: const Color(0xFFB173FF),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      ...room.tags.take(2).map((tag) => Container(
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
                  onTap: () => _handleJoinRoom(room),
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
      ),
    );
  }

  Widget _buildDummyRecommendRoom(String name, String imageAsset, String members, List<String> tags, double scale) {
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C135C).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.3), width: 1 * scale),
      ),
      child: Row(
        children: [
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
                onTap: () {
                  context.push(
                    AppConstants.roomDetailRoute,
                    extra: {'title': name, 'id': '101'},
                  );
                },
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

  // ======================== Hot Tab Content ========================
  Widget _buildHotContent(BattleLobbyState state, double scale) {
    final hot = state.hotData;
    final popularHosts = hot?.popularHosts ?? [];
    final trendingRooms = hot?.trendingRooms ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Popular Hosts Title
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
          height: 75 * scale,
          child: popularHosts.isNotEmpty
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularHosts.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10 * scale),
                  itemBuilder: (context, index) {
                    final host = popularHosts[index];
                    return _buildHostAvatar(
                      '${host.username} ${host.badge}',
                      const Color(0xFFFFD200),
                      scale,
                      onTap: () {
                        UserProfileModal.show(
                          context,
                          userId: host.userId,
                          username: host.username,
                          avatarUrl: host.avatarUrl,
                          isHost: true,
                        );
                      },
                    );
                  },
                )
              : ListView(
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

        // Trending live rooms list
        if (trendingRooms.isNotEmpty)
          ...trendingRooms.map((room) => Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: _buildRoomCard(room, scale),
              ))
        else
          Column(
            children: [
              _buildDummyRecommendRoom('🔴 Ludo Master Championship live', 'assets/graphics/card_tournament.png', '342', ['Ludo', 'Live'], scale),
              SizedBox(height: 8 * scale),
              _buildDummyRecommendRoom('🎧 Request your songs here!', 'assets/graphics/card_vip.png', '224', ['Music', 'Party'], scale),
              SizedBox(height: 8 * scale),
              _buildDummyRecommendRoom('Talk Room: Meet New Friends', 'assets/graphics/card_private.png', '175', ['Social', 'Chills'], scale),
            ],
          ),
        SizedBox(height: 10 * scale),
      ],
    );
  }

  Widget _buildHostAvatar(String name, Color border, double scale, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  // ======================== My Tab Content ========================
  Widget _buildMyContent(BattleLobbyState state, double scale) {
    final currentFilter = BattleLobbyState.mySubTabFilters[state.selectedMySubTab];
    final myData = state.myDataByFilter[currentFilter];
    final myRooms = myData?.rooms ?? [];

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

        // Rooms list or Empty placeholder
        if (myRooms.isNotEmpty)
          ...myRooms.map((room) => Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: _buildRoomCard(room, scale),
              ))
        else ...[
          SizedBox(height: 20 * scale),
          Icon(
            Icons.home_work_rounded,
            size: 90 * scale,
            color: const Color(0xFF2C198E).withOpacity(0.35),
          ),
          SizedBox(height: 12 * scale),
          Text(
            state.selectedMySubTab == 0
                ? "You haven't visited any rooms"
                : state.selectedMySubTab == 1
                    ? "You haven't joined any rooms"
                    : state.selectedMySubTab == 2
                        ? "No rooms from hosts you follow"
                        : "No active rooms with your friends",
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
                  ref.read(battleLobbyProvider.notifier).setTab(0); // Switch to Explore
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
        ],

        SizedBox(height: 24 * scale),
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
