import 'package:flutter/material.dart';

import 'manage_category.dart';
import 'manage_order.dart';
import 'manage_product.dart';
import 'manage_user.dart';
import '../login_page.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF5A3A12);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _surfaceColor = Colors.white;
const Color _mutedText = Color(0xFF6E6554);

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageTint,
      drawer: _buildDrawer(context),
      body: Builder(
        builder: (context) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildHero(),
              const SizedBox(height: 16),
              const Text(
                "Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child:
                          _summaryCard("Users", "120", Icons.people_outline)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _summaryCard(
                          "Products", "80", Icons.shopping_bag_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _summaryCard(
                          "Orders", "45", Icons.receipt_long_outlined)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _summaryCard(
                          "Category", "5", Icons.category_outlined)),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _actionTile(context, "Manage Users", "Review customer accounts",
                  Icons.people_outline, const ManageUsersPage()),
              _actionTile(
                  context,
                  "Manage Products",
                  "Create, update and remove products",
                  Icons.shopping_bag_outlined,
                  const ManageProductsPage()),
              _actionTile(
                  context,
                  "Manage Orders",
                  "Track order status and delivery flow",
                  Icons.inventory_2_outlined,
                  const ManageOrdersPage()),
              _actionTile(
                  context,
                  "Manage Category",
                  "Organize browse sections",
                  Icons.category_outlined,
                  const ManageCategoryPage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE3A3), Color(0xFFF3B55D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.admin_panel_settings_rounded,
                    size: 44, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  "Admin Panel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage store activity with one clean dashboard.",
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _drawerItem(context, Icons.dashboard_rounded, "Dashboard",
              "Store overview", null),
          _drawerItem(context, Icons.group_outlined, "Users",
              "Customer accounts", const ManageUsersPage()),
          _drawerItem(context, Icons.inventory_2_outlined, "Products",
              "Stock and catalog", const ManageProductsPage()),
          _drawerItem(context, Icons.receipt_long_outlined, "Orders",
              "Status and delivery", const ManageOrdersPage()),
          _drawerItem(context, Icons.category_outlined, "Categories",
              "Browse sections", const ManageCategoryPage()),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Scaffold.of(context).openDrawer(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.menu_rounded),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Admin Dashboard",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                "Store insights and quick controls",
                style: TextStyle(color: _mutedText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE7B3), Color(0xFFFFF6E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Admin",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Check users, products, orders and categories from a polished admin workspace.",
                  style: TextStyle(color: _mutedText, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.space_dashboard_rounded,
                size: 40, color: _accentDark),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget? page,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.pop(context);
          if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: page == null ? const Color(0xFFFFF3D5) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: page == null ? _accentColor : const Color(0xFFFFF7E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _accentDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _mutedText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _mutedText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: _mutedText)),
          const SizedBox(height: 6),
          Text(
            count,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(BuildContext context, String title, String subtitle,
      IconData icon, Widget page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3D5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: _accentDark),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(color: _mutedText)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
