import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({
    super.key,
    this.roomTitle = 'Ludo VIP Lounge #104',
    this.roomId = '892401',
  });

  final String roomTitle;
  final String roomId;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _isMicMuted = false;
  final TextEditingController _msgController = TextEditingController();

  final List<_VoiceSeat> _seats = const [
    _VoiceSeat(
        index: 1,
        name: 'Ali (Host)',
        isSpeaking: true,
        isHost: true,
        avatar: 'assets/graphics/musician_avatar.png'),
    _VoiceSeat(
        index: 2,
        name: 'Sara VIP',
        isSpeaking: false,
        isHost: false,
        avatar: 'assets/graphics/wealthy_avatar.png'),
    _VoiceSeat(
        index: 3,
        name: 'ProGamer',
        isSpeaking: true,
        isHost: false,
        avatar: 'assets/graphics/musician_avatar.png'),
    _VoiceSeat(index: 4, name: 'Empty', isEmpty: true),
    _VoiceSeat(index: 5, name: 'Empty', isEmpty: true),
    _VoiceSeat(index: 6, name: 'Empty', isEmpty: true),
    _VoiceSeat(index: 7, name: 'Empty', isEmpty: true),
    _VoiceSeat(index: 8, name: 'Empty', isEmpty: true),
  ];

  final List<String> _chatMessages = [
    'Ali (Host): Welcome everyone to the VIP Ludo Room!',
    'Sara VIP: Good luck on the next betting round guys!',
    'ProGamer: Let’s roll 6!',
  ];

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgController.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add('You: ${_msgController.text.trim()}');
        _msgController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 22 * scale),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.roomTitle,
                            style: AppTextStyles.headingMedium.copyWith(
                              fontSize: 16 * scale,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID: ${widget.roomId} • 14 Online',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11 * scale,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.share_rounded,
                          color: Colors.white, size: 22 * scale),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // 8 Mic Seats Grid
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12 * scale,
                    mainAxisSpacing: 12 * scale,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final seat = _seats[index];
                    return _buildSeatItem(seat, scale);
                  },
                ),
              ),

              // Chat Stream
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16 * scale),
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C073E).withOpacity(0.55),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(
                        color: AppColors.primaryBorder.withOpacity(0.3)),
                  ),
                  child: ListView.builder(
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 6 * scale),
                        child: Text(
                          _chatMessages[index],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12 * scale,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 8 * scale),

              // Bottom Control & Input Bar
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    // Mic toggle
                    IconButton(
                      icon: Icon(
                        _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: _isMicMuted
                            ? Colors.white38
                            : const Color(0xFF56AB2F),
                        size: 26 * scale,
                      ),
                      onPressed: () =>
                          setState(() => _isMicMuted = !_isMicMuted),
                    ),
                    SizedBox(width: 4 * scale),

                    // Chat input field
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        style: TextStyle(
                            color: Colors.white, fontSize: 13 * scale),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                              color: Colors.white38, fontSize: 13 * scale),
                          filled: true,
                          fillColor: const Color(0xFF1C1354),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14 * scale, vertical: 8 * scale),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20 * scale),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8 * scale),

                    // Send Button
                    IconButton(
                      icon: Icon(Icons.send_rounded,
                          color: const Color(0xFFFF9B63), size: 24 * scale),
                      onPressed: _sendMessage,
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

  Widget _buildSeatItem(_VoiceSeat seat, double scale) {
    if (seat.isEmpty) {
      return Column(
        children: [
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white10,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(Icons.add_rounded,
                color: Colors.white38, size: 24 * scale),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Seat ${seat.index}',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9 * scale,
                color: Colors.white38),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          width: 48 * scale,
          height: 48 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: seat.isSpeaking
                  ? const Color(0xFF56AB2F)
                  : const Color(0xFFFFD369),
              width: seat.isSpeaking ? 2.5 * scale : 1.5 * scale,
            ),
            boxShadow: [
              if (seat.isSpeaking)
                BoxShadow(
                  color: const Color(0xFF56AB2F).withOpacity(0.5),
                  blurRadius: 10 * scale,
                ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              seat.avatar!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          seat.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _VoiceSeat {
  final int index;
  final String name;
  final bool isSpeaking;
  final bool isHost;
  final String? avatar;
  final bool isEmpty;

  const _VoiceSeat({
    required this.index,
    required this.name,
    this.isSpeaking = false,
    this.isHost = false,
    this.avatar,
    this.isEmpty = false,
  });
}
