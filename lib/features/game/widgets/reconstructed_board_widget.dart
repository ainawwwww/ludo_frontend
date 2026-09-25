import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';
import 'package:ludo_vibe/features/game/providers/board_theme_provider.dart';
import 'package:ludo_vibe/features/game/widgets/classic_procedural_board.dart';

/// Renders a reconstructed vector Ludo board from individual SVG components and manifest.json.
/// If vector reconstruction is not enabled or fails, it gracefully falls back to the
/// actual existing Classic procedural Ludo board.
class ReconstructedBoardWidget extends ConsumerWidget {
  final LudoTheme theme;
  final double? size;

  const ReconstructedBoardWidget({
    super.key,
    required this.theme,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. If theme is classic or does not use vector reconstruction, render procedural classic board
    if (theme.isClassic || !theme.usesVectorReconstruction || theme.manifestPath == null) {
      return ClassicProceduralBoardWidget(
        size: size,
        greenColor: theme.seatColors[Seat.tl] ?? const Color(0xFF0F9D58),
        yellowColor: theme.seatColors[Seat.tr] ?? const Color(0xFFF4B400),
        blueColor: theme.seatColors[Seat.br] ?? const Color(0xFF4285F4),
        redColor: theme.seatColors[Seat.bl] ?? const Color(0xFFDB4437),
      );
    }

    final boardAsync = ref.watch(reconstructedBoardSvgProvider(theme.id));

    return boardAsync.when(
      data: (svgString) {
        if (svgString.isEmpty) {
          // Fallback to Classic procedural board if string is empty
          return _buildClassicFallback();
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular((size ?? 300) * 0.025),
          child: SvgPicture.string(
            svgString,
            width: size,
            height: size,
            fit: BoxFit.fill,
            placeholderBuilder: (_) => _buildLoadingPlaceholder(size),
          ),
        );
      },
      loading: () => _buildLoadingPlaceholder(size),
      error: (err, stack) {
        debugPrint('[ReconstructedBoardWidget] Vector reconstruction failed for ${theme.id}: $err. Falling back to Classic procedural board.');
        // Required Correction: Render actual existing Classic procedural board on error
        return _buildClassicFallback();
      },
    );
  }

  Widget _buildClassicFallback() {
    return ClassicProceduralBoardWidget(
      size: size,
      greenColor: theme.seatColors[Seat.tl] ?? const Color(0xFF0F9D58),
      yellowColor: theme.seatColors[Seat.tr] ?? const Color(0xFFF4B400),
      blueColor: theme.seatColors[Seat.br] ?? const Color(0xFF4285F4),
      redColor: theme.seatColors[Seat.bl] ?? const Color(0xFFDB4437),
    );
  }

  Widget _buildLoadingPlaceholder(double? boardSize) {
    final s = boardSize ?? 300;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1432),
        borderRadius: BorderRadius.circular(s * 0.025),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFFFFD200),
          ),
        ),
      ),
    );
  }
}
