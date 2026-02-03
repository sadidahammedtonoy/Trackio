import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/AppColors.dart';
import '../Controller/Controller.dart';

class categories extends StatelessWidget {
  categories({super.key});
  final controller = Get.find<caregoriesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        titleSpacing: -10,
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.white,
        onPressed: () => _openAddDialog(),
        child: Icon(Icons.add, color: AppColors.primary,),
      ),
      body: Obx(() {
        final list = controller.categories;

        if (list.isEmpty) {
          return const Center(
            child: Text("No categories yet"),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = list[index];
            final id = item["id"].toString();
            final name = (item["name"] ?? "").toString();
            final createdAtText = _formatCreatedAt(item["createdAt"]);

            return Dismissible(
              key: ValueKey(id),

              // ✅ BOTH swipe directions allowed
              direction: DismissDirection.horizontal,

              // Background for LEFT ➜ RIGHT (Edit)
              background: _swipeBg(
                color: const Color(0xFF1976D2),
                icon: Icons.edit,
                text: "Edit",
                alignLeft: true,
              ),

              // Background for RIGHT ➜ LEFT (Delete)
              secondaryBackground: _swipeBg(
                color: const Color(0xFFD32F2F),
                icon: Icons.delete,
                text: "Delete",
                alignLeft: false,
              ),

              // ✅ Decide what happens before dismiss
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Left ➜ Right = EDIT (do not dismiss)
                  _openEditDialog(categoryId: id, currentName: name);
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  // Right ➜ Left = DELETE (confirm)
                  final ok = await _confirmDelete(name);
                  if (ok == true) {
                    await controller.deleteCategory(id);
                    return true; // remove from list animation
                  }
                  return false;
                }
                return false;
              },

              child: _categoryTile(
                name: name,
                createdAtText: createdAtText,
              ),
            );
          },
        );
      }),
    );
  }

  // ---------- UI widgets ----------

  Widget _categoryTile({required String name, required String createdAtText}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFF2F4F7),
            child: Icon(Icons.label_outline, color: Colors.black87, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  createdAtText,
                  style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _swipeBg({
    required Color color,
    required IconData icon,
    required String text,
    required bool alignLeft,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- dialogs ----------

  void _openAddDialog() {
    final tc = TextEditingController();

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Add Category"),
        content: TextField(
          controller: tc,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Category name",
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.black87),),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final name = tc.text;
                    Get.back();
                    await controller.addCategory(name);
                  },
                  child: const Text("Add", style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          )

        ],
      ),
    );
  }

  void _openEditDialog({
    required String categoryId,
    required String currentName,
  }) {
    final tc = TextEditingController(text: currentName);

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Edit Category"),
        content: TextField(
          controller: tc,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Category name",
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.black),),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = tc.text;
                    Get.back();
                    await controller.editCategory(
                      categoryId: categoryId,
                      newName: newName,
                    );
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          )

        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(String name) {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Delete Category?"),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text("No", style: TextStyle(color: Colors.black),),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
                  onPressed: () => Get.back(result: true),
                  child: const Text("Delete", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )

        ],
      ),
    );
  }

  // ---------- date formatter (simple) ----------
  String _formatCreatedAt(dynamic createdAt) {
    // Firestore serverTimestamp can be null briefly.
    if (createdAt == null) return "Just now";

    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      // simple readable format: 02 Feb 2026
      final months = [
        "Jan","Feb","Mar","Apr","May","Jun",
        "Jul","Aug","Sep","Oct","Nov","Dec"
      ];
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = months[dt.month - 1];
      final yyyy = dt.year.toString();
      return "Created: $dd $mm $yyyy";
    }

    return "Created: —";
  }
}

