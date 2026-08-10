import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _hotQuestions = [
    'Reminder About Payment Failures/Item Issuance Failures on Huawei AppGallery',
    'I lost my old account! How to get it back?',
    "Why can't I use my mobile phone credit to recharge?",
    'How to prevent account loss?',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Light purple background
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Blue/Purple Top Header Bar with Back Button
            Container(
              height: 70 * scale + MediaQuery.paddingOf(context).top,
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 10 * scale,
                left: 16 * scale,
                right: 16 * scale,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24 * scale,
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Self Service Header
                    Text(
                      'Self Service',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4A148C),
                      ),
                    ),
                    SizedBox(height: 12 * scale),

                    // 4 Action Buttons Grid Row
                    Row(
                      children: [
                        Expanded(child: _buildServiceCard('Retrieve Account', Icons.replay, scale)),
                        SizedBox(width: 8 * scale),
                        Expanded(child: _buildServiceCard('Payment Issue', Icons.payment, scale)),
                        SizedBox(width: 8 * scale),
                        Expanded(child: _buildServiceCard('Violation Appeal', Icons.assignment, scale)),
                        SizedBox(width: 8 * scale),
                        Expanded(child: _buildServiceCard('App Suggestion', Icons.edit_note, scale)),
                      ],
                    ),
                    SizedBox(height: 16 * scale),

                    // Yellow Warning Alert Banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(color: const Color(0xFFFFB300), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, color: const Color(0xFFFFB300), size: 20 * scale),
                          SizedBox(width: 8 * scale),
                          Expanded(
                            child: Text(
                              'Reminder About Payment Failures/Item Issuance Failures on Huawei AppGallery',
                              style: TextStyle(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20 * scale),

                    // Hot Questions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hot Questions',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF4A148C),
                          ),
                        ),
                        Icon(Icons.search, color: const Color(0xFF7E57C2), size: 20 * scale),
                      ],
                    ),
                    SizedBox(height: 10 * scale),

                    // Hot Questions List
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                      child: Column(
                        children: _hotQuestions.map((q) => Column(
                          children: [
                            ListTile(
                              dense: true,
                              title: Text(
                                q,
                                style: TextStyle(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF5E35B1),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_fire_department, color: Colors.orange, size: 16 * scale),
                                  SizedBox(width: 4 * scale),
                                  Icon(Icons.chevron_right, color: Colors.purple.shade200, size: 18 * scale),
                                ],
                              ),
                              onTap: () {},
                            ),
                            const Divider(height: 1, color: Color(0xFFF3E5F5)),
                          ],
                        )).toList(),
                      ),
                    ),

                    SizedBox(height: 24 * scale),

                    // Account Registration Date Footer
                    Center(
                      child: Text(
                        'Account Registration Date: 12-08-2026',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7E57C2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * scale),

                    // Customer Service Pill Button
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40 * scale, vertical: 10 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E35B1),
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        child: Text(
                          'Customer Service',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String label, IconData icon, double scale) {
    return Container(
      height: 72 * scale,
      padding: EdgeInsets.all(6 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF5E35B1),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22 * scale),
          SizedBox(height: 4 * scale),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
