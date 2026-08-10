import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

class AccountCentreScreen extends StatefulWidget {
  const AccountCentreScreen({super.key});

  @override
  State<AccountCentreScreen> createState() => _AccountCentreScreenState();
}

class _AccountCentreScreenState extends State<AccountCentreScreen> {
  int _selectedTab = 0; // 0: Binding Methods, 1: Login Devices

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFDCD2FD),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Dark Purple Top Banner Header
            Container(
              height: 70 * scale + MediaQuery.paddingOf(context).top,
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 10 * scale,
                left: 16 * scale,
                right: 16 * scale,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D0F64), Color(0xFF4C1895), Color(0xFF5D1CA8)],
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    'Account Centre',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24 * scale,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(18 * scale),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DEFF),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: const Color(0xFFC7B3FF), width: 1),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 16 * scale),

                      // Tabs: Binding Methods | Login Devices
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTabItem('Binding Methods', 0, scale),
                            ),
                            SizedBox(width: 8 * scale),
                            Expanded(
                              child: _buildTabItem('Login Devices', 1, scale),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20 * scale),

                      // User ID Text
                      Text(
                        'ID:515693332660',
                        style: TextStyle(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF260D5C),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 20 * scale),

                      // 3 Bind Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                        child: Column(
                          children: [
                            // Bind ludo chat
                            _buildBindButton(
                              label: 'Bind ludo chat',
                              icon: Icons.chat_bubble,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                              ),
                              scale: scale,
                            ),
                            SizedBox(height: 12 * scale),

                            // Bind Email
                            _buildBindButton(
                              label: 'Bind Email',
                              icon: Icons.email,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                              ),
                              scale: scale,
                            ),
                            SizedBox(height: 12 * scale),

                            // Bind Facebook
                            _buildBindButton(
                              label: 'Bind Facebook',
                              icon: Icons.facebook,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                              ),
                              scale: scale,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24 * scale),

                      // Header Row: Methods | Details | Operations
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Methods', style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: const Color(0xFF7565A4))),
                            Text('Details', style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: const Color(0xFF7565A4))),
                            Text('Operations', style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: const Color(0xFF7565A4))),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Warning Banner at Bottom
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10 * scale, horizontal: 12 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D1CA8),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15 * scale)),
                        ),
                        child: Text(
                          "Please don't provide your account or password to others",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int index, double scale) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8 * scale),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : const Color(0xFFB388FF),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13 * scale,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF7565A4),
          ),
        ),
      ),
    );
  }

  Widget _buildBindButton({
    required String label,
    required IconData icon,
    required LinearGradient gradient,
    required double scale,
  }) {
    return Container(
      height: 44 * scale,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(22 * scale),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20 * scale),
                SizedBox(width: 12 * scale),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
