import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/home/providers/home_provider.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class CountrySelectScreen extends ConsumerStatefulWidget {
  const CountrySelectScreen({super.key});

  @override
  ConsumerState<CountrySelectScreen> createState() =>
      _CountrySelectScreenState();
}

class _CountrySelectScreenState extends ConsumerState<CountrySelectScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;
    final countries = ref.watch(countriesProvider);
    final filtered = countries
        .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(12 * scale),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 22 * scale,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Game\nFriends',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.tabLabel.copyWith(
                          fontSize: 13 * scale,
                          color: AppColors.textSecondary,
                          height: 1.008,
                        ),
                      ),
                    ),
                    SizedBox(width: 48 * scale),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 13 * scale),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppConstants.radius14),
                  border: Border.all(color: AppColors.primaryBorderSoft),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12 * scale),
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search country...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.primaryDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radius8,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          color: AppColors.primaryBorderSoft
                              .withValues(alpha: 0.4),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final country = filtered[index];
                          return ListTile(
                            onTap: () => context.pop(country.name),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4 * scale,
                            ),
                            leading: Text(
                              country.flagEmoji,
                              style: TextStyle(fontSize: 24 * scale),
                            ),
                            title: Text(
                              country.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontSize: 15 * scale,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
          ],
        ),
      ),
    );
  }
}
