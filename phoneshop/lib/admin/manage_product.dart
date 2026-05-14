import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF5A3A12);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _surfaceColor = Colors.white;
const Color _mutedText = Color(0xFF6E6554);

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
          "Manage Products",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder(
        stream: firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          return ListView(
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
                child: Text(
                  "${products.length} products available for admin control.",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...products.map((product) => _productCard(product)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        onPressed: () => showProductDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _productCard(DocumentSnapshot product) {
    final data = product.data() as Map;
    final image = (data["image"] ?? "").toString();
    final stockLabel = _stockLabel(data["stock"]);
    final isOutOfStock = stockLabel == "Out of Stock";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 92,
              height: 92,
              color: const Color(0xFFFFF3D5),
              child: image.startsWith("http")
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.shopping_bag_outlined),
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.shopping_bag_outlined),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (data["name"] ?? "").toString(),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  "${String.fromCharCode(0x20B9)}${data["price"]}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: _accentDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (data["description"] ?? "").toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _mutedText, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    stockLabel,
                    style: TextStyle(
                      color: isOutOfStock ? Colors.redAccent : Colors.green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: () =>
                    showProductDialog(product: data, id: product.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
                onPressed: () async {
                  await firestore
                      .collection('products')
                      .doc(product.id)
                      .delete();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showProductDialog({Map? product, String? id}) {
    final nameController = TextEditingController(text: product?["name"] ?? "");
    final priceController =
        TextEditingController(text: product?["price"] ?? "");
    final imageController =
        TextEditingController(text: product?["image"] ?? "");
    final descController =
        TextEditingController(text: product?["description"] ?? "");
    String selectedStock =
        product == null ? "In Stock" : _stockLabel(product["stock"]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                decoration: const BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product == null ? "Add Product" : "Edit Product",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      _field("Product Name", nameController),
                      const SizedBox(height: 12),
                      _field("Price", priceController),
                      const SizedBox(height: 12),
                      _field("Image Path", imageController),
                      const SizedBox(height: 12),
                      _field("Description", descController),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStock,
                        decoration: InputDecoration(
                          labelText: "Stock",
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
                        items: const [
                          DropdownMenuItem(
                              value: "In Stock", child: Text("In Stock")),
                          DropdownMenuItem(
                              value: "Out of Stock",
                              child: Text("Out of Stock")),
                        ],
                        onChanged: (value) {
                          setSheetState(
                              () => selectedStock = value ?? "In Stock");
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
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
                          onPressed: () async {
                            if (nameController.text.isEmpty ||
                                priceController.text.isEmpty) return;

                            if (product == null) {
                              await firestore.collection('products').add({
                                "name": nameController.text,
                                "price": priceController.text,
                                "image": imageController.text,
                                "description": descController.text,
                                "stock": selectedStock,
                              });
                            } else {
                              await firestore
                                  .collection('products')
                                  .doc(id)
                                  .update({
                                "name": nameController.text,
                                "price": priceController.text,
                                "image": imageController.text,
                                "description": descController.text,
                                "stock": selectedStock,
                              });
                            }

                            if (mounted) Navigator.pop(context);
                          },
                          child: const Text("Save",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
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

  String _stockLabel(dynamic rawStock) {
    final stockText = (rawStock ?? "").toString().trim().toLowerCase();
    if (stockText == "out stock" || stockText == "out of stock")
      return "Out of Stock";
    if (stockText == "in stock") return "In Stock";

    final stock = int.tryParse(stockText) ?? 0;
    return stock <= 0 ? "Out of Stock" : "In Stock";
  }
}
