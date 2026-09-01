import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/core/theme/app_theme.dart';
import 'package:ludo_vibe/features/battle/providers/battle_provider.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final TextEditingController _titleController = TextEditingController(text: 'VIP Ludo Lounge');
  String _privacy = 'public'; // public or private
  int _maxPlayers = 4; // 2 or 4
  int _turnTimer = 15; // 15 or 30
  int _entryFee = 500; // 0, 500, 1000, 2000, 5000
  bool _isLoading = false;

  final List<int> _entryFeeOptions = [0, 500, 1000, 2000, 5000];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _cyclePrivacy() {
    setState(() {
      _privacy = _privacy == 'public' ? 'private' : 'public';
    });
  }

  void _cycleMaxPlayers() {
    setState(() {
      _maxPlayers = _maxPlayers == 4 ? 2 : 4;
    });
  }

  void _cycleTurnTimer() {
    setState(() {
      _turnTimer = _turnTimer == 15 ? 30 : 15;
    });
  }

  void _cycleEntryFee() {
    final currentIndex = _entryFeeOptions.indexOf(_entryFee);
    final nextIndex = (currentIndex + 1) % _entryFeeOptions.length;
    setState(() {
      _entryFee = _entryFeeOptions[nextIndex];
    });
  }

  Future<void> _handleCreateRoom() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(battleRepositoryProvider);
      final room = await repository.createRoom(
        title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'VIP Ludo Lounge',
        type: _privacy,
        maxPlayers: _maxPlayers,
        entryFee: _entryFee,
      );

      // Refresh lobby explore/my lists
      ref.read(battleLobbyProvider.notifier).loadExploreData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room "${room.title}" created successfully! Code: ${room.roomCode ?? room.roomId}'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to room detail
        context.pushReplacement(
          AppConstants.roomDetailRoute,
          extra: {
            'title': room.title,
            'id': room.roomId.toString(),
          },
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create room. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(12 * scale),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Create My Room',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(fontSize: 20 * scale),
                      ),
                    ),
                    SizedBox(width: 48 * scale),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room Name Field
                      Container(
                        margin: EdgeInsets.only(bottom: 12 * scale),
                        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                        decoration: BoxDecoration(
                          gradient: AppColors.rewardCardGradient,
                          borderRadius: BorderRadius.circular(AppConstants.radius10),
                          boxShadow: AppTheme.purpleInsetGlow,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_note_rounded, color: AppColors.secondary, size: 24 * scale),
                            SizedBox(width: 12 * scale),
                            Expanded(
                              child: TextField(
                                controller: _titleController,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontSize: 15 * scale,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  labelText: 'Room Name',
                                  labelStyle: AppTextStyles.subtitle.copyWith(
                                    fontSize: 12 * scale,
                                    color: const Color(0xFFB173FF),
                                  ),
                                  hintText: 'Enter room name',
                                  hintStyle: TextStyle(color: Colors.white38, fontSize: 14 * scale),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Room Privacy Tile
                      _SettingTile(
                        scale: scale,
                        icon: _privacy == 'private' ? Icons.lock_outline : Icons.public_rounded,
                        title: 'Room Privacy',
                        subtitle: _privacy == 'private' ? 'Private Room (Code Only)' : 'Public Room (Visible in Lobby)',
                        onTap: _cyclePrivacy,
                      ),

                      // Max Players Tile
                      _SettingTile(
                        scale: scale,
                        icon: Icons.people_outline,
                        title: 'Max Players',
                        subtitle: '$_maxPlayers Players',
                        onTap: _cycleMaxPlayers,
                      ),

                      // Turn Timer Tile
                      _SettingTile(
                        scale: scale,
                        icon: Icons.timer_outlined,
                        title: 'Turn Timer',
                        subtitle: '$_turnTimer seconds',
                        onTap: _cycleTurnTimer,
                      ),

                      // Entry Fee Tile
                      _SettingTile(
                        scale: scale,
                        icon: Icons.monetization_on_outlined,
                        title: 'Entry Fee',
                        subtitle: _entryFee == 0 ? 'Free Entry' : '$_entryFee Coins',
                        onTap: _cycleEntryFee,
                      ),

                      SizedBox(height: 24 * scale),
                      Text(
                        'Friend Request',
                        style: AppTextStyles.sectionHeader.copyWith(
                          fontSize: 15 * scale,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Container(
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          gradient: AppColors.modalInnerGradient,
                          borderRadius: BorderRadius.circular(AppConstants.radius14),
                          border: Border.all(
                            color: AppColors.primaryBorderSoft,
                          ),
                        ),
                        child: Text(
                          'Your friends can see your active room and join directly from the lobby!',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12 * scale,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: OrangeButton(
                  label: _isLoading ? 'Creating Room...' : 'Create Room',
                  width: double.infinity,
                  onPressed: _isLoading ? null : _handleCreateRoom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.scale,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8 * scale),
        padding: EdgeInsets.all(14 * scale),
        decoration: BoxDecoration(
          gradient: AppColors.rewardCardGradient,
          borderRadius: BorderRadius.circular(AppConstants.radius10),
          boxShadow: AppTheme.purpleInsetGlow,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 24 * scale),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(fontSize: 15 * scale),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 12 * scale,
                      color: const Color(0xFFB173FF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
