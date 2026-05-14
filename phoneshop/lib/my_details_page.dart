import 'dart:io';

import 'package:flutter/material.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF8F5A00);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _surfaceColor = Colors.white;
const Color _mutedText = Color(0xFF6E6554);

class MyDetailsPage extends StatelessWidget {
  final String name;
  final String email;
  final String imagePath;

  const MyDetailsPage({
    super.key,
    required this.name,
    required this.email,
    required this.imagePath,
  });

  ImageProvider _profileImage() {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }
    return FileImage(File(imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageTint,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _pageTint,
        foregroundColor: Colors.black87,
        title: const Text(
          "My Details",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE7B3), Color(0xFFFFF5DD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  backgroundImage: _profileImage(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(email, style: const TextStyle(color: _mutedText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _detailCard(
            title: "Full Name",
            value: name,
            icon: Icons.person_outline,
          ),
          _detailCard(
            title: "Email Address",
            value: email,
            icon: Icons.email_outlined,
          ),
          _detailCard(
            title: "Account Type",
            value: "User",
            icon: Icons.verified_user_outlined,
          ),
          _detailCard(
            title: "Member Since",
            value: "2026",
            icon: Icons.calendar_month_outlined,
          ),
        ],
      ),
    );
  }

  Widget _detailCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _accentDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: _mutedText)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
