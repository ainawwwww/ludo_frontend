import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';

class LudoLobbyScreen extends ConsumerStatefulWidget {
  const LudoLobbyScreen({super.key});

  @override
  ConsumerState<LudoLobbyScreen> createState() => _LudoLobbyScreenState();
}

class _LudoLobbyScreenState extends ConsumerState<LudoLobbyScreen> {
  bool _isOnlineMatch = true; // true = Online Match, false = Play vs Computer
  int _playerCount = 4;
  int _betAmount = 500;
  bool _isLoading = false;

  final List<int> _availableBets = [500, 1000, 2000, 5000, 10000];

  void _incrementBet() {
    final currentIndex = _availableBets.indexOf(_betAmount);
    if (currentIndex != -1 && currentIndex < _availableBets.length - 1) {
      setState(() {
        _betAmount = _availableBets[currentIndex + 1];
      });
    } else if (currentIndex == -1) {
      setState(() {
        _betAmount += 500;
      });
    }
  }

  void _decrementBet() {
    final currentIndex = _availableBets.indexOf(_betAmount);
    if (currentIndex > 0) {
      setState(() {
        _betAmount = _availableBets[currentIndex - 1];
      });
    } else if (currentIndex == -1 && _betAmount > 500) {
      setState(() {
        _betAmount -= 500;
      });
    }
  }

