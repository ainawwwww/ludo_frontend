import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/game/engine/ludo_game_engine.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';
import 'package:ludo_vibe/features/game/providers/board_theme_provider.dart';
import 'package:ludo_vibe/features/game/widgets/themed_ludo_board.dart';
import 'package:ludo_vibe/features/game/widgets/classic_procedural_board.dart';

/// Debug & QA Theme Gallery Screen
/// Gated by kDebugMode (Requirement 5).
/// Allows cycling through all themes, toggling 15x15 grid overlay, dummy base tokens,
/// and drawing engine home-stretch and start cells on top to spot lane mismatches (Requirement 2).
class ThemeGalleryScreen extends ConsumerStatefulWidget {
  const ThemeGalleryScreen({super.key});

  @override
  ConsumerState<ThemeGalleryScreen> createState() => _ThemeGalleryScreenState();
}

class _ThemeGalleryScreenState extends ConsumerState<ThemeGalleryScreen> {
  int _currentThemeIndex = 0;
  bool _showGridOverlay = true;
  bool _showLaneHighlights = true;
  bool _showDummyBaseTokens = true;
  bool _showDummyTrackTokens = true;

  @override
  Widget build(BuildContext context) {
    // Requirement 5: Gate /theme-gallery with kDebugMode
    if (!kDebugMode) {
      return Scaffold(
        backgroundColor: const Color(0xFF14082D),
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text(
            'Theme Gallery is only accessible in Debug Mode.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final catalogAsync = ref.watch(themeCatalogProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F081D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B0F33),
        elevation: 0,
        title: const Text(
          'Board Theme Gallery (QA)',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      body: catalogAsync.when(
        data: (themes) {
          if (themes.isEmpty) {
            return const Center(child: Text('No themes found', style: TextStyle(color: Colors.white)));
          }

          final themeIndex = _currentThemeIndex.clamp(0, themes.length - 1);
          final currentTheme = themes[themeIndex];
          final pieces = _generateDummyPieces(currentTheme);

          return Column(
            children: [
              // Theme Navigator Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF1F123B),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                      onPressed: themeIndex > 0
                          ? () => setState(() => _currentThemeIndex--)
                          : null,
                    ),
                    Column(
                      children: [
                        Text(
                          currentTheme.name.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD200),
                          ),
                        ),
                        Text(
                          'ID: ${currentTheme.id} (${themeIndex + 1}/${themes.length})',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                      onPressed: themeIndex < themes.length - 1
                          ? () => setState(() => _currentThemeIndex++)
                          : null,
                    ),
                  ],
                ),
              ),

              // Interactive Toggle Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _buildToggleChip(
                      '15x15 Grid',
                      _showGridOverlay,
                      (v) => setState(() => _showGridOverlay = v),
                    ),
                    const SizedBox(width: 8),
                    _buildToggleChip(
                      'Engine Lanes & Starts',
                      _showLaneHighlights,
                      (v) => setState(() => _showLaneHighlights = v),
                    ),
                    const SizedBox(width: 8),
                    _buildToggleChip(
                      'Base Tokens',
                      _showDummyBaseTokens,
                      (v) => setState(() => _showDummyBaseTokens = v),
                    ),
                    const SizedBox(width: 8),
                    _buildToggleChip(
                      'Track Tokens',
                      _showDummyTrackTokens,
                      (v) => setState(() => _showDummyTrackTokens = v),
                    ),
                  ],
                ),
              ),

              // Themed Ludo Board with Overlays
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF7A4BC8), width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 16),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: currentTheme.isClassic
                              ? const ClassicProceduralBoardWidget()
                              : ThemedLudoBoard(
                                  theme: currentTheme,
                                  pieces: pieces,
                                  showGridOverlay: _showGridOverlay,
                                  showLaneHighlights: _showLaneHighlights,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Manifest Inspector Info Panel
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFF180D2E),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(
                      'Grid Rect',
                      'L:${currentTheme.grid.left.toStringAsFixed(3)} T:${currentTheme.grid.top.toStringAsFixed(3)} S:${currentTheme.grid.size.toStringAsFixed(3)}',
                    ),
                    _buildColorSwatch('TL', currentTheme.seatColors[Seat.tl]),
                    _buildColorSwatch('TR', currentTheme.seatColors[Seat.tr]),
                    _buildColorSwatch('BL', currentTheme.seatColors[Seat.bl]),
                    _buildColorSwatch('BR', currentTheme.seatColors[Seat.br]),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFFD200))),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildToggleChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: value ? Colors.white : Colors.white60,
        ),
      ),
      selected: value,
      selectedColor: const Color(0xFF6B2ED6),
      backgroundColor: const Color(0xFF22153F),
      checkmarkColor: Colors.white,
      onSelected: onChanged,
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, color: Colors.white38)),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildColorSwatch(String label, Color? color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, color: Colors.white38)),
        const SizedBox(height: 2),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color ?? Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 1),
          ),
        ),
      ],
    );
  }

  List<ThemedBoardPiece> _generateDummyPieces(LudoTheme theme) {
    final list = <ThemedBoardPiece>[];

    // Dummy base tokens for all 4 quadrants
    if (_showDummyBaseTokens) {
      for (final color in PlayerColor.values) {
        for (int i = 0; i < 4; i++) {
          list.add(ThemedBoardPiece(
            id: 'dummy_base_${color.name}_$i',
            playerColor: color,
            isInBase: true,
            baseSlotIndex: i,
          ));
        }
      }
    }

    // Dummy track tokens on start points and home stretches
    if (_showDummyTrackTokens) {
      // Start points
      list.add(const ThemedBoardPiece(id: 'start_green', playerColor: PlayerColor.green, gridCol: 1, gridRow: 6));
      list.add(const ThemedBoardPiece(id: 'start_yellow', playerColor: PlayerColor.yellow, gridCol: 8, gridRow: 1));
      list.add(const ThemedBoardPiece(id: 'start_blue', playerColor: PlayerColor.blue, gridCol: 13, gridRow: 8));
      list.add(const ThemedBoardPiece(id: 'start_red', playerColor: PlayerColor.red, gridCol: 6, gridRow: 13));

      // Home stretches
      list.add(const ThemedBoardPiece(id: 'stretch_green', playerColor: PlayerColor.green, gridCol: 3, gridRow: 7));
      list.add(const ThemedBoardPiece(id: 'stretch_yellow', playerColor: PlayerColor.yellow, gridCol: 7, gridRow: 3));
      list.add(const ThemedBoardPiece(id: 'stretch_blue', playerColor: PlayerColor.blue, gridCol: 11, gridRow: 7));
      list.add(const ThemedBoardPiece(id: 'stretch_red', playerColor: PlayerColor.red, gridCol: 7, gridRow: 11));
    }

    return list;
  }
}
