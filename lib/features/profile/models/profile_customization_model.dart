import 'package:flutter/material.dart';

/// Representation of a wallpaper / app theme
class ProfileThemeItem {
  final String id;
  final String title;
  final String assetPath;
  final Color accentColor;
  final String description;
  final bool isRoyal;

  const ProfileThemeItem({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.accentColor,
    this.description = '',
    this.isRoyal = false,
  });

  static const List<ProfileThemeItem> allThemes = [
    ProfileThemeItem(
      id: 'theme_classic_main',
      title: 'Classic Vibe',
      assetPath: 'assets/graphics/bg_main.png',
      accentColor: Color(0xFF7C4DFF),
      description: 'The standard timeless dark royal table background.',
    ),
    ProfileThemeItem(
      id: 'theme_golden_mountain',
      title: 'Golden Mountain',
      assetPath: 'assets/graphics/themes/basic themes/Golden Mountain.png',
      accentColor: Color(0xFFFFB300),
      description: 'Lustrous golden peaks glowing under majestic sunlight.',
    ),
    ProfileThemeItem(
      id: 'theme_starry_night',
      title: 'Starry Night',
      assetPath: 'assets/graphics/themes/basic themes/Starry night.png',
      accentColor: Color(0xFF651FFF),
      description: 'Deep cosmic night sky filled with radiant twinkling stars.',
    ),
    ProfileThemeItem(
      id: 'theme_bonfire',
      title: 'Bonfire Night',
      assetPath: 'assets/graphics/themes/basic themes/bonfir.png',
      accentColor: Color(0xFFFF5722),
      description: 'Warm crackling hearth and cozy twilight sparks.',
    ),
    ProfileThemeItem(
      id: 'theme_fantastic_lion',
      title: 'Fantastic Lion',
      assetPath: 'assets/graphics/themes/basic themes/Fantastic lion.png',
      accentColor: Color(0xFFFFC107),
      description: 'Grand celestial lion guardian overlooking your matches.',
    ),
    ProfileThemeItem(
      id: 'theme_jellyfish',
      title: 'Neon Jellyfish',
      assetPath: 'assets/graphics/themes/basic themes/jellyfish.png',
      accentColor: Color(0xFF00E5FF),
      description: 'Luminescent underwater creatures drifting in deep blue.',
    ),
    ProfileThemeItem(
      id: 'theme_sky_scrapper',
      title: 'Urban Twilight',
      assetPath: 'assets/graphics/themes/basic themes/Urban twilight.png',
      accentColor: Color(0xFF29B6F6),
      description: 'Modern metropolis skyline lit by glowing neon skyscrapers.',
    ),
    ProfileThemeItem(
      id: 'theme_sky_wheel',
      title: 'Sky Wheel',
      assetPath: 'assets/graphics/themes/basic themes/Sky wheel.png',
      accentColor: Color(0xFFE040FB),
      description: 'Glowing carnival ferris wheel under a vibrant purple dusk.',
    ),
    ProfileThemeItem(
      id: 'theme_waterfall',
      title: 'Waterfall Valley',
      assetPath: 'assets/graphics/themes/basic themes/waterfall.png',
      accentColor: Color(0xFF00BFA5),
      description: 'Cascading turquoise alpine falls surrounded by lush trees.',
    ),
    // Royal Themes (High Resolution)
    ProfileThemeItem(
      id: 'theme_castle_royal',
      title: 'Royal Castle',
      assetPath: 'assets/graphics/themes/Royal theme/castle.png',
      accentColor: Color(0xFFFF4081),
      description: 'Majestic fantasy fortress glowing under pink twilight.',
      isRoyal: true,
    ),
    ProfileThemeItem(
      id: 'theme_dream_garden',
      title: 'Dream Garden',
      assetPath: 'assets/graphics/themes/Royal theme/Dream Garden.png',
      accentColor: Color(0xFF69F0AE),
      description: 'Enchanted blooming paradise garden with ethereal fairy glow.',
      isRoyal: true,
    ),
    ProfileThemeItem(
      id: 'theme_twilight_knight',
      title: 'Twilight Knight',
      assetPath: 'assets/graphics/themes/Royal theme/Twilight knight.png',
      accentColor: Color(0xFFB388FF),
      description: 'Honorable warrior sword standing tall against purple clouds.',
      isRoyal: true,
    ),
    ProfileThemeItem(
      id: 'theme_bonfire_royal',
      title: 'Royal Bonfire',
      assetPath: 'assets/graphics/themes/Royal theme/Bonfire night.png',
      accentColor: Color(0xFFFF6D00),
      description: 'Grand royal bonfire night in high resolution.',
      isRoyal: true,
    ),
    ProfileThemeItem(
      id: 'theme_mountain_royal',
      title: 'Mountain Summit',
      assetPath: 'assets/graphics/themes/Royal theme/Mountain.png',
      accentColor: Color(0xFF00B0FF),
      description: 'High altitude mountain summit with crystal vistas.',
      isRoyal: true,
    ),
    ProfileThemeItem(
      id: 'theme_supreme_car',
      title: 'Supreme Car',
      assetPath: 'assets/graphics/themes/Royal theme/Supreme car.png',
      accentColor: Color(0xFFFFD700),
      description: 'Luxury supercar under starry dusk horizon.',
      isRoyal: true,
    ),
    ProfileThemeItem(
      id: 'theme_couple_at_dusk',
      title: 'Couple at Dusk',
      assetPath: 'assets/graphics/themes/Royal theme/couple at dusk.png',
      accentColor: Color(0xFFFF4081),
      description: 'Serene sunset glow over peaceful silhouettes.',
      isRoyal: true,
    ),
    ProfileThemeItem(
      id: 'theme_knight_sword',
      title: 'Knight Sword',
      assetPath: 'assets/graphics/themes/Royal theme/knight sword.png',
      accentColor: Color(0xFF7C4DFF),
      description: 'Legendary sword of honor embedded in imperial shrine.',
      isRoyal: true,
    ),
    ProfileThemeItem(
      id: 'theme_snow_car',
      title: 'Red Car in Snow',
      assetPath: 'assets/graphics/themes/Royal theme/red caar beneath snow.png',
      accentColor: Color(0xFFFF1744),
      description: 'Bold red grand tourer cruising frozen winter trails.',
      isRoyal: true,
    ),
  ];
}

