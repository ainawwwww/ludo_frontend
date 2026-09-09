import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/home/models/event_model.dart';
import 'package:ludo_vibe/features/home/providers/events_provider.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/bottom_nav_bar.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';
import 'package:ludo_vibe/shared/widgets/top_bar.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startCountdownTimer(int initialSeconds) {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = initialSeconds;
    });

    if (_secondsRemaining <= 0) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        ref.read(eventsProvider.notifier).fetchEventsData();
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00:00';
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;
    final eventsState = ref.watch(eventsProvider);

    ref.listen(eventsProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
      }
      if (next.arrivalChest != null && !next.arrivalChest!.isReady && _countdownTimer == null) {
        _startCountdownTimer(next.arrivalChest!.secondsRemaining);
      }
    });

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            const TopBar(),
            SizedBox(height: 8 * scale),

            // Screen Header Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFFFD700),
                    size: 28 * scale,
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    'EVENTS & REWARDS',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, color: Colors.white70, size: 22 * scale),
                    onPressed: () => ref.read(eventsProvider.notifier).fetchEventsData(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * scale),

            // Tab Navigation Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16 * scale),
              height: 42 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF0C073E).withOpacity(0.6),
                borderRadius: BorderRadius.circular(21 * scale),
                border: Border.all(
                  color: AppColors.primaryBorder.withOpacity(0.4),
                  width: 1 * scale,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.leagueCardGradient,
                  borderRadius: BorderRadius.circular(21 * scale),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Daily Tasks'),
                  Tab(text: 'VIP Pass'),
                  Tab(text: 'Arrival Chest'),
                ],
              ),
            ),
            SizedBox(height: 12 * scale),

            // Tab Content Body
            Expanded(
              child: eventsState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.actionOrange))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDailyTasksTab(scale, eventsState),
                        _buildVipPassTab(scale),
                        _buildArrivalChestTab(scale, eventsState),
                      ],
                    ),
            ),

            const BottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTasksTab(double scale, EventsState state) {
    final tasks = state.dailyTasks;

    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No daily tasks available.',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 14 * scale),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isCompleted = task.isCompleted;
        final isClaiming = state.claimingTaskId == task.id;

        return Container(
          margin: EdgeInsets.only(bottom: 12 * scale),
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            gradient: AppColors.listItemGradient,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: AppColors.primaryBorder.withOpacity(0.5),
              width: 1 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6 * scale,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1C7A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD369),
                    width: 1.5 * scale,
                  ),
                ),
                child: Image.asset(
                  task.rewardType == 'diamonds'
                      ? 'assets/graphics/icon_diamonds.png'
                      : 'assets/graphics/icon_coins.png',
                  width: 24 * scale,
                  height: 24 * scale,
                  errorBuilder: (_, __, ___) => Icon(
                    task.rewardType == 'diamonds' ? Icons.diamond_rounded : Icons.monetization_on_rounded,
                    color: const Color(0xFFFFD369),
                    size: 24 * scale,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),

              // Task Text and Progress Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        fontSize: 13 * scale,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Row(
                      children: [
                        Text(
                          '+${task.rewardAmount} ${task.rewardType.toUpperCase()}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFD369),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${task.currentProgress}/${task.totalProgress}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11 * scale,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6 * scale),
                    // Progress Track
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4 * scale),
                      child: LinearProgressIndicator(
                        value: (task.currentProgress / task.totalProgress).clamp(0.0, 1.0),
                        backgroundColor:
                            AppColors.progressTrack.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted
                              ? const Color(0xFF56AB2F)
                              : AppColors.actionOrange,
                        ),
                        minHeight: 6 * scale,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * scale),

              // Action / Claim Button
              if (task.isClaimed)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Text(
                    'CLAIMED',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                    ),
                  ),
                )
              else if (isClaiming)
                SizedBox(
                  width: 32 * scale,
                  height: 32 * scale,
                  child: const CircularProgressIndicator(color: AppColors.actionOrange, strokeWidth: 2.5),
                )
              else
                OrangeButton(
                  text: 'CLAIM',
                  onPressed: isCompleted
                      ? () => ref.read(eventsProvider.notifier).claimDailyTask(task.id)
                      : null,
                  width: 72 * scale,
                  height: 32 * scale,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVipPassTab(double scale) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              gradient: AppColors.modalGradient,
              borderRadius: BorderRadius.circular(20 * scale),
              border:
                  Border.all(color: const Color(0xFFFFD369), width: 2 * scale),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.card_membership_rounded,
                  size: 64 * scale,
                  color: const Color(0xFFFFD369),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  'KNIGHT VIP SUBSCRIPTION',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 18 * scale,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Unlock 2x Daily Coins, Golden Profile Frame, Custom Dice Skins & Priority Voice Lobbies!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 16 * scale),
                OrangeButton(
                  text: 'ACTIVATE VIP - \$4.99/mo',
                  onPressed: () => context.pushNamed('subscription'),
                  width: 220 * scale,
                  height: 44 * scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalChestTab(double scale, EventsState state) {
    final chest = state.arrivalChest;
    final isReady = chest?.isReady ?? false;
    final isClaiming = state.isClaimingChest;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120 * scale,
              height: 120 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1055),
                boxShadow: isReady
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF9B63).withOpacity(0.6),
                          blurRadius: 20 * scale,
                          spreadRadius: 4 * scale,
                        ),
                      ]
                    : null,
                border: Border.all(
                  color: isReady ? const Color(0xFFFFD369) : Colors.white24,
                  width: 3 * scale,
                ),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 70 * scale,
                color: isReady ? const Color(0xFFFFD369) : Colors.white38,
              ),
            ),
            SizedBox(height: 20 * scale),
            Text(
              'DAILY ARRIVAL CHEST',
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 18 * scale,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8 * scale),
            if (isReady)
              Text(
                'Your free daily reward chest is ready to open!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13 * scale,
                  color: const Color(0xFFFFD369),
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                'Check back in ${_formatDuration(_secondsRemaining)} for your next chest!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  color: Colors.white70,
                ),
              ),
            SizedBox(height: 24 * scale),
            if (isClaiming)
              const CircularProgressIndicator(color: AppColors.actionOrange)
            else
              OrangeButton(
                text: isReady ? 'OPEN CHEST' : 'LOCKED',
                onPressed: isReady
                    ? () => ref.read(eventsProvider.notifier).claimArrivalChest()
                    : null,
                width: 180 * scale,
                height: 44 * scale,
              ),
          ],
        ),
      ),
    );
  }
}
