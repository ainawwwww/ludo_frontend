import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';
import 'package:share_plus/share_plus.dart';

/// Callback when room settings are updated
typedef RoomSettingsUpdatedCallback = void Function({
  String? newName,
  String? newAnnouncement,
  String? newTag,
  String? newMicMode,
  int? newMembershipFee,
});

/// Room Profile Modal (Matches user screenshot: Profile, Members, Moments tabs, Level badge, Gear settings)
class RoomProfileModal extends StatefulWidget {
  final RoomModel room;
  final String hostName;
  final String? announcement;
  final String activeTag;
  final String micMode;
  final int membershipFee;
  final bool isHost;
  final RoomSettingsUpdatedCallback onSettingsUpdated;

  const RoomProfileModal({
    super.key,
    required this.room,
    required this.hostName,
    this.announcement,
    required this.activeTag,
    required this.micMode,
    required this.membershipFee,
    this.isHost = false,
    required this.onSettingsUpdated,
  });

  static void show(
    BuildContext context, {
    required RoomModel room,
    required String hostName,
    String? announcement,
    required String activeTag,
    required String micMode,
    required int membershipFee,
    bool isHost = false,
    required RoomSettingsUpdatedCallback onSettingsUpdated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RoomProfileModal(
        room: room,
        hostName: hostName,
        announcement: announcement,
        activeTag: activeTag,
        micMode: micMode,
        membershipFee: membershipFee,
        isHost: isHost,
        onSettingsUpdated: onSettingsUpdated,
      ),
    );
  }

  @override
  State<RoomProfileModal> createState() => _RoomProfileModalState();
}

class _RoomProfileModalState extends State<RoomProfileModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.72,
      decoration: BoxDecoration(
        color: const Color(0xFF160E3F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        border: Border(
          top: BorderSide(color: const Color(0xFF8E2DE2).withOpacity(0.5), width: 1.5 * scale),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20 * scale,
            offset: Offset(0, -5 * scale),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40 * scale,
            height: 4 * scale,
            margin: EdgeInsets.only(top: 10 * scale, bottom: 8 * scale),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),

          // Header Row with Tabs and Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: Row(
              children: [
                // Tabs
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(color: const Color(0xFFFFD200), width: 3 * scale),
                      insets: EdgeInsets.symmetric(horizontal: 6 * scale),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Members'),
                      Tab(text: 'Moments'),
                    ],
                  ),
                ),

                // Share Button
                IconButton(
                  icon: Icon(Icons.share_rounded, color: Colors.white70, size: 20 * scale),
                  onPressed: () {
                    Share.share('Join my Ludo room: ${widget.room.title}! Room Code: ${widget.room.roomCode}');
                  },
                ),

                // Gear Settings Button (ONLY visible to room creator / admin)
                if (widget.isHost)
                  IconButton(
                    icon: Icon(Icons.settings_rounded, color: const Color(0xFFFFD200), size: 22 * scale),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => RoomSettingsScreen(
                            room: widget.room,
                            hostName: widget.hostName,
                            announcement: widget.announcement,
                            activeTag: widget.activeTag,
                            micMode: widget.micMode,
                            membershipFee: widget.membershipFee,
                            onSettingsUpdated: widget.onSettingsUpdated,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(scale),
                _buildMembersTab(scale),
                _buildMomentsTab(scale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(double scale) {
    final hostAvatar = widget.room.players.isNotEmpty ? widget.room.players.first.avatarUrl : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20 * scale),
      child: Column(
        children: [
          // Room Avatar with Level Shield
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90 * scale,
                height: 90 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD200), width: 3 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD200).withOpacity(0.3),
                      blurRadius: 12 * scale,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: hostAvatar != null
                      ? Image.asset(hostAvatar, fit: BoxFit.cover)
                      : Image.asset('assets/graphics/wealthy_avatar.png', fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: -10 * scale,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 2 * scale),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
                    ),
                    borderRadius: BorderRadius.circular(10 * scale),
                    border: Border.all(color: Colors.white, width: 1.5 * scale),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded, color: Colors.white, size: 11 * scale),
                      SizedBox(width: 2 * scale),
                      Text(
                        'Lv. 1',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10 * scale,
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
          SizedBox(height: 18 * scale),

          // Room Title
          Text(
            widget.room.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * scale),

          // Room ID with copy button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ID: ${widget.room.roomCode}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  color: Colors.white60,
                ),
              ),
              SizedBox(width: 6 * scale),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.room.roomCode ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Room ID copied to clipboard!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(Icons.copy_rounded, color: const Color(0xFFFFD200), size: 14 * scale),
              ),
            ],
          ),
          SizedBox(height: 14 * scale),

          // Tag Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF8E2DE2).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: const Color(0xFF8E2DE2), width: 1 * scale),
            ),
            child: Text(
              '🏷️ ${widget.activeTag}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11 * scale,
                color: const Color(0xFFFFD200),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 16 * scale),

          // Announcement Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign_rounded, color: const Color(0xFFFFD200), size: 16 * scale),
                    SizedBox(width: 6 * scale),
                    Text(
                      'Announcement',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6 * scale),
                Text(
                  (widget.announcement != null && widget.announcement!.isNotEmpty)
                      ? widget.announcement!
                      : 'Welcome to our room! Follow the host, respect others, and enjoy playing together! 🎲✨',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5 * scale,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),

          // Room Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Members', '${widget.room.memberCount}', scale),
              _buildStatItem('Mic Mode', widget.micMode, scale),
              _buildStatItem('Fee', widget.membershipFee > 0 ? '${widget.membershipFee} 💎' : 'Free', scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, double scale) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14 * scale,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD200),
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11 * scale,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab(double scale) {
    final players = widget.room.players;
    if (players.isEmpty) {
      return Center(
        child: Text(
          'No members currently active',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white54, fontSize: 13 * scale),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      itemCount: players.length,
      itemBuilder: (ctx, idx) {
        final p = players[idx];
        return Container(
          margin: EdgeInsets.only(bottom: 8 * scale),
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20 * scale,
                backgroundImage: p.avatarUrl != null ? AssetImage(p.avatarUrl!) : null,
                child: p.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.username,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      p.seatPosition == 1 ? '👑 Host' : 'Seat ${p.seatPosition}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5 * scale,
                        color: p.seatPosition == 1 ? const Color(0xFFFFD200) : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMomentsTab(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 50 * scale, color: Colors.white24),
          SizedBox(height: 8 * scale),
          Text(
            'No moments shared yet',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white54, fontSize: 13 * scale),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Special victory photos and room memories will appear here',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white38, fontSize: 11 * scale),
          ),
        ],
      ),
    );
  }
}

