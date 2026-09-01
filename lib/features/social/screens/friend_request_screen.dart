import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/social/models/message_model.dart';
import 'package:ludo_vibe/features/social/providers/social_provider.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class FriendRequestScreen extends ConsumerStatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  ConsumerState<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends ConsumerState<FriendRequestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRespond(int requestId, String status) async {
    try {
      final repo = ref.read(socialRepositoryProvider);
      await repo.respondFriendRequest(requestId, status);
      ref.invalidate(friendRequestsProvider);
      ref.invalidate(friendsListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'accepted' ? 'Friend request accepted!' : 'Friend request declined'),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _handleSendRequest() async {
    final text = _searchController.text.trim();
    final targetId = int.tryParse(text);
    if (targetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid numeric user ID')),
      );
      return;
    }

    try {
      final repo = ref.read(socialRepositoryProvider);
      await repo.sendFriendRequest(targetId);
      _searchController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send request or already friends'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;
    final requestsAsync = ref.watch(friendRequestsProvider);
    final friendsAsync = ref.watch(friendsListProvider);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Friends & Requests',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(fontSize: 18 * scale, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 48 * scale),
                  ],
                ),
              ),

              // Search Bar to Add by ID
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1354),
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.4)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter Player ID to add...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 13 * scale),
                            border: InputBorder.none,
                            icon: const Icon(Icons.person_search, color: Color(0xFFB173FF)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    ElevatedButton(
                      onPressed: _handleSendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9B63),
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                      ),
                      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),

              // Tab Bar (Requests vs Friends)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C073E).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.3)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF8E2DE2),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13 * scale),
                  tabs: const [
                    Tab(text: 'Incoming Requests'),
                    Tab(text: 'My Friends'),
                  ],
                ),
              ),

              // Tab View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Incoming Requests Tab
                    requestsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8E2DE2))),
                      error: (err, _) => Center(
                        child: Text('Error loading requests', style: TextStyle(color: Colors.white60, fontSize: 13 * scale)),
                      ),
                      data: (requests) {
                        if (requests.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mark_email_read_outlined, size: 48 * scale, color: Colors.white24),
                                SizedBox(height: 8 * scale),
                                Text(
                                  'No pending friend requests',
                                  style: TextStyle(color: Colors.white54, fontSize: 13 * scale),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.all(16 * scale),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final req = requests[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 10 * scale),
                              padding: EdgeInsets.all(12 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C135C).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12 * scale),
                                border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20 * scale,
                                    backgroundColor: const Color(0xFF8E2DE2),
                                    backgroundImage: req.avatarUrl != null ? NetworkImage(req.avatarUrl!) : null,
                                    child: req.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          req.username,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14 * scale,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Sent you a friend request',
                                          style: TextStyle(fontSize: 11 * scale, color: const Color(0xFFB173FF)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Accept Button
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF56AB2F)),
                                    iconSize: 28 * scale,
                                    onPressed: () => _handleRespond(req.id, 'accepted'),
                                  ),
                                  // Decline Button
                                  IconButton(
                                    icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                                    iconSize: 28 * scale,
                                    onPressed: () => _handleRespond(req.id, 'declined'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // My Friends Tab
                    friendsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8E2DE2))),
                      error: (err, _) => Center(
                        child: Text('Error loading friends', style: TextStyle(color: Colors.white60, fontSize: 13 * scale)),
                      ),
                      data: (friends) {
                        if (friends.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 48 * scale, color: Colors.white24),
                                SizedBox(height: 8 * scale),
                                Text(
                                  'No friends added yet\nUse user ID above or tap players in rooms to add!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white54, fontSize: 13 * scale),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.all(16 * scale),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 10 * scale),
                              padding: EdgeInsets.all(12 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C135C).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12 * scale),
                                border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20 * scale,
                                    backgroundColor: const Color(0xFF56AB2F),
                                    backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
                                    child: friend.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          friend.username,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14 * scale,
                                            color: Colors.white,
                                          ),
                                        ),
                                         Row(
                                           children: [
                                             Container(
                                               width: 6 * scale,
                                               height: 6 * scale,
                                               decoration: BoxDecoration(
                                                 shape: BoxShape.circle,
                                                 color: friend.isOnline ? const Color(0xFF56AB2F) : Colors.white38,
                                               ),
                                             ),
                                             SizedBox(width: 4 * scale),
                                             Text(
                                               friend.isOnline ? 'Friend • Online' : 'Friend • Offline',
                                               style: TextStyle(
                                                 fontSize: 11 * scale,
                                                 color: friend.isOnline ? const Color(0xFF56AB2F) : Colors.white38,
                                               ),
                                             ),
                                           ],
                                         ),
                                      ],
                                    ),
                                  ),
                                  // Chat / Message Button
                                  ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Opening chat with ${friend.username}')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B2F7E),
                                      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8 * scale)),
                                    ),
                                    child: const Text('Chat', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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
}
