import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

class LudoLobbyScreen extends StatefulWidget {
  const LudoLobbyScreen({super.key});

  @override
  State<LudoLobbyScreen> createState() => _LudoLobbyScreenState();
}

class _LudoLobbyScreenState extends State<LudoLobbyScreen> {
  int _playerCount = 4;
  int _betAmount = 500;

  void _incrementBet() {
    setState(() {
      _betAmount += 500;
    });
  }

  void _decrementBet() {
    if (_betAmount > 500) {
      setState(() {
        _betAmount -= 500;
      });
    }
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
            color: const Color(0xFF0F0842).withOpacity(0.85),
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
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22 * scale),
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
                      SizedBox(width: 48 * scale), // spacer visual symmetry
                    ],
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Card base panel containing options
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C135C).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20 * scale),
                      border: Border.all(color: const Color(0xFF8C7DF5).withOpacity(0.3), width: 1.5 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 15 * scale,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title 1
                        Text(
                          'CHOOSE GAME MODE',
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
                            Expanded(child: _buildModeToggle(2, '2 Players', scale)),
                            SizedBox(width: 12 * scale),
                            Expanded(child: _buildModeToggle(4, '4 Players', scale)),
                          ],
                        ),
                        
                        SizedBox(height: 24 * scale),
                        
                        // Title 2
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
                            color: const Color(0xFF0C073E).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(14 * scale),
                            border: Border.all(color: const Color(0xFF5D48E8).withOpacity(0.3), width: 1 * scale),
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
                                  color: const Color(0xFFB173FF),
                                  size: 32 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 3),
                  
                  // PLAY NOW Button
                  GestureDetector(
                    onTap: () {
                      context.push(
                        AppConstants.ludoBoardRoute,
                        extra: {
                          'players': _playerCount,
                          'bet': _betAmount,
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52 * scale,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        ),
                        borderRadius: BorderRadius.circular(26 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A00E0).withOpacity(0.4),
                            blurRadius: 10 * scale,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'PLAY NOW',
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
                    color: const Color(0xFF4C3EC8).withOpacity(0.4),
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
