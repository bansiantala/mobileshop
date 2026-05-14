import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'ProductDetailsPage.dart';
import 'cart_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'wishlist_page.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF8F5A00);
const Color _lightBackground = Color(0xFFF7F4ED);
const Color _darkBackground = Color(0xFF171512);
const Color _lightSurface = Colors.white;
const Color _darkSurface = Color(0xFF22201D);
const Color _lightTextMuted = Color(0xFF71695A);
const Color _darkTextMuted = Color(0xFFD0C7B6);

class HomePage extends StatefulWidget {
  final User currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map> favorites = [];
  final List<Map> cart = [];
  final TextEditingController searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.92);

  bool isDarkMode = false;
  int selectedIndex = 0;
  String selectedCategory = "all";
  String searchText = "";
  String sortBy = "none";
  int _currentPage = 0;
  Timer? _timer;

  final List<String> sliderImages = [
    "assets/welcome.jpg",
    "assets/all2.jpg",
    "assets/b2.jpg",
    "assets/b3.jpg",
    "assets/b.jpg",
    "assets/b5.jpg",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSlider();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _startSlider() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_pageController.hasClients || sliderImages.isEmpty) return;

      _currentPage = (_currentPage + 1) % sliderImages.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Sort by price"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sortTile("Highest Price", "highest"),
              _sortTile("Lowest Price", "lowest"),
              _sortTile("None", "none"),
            ],
          ),
        );
      },
    );
  }

  Widget _sortTile(String label, String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: sortBy,
      activeColor: _accentColor,
      title: Text(label),
      onChanged: (selected) {
        setState(() {
          sortBy = selected!;
        });
        Navigator.of(context).pop();
      },
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  Color get _background => isDarkMode ? _darkBackground : _lightBackground;
  Color get _surface => isDarkMode ? _darkSurface : _lightSurface;
  Color get _primaryText => isDarkMode ? Colors.white : Colors.black87;
  Color get _secondaryText => isDarkMode ? _darkTextMuted : _lightTextMuted;

  List<Widget> pages() {
    return [
      buildHomeContent(),
      WishlistPage(wishlist: favorites, cart: cart),
      CartPage(
          cart: cart.cast<Map<String, dynamic>>(),
          currentUser: widget.currentUser),
      ProfilePage(currentUser: widget.currentUser, orders: cart),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: pages()[selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = const [
      (Icons.home_rounded, "Home"),
      (Icons.favorite_rounded, "Wishlist"),
      (Icons.shopping_bag_rounded, "Cart"),
      (Icons.person_rounded, "You"),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.24 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final selected = selectedIndex == index;
            final item = items[index];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? _accentColor.withOpacity(isDarkMode ? 0.22 : 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.$1,
                        color: selected ? _accentDark : _secondaryText,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: TextStyle(
                          color: selected ? _accentDark : _secondaryText,
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
              children: [
                _buildHeroHeader(),
                const SizedBox(height: 14),
                _buildSearchRow(),
                const SizedBox(height: 14),
                buildSlider(),
                const SizedBox(height: 14),
                _buildCategorySection(),
                const SizedBox(height: 14),
                _buildProductsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD98B), Color(0xFFF4B45B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(widget.currentUser.image),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getGreeting(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.currentUser.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Discover premium phones, flash offers and smooth checkout in one place.",
                      style: TextStyle(
                          color: Colors.white70, height: 1.3, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _headerIconButton(
                icon: isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: toggleTheme,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _heroStat(
                  title: "Cart",
                  value: "${cart.length}",
                  subtitle: "items selected",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _heroStat(
                  title: "Wishlist",
                  value: "${favorites.length}",
                  subtitle: "saved products",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              setState(() {
                selectedIndex = 2;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart_checkout_rounded,
                      color: Colors.white),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Jump back into your cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (cart.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "${cart.length}",
                        style: const TextStyle(
                          color: _accentDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchText = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "Search phones, brands, offers",
              hintStyle: TextStyle(color: _secondaryText),
              prefixIcon: Icon(Icons.search_rounded, color: _secondaryText),
              filled: true,
              fillColor: _surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: showFilterDialog,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildSlider() {
    return Column(
      children: [
        SizedBox(
          height: 154,
          child: PageView.builder(
            controller: _pageController,
            itemCount: sliderImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(
                    image: AssetImage(sliderImages[index]),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.18),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Fresh arrivals",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Upgrade your everyday setup",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sliderImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? _accentColor
                    : _secondaryText.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Browse categories", "Filter your next device fast"),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("categories").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No categories",
                    style: TextStyle(color: _secondaryText),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = "all";
                      });
                    },
                    child: categoryItem(
                        "All", "assets/all3.jpg", selectedCategory == "all"),
                  ),
                  ...docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data["name"] ?? "").toString();
                    final image = (data["image"] ?? "").toString();
                    final key = name.toLowerCase().trim();

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = key;
                        });
                      },
                      child: categoryItem(name, image, selectedCategory == key),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
            "Trending products", "Curated picks with fast add-to-cart"),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("products").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final filtered = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final matchCategory = selectedCategory == "all" ||
                  data["category"].toString().toLowerCase().trim() ==
                      selectedCategory;
              final matchSearch =
                  data["name"].toString().toLowerCase().contains(searchText);
              return matchCategory && matchSearch;
            }).toList();

            if (sortBy == "highest") {
              filtered.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                return _priceValue(bData["price"])
                    .compareTo(_priceValue(aData["price"]));
              });
            } else if (sortBy == "lowest") {
              filtered.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                return _priceValue(aData["price"])
                    .compareTo(_priceValue(bData["price"]));
              });
            }

            if (filtered.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 34, color: _accentDark),
                    const SizedBox(height: 10),
                    Text(
                      "No products found",
                      style: TextStyle(
                        color: _primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              itemCount: filtered.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final data = filtered[index].data() as Map<String, dynamic>;
                return productCard(data);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: _secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget categoryItem(String name, String? image, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? _accentColor.withOpacity(0.18) : _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? _accentColor : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                isDarkMode ? const Color(0xFF2E2A25) : const Color(0xFFFFF3D8),
            backgroundImage: image != null && image.isNotEmpty
                ? (image.startsWith("http")
                    ? NetworkImage(image)
                    : AssetImage(image) as ImageProvider)
                : null,
            child: image == null || image.isEmpty
                ? const Icon(Icons.category_rounded, color: _accentDark)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? _accentDark : _primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget productCard(Map phone) {
    final String name = phone["name"]?.toString() ?? "Phone";
    final String price = phone["price"]?.toString() ?? "0";
    final String image = phone["image"]?.toString() ?? "";
    final bool isFav = favorites.any((e) => e["name"] == phone["name"]);
    final bool isOutOfStock = _isOutOfStock(phone["stock"]);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(
              product: phone,
              cart: cart,
              wishlist: favorites,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.20 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 132,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF2C2824)
                          : const Color(0xFFFFF7E8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: image.startsWith("http")
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.phone_android_rounded),
                            )
                          : Image.asset(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.phone_android_rounded),
                            ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isFav) {
                            favorites
                                .removeWhere((e) => e["name"] == phone["name"]);
                          } else {
                            favorites.add(phone);
                          }
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tap to view product details",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(color: _secondaryText, height: 1.25, fontSize: 11),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${String.fromCharCode(0x20B9)} $price",
                          style: const TextStyle(
                            color: _accentDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isOutOfStock ? "Out of Stock" : "In Stock",
                        style: TextStyle(
                          color: isOutOfStock ? Colors.redAccent : Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: isOutOfStock
                      ? null
                      : () {
                          setState(() {
                            cart.add(phone);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF2F2A22),
                              elevation: 8,
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              content: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: _accentColor.withOpacity(0.24),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: _accentColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "$name added to cart",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isOutOfStock ? Colors.grey : _accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }

  double _priceValue(dynamic rawPrice) {
    return double.tryParse(
          rawPrice.toString().replaceAll(RegExp(r"[^\d.]"), ""),
        ) ??
        0;
  }

  bool _isOutOfStock(dynamic rawStock) {
    final stockText = (rawStock ?? "").toString().trim().toLowerCase();
    if (stockText == "out stock" || stockText == "out of stock") return true;
    if (stockText == "in stock") return false;

    final stock = int.tryParse(stockText) ?? 0;
    return stock <= 0;
  }
}
