import 'package:flutter/material.dart';

import 'cart_page.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF8F5A00);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _surfaceColor = Colors.white;
const Color _mutedText = Color(0xFF6E6554);

class ProductDetailsPage extends StatefulWidget {
  final Map product;
  final List cart;
  final List wishlist;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.cart,
    required this.wishlist,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool addedToCart = false;
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    addedToCart =
        widget.cart.any((item) => item["name"] == widget.product["name"]);
    isWishlisted =
        widget.wishlist.any((item) => item["name"] == widget.product["name"]);
  }

  Widget _buildProductImage() {
    final image = (widget.product["image"] ?? "").toString();
    if (image.isEmpty) {
      return const Center(
        child: Icon(Icons.phone_android_rounded, size: 80, color: _accentDark),
      );
    }

    if (image.startsWith("http")) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.phone_android_rounded,
          size: 80,
          color: _accentDark,
        ),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.phone_android_rounded,
        size: 80,
        color: _accentDark,
      ),
    );
  }

  String _priceText() {
    final price = (widget.product["price"] ?? "0").toString();
    if (price.contains("₹")) return price;
    return "${String.fromCharCode(0x20B9)}$price";
  }

  @override
  Widget build(BuildContext context) {
    final productName = (widget.product["name"] ?? "Product").toString();
    final description = (widget.product["description"] ?? "").toString();
    final rating = (widget.product["rating"] ?? "4.5").toString();
    final reviews = (widget.product["reviews"] ?? "100").toString();
    final bool isOutOfStock = _isOutOfStock(widget.product["stock"]);

    return Scaffold(
      backgroundColor: _pageTint,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _pageTint,
        foregroundColor: Colors.black87,
        title: Text(
          productName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE7B3), Color(0xFFFFF6E1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.86),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Text(
                              "Featured device",
                              style: TextStyle(
                                color: _accentDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _priceText(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: _accentDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isOutOfStock ? "Out of Stock" : "In Stock",
                            style: TextStyle(
                              color: isOutOfStock
                                  ? Colors.redAccent
                                  : Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isWishlisted = !isWishlisted;
                            if (isWishlisted) {
                              if (!widget.wishlist.any((item) =>
                                  item["name"] == widget.product["name"])) {
                                widget.wishlist.add(widget.product);
                              }
                            } else {
                              widget.wishlist.removeWhere((item) =>
                                  item["name"] == widget.product["name"]);
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isWishlisted
                                    ? "Added to wishlist"
                                    : "Removed from wishlist",
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 280,
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: _buildProductImage(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3D5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 18, color: Colors.orange),
                          const SizedBox(width: 6),
                          Text(
                            "$rating rating",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "$reviews reviews",
                      style: const TextStyle(color: _mutedText),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  "About this product",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  description.isEmpty
                      ? "Powerful hardware, premium finish and a smooth everyday mobile experience."
                      : description,
                  style: const TextStyle(color: _mutedText, height: 1.5),
                ),
                const SizedBox(height: 18),
                _featureRow(Icons.flash_on_rounded,
                    "High performance for daily multitasking"),
                _featureRow(Icons.verified_rounded,
                    "Curated product quality and trusted look"),
                _featureRow(Icons.local_shipping_outlined,
                    "Fast delivery and quick checkout flow"),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: BoxDecoration(
          color: _surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Price", style: TextStyle(color: _mutedText)),
                    const SizedBox(height: 4),
                    Text(
                      _priceText(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (addedToCart || isOutOfStock)
                        ? Colors.grey
                        : _accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: (addedToCart || isOutOfStock)
                      ? null
                      : () {
                          setState(() {
                            addedToCart = true;
                          });

                          if (!widget.cart.any((item) =>
                              item["name"] == widget.product["name"])) {
                            widget.cart.add(widget.product);
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartPage(cart: widget.cart),
                            ),
                          );
                        },
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: Text(
                    isOutOfStock
                        ? "Out of Stock"
                        : (addedToCart ? "Added" : "Add to Cart"),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _accentDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  bool _isOutOfStock(dynamic rawStock) {
    final stockText = (rawStock ?? "").toString().trim().toLowerCase();
    if (stockText == "out stock" || stockText == "out of stock") return true;
    if (stockText == "in stock") return false;

    final stock = int.tryParse(stockText) ?? 0;
    return stock <= 0;
  }
}
