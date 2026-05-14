import 'package:flutter/material.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF8F5A00);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _surfaceColor = Colors.white;
const Color _mutedText = Color(0xFF6E6554);

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
          "Help Center",
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Need help with your shopping experience?",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Quick answers, support contacts and order guidance all in one place.",
                  style: TextStyle(color: _mutedText, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "FAQs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _helpItem("How to place an order?", Icons.shopping_bag_outlined),
          _helpItem("How to cancel order?", Icons.cancel_outlined),
          _helpItem("How to track order?", Icons.local_shipping_outlined),
          _helpItem("Return & refund policy", Icons.assignment_return_outlined),
          const SizedBox(height: 18),
          const Text(
            "Contact Support",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _contactCard(
            icon: Icons.phone_outlined,
            title: "Call Us",
            subtitle: "+91 9876543210",
          ),
          const SizedBox(height: 12),
          _contactCard(
            icon: Icons.email_outlined,
            title: "Email Support",
            subtitle: "support@phonemart.com",
          ),
        ],
      ),
    );
  }

  Widget _helpItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _accentDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _mutedText),
        ],
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _accentDark),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: _mutedText)),
            ],
          ),
        ],
      ),
    );
  }
}
