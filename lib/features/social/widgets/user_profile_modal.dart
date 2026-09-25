import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/social/providers/social_provider.dart';

class UserProfileModal extends ConsumerStatefulWidget {
  const UserProfileModal({
    super.key,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.country,
    this.isHost = false,
  });

  final int userId;
  final String username;
  final String? avatarUrl;
  final String? country;
  final bool isHost;

  static void show(
    BuildContext context, {
    required int userId,
    required String username,
    String? avatarUrl,
    String? country,
    bool isHost = false,
  }) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => UserProfileModal(
        userId: userId,
        username: username,
        avatarUrl: avatarUrl,
        country: country,
        isHost: isHost,
      ),
    );
  }

  @override
  ConsumerState<UserProfileModal> createState() => _UserProfileModalState();
}

class _UserProfileModalState extends ConsumerState<UserProfileModal> {
  bool _isFollowing = false;
  bool _isLoadingFollow = true;
  bool _isSendingFriendReq = false;
  bool _isFriendReqSent = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    try {
      final repo = ref.read(socialRepositoryProvider);
      final status = await repo.getFollowStatus(widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = status;
          _isLoadingFollow = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    final repo = ref.read(socialRepositoryProvider);
    final previousState = _isFollowing;
    setState(() {
      _isFollowing = !_isFollowing;
    });

    try {
      if (previousState) {
        await repo.unfollowUser(widget.userId);
      } else {
        await repo.followUser(widget.userId);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFollowing = previousState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update follow status')),
        );
      }
    }
  }

  Future<void> _sendFriendRequest() async {
    if (_isSendingFriendReq || _isFriendReqSent) return;

    setState(() {
      _isSendingFriendReq = true;
    });

    try {
      final repo = ref.read(socialRepositoryProvider);
      await repo.sendFriendRequest(widget.userId);
      if (mounted) {
        setState(() {
          _isSendingFriendReq = false;
          _isFriendReqSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friend request sent to ${widget.username}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isSendingFriendReq = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.orange),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSendingFriendReq = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;
    final currentUserId = ref.watch(authProvider).user?.id;
    final isMe = currentUserId != null && currentUserId == widget.userId;

    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF140D4A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20 * scale,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40 * scale,
              height: 4 * scale,
              margin: EdgeInsets.only(bottom: 16 * scale),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            ),

            // User Avatar
            Container(
              width: 72 * scale,
              height: 72 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isHost ? const Color(0xFFFFD200) : const Color(0xFF56AB2F),
                  width: 3 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isHost
                        ? const Color(0xFFFFD200).withOpacity(0.4)
                        : const Color(0xFF56AB2F).withOpacity(0.4),
                    blurRadius: 12 * scale,
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                    ? Image.network(
                        widget.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 36),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 36),
              ),
            ),
            SizedBox(height: 10 * scale),

            // Username
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.username,
                  style: AppTextStyles.h2.copyWith(fontSize: 18 * scale, color: Colors.white),
                ),
                if (widget.isHost) ...[
                  SizedBox(width: 6 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD200).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4 * scale),
                      border: Border.all(color: const Color(0xFFFFD200), width: 1),
                    ),
                    child: Text(
                      '👑 Host',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD200),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 4 * scale),

            // User ID
            Text(
              'ID: ${widget.userId}',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11 * scale, color: Colors.white60),
            ),
            SizedBox(height: 20 * scale),

            // Action Buttons (Follow / Add Friend)
            if (!isMe)
              Row(
                children: [
                  // Follow / Unfollow Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingFollow ? null : _toggleFollow,
                      icon: Icon(
                        _isFollowing ? Icons.check : Icons.person_add_alt_1,
                        size: 16 * scale,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing ? const Color(0xFF3B2F7E) : const Color(0xFFFF9B63),
                        padding: EdgeInsets.symmetric(vertical: 12 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                          side: _isFollowing ? const BorderSide(color: Color(0xFF5D48E8)) : BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * scale),

                  // Add Friend Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isFriendReqSent ? null : _sendFriendRequest,
                      icon: Icon(
                        _isFriendReqSent ? Icons.done_all : Icons.favorite_border_rounded,
                        size: 16 * scale,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isFriendReqSent ? 'Request Sent' : 'Add Friend',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFriendReqSent ? const Color(0xFF3B2F7E) : const Color(0xFF8E2DE2),
                        padding: EdgeInsets.symmetric(vertical: 12 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                'This is your profile',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13 * scale, color: Colors.white54),
              ),

            SizedBox(height: 12 * scale),
          ],
        ),
      ),
    );
  }
}
