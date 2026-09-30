import 'package:flutter/material.dart';

enum TournamentMode {
  classic,
  quick;

  String get displayName {
    switch (this) {
      case TournamentMode.classic:
        return 'Classic';
      case TournamentMode.quick:
        return 'Quick';
    }
  }

  String get trophyAsset {
    switch (this) {
      case TournamentMode.classic:
        return 'assets/images/tournament/trophy_gold_classic.png';
      case TournamentMode.quick:
        return 'assets/images/tournament/trophy_gold_quick.png';
    }
  }

  LinearGradient get cardGradient {
    switch (this) {
      case TournamentMode.classic:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF283A8C),
            Color(0xFF1B1A56),
            Color(0xFF0F103A),
          ],
        );
      case TournamentMode.quick:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D6970),
            Color(0xFF0A444C),
            Color(0xFF07272F),
          ],
        );
    }
  }

  Color get accentColor {
    switch (this) {
      case TournamentMode.classic:
        return const Color(0xFF2F6FED);
      case TournamentMode.quick:
        return const Color(0xFF2FD7C4);
    }
  }

  Color get borderColor {
    switch (this) {
      case TournamentMode.classic:
        return const Color(0xFF4A7FFF);
      case TournamentMode.quick:
        return const Color(0xFF3FEAD7);
    }
  }
}