  Future<void> _handlePlayNow() async {
    if (_isLoading) return; // Double-tap protection

    if (!_isOnlineMatch) {
      // Practice / Offline Mode with Local AI
      context.push(
        AppConstants.ludoBoardRoute,
        extra: {
          'players': _playerCount,
          'bet': 0,
          'isPractice': true,
        },
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      final wsService = ref.read(webSocketServiceProvider);

      if (userId != null) {
        if (!wsService.isConnected) {
          await wsService.connect();
        }
        wsService.subscribeToUserChannel(userId);
      }

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.quickMatch,
        data: {
          'max_players': _playerCount,
          'entry_fee': _betAmount,
        },
      );

      if (!mounted) return;

      final data = response is Map<String, dynamic> ? response['data'] : null;

      // Successfully queued or matched immediately -> Go to waiting room
      context.push(
        AppConstants.waitingRoomRoute,
        extra: {
          'players': _playerCount,
          'bet': _betAmount,
          'initialMatchData': data,
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      if (e.statusCode == 409) {
        // Already in queue -> Resume waiting room
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resuming active matchmaking queue...'),
            backgroundColor: Color(0xFF5D48E8),
            duration: Duration(seconds: 2),
          ),
        );
        context.push(
          AppConstants.waitingRoomRoute,
          extra: {
            'players': _playerCount,
            'bet': _betAmount,
          },
        );
      } else if (e.statusCode == 400 && e.message.toLowerCase().contains('insufficient')) {
        _showInsufficientCoinsDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1058),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF8C7DF5), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD200)),
            SizedBox(width: 8),
            Text(
              'Insufficient Coins',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'You need at least $_betAmount coins to enter this match. Please lower your entry fee or top up your coins.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFCCA3FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background main image
          Image.asset(
            'assets/graphics/bg_home.png',
            fit: BoxFit.cover,
          ),
          // Gradient backdrop overlay
          Container(
            color: const Color(0xFF0F0842).withValues(alpha: 0.85),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Column(
                children: [
                  // Custom Header with back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 22 * scale),
                      ),
                      const Spacer(),
                      Text(
                        'LUDO BATTLE',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(width: 48 * scale),
                    ],
                  ),
                  
                  SizedBox(height: 12 * scale),

                  // Segmented Match Type Toggle (Online Match vs Play vs Computer)
                  Container(
                    height: 48 * scale,
                    padding: EdgeInsets.all(4 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140D4A).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24 * scale),
                      border: Border.all(color: const Color(0xFF6C52EE).withValues(alpha: 0.5), width: 1.5 * scale),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTypeTab(
                            title: 'Online Battle',
                            icon: Icons.public_rounded,
                            isSelected: _isOnlineMatch,
                            scale: scale,
                            onTap: () => setState(() => _isOnlineMatch = true),
                          ),
                        ),
                        Expanded(
                          child: _buildTypeTab(
                            title: 'Play vs Computer',
                            icon: Icons.smart_toy_rounded,
                            isSelected: !_isOnlineMatch,
                            scale: scale,
                            onTap: () => setState(() => _isOnlineMatch = false),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),
                  
                  // Card base panel containing options
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C135C).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20 * scale),
                      border: Border.all(color: const Color(0xFF8C7DF5).withValues(alpha: 0.3), width: 1.5 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 15 * scale,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title 1: Player Count
                        Text(
                          'CHOOSE PLAYER COUNT',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFCCA3FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 12 * scale),

                        // 2 vs 4 player Row
                        Row(
                          children: [
                            Expanded(
                                child: _buildModeToggle(2, '2 Players', scale)),
                            SizedBox(width: 12 * scale),
                            Expanded(
                                child: _buildModeToggle(4, '4 Players', scale)),
                          ],
                        ),

                        SizedBox(height: 24 * scale),

                        // Title 2: Entry Fee or Practice Notice
                        if (_isOnlineMatch) ...[
                          Text(
                            'ENTRY FEE (BET)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFCCA3FF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          
                          // Bet selector box
                          Container(
                            height: 60 * scale,
                            padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C073E).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14 * scale),
                              border: Border.all(color: const Color(0xFF5D48E8).withValues(alpha: 0.3), width: 1 * scale),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Minus Button
                                IconButton(
                                  onPressed: _decrementBet,
                                  icon: Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: _betAmount > 500 ? const Color(0xFFB173FF) : Colors.white24,
                                    size: 32 * scale,
                                  ),
                                ),
                                
                                // Coin amount display
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/graphics/icon_coins.png',
                                      width: 24 * scale,
                                      height: 24 * scale,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: 8 * scale),
                                    Text(
                                      '$_betAmount',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 22 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFFD200),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Plus Button
                                IconButton(
                                  onPressed: _incrementBet,
                                  icon: Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: _availableBets.indexOf(_betAmount) < _availableBets.length - 1
                                        ? const Color(0xFFB173FF)
                                        : Colors.white24,
                                    size: 32 * scale,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Practice Mode Badge
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 16 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E2C22).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(14 * scale),
                              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4), width: 1 * scale),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: const Color(0xFF00E676), size: 24 * scale),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Offline Practice Mode',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Free match against AI bots • No coins required',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11 * scale,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // PLAY NOW Button with Loading & Double-tap Protection
                  GestureDetector(
                    onTap: _isLoading ? null : _handlePlayNow,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 52 * scale,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isLoading
                              ? [const Color(0xFF555555), const Color(0xFF333333)]
                              : (_isOnlineMatch
                                  ? [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)]
                                  : [const Color(0xFF00B09B), const Color(0xFF96C93D)]),
                        ),
                        borderRadius: BorderRadius.circular(26 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: (_isOnlineMatch ? const Color(0xFF4A00E0) : const Color(0xFF00B09B)).withValues(alpha: 0.4),
                            blurRadius: 10 * scale,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                width: 24 * scale,
                                height: 24 * scale,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isOnlineMatch ? 'FIND MATCH' : 'START PRACTICE',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D48E8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5D48E8).withValues(alpha: 0.4),
                    blurRadius: 8 * scale,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18 * scale,
              color: isSelected ? Colors.white : Colors.white60,
            ),
            SizedBox(width: 6 * scale),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13 * scale,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle(int count, String label, double scale) {
    final isSelected = _playerCount == count;
    return GestureDetector(
      onTap: () {
        setState(() {
          _playerCount = count;
        });
      },
      child: Container(
        height: 50 * scale,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4C3EC8) : Colors.transparent,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: isSelected ? const Color(0xFF8C7DF5) : Colors.white30,
            width: 1.5 * scale,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4C3EC8).withValues(alpha: 0.4),
                    blurRadius: 6 * scale,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14 * scale,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