/// Room Settings Screen (Matches user screenshot: Room Name, Tag, Announcement, Mic Mode, Admin Permissions, Fee, Bonus)
class RoomSettingsScreen extends StatefulWidget {
  final RoomModel room;
  final String hostName;
  final String? announcement;
  final String activeTag;
  final String micMode;
  final int membershipFee;
  final RoomSettingsUpdatedCallback onSettingsUpdated;

  const RoomSettingsScreen({
    super.key,
    required this.room,
    required this.hostName,
    this.announcement,
    required this.activeTag,
    required this.micMode,
    required this.membershipFee,
    required this.onSettingsUpdated,
  });

  @override
  State<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends State<RoomSettingsScreen> {
  late String _currentName;
  late String _currentAnnouncement;
  late String _currentTag;
  late String _currentMicMode;
  late int _currentFee;

  // Admin permission switches
  bool _permClock = true;
  bool _permVote = true;
  bool _permFruitFight = true;
  bool _permLockMic = true;
  bool _permChangeTheme = true;

  @override
  void initState() {
    super.initState();
    _currentName = widget.room.title;
    _currentAnnouncement = widget.announcement ?? 'Welcome to our room! 🎲✨';
    _currentTag = widget.activeTag;
    _currentMicMode = widget.micMode;
    _currentFee = widget.membershipFee;
  }

  void _showEditNameDialog(double scale) {
    final controller = TextEditingController(text: _currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D144A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
        title: Text(
          'Edit Room Name',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 15 * scale),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter room name',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD200))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E2DE2)),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() => _currentName = newName);
                widget.onSettingsUpdated(newName: newName);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTagSelector(double scale) {
    final tags = ['Lucky 77', 'Mehfil', 'Gossip', 'Competitions', 'Music Lounge', 'Urdu Club', 'Gaming Hub'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String selected = _currentTag;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF160E3F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
              border: Border(top: BorderSide(color: const Color(0xFF8E2DE2), width: 1.5 * scale)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36 * scale,
                    height: 4 * scale,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2 * scale)),
                  ),
                ),
                SizedBox(height: 14 * scale),
                Text(
                  'Select Room Tag',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 14 * scale),
                Wrap(
                  spacing: 10 * scale,
                  runSpacing: 10 * scale,
                  children: tags.map((t) {
                    final isSel = t == selected;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selected = t),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF8E2DE2) : Colors.white12,
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(color: isSel ? const Color(0xFFFFD200) : Colors.transparent),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12 * scale,
                            color: Colors.white,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20 * scale),
                SizedBox(
                  width: double.infinity,
                  height: 42 * scale,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21 * scale)),
                    ),
                    onPressed: () {
                      setState(() => _currentTag = selected);
                      widget.onSettingsUpdated(newTag: selected);
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C198E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditAnnouncementDialog(double scale) {
    final controller = TextEditingController(text: _currentAnnouncement);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D144A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
        title: Text(
          'Room Announcement',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 15 * scale),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Add your room announcement here...',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD200))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E2DE2)),
            onPressed: () {
              final newAnn = controller.text.trim();
              setState(() => _currentAnnouncement = newAnn);
              widget.onSettingsUpdated(newAnnouncement: newAnn);
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMicModeModal(double scale) {
    final modes = [
      {'title': 'Chat - 5 Mics', 'desc': '5 Free mic seats for chat & games', 'locked': false},
      {'title': 'Broadcast - 5 Mics', 'desc': 'Host controls broadcast, guests listen', 'locked': false},
      {'title': 'Chat - 10 Mics', 'desc': 'Expanded 10 seats (Requires Room Lv. 5)', 'locked': true},
      {'title': 'Team - 10 Mics', 'desc': 'Team 5v5 battle mode (Requires Room Lv. 8)', 'locked': true},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF160E3F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
          border: Border(top: BorderSide(color: const Color(0xFF8E2DE2), width: 1.5 * scale)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2 * scale)),
              ),
            ),
            SizedBox(height: 14 * scale),
            Text(
              'Select Mic Mode',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12 * scale),
            ...modes.map((m) {
              final isLocked = m['locked'] as bool;
              final title = m['title'] as String;
              final isSel = title == _currentMicMode;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isLocked ? Icons.lock_rounded : (isSel ? Icons.radio_button_checked : Icons.radio_button_off),
                  color: isLocked ? Colors.white30 : (isSel ? const Color(0xFFFFD200) : Colors.white60),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isLocked ? Colors.white38 : Colors.white,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  m['desc'] as String,
                  style: TextStyle(fontSize: 11 * scale, color: Colors.white38),
                ),
                onTap: isLocked
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Level up your room to unlock this mode!')),
                        );
                      }
                    : () {
                        setState(() => _currentMicMode = title);
                        widget.onSettingsUpdated(newMicMode: title);
                        Navigator.pop(ctx);
                      },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showMembershipFeeModal(double scale) {
    int fee = _currentFee;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setFeeState) => Container(
          padding: EdgeInsets.all(20 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF160E3F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
            border: Border(top: BorderSide(color: const Color(0xFF8E2DE2), width: 1.5 * scale)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36 * scale,
                  height: 4 * scale,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2 * scale)),
                ),
              ),
              SizedBox(height: 14 * scale),
              Text(
                'Room Membership Fee',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                'Members pay this diamond fee once upon entering your room.',
                style: TextStyle(fontSize: 11.5 * scale, color: Colors.white60),
              ),
              SizedBox(height: 20 * scale),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/graphics/icon_diamond.png', width: 24 * scale, height: 24 * scale),
                    SizedBox(width: 8 * scale),
                    Text(
                      fee == 0 ? 'Free (0 💎)' : '$fee Diamonds',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD200),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14 * scale),
              Slider(
                value: fee.toDouble(),
                min: 0,
                max: 2000,
                divisions: 40,
                activeColor: const Color(0xFFFFD200),
                inactiveColor: Colors.white24,
                onChanged: (val) {
                  setFeeState(() => fee = val.round());
                },
              ),
              SizedBox(height: 16 * scale),
              SizedBox(
                width: double.infinity,
                height: 42 * scale,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E2DE2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21 * scale)),
                  ),
                  onPressed: () {
                    setState(() => _currentFee = fee);
                    widget.onSettingsUpdated(newMembershipFee: fee);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Fee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDailyBonusDialog(double scale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D144A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFFFD200)),
            SizedBox(width: 8 * scale),
            Text(
              'Daily Bonus Rules',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16 * scale),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💎 Host Daily Reward Pool:',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13 * scale),
            ),
            SizedBox(height: 6 * scale),
            Text(
              '• 100+ Live Minutes = +50 Diamonds\n• 500+ Gifts Exchanged = +200 Diamonds\n• Room Lv. 2 Bonus = 10% Extra Cashout\n• VIP Host Tier = Weekly Trophy Plaque',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 11.5 * scale, height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD200)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: Color(0xFF2C198E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFF110A33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF160E3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Room Settings',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
        children: [
          // Room Avatar Header
          Center(
            child: Stack(
              children: [
                Container(
                  width: 80 * scale,
                  height: 80 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD200), width: 2.5 * scale),
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/graphics/wealthy_avatar.png', fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(6 * scale),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8E2DE2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14 * scale),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),

          // Basic Settings Group
          _buildSettingsTile(
            title: 'Room Name',
            value: _currentName,
            onTap: () => _showEditNameDialog(scale),
            scale: scale,
          ),
          _buildSettingsTile(
            title: 'Tag',
            value: _currentTag,
            onTap: () => _showTagSelector(scale),
            scale: scale,
          ),
          _buildSettingsTile(
            title: 'Announcement',
            value: _currentAnnouncement,
            onTap: () => _showEditAnnouncementDialog(scale),
            scale: scale,
          ),
          _buildSettingsTile(
            title: 'Mic Mode',
            value: _currentMicMode,
            onTap: () => _showMicModeModal(scale),
            scale: scale,
          ),

          SizedBox(height: 20 * scale),

          // Admin Permission Section (Matches media_1790769060071.png)
          Text(
            'Admin Permission',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD200),
            ),
          ),
          SizedBox(height: 10 * scale),

          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14 * scale),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildSwitchTile('Clock', _permClock, (val) => setState(() => _permClock = val), scale),
                _buildSwitchTile('Vote', _permVote, (val) => setState(() => _permVote = val), scale),
                _buildSwitchTile('Fruit Fight', _permFruitFight, (val) => setState(() => _permFruitFight = val), scale),
                _buildSwitchTile('Lock / Unlock Mic', _permLockMic, (val) => setState(() => _permLockMic = val), scale),
                _buildSwitchTile('Change Room Theme', _permChangeTheme, (val) => setState(() => _permChangeTheme = val), scale, isLast: true),
              ],
            ),
          ),

          SizedBox(height: 20 * scale),

          // More Options Group
          Text(
            'More Room Options',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD200),
            ),
          ),
          SizedBox(height: 10 * scale),

          _buildSettingsTile(
            title: 'Membership Fee',
            value: _currentFee > 0 ? '$_currentFee 💎' : 'Free (0 💎)',
            onTap: () => _showMembershipFeeModal(scale),
            scale: scale,
          ),
          _buildSettingsTile(
            title: 'Daily Bonus',
            value: 'VIP Reward Pool',
            onTap: () => _showDailyBonusDialog(scale),
            scale: scale,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String value,
    required VoidCallback onTap,
    required double scale,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 8 * scale),
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 14 * scale),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            // Title heading: guaranteed 1 line, never line breaks!
            Text(
              title,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 13.5 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 12 * scale),
            // Value text: takes available space and truncates if long
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white60,
                  fontSize: 12 * scale,
                ),
              ),
            ),
            SizedBox(width: 6 * scale),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 12 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged, double scale, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 13 * scale, fontWeight: FontWeight.w500),
              ),
              Switch(
                value: value,
                activeColor: const Color(0xFFFFD200),
                activeTrackColor: const Color(0xFF8E2DE2),
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: Colors.white12,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(color: Colors.white10, height: 1),
      ],
    );
  }
}
