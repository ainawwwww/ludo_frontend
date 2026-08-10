import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/bottom_nav_bar.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';
import 'package:ludo_vibe/shared/widgets/top_bar.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_DailyTask> _dailyTasks = [
    const _DailyTask(
      id: '1',
      title: 'Win 2 Ludo Matches',
      rewardCoins: 500,
      currentProgress: 2,
      totalProgress: 2,
      isClaimed: false,
    ),
    const _DailyTask(
      id: '2',
      title: 'Play 5 Betting Battles',
      rewardCoins: 1200,
      currentProgress: 3,
      totalProgress: 5,
      isClaimed: false,
    ),
    const _DailyTask(
      id: '3',
      title: 'Send 3 Gifts in Voice Lobbies',
      rewardCoins: 800,
      currentProgress: 1,
      totalProgress: 3,
      isClaimed: false,
    ),
    const _DailyTask(
      id: '4',
      title: 'Roll 6 Three Times',
      rewardCoins: 300,
      currentProgress: 3,
      totalProgress: 3,
      isClaimed: true,
    ),
  ];

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
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyTasksTab(scale),
                  _buildVipPassTab(scale),
                  _buildArrivalChestTab(scale),
                ],
              ),
            ),

            const BottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTasksTab(double scale) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      itemCount: _dailyTasks.length,
      itemBuilder: (context, index) {
        final task = _dailyTasks[index];
        final isCompleted = task.currentProgress >= task.totalProgress;

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
                  'assets/graphics/icon_coins.png',
                  width: 24 * scale,
                  height: 24 * scale,
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
                          '+${task.rewardCoins} Coins',
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
                        value: task.currentProgress / task.totalProgress,
                        backgroundColor: AppColors.progressTrack.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? const Color(0xFF56AB2F) : AppColors.actionOrange,
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
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
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
              else
                OrangeButton(
                  text: 'CLAIM',
                  onPressed: isCompleted
                      ? () {
                          setState(() {
                            _dailyTasks[index] = task.copyWith(isClaimed: true);
                          });
                        }
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
              border: Border.all(color: const Color(0xFFFFD369), width: 2 * scale),
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
                  onPressed: () {},
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

  Widget _buildArrivalChestTab(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 80 * scale,
            color: const Color(0xFFFF9B63),
          ),
          SizedBox(height: 16 * scale),
          Text(
            'DAILY ARRIVAL CHEST',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 18 * scale,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Check back in 04:32:10 for your next free chest drop!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12 * scale,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTask {
  final String id;
  final String title;
  final int rewardCoins;
  final int currentProgress;
  final int totalProgress;
  final bool isClaimed;

  const _DailyTask({
    required this.id,
    required this.title,
    required this.rewardCoins,
    required this.currentProgress,
    required this.totalProgress,
    required this.isClaimed,
  });

  _DailyTask copyWith({bool? isClaimed}) {
    return _DailyTask(
      id: id,
      title: title,
      rewardCoins: rewardCoins,
      currentProgress: currentProgress,
      totalProgress: totalProgress,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}