/// Representation of a decorative Profile Frame
class ProfileFrameItem {
  final String id;
  final String title;
  final List<Color> gradientColors;
  final Color glowColor;
  final Color jewelColor;
  final IconData badgeIcon;
  final String description;

  const ProfileFrameItem({
    required this.id,
    required this.title,
    required this.gradientColors,
    required this.glowColor,
    required this.jewelColor,
    required this.badgeIcon,
    this.description = '',
  });

  static const List<ProfileFrameItem> allFrames = [
    ProfileFrameItem(
      id: 'frame_classic',
      title: 'Classic Gold',
      gradientColors: [
        Color(0xFFFFF176),
        Color(0xFFFFD54F),
        Color(0xFFFFB300),
        Color(0xFFFF8F00),
        Color(0xFFFFF59D),
      ],
      glowColor: Color(0xFFFFB300),
      jewelColor: Color(0xFFFFD54F),
      badgeIcon: Icons.star_rounded,
      description: 'The standard timeless polished golden rim.',
    ),
    ProfileFrameItem(
      id: 'frame_royal_crown',
      title: 'Royal King Crown',
      gradientColors: [
        Color(0xFFFFD700),
        Color(0xFFFFA000),
        Color(0xFFFF3D00),
        Color(0xFFFFD700),
      ],
      glowColor: Color(0xFFFFD700),
      jewelColor: Color(0xFFE91E63),
      badgeIcon: Icons.military_tech_rounded,
      description: 'Ornate Imperial crown frame encrusted with royal rubies.',
    ),
    ProfileFrameItem(
      id: 'frame_cyber_neon',
      title: 'Cyber Neon Pulse',
      gradientColors: [
        Color(0xFF00E5FF),
        Color(0xFF7C4DFF),
        Color(0xFFFF4081),
        Color(0xFF00E5FF),
      ],
      glowColor: Color(0xFF00E5FF),
      jewelColor: Color(0xFF7C4DFF),
      badgeIcon: Icons.bolt_rounded,
      description: 'Electrifying neon aura with hyper-tech circuit pulse.',
    ),
    ProfileFrameItem(
      id: 'frame_diamond_frost',
      title: 'Diamond Glacier',
      gradientColors: [
        Color(0xFFE0F7FA),
        Color(0xFF80DEEA),
        Color(0xFF00B0FF),
        Color(0xFFE1F5FE),
      ],
      glowColor: Color(0xFF00E5FF),
      jewelColor: Color(0xFF40C4FF),
      badgeIcon: Icons.diamond_rounded,
      description: 'Glacial crystalline diamonds with shimmering frost particles.',
    ),
    ProfileFrameItem(
      id: 'frame_flame_dragon',
      title: 'Blazing Dragon',
      gradientColors: [
        Color(0xFFFFD600),
        Color(0xFFFF6D00),
        Color(0xFFDD2C00),
        Color(0xFFFF9100),
      ],
      glowColor: Color(0xFFFF3D00),
      jewelColor: Color(0xFFFF6D00),
      badgeIcon: Icons.local_fire_department_rounded,
      description: 'Molten dragon embers that blaze with unyielding power.',
    ),
    ProfileFrameItem(
      id: 'frame_emerald_laurel',
      title: 'Emerald Laurel',
      gradientColors: [
        Color(0xFFB9F6CA),
        Color(0xFF00E676),
        Color(0xFF00BFA5),
        Color(0xFFFFD700),
      ],
      glowColor: Color(0xFF00E676),
      jewelColor: Color(0xFF00E676),
      badgeIcon: Icons.eco_rounded,
      description: 'Champion laurel wreath with radiant green gemstones.',
    ),
    ProfileFrameItem(
      id: 'frame_rose_gold',
      title: 'Rose Gold Petal',
      gradientColors: [
        Color(0xFFFFE082),
        Color(0xFFFF80AB),
        Color(0xFFFF4081),
        Color(0xFFFF80AB),
      ],
      glowColor: Color(0xFFFF4081),
      jewelColor: Color(0xFFFF80AB),
      badgeIcon: Icons.auto_awesome_rounded,
      description: 'Luxe metallic rose gold finish with blooming floral accents.',
    ),
  ];
}

