import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/Controller.dart';

class HelpSupportPage extends StatelessWidget {
  HelpSupportPage({super.key});

  final HelpSupportController controller = Get.put(HelpSupportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: controller.openReportSheet,
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: "Report a problem",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SearchBar(controller: controller),
          const SizedBox(height: 12),
          _ContactCard(controller: controller),
          const SizedBox(height: 12),
          _CategoryChips(controller: controller),
          const SizedBox(height: 12),
          const _FaqHeader(),
          const SizedBox(height: 10),
          Obx(() {
            final list = controller.filteredFaqs;

            if (list.isEmpty) {
              return _EmptyState(
                onClear: () {
                  controller.search.value = "";
                  controller.selectedCategory.value = "All";
                },
              );
            }

            return Column(
              children: list.map((f) {
                return _FaqTile(
                  question: f["q"].toString(),
                  answer: f["a"].toString(),
                  tag: f["category"].toString(),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

/* ---------------- UI Widgets ---------------- */

class _SearchBar extends StatelessWidget {
  final HelpSupportController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => controller.search.value = v,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey,),
                hintText: "Search questions (sync, guest, password...)",
                border: InputBorder.none,
              ),
            ),
          ),
          Obx(() {
            final hasText = controller.search.value.trim().isNotEmpty;
            return hasText
                ? IconButton(
              onPressed: () => controller.search.value = "",
              icon: const Icon(Icons.close),
            )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final HelpSupportController controller;

  const _ContactCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Contact Support",
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            "Need help quickly? Contact us using one of the options below.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.openReportSheet,
              icon: const Icon(Icons.bug_report_outlined, color: Colors.white,),
              label: const Text("Report a problem", style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}

 class _CategoryChips extends StatelessWidget {
  final HelpSupportController controller;

  const _CategoryChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedCat = controller.selectedCategory.value;

      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final c = controller.categories[i];
            final selected = (selectedCat == c);

            return ChoiceChip(
              label: Text(c),
              selected: selected,
              onSelected: (_) => controller.selectedCategory.value = c,
              selectedColor: Colors.blueGrey,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      );
    });
  }
}


class _FaqHeader extends StatelessWidget {
  const _FaqHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Frequently Asked Questions",
      style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final String tag;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        leading: const Icon(Icons.help_outline),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            tag,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(color: Colors.black87, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "No results found",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try searching with different keywords or clear filters.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onClear,
              child: const Text("Clear search & filters"),
            ),
          ),
        ],
      ),
    );
  }
}


class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;

  const _Card({required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
