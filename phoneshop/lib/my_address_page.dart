import 'package:flutter/material.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF8F5A00);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _surfaceColor = Colors.white;
const Color _mutedText = Color(0xFF6E6554);

class MyAddressPage extends StatefulWidget {
  const MyAddressPage({super.key});

  @override
  State<MyAddressPage> createState() => _MyAddressPageState();
}

class _MyAddressPageState extends State<MyAddressPage> {
  List<Map<String, String>> addresses = [
    {
      "title": "Home",
      "address": "Street 1, Rajkot, Gujarat - 360001",
      "phone": "9876543210"
    }
  ];

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
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
    );
  }

  void openAddressForm({int? index}) {
    final titleController =
        TextEditingController(text: index != null ? addresses[index]["title"] : "");
    final addressController =
        TextEditingController(text: index != null ? addresses[index]["address"] : "");
    final phoneController =
        TextEditingController(text: index != null ? addresses[index]["phone"] : "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            decoration: const BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index == null ? "Add Address" : "Edit Address",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: inputStyle("Title", Icons.location_on_outlined),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  maxLines: 3,
                  decoration: inputStyle("Full Address", Icons.home_outlined),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: inputStyle("Phone Number", Icons.phone_outlined),
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
                    onPressed: () {
                      if (index == null) {
                        setState(() {
                          addresses.add({
                            "title": titleController.text,
                            "address": addressController.text,
                            "phone": phoneController.text,
                          });
                        });
                      } else {
                        setState(() {
                          addresses[index] = {
                            "title": titleController.text,
                            "address": addressController.text,
                            "phone": phoneController.text,
                          };
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Save Address",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
    });
  }

  Widget addressCard(int index) {
    final data = addresses[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.location_on_outlined, color: _accentDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data["title"] ?? "",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => openAddressForm(index: index),
                icon: const Icon(Icons.edit_outlined, color: _mutedText),
              ),
              IconButton(
                onPressed: () => deleteAddress(index),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data["address"] ?? "",
            style: const TextStyle(color: _mutedText, height: 1.35),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 18, color: _accentDark),
              const SizedBox(width: 8),
              Text(
                data["phone"] ?? "",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
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
          "My Address",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
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
                    "${addresses.length} saved address${addresses.length == 1 ? "" : "es"} for quick delivery.",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(addresses.length, addressCard),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text(
                    "Add New Address",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: openAddressForm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
