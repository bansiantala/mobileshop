import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Map<int, int> quantity;

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.quantity,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int getTotal() {
    int total = 0;

    for (int i = 0; i < widget.cart.length; i++) {
      var item = widget.cart[i];

      // Safely extract price string
      String priceStr = item["price"]?.toString() ?? "₹0";

      // Convert to int
      int price = int.tryParse(priceStr.replaceAll("₹", "")) ?? 0;

      // Get quantity, default to 1
      int q = widget.quantity[i] ?? 1;

      total += price * q;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    int total = getTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Color.fromARGB(255, 238, 194, 91),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ///  CART LIST
            Expanded(
              child: widget.cart.isEmpty
                  ? const Center(child: Text("Cart is empty"))
                  : ListView.builder(
                      itemCount: widget.cart.length,
                      itemBuilder: (context, index) {
                        var item = widget.cart[index];

                        String name = item["name"]?.toString() ?? "No Name";
                        String priceStr = item["price"]?.toString() ?? "₹0";

                        int q = widget.quantity[index] ?? 1;

                        return Card(
                          child: ListTile(
                            title: Text(name),
                            subtitle: Text("Price: $priceStr  x$q"),
                            trailing: Text(
                              "₹${(int.tryParse(priceStr.replaceAll("₹", "")) ?? 0) * q}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Text(
              "Total: ₹$total",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 238, 194, 91),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
              ),
              onPressed: () async {
                String customerName = FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? "Customer";
                String userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
                
                // Add order to Firestore for Admin
                await FirebaseFirestore.instance.collection("orders").add({
                  "customerName": customerName,
                  "userEmail": userEmail,
                  "totalPrice": total,
                  "status": "Pending",
                  "date": DateTime.now().toString(),
                  "items": widget.cart,
                });

                Orders.orderList.add({
                  "items": List.from(widget.cart),
                  "total": total,
                  "date": DateTime.now().toString(),
                });

                widget.cart.clear();
                widget.quantity.clear();

                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderPage(
                        currentUserEmail: userEmail,
                      ),
                    ),
                  );
                }
              },
              child: const Text("Place Order"),
            )
          ],
        ),
      ),
    );
  }
}
