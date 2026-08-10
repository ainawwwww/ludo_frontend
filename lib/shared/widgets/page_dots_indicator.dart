import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

class PageDotsIndicator extends StatelessWidget {
  const PageDotsIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 4 * scale),
          width: (isActive ? 9.0 : 6.0) * scale,
          height: (isActive ? 9.0 : 6.0) * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
          ),
        );
      }),
    );
  }
}
