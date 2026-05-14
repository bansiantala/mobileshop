import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'order_page.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF8F5A00);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _surfaceColor = Colors.white;
const Color _mutedText = Color(0xFF6E6554);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final List products = [
    ["iPhone 14", "Latest iPhone", 70000, "assets/iphone.jpg"],
    ["Samsung S22", "Flagship Samsung", 65000, "assets/s25ultra.jpg"],
    ["OnePlus 10 Pro", "High performance", 60000, "assets/onepluse.jpg"],
    ["Pixel 6", "Pure Android", 55000, "assets/pixel9.jpg"],
  ];

  List cart = [];

  void addToCart(List product) {
    setState(() {
      cart.add(product);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product[0]} added to cart")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageTint,
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: _accentColor,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CartPage(cart: cart)),
                  );
                },
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${cart.length}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];

          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Image.asset(
                item[3],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(item[0].toString()),
              subtitle: Text(item[1].toString()),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${_rupee()}${item[2]}",
                    style: const TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                      ),
                      onPressed: () => addToCart(item),
                      child: const Text(
                        "Add",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List cart;
  final User? currentUser;

  const CartPage({super.key, required this.cart, this.currentUser});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<int, int> quantity = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String _filterBy = "all";

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.cart.length; i++) {
      quantity[i] = 1;
    }
  }

  int _itemPrice(dynamic item) {
    final rawPrice = item is Map ? item["price"] : item[2];
    return _parsePrice(rawPrice);
  }

  String _itemName(dynamic item) {
    return item is Map
        ? (item["name"] ?? "Unknown").toString()
        : item[0].toString();
  }

  String _itemDescription(dynamic item) {
    if (item is Map) {
      return (item["description"] ?? "Fast delivery available").toString();
    }
    return item[1].toString();
  }

  String _itemImage(dynamic item) {
    return item is Map ? (item["image"] ?? "").toString() : item[3].toString();
  }

  Widget _buildItemImage(dynamic item) {
    final imagePath = _itemImage(item);

    if (imagePath.isEmpty) {
      return Container(
        color: const Color(0xFFF1E6C9),
        child:
            const Icon(Icons.image_not_supported_outlined, color: _accentDark),
      );
    }

    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF1E6C9),
          child: const Icon(Icons.broken_image_outlined, color: _accentDark),
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF1E6C9),
        child: const Icon(Icons.broken_image_outlined, color: _accentDark),
      ),
    );
  }

  int getTotalPrice() {
    int total = 0;
    for (int i = 0; i < widget.cart.length; i++) {
      total += _itemPrice(widget.cart[i]) * (quantity[i] ?? 1);
    }
    return total;
  }

  void increaseQty(int index) {
    setState(() {
      quantity[index] = (quantity[index] ?? 1) + 1;
    });
  }

  void decreaseQty(int index) {
    setState(() {
      if ((quantity[index] ?? 1) > 1) {
        quantity[index] = quantity[index]! - 1;
      }
    });
  }

  void deleteItem(int index) {
    setState(() {
      widget.cart.removeAt(index);

      final Map<int, int> newQty = {};
      for (int i = 0; i < widget.cart.length; i++) {
        newQty[i] = quantity[i] ?? 1;
      }

      quantity
        ..clear()
        ..addAll(newQty);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<int> _filteredCartIndexes() {
    final indexes =
        List<int>.generate(widget.cart.length, (index) => index).where((index) {
      final item = widget.cart[index];
      final text = "${_itemName(item)} ${_itemDescription(item)}".toLowerCase();
      return text.contains(_searchText);
    }).toList();

    if (_filterBy == "high") {
      indexes.sort((a, b) =>
          _itemPrice(widget.cart[b]).compareTo(_itemPrice(widget.cart[a])));
    } else if (_filterBy == "low") {
      indexes.sort((a, b) =>
          _itemPrice(widget.cart[a]).compareTo(_itemPrice(widget.cart[b])));
    }

    return indexes;
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
              hintText: "Search cart",
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

  @override
  Widget build(BuildContext context) {
    final subtotal = getTotalPrice();
    final shipping = widget.cart.isEmpty ? 0 : 99;
    final visibleIndexes = _filteredCartIndexes();

    return Scaffold(
      backgroundColor: _pageTint,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _pageTint,
        foregroundColor: Colors.black87,
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: widget.cart.isEmpty
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                _buildSearchFilterRow(),
                _buildEmptyState(),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    children: [
                      _buildSearchFilterRow(),
                      const SizedBox(height: 14),
                      _buildCartHero(subtotal),
                      const SizedBox(height: 16),
                      if (visibleIndexes.isEmpty)
                        _buildNoResultsState()
                      else ...[
                        ...visibleIndexes.map(
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildCartItemCard(index),
                          ),
                        ),
                        _buildSummaryCard(
                          subtotal: subtotal,
                          shipping: shipping,
                          total: subtotal + shipping,
                        ),
                      ],
                    ],
                  ),
                ),
                _buildBottomCheckoutBar(
                  total: subtotal + shipping,
                  itemCount: widget.cart.length,
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 42,
                color: _accentDark,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add products to continue with a faster, cleaner checkout experience.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _mutedText, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Continue Shopping"),
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
            "No cart items found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildCartHero(int subtotal) {
    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Smart cart",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _accentDark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "${widget.cart.length} items ready for checkout",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Subtotal ${_formatPrice(subtotal)} with delivery tracking and quick payment.",
                  style: const TextStyle(color: _mutedText, height: 1.4),
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
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.shopping_cart_checkout_rounded,
              color: _accentDark,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(int index) {
    final item = widget.cart[index];
    final price = _itemPrice(item);
    final qty = quantity[index] ?? 1;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 86,
                height: 86,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4DB),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _formatPrice(price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _accentDark,
                          ),
                        ),
                      ),
                      _buildQuantityControl(index, qty),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => deleteItem(index),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatPrice(price * qty),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(int index, int qty) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE7DEC9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(
            icon: Icons.remove,
            onTap: () => decreaseQty(index),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              "$qty",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          _qtyButton(
            icon: Icons.add,
            onTap: () => increaseQty(index),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9EB),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: _accentDark),
      ),
    );
  }

  Widget _buildSummaryCard({
    required int subtotal,
    required int shipping,
    required int total,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Price details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _summaryRow("Subtotal", _formatPrice(subtotal)),
          const SizedBox(height: 10),
          _summaryRow("Shipping", _formatPrice(shipping)),
          const SizedBox(height: 10),
          _summaryRow("Platform assurance", "Free"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          _summaryRow("Estimated total", _formatPrice(total), isBold: true),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar({
    required int total,
    required int itemCount,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$itemCount items",
                    style: const TextStyle(color: _mutedText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(total),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(
                        cart: widget.cart,
                        quantity: Map.from(quantity),
                        currentUser: widget.currentUser,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.black : _mutedText,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? Colors.black : _accentDark,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final List cart;
  final Map<int, int> quantity;
  final User? currentUser;

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.quantity,
    this.currentUser,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController couponController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final List<Map<String, dynamic>> offers = const [
    {"code": "NONE", "label": "NONE - No offer", "type": "none", "value": 0},
    {
      "code": "SAVE10",
      "label": "SAVE10 - 10% off",
      "type": "percent",
      "value": 10
    },
    {
      "code": "SAVE20",
      "label": "SAVE20 - 20% off",
      "type": "percent",
      "value": 20
    },
    {
      "code": "FLAT500",
      "label": "FLAT500 - Flat 500 off",
      "type": "flat",
      "value": 500
    },
    {
      "code": "SHIPFREE",
      "label": "SHIPFREE - Free shipping",
      "type": "shipping",
      "value": 99
    },
  ];

  int discount = 0;
  String message = "";
  String? selectedOfferCode;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.currentUser?.name ?? "";
  }

  @override
  void dispose() {
    couponController.dispose();
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  int getTotal() {
    int total = 0;
    for (int i = 0; i < widget.cart.length; i++) {
      total += _parsePrice(widget.cart[i] is Map
              ? widget.cart[i]["price"]
              : widget.cart[i][2]) *
          (widget.quantity[i] ?? 1);
    }
    return total;
  }

  List<Map<String, dynamic>> _buildOrderItems() {
    final List<Map<String, dynamic>> orderItems = [];
    for (int i = 0; i < widget.cart.length; i++) {
      final item = widget.cart[i];
      final qty = widget.quantity[i] ?? 1;
      final price = _parsePrice(item is Map ? item["price"] : item[2]);

      orderItems.add({
        "name": _itemName(item),
        "image": _itemImage(item),
        "price": price,
        "quantity": qty,
        "lineTotal": price * qty,
      });
    }
    return orderItems;
  }

  String _itemName(dynamic item) {
    return item is Map
        ? (item["name"] ?? "Unknown").toString()
        : item[0].toString();
  }

  String _itemImage(dynamic item) {
    return item is Map ? (item["image"] ?? "").toString() : item[3].toString();
  }

  Widget _buildItemImage(dynamic item) {
    final imagePath = _itemImage(item);

    if (imagePath.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFF1E6C9),
        child: Icon(Icons.image_not_supported_outlined, color: _accentDark),
      );
    }

    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Color(0xFFF1E6C9),
          child: Icon(Icons.broken_image_outlined, color: _accentDark),
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: Color(0xFFF1E6C9),
        child: Icon(Icons.broken_image_outlined, color: _accentDark),
      ),
    );
  }

  void applyCoupon() {
    final code =
        (selectedOfferCode ?? couponController.text.trim()).toUpperCase();
    final total = getTotal();
    final shipping = widget.cart.isEmpty ? 0 : 99;

    setState(() {
      final matchingOffers = offers.where((offer) => offer["code"] == code);
      if (matchingOffers.isNotEmpty) {
        final offer = matchingOffers.first;
        final type = offer["type"];
        final value = offer["value"] as int;

        if (type == "percent") {
          discount = (total * (value / 100)).toInt();
        } else if (type == "flat") {
          discount = value;
        } else if (type == "shipping") {
          discount = shipping;
        } else {
          discount = 0;
        }

        final maxDiscount = total + shipping;
        if (discount > maxDiscount) {
          discount = maxDiscount;
        }

        couponController.text = code;
        message =
            code == "NONE" ? "No offer applied" : "$code applied successfully";
      } else {
        discount = 0;
        message = "Invalid coupon code";
      }
    });
  }

  Future<void> placeOrder(int finalTotal) async {
    if (nameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and address are required.")),
      );
      return;
    }

    final customerName = nameController.text.trim();
    final orderItems = _buildOrderItems();

    await FirebaseFirestore.instance.collection("orders").add({
      "customerName": customerName,
      "userEmail": widget.currentUser?.email ?? "",
      "address": addressController.text.trim(),
      "totalPrice": finalTotal,
      "subtotal": getTotal(),
      "discount": discount,
      "couponCode": couponController.text.trim().toUpperCase(),
      "status": "Pending",
      "date": DateTime.now().toString(),
      "items": orderItems,
    });

    Orders.orderList.add({
      "items": List<Map<String, dynamic>>.from(orderItems),
      "total": finalTotal,
      "date": DateTime.now().toString(),
    });

    widget.cart.clear();
    widget.quantity.clear();

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Order placed"),
        content: const Text("Your order has been placed successfully."),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => widget.currentUser != null
            ? HomePage(currentUser: widget.currentUser!)
            : const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = getTotal();
    final shipping = widget.cart.isEmpty ? 0 : 99;
    final finalTotal =
        (subtotal + shipping - discount).clamp(0, subtotal + shipping);

    return Scaffold(
      backgroundColor: _pageTint,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _pageTint,
        foregroundColor: Colors.black87,
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              children: [
                _buildCheckoutHero(finalTotal),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: "Delivery details",
                  icon: Icons.location_on_outlined,
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: nameController,
                        label: "Full name",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: addressController,
                        label: "Delivery address",
                        icon: Icons.home_work_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: "Order items",
                  icon: Icons.inventory_2_outlined,
                  child: Column(
                    children: List.generate(
                      widget.cart.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index == widget.cart.length - 1 ? 0 : 12,
                        ),
                        child: _buildCheckoutItem(index),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: "Offers",
                  icon: Icons.local_offer_outlined,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedOfferCode,
                        decoration: InputDecoration(
                          labelText: "Select offer code",
                          prefixIcon: const Icon(
                            Icons.confirmation_number_outlined,
                            color: _accentDark,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFFBF2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: _accentColor),
                          ),
                        ),
                        items: offers
                            .map(
                              (offer) => DropdownMenuItem<String>(
                                value: offer["code"] as String,
                                child: Text(offer["label"] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedOfferCode = value;
                            couponController.text = value ?? "";
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: applyCoupon,
                          child: const Text("Apply Offer"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Offers: NONE, SAVE10, SAVE20, FLAT500, SHIPFREE",
                          style: TextStyle(color: _mutedText, fontSize: 12),
                        ),
                      ),
                      if (message.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message,
                            style: TextStyle(
                              color: message.contains("Invalid")
                                  ? Colors.redAccent
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: "Payment summary",
                  icon: Icons.receipt_long_outlined,
                  child: Column(
                    children: [
                      _checkoutRow("Subtotal", _formatPrice(subtotal)),
                      const SizedBox(height: 10),
                      _checkoutRow("Shipping", _formatPrice(shipping)),
                      const SizedBox(height: 10),
                      _checkoutRow(
                        "Discount",
                        discount == 0
                            ? _formatPrice(0)
                            : "- ${_formatPrice(discount)}",
                        valueColor: discount == 0 ? _accentDark : Colors.green,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1),
                      ),
                      _checkoutRow(
                        "Final total",
                        _formatPrice(finalTotal),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Payable amount",
                          style: TextStyle(color: _mutedText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(finalTotal),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => placeOrder(finalTotal),
                      child: const Text(
                        "Place Order",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _buildCheckoutHero(int finalTotal) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6E0), Color(0xFFFFE2A7)],
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
                    "Secure checkout",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _accentDark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Review and place your order",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Final payment ${_formatPrice(finalTotal)} with address and offer details in one place.",
                  style: const TextStyle(color: _mutedText, height: 1.4),
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
              Icons.credit_card_rounded,
              color: _accentDark,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _accentDark),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _accentDark),
        filled: true,
        fillColor: const Color(0xFFFFFBF2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _accentColor),
        ),
      ),
    );
  }

  Widget _buildCheckoutItem(int index) {
    final item = widget.cart[index];
    final qty = widget.quantity[index] ?? 1;
    final price = _parsePrice(item is Map ? item["price"] : item[2]);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 64,
            height: 64,
            child: _buildItemImage(item),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _itemName(item),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                "Qty $qty",
                style: const TextStyle(color: _mutedText),
              ),
            ],
          ),
        ),
        Text(
          _formatPrice(price * qty),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: _accentDark,
          ),
        ),
      ],
    );
  }

  Widget _checkoutRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.black : _mutedText,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isBold ? Colors.black : _accentDark),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

int _parsePrice(dynamic rawPrice) {
  if (rawPrice is num) return rawPrice.toInt();
  return int.tryParse(rawPrice.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
      0;
}

String _formatPrice(int amount) => "${_rupee()}$amount";

String _rupee() => String.fromCharCode(0x20B9);
