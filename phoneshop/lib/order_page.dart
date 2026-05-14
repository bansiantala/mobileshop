import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF8F5A00);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _mutedText = Color(0xFF6E6554);

class Orders {
  static List<Map<String, dynamic>> orderList = [];
}

class OrderPage extends StatefulWidget {
  final String currentUserEmail;

  const OrderPage({super.key, required this.currentUserEmail});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Color getStatusColor(String status) {
    return status == "Delivered" ? Colors.green : Colors.orange;
  }

  Future<void> removeOrder(String docId) async {
    await FirebaseFirestore.instance.collection("orders").doc(docId).delete();
  }

  Future<void> cancelOrder(String docId) async {
    await FirebaseFirestore.instance.collection("orders").doc(docId).update({
      "status": "Cancelled",
    });
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
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userEmail", isEqualTo: widget.currentUserEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final orderDocs = snapshot.data!.docs;
          final totalSpent = orderDocs.fold<int>(
            0,
            (sum, doc) => sum + _parsePrice((doc.data() as Map<String, dynamic>)["totalPrice"]),
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            children: [
              _buildHero(orderDocs.length, totalSpent),
              const SizedBox(height: 16),
              ...List.generate(
                orderDocs.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildOrderCard(index, orderDocs[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(int totalOrders, int totalSpent) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    "Orders overview",
                    style: TextStyle(
                      color: _accentDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "$totalOrders orders tracked",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Total value ${_formatPrice(totalSpent)} from your account history.",
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
              Icons.inventory_2_rounded,
              color: _accentDark,
              size: 34,
            ),
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
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: _accentDark,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "No orders yet",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your placed orders will appear here after you checkout from this account.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _mutedText, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(int index, QueryDocumentSnapshot orderDoc) {
    final order = orderDoc.data() as Map<String, dynamic>;
    final String status = (order["status"] ?? "Pending").toString();
    final List items = (order["items"] as List?) ?? [];
    final total = _parsePrice(order["totalPrice"]);
    final date = (order["date"] ?? "").toString();

    return Dismissible(
      key: Key("${orderDoc.id}-$index"),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        await removeOrder(orderDoc.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order removed")),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order ${index + 1}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatOrderDate(date),
                        style: const TextStyle(color: _mutedText),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: getStatusColor(status),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              items.length,
              (itemIndex) => Padding(
                padding: EdgeInsets.only(bottom: itemIndex == items.length - 1 ? 0 : 12),
                child: _buildOrderItem(items[itemIndex]),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    "Items",
                    "${items.fold<int>(0, (sum, item) => sum + _itemQuantity(item))}",
                  ),
                ),
                Expanded(child: _miniInfo("Total", _formatPrice(total))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _accentColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _showOrderDetails(order),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        color: _accentDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (status == "Cancelled" || status == "Delivered")
                              ? Colors.grey
                              : Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: (status == "Cancelled" || status == "Delivered")
                        ? null
                        : () => cancelOrder(orderDoc.id),
                    child: const Text(
                      "Cancel Order",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    final String itemName =
        item is Map ? (item["name"] ?? "Unknown").toString() : item[0].toString();
    final dynamic rawPrice = item is Map ? item["price"] : item[2];
    final String itemImage = item is Map ? (item["image"] ?? "").toString() : "";
    final int qty = _itemQuantity(item);
    final int lineTotal = item is Map && item["lineTotal"] != null
        ? _parsePrice(item["lineTotal"])
        : _parsePrice(rawPrice) * qty;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 60,
            height: 60,
            color: const Color(0xFFFFF7E8),
            child: itemImage.isEmpty
                ? const Icon(Icons.shopping_bag_outlined, color: _accentDark)
                : (itemImage.startsWith("http")
                    ? Image.network(
                        itemImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shopping_bag_outlined,
                          color: _accentDark,
                        ),
                      )
                    : Image.asset(
                        itemImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shopping_bag_outlined,
                          color: _accentDark,
                        ),
                      )),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                "Qty: $qty",
                style: const TextStyle(color: _mutedText, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _formatPrice(lineTotal),
          style: const TextStyle(
            color: _accentDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _miniInfo(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _mutedText, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: _accentDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final List items = (order["items"] as List?) ?? [];
    final total = _parsePrice(order["totalPrice"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Order details"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...items.map((item) {
                final name =
                    item is Map ? (item["name"] ?? "Unknown").toString() : item[0].toString();
                final price = item is Map ? item["price"] : item[2];
                final qty = _itemQuantity(item);
                final lineTotal = item is Map && item["lineTotal"] != null
                    ? _parsePrice(item["lineTotal"])
                    : _parsePrice(price) * qty;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text("$name x$qty")),
                      const SizedBox(width: 12),
                      Text(_formatPrice(lineTotal)),
                    ],
                  ),
                );
              }),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _formatPrice(total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _accentDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

int _itemQuantity(dynamic item) {
  if (item is Map && item["quantity"] != null) {
    return _parsePrice(item["quantity"]);
  }
  return 1;
}

int _parsePrice(dynamic rawPrice) {
  if (rawPrice is num) return rawPrice.toInt();
  return int.tryParse(rawPrice.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

String _formatPrice(int amount) => "${String.fromCharCode(0x20B9)}$amount";

String _formatOrderDate(String rawDate) {
  if (rawDate.isEmpty) return "Unknown date";
  final parsed = DateTime.tryParse(rawDate);
  if (parsed == null) return rawDate;
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return "$day/$month/${parsed.year}";
}