/// Representation of an equipped Ornament
class ProfileOrnamentItem {
  final String id;
  final String title;
  final String? assetPath;
  final Color glowColor;
  final String description;

  const ProfileOrnamentItem({
    required this.id,
    required this.title,
    this.assetPath,
    required this.glowColor,
    this.description = '',
  });

  bool get isNone => assetPath == null || assetPath!.isEmpty;

  static const List<ProfileOrnamentItem> allOrnaments = [
    ProfileOrnamentItem(
      id: 'ornament_none',
      title: 'None',
      assetPath: null,
      glowColor: Colors.transparent,
      description: 'Default clean avatar look without additional ornaments.',
    ),
    ProfileOrnamentItem(
      id: 'ornament_phoenix_wings',
      title: 'Celestial Phoenix Wings',
      assetPath: 'assets/graphics/shop/08_ornaments/image 317.png',
      glowColor: Color(0xFFFFD700),
      description: 'Grand golden angel & phoenix wings floating behind avatar.',
    ),
    ProfileOrnamentItem(
      id: 'ornament_royal_scepter',
      title: 'Royal Sun Scepter',
      assetPath: 'assets/graphics/shop/08_ornaments/image 319.png',
      glowColor: Color(0xFFFF9100),
      description: 'Emblematic solar scepter blessed with prosperity.',
    ),
    ProfileOrnamentItem(
      id: 'ornament_magic_halo',
      title: 'Astral Magic Halo',
      assetPath: 'assets/graphics/shop/08_ornaments/image 320.png',
      glowColor: Color(0xFF7C4DFF),
      description: 'Luminous magical rune ring pulsating around the crown.',
    ),
    ProfileOrnamentItem(
      id: 'ornament_dragon_shield',
      title: 'Dragon Crest Shield',
      assetPath: 'assets/graphics/shop/08_ornaments/image 322.png',
      glowColor: Color(0xFF00E5FF),
      description: 'Armored dragon emblem of valor and defense.',
    ),
    ProfileOrnamentItem(
      id: 'ornament_starry_lantern',
      title: 'Starry Lantern',
      assetPath: 'assets/graphics/shop/08_ornaments/image 324.png',
      glowColor: Color(0xFFFFD54F),
      description: 'Enchanted floating lantern casting warm lucky sparkles.',
    ),
    ProfileOrnamentItem(
      id: 'ornament_festive_blossom',
      title: 'Festive Blossom',
      assetPath: 'assets/graphics/shop/08_ornaments/image 325.png',
      glowColor: Color(0xFFFF4081),
      description: 'Spring blossom petals radiating peaceful fortune.',
    ),
    ProfileOrnamentItem(
      id: 'ornament_crown_crest',
      title: 'Imperial Crown Seal',
      assetPath: 'assets/graphics/shop/08_ornaments/image 326.png',
      glowColor: Color(0xFFFFAB00),
      description: 'High monarch crest of royal supreme authority.',
    ),
    ProfileOrnamentItem(
      id: 'ornament_crystal_orb',
      title: 'Mystic Crystal Orb',
      assetPath: 'assets/graphics/shop/08_ornaments/image 330.png',
      glowColor: Color(0xFF00E676),
      description: 'Swirling emerald fortune orb containing secret energies.',
    ),
    ProfileOrnamentItem(
      id: 'ornament_phoenix_aura',
      title: 'Eternal Flame Aura',
      assetPath: 'assets/graphics/shop/08_ornaments/image 332.png',
      glowColor: Color(0xFFFF3D00),
      description: 'Flaring crimson aura igniting every game victory.',
    ),
  ];
}

