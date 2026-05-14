import 'package:flutter/material.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF8F5A00);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _surfaceColor = Colors.white;
const Color _mutedText = Color(0xFF6E6554);

class WishlistPage extends StatefulWidget {
  final List wishlist;
  final List cart;

  const WishlistPage({
    super.key,
    required this.wishlist,
    required this.cart,
  });

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String _filterBy = "all";

  String _itemName(dynamic item) => (item["name"] ?? "No name").toString();
  String _itemPrice(dynamic item) => (item["price"] ?? "0").toString();
  String _itemDescription(dynamic item) =>
      (item["description"] ?? "Saved for your next purchase").toString();
  String _itemImage(dynamic item) => (item["image"] ?? "").toString();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildItemImage(dynamic item) {
    final image = _itemImage(item);
    if (image.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFFFF6E5),
        child: Icon(Icons.favorite_border_rounded, color: _accentDark),
      );
    }

    if (image.startsWith("http")) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Color(0xFFFFF6E5),
          child: Icon(Icons.broken_image_outlined, color: _accentDark),
        ),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: Color(0xFFFFF6E5),
        child: Icon(Icons.broken_image_outlined, color: _accentDark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleIndexes = _filteredWishlistIndexes();

    return Scaffold(
      backgroundColor: _pageTint,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _pageTint,
        foregroundColor: Colors.black87,
        title: const Text(
          "Wishlist",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          _buildHero(),
          const SizedBox(height: 14),
          _buildSearchFilterRow(),
          const SizedBox(height: 16),
          if (widget.wishlist.isEmpty)
            _buildEmptyState()
          else if (visibleIndexes.isEmpty)
            _buildNoResultsState()
          else
            ...visibleIndexes.map(
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildWishlistCard(index),
              ),
            ),
        ],
      ),
    );
  }

  List<int> _filteredWishlistIndexes() {
    final indexes = List<int>.generate(widget.wishlist.length, (index) => index)
        .where((index) {
      final item = widget.wishlist[index];
      final text = "${_itemName(item)} ${_itemDescription(item)}".toLowerCase();
      return text.contains(_searchText);
    }).toList();

    if (_filterBy == "high") {
      indexes.sort(
        (a, b) => _priceValue(widget.wishlist[b])
            .compareTo(_priceValue(widget.wishlist[a])),
      );
    } else if (_filterBy == "low") {
      indexes.sort(
        (a, b) => _priceValue(widget.wishlist[a])
            .compareTo(_priceValue(widget.wishlist[b])),
      );
    }

    return indexes;
  }

  int _priceValue(dynamic item) {
    return int.tryParse(_itemPrice(item).replaceAll(RegExp(r"[^0-9]"), "")) ??
        0;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        decoration: const BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _filterTile("All items", "all"),
            _filterTile("Highest price", "high"),
            _filterTile("Lowest price", "low"),
          ],
        ),
      ),
    );
  }

  Widget _filterTile(String title, String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: _filterBy,
      activeColor: _accentColor,
      title: Text(title),
      onChanged: (selected) {
        setState(() => _filterBy = selected ?? "all");
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSearchFilterRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                setState(() => _searchText = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Search wishlist",
              prefixIcon: const Icon(Icons.search_rounded, color: _accentDark),
              filled: true,
              fillColor: _surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: _showFilterSheet,
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

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE7B3), Color(0xFFFFF6E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    "Saved collection",
                    style: TextStyle(
                      color: _accentDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "${widget.wishlist.length} items in wishlist",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Save favorites here and move them to cart whenever you're ready.",
                  style: TextStyle(color: _mutedText, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.redAccent,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 42,
                color: _accentDark,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "No items in wishlist",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              "Mark products as favorite and they will appear here in a cleaner saved-items view.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _mutedText, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 36, color: _accentDark),
          SizedBox(height: 10),
          Text(
            "No wishlist items found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(int index) {
    final item = widget.wishlist[index];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 84,
              height: 84,
              child: _buildItemImage(item),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _itemName(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _itemDescription(item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _mutedText, height: 1.35),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4DB),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "${String.fromCharCode(0x20B9)}${_itemPrice(item)}",
                    style: const TextStyle(
                      color: _accentDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            widget.cart.add(item);
                            widget.wishlist.removeAt(index);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to cart")),
                          );
                        },
                        child: const Text(
                          "Move to Cart",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          widget.wishlist.removeAt(index);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Removed from wishlist")),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
