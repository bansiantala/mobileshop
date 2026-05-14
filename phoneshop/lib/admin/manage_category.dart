import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color _accentColor = Color.fromARGB(255, 238, 194, 91);
const Color _accentDark = Color(0xFF5A3A12);
const Color _pageTint = Color(0xFFF7F4ED);
const Color _surfaceColor = Colors.white;
const Color _mutedText = Color(0xFF6E6554);

class ManageCategoryPage extends StatefulWidget {
  const ManageCategoryPage({super.key});

  @override
  State<ManageCategoryPage> createState() => _ManageCategoryPageState();
}

class _ManageCategoryPageState extends State<ManageCategoryPage> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  final CollectionReference categoriesRef =
      FirebaseFirestore.instance.collection("categories");

  @override
  void dispose() {
    categoryController.dispose();
    imageController.dispose();
    super.dispose();
  }

  void addCategory() async {
    final name = categoryController.text.trim();
    final image = imageController.text.trim();
    if (name.isEmpty || image.isEmpty) return;
    if (!image.startsWith("assets/")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image must use assets path only.")),
      );
      return;
    }

    await categoriesRef.add({
      "name": name,
      "image": image,
      "createdAt": Timestamp.now(),
    });

    categoryController.clear();
    imageController.clear();
  }

  void deleteCategory(String id) async {
    await categoriesRef.doc(id).delete();
  }

  void editCategory(String id, String oldName, String oldImage) {
    categoryController.text = oldName;
    imageController.text = oldImage;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Edit Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(categoryController, "Category Name"),
            const SizedBox(height: 12),
            _field(imageController, "Image Path (assets/...)"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              categoryController.clear();
              imageController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
            onPressed: () async {
              if (!imageController.text.trim().startsWith("assets/")) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Image must use assets path only.")),
                );
                return;
              }
              await categoriesRef.doc(id).update({
                "name": categoryController.text.trim(),
                "image": imageController.text.trim(),
              });
              categoryController.clear();
              imageController.clear();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  ImageProvider? getImage(String image) {
    if (image.isEmpty || image == "assets/") return null;
    if (!image.startsWith("assets/")) return null;
    return AssetImage(image);
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
          "Manage Categories",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Add category",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _field(categoryController, "Category Name"),
                  const SizedBox(height: 12),
                  _field(imageController, "Image Path (assets/...)"),
                  const SizedBox(height: 14),
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
                      onPressed: addCategory,
                      child: const Text(
                        "Add Category",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: categoriesRef.snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text("No Categories Found"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data["name"] ?? "").toString();
                      final image = (data["image"] ?? "").toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _accentColor, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFFFF3D5),
                                backgroundImage: getImage(image),
                                child: (image.isEmpty || image == "assets/")
                                    ? const Icon(Icons.category_outlined, color: _accentDark)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    image,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: _mutedText, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                              onPressed: () => editCategory(doc.id, name, image),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                              onPressed: () => deleteCategory(doc.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
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
}