/// Representation of a cartoon avatar preset
class ProfileAvatarPreset {
  final String id;
  final String title;
  final String assetPath;

  const ProfileAvatarPreset({
    required this.id,
    required this.title,
    required this.assetPath,
  });

  static const List<ProfileAvatarPreset> allPresets = [
    ProfileAvatarPreset(
      id: 'avatar_lion_king',
      title: 'King Simba',
      assetPath: 'assets/graphics/profile/avatars/avatar_lion_king.png',
    ),
    ProfileAvatarPreset(
      id: 'avatar_cyber_tiger',
      title: 'Cyber Tiger',
      assetPath: 'assets/graphics/profile/avatars/avatar_cyber_tiger.png',
    ),
    ProfileAvatarPreset(
      id: 'avatar_fox_magician',
      title: 'Fox Mage',
      assetPath: 'assets/graphics/profile/avatars/avatar_fox_magician.png',
    ),
    ProfileAvatarPreset(
      id: 'avatar_panda_warrior',
      title: 'Kung Fu Panda',
      assetPath: 'assets/graphics/profile/avatars/avatar_panda_warrior.png',
    ),
    ProfileAvatarPreset(
      id: 'avatar_royal_queen',
      title: 'Royal Queen',
      assetPath: 'assets/graphics/profile/avatars/avatar_royal_queen.png',
    ),
    ProfileAvatarPreset(
      id: 'avatar_golden_sheikh',
      title: 'Golden Sheikh',
      assetPath: 'assets/graphics/profile/avatars/avatar_golden_sheikh.png',
    ),
    ProfileAvatarPreset(
      id: 'avatar_wealthy',
      title: 'Wealthy Tycoon',
      assetPath: 'assets/graphics/wealthy_avatar.png',
    ),
    ProfileAvatarPreset(
      id: 'avatar_musician',
      title: 'Rock Musician',
      assetPath: 'assets/graphics/musician_avatar.png',
    ),
  ];
}
