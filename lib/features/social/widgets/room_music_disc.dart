import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';

class RoomMusicDisc extends StatefulWidget {
  final bool isPlaying;
  final String currentTrack;
  final ValueChanged<bool> onPlayPauseChanged;
  final ValueChanged<String> onTrackSelected;

  const RoomMusicDisc({
    super.key,
    required this.isPlaying,
    required this.currentTrack,
    required this.onPlayPauseChanged,
    required this.onTrackSelected,
  });

  @override
  State<RoomMusicDisc> createState() => _RoomMusicDiscState();
}

class _RoomMusicDiscState extends State<RoomMusicDisc> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RoomMusicDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!widget.isPlaying && _rotationController.isAnimating) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _showMusicSelectorSheet(BuildContext context, double scale) {
    final tracks = [
      {'name': 'Lofi Chill Lounge', 'genre': 'Chill Beats', 'icon': Icons.music_note_rounded},
      {'name': 'Ludo High Energy', 'genre': 'Party Electronic', 'icon': Icons.flash_on_rounded},
      {'name': 'Acoustic Guitar Mehfil', 'genre': 'Acoustic', 'icon': Icons.music_video_rounded},
      {'name': 'Cyber Synthwave Night', 'genre': 'Synthwave', 'icon': Icons.nightlife_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool playing = widget.isPlaying;
        String track = widget.currentTrack;

        return StatefulBuilder(
          builder: (ctx, setSheetState) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF160E3F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
              border: Border(top: BorderSide(color: const Color(0xFFFFD200), width: 1.5 * scale)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36 * scale,
                      height: 4 * scale,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2 * scale)),
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.album_rounded, color: Color(0xFFFFD200)),
                          SizedBox(width: 8 * scale),
                          Text(
                            'Room Music Player',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // Toggle Play / Pause
                      IconButton(
                        icon: Icon(
                          playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                          color: const Color(0xFFFFD200),
                          size: 32 * scale,
                        ),
                        onPressed: () {
                          setSheetState(() => playing = !playing);
                          widget.onPlayPauseChanged(playing);
                          if (playing) {
                            SoundService().startBgMusic();
                          } else {
                            SoundService().stopBgMusic();
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    'Music selected will be heard by everyone inside this room lobby 📻',
                    style: TextStyle(fontSize: 11 * scale, color: Colors.white60),
                  ),
                  SizedBox(height: 14 * scale),
                  ...tracks.map((t) {
                    final isCurrent = t['name'] == track && playing;
                    return Container(
                      margin: EdgeInsets.only(bottom: 8 * scale),
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF8E2DE2).withOpacity(0.3) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12 * scale),
                        border: Border.all(
                          color: isCurrent ? const Color(0xFFFFD200) : Colors.white12,
                          width: isCurrent ? 1.5 * scale : 1 * scale,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(t['icon'] as IconData, color: isCurrent ? const Color(0xFFFFD200) : Colors.white70),
                        title: Text(
                          t['name'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13 * scale,
                          ),
                        ),
                        subtitle: Text(
                          t['genre'] as String,
                          style: TextStyle(fontSize: 10.5 * scale, color: Colors.white54),
                        ),
                        trailing: isCurrent
                            ? const Icon(Icons.graphic_eq_rounded, color: Color(0xFFFFD200))
                            : const Icon(Icons.play_arrow_rounded, color: Colors.white38),
                        onTap: () {
                          setSheetState(() {
                            track = t['name'] as String;
                            playing = true;
                          });
                          widget.onTrackSelected(track);
                          widget.onPlayPauseChanged(true);
                          SoundService().startBgMusic();
                        },
                      ),
                    );
                  }),
                  SizedBox(height: 8 * scale),
                  // Stop music button
                  TextButton.icon(
                    onPressed: () {
                      setSheetState(() => playing = false);
                      widget.onPlayPauseChanged(false);
                      SoundService().stopBgMusic();
                    },
                    icon: const Icon(Icons.volume_off_rounded, color: Colors.white54),
                    label: const Text('Mute Lobby Music', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;

    return GestureDetector(
      onTap: () => _showMusicSelectorSheet(context, scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: 44 * scale,
              height: 44 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF1B1B1B),
                    Color(0xFF0F0F0F),
                    Color(0xFF333333),
                    Color(0xFF111111),
                  ],
                  stops: [0.2, 0.45, 0.8, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPlaying ? const Color(0xFFFFD200).withOpacity(0.5) : Colors.black45,
                    blurRadius: 8 * scale,
                    spreadRadius: widget.isPlaying ? 2 * scale : 0,
                  ),
                ],
                border: Border.all(
                  color: widget.isPlaying ? const Color(0xFFFFD200) : Colors.white24,
                  width: 1.5 * scale,
                ),
              ),
              child: Center(
                // Vinyl grooves & center music note
                child: Container(
                  width: 18 * scale,
                  height: 18 * scale,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    ),
                  ),
                  child: Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 11 * scale,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 3 * scale),
          Text(
            'Music',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10 * scale,
              fontWeight: FontWeight.bold,
              color: widget.isPlaying ? const Color(0xFFFFD200) : Colors.white70,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4 * scale),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
