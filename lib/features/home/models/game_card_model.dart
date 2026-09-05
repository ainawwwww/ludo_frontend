import 'package:flutter/material.dart';

enum CardSize { large, small }

enum CardLayoutType { vertical, horizontalLeftImage, horizontalRightImage }

class PageCardModel {
  const PageCardModel({
    required this.title,
    required this.imagePath,
    this.backgroundImagePath,
    this.gradientColors,
    this.size = CardSize.large,
    this.layoutType = CardLayoutType.vertical,
    this.flex,
    this.onTap,
  });

  final String title;
  final String imagePath;
  final String? backgroundImagePath;
  final List<Color>? gradientColors;
  final CardSize size;
  final CardLayoutType layoutType;
  final int? flex;
  final VoidCallback? onTap;
}

class HomePageData {
  const HomePageData({
    required this.cards,
  });

  final List<PageCardModel> cards;
}
