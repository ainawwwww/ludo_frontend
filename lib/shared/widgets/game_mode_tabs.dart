import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/home/providers/home_provider.dart';

class GameModeTabs extends ConsumerWidget {
  const GameModeTabs({super.key});

  static const _tabs = [
    (GameModeTab.ludo, 'assets/graphics/tab_ludo.png', 'Ludo'),
    (GameModeTab.domino, 'assets/graphics/tab_domino.png', 'Domino'),
    (GameModeTab.jackpot, 'assets/graphics/tab_jackaroo.png', 'Jackaroo'),
    (GameModeTab.other, 'assets/graphics/tab_others.png', 'Other'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;
    final selectedMode = ref.watch(homeProvider).gameMode;

    return Center(
      child: Container(
        width: 333.42 * scale,
        height: 75.69 * scale, // From Figma: height 75.69
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(69 * scale), // From Figma: borderRadius 69
          image: const DecorationImage(
            image: AssetImage('assets/graphics/gameboardswitcherbackground.png'),
            fit: BoxFit.fill,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: Offset(0, 4),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _tabs.map((tab) {
            final isSelected = selectedMode == tab.$1;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ref.read(homeProvider.notifier).setGameMode(tab.$1);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isSelected)
                          Container(
                            width: 30 * scale,
                            height: 30 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.35),
                                  blurRadius: 10 * scale,
                                  spreadRadius: 1 * scale,
                                ),
                              ],
                            ),
                          ),
                        Image.asset(
                          tab.$2,
                          width: 28 * scale,
                          height: 28 * scale,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    SizedBox(height: 3 * scale),
                    Text(
                      tab.$3,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10 * scale, // From Figma: fontSize 10
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFFB173FF), // From Figma: fill_98609e7b is #B173FF
                        height: 1.0,
                        shadows: isSelected
                            ? [
                                Shadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: const Offset(0, 0),
                                  blurRadius: 8 * scale,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
