import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class NamePlatesScreen extends StatelessWidget {
  const NamePlatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header Bar with Back Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22 * scale),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'NAME PLATES',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 18 * scale,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 48 * scale),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Column(
                    children: [
                      SizedBox(height: 12 * scale),

                      // Name Plates Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12 * scale,
                          mainAxisSpacing: 12 * scale,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return _buildNamePlateItem(index, scale);
                        },
                      ),
                      SizedBox(height: 24 * scale),

                      // Add New Name Plate Button
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16 * scale),
                        decoration: BoxDecoration(
                          gradient: AppColors.modalGradient,
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(
                            color: AppColors.primaryBorder,
                            width: 1.5 * scale,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: const Color(0xFFFFD369),
                              size: 24 * scale,
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              'Unlock More Name Plates',
                              style: AppTextStyles.bodyMediumBold.copyWith(
                                fontSize: 14 * scale,
                                color: const Color(0xFFFFD369),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNamePlateItem(int index, double scale) {
    final plateColors = [
      const Color(0xFFFFD369), // Gold
      const Color(0xFFB173FF), // Purple
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4CAF50), // Green
      const Color(0xFFF97023), // Orange
    ];

    final plateNames = [
      'Golden Frame',
      'Royal Purple',
      'Ocean Blue',
      'Fire Red',
      'Lucky Green',
      'Sunset Orange',
    ];

    final isSelected = index == 0; // First plate is selected

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            plateColors[index].withOpacity(0.3),
            plateColors[index].withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFD369) : plateColors[index],
          width: isSelected ? 2.5 * scale : 1.5 * scale,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              plateNames[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12 * scale,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              top: 6 * scale,
              right: 6 * scale,
              child: Icon(
                Icons.check_circle,
                color: const Color(0xFFFFD369),
                size: 16 * scale,
              ),
            ),
        ],
      ),
    );
  }
}
