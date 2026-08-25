import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../Controller/Controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class HelpSupportPage extends StatelessWidget {
  HelpSupportPage({super.key});

  final HelpSupportController controller = Get.put(HelpSupportController());

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    Widget body = ListView(
      padding: EdgeInsets.fromLTRB(
        tablet ? 24.0 : 16, 
        tablet ? 24.0 : 16, 
        tablet ? 24.0 : 16, 
        tablet ? 32.0 : 24
      ),
      children: [
        _SearchBar(controller: controller, tablet: tablet),
        SizedBox(height: tablet ? 16.0 : 12.0),
        _ContactCard(controller: controller, tablet: tablet),
        SizedBox(height: tablet ? 16.0 : 12.0),
        _CategoryChips(controller: controller, tablet: tablet),
        SizedBox(height: tablet ? 16.0 : 12.0),
        _FaqHeader(tablet: tablet),
        SizedBox(height: tablet ? 14.0 : 10.0),
        Obx(() {
          final list = controller.filteredFaqs;
  
          if (list.isEmpty) {
            return _EmptyState(
              onClear: () {
                controller.search.value = "";
                controller.selectedCategory.value = "All";
              },
              tablet: tablet,
            );
          }
  
          return Column(
            children: list.map((f) {
              return _FaqTile(
                question: f["q"].toString(),
                answer: f["a"].toString(),
                tag: f["category"].toString(),
                tablet: tablet,
              );
            }).toList(),
          );
        }),
      ],
    );

    if (tablet) {
      body = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: body,
        ),
      );
    }

    return background(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Help & Support".tr,
            style: tablet ? const TextStyle(fontSize: 18.0) : null,
          ),
          centerTitle: false,
          titleSpacing: -10,
          elevation: 0.5,
          actions: [
            IconButton(
              onPressed: controller.openReportSheet,
              icon: Icon(Icons.bug_report_outlined, size: tablet ? 28.0 : 24.0),
              tooltip: "Report a problem".tr,
            ),
          ],
        ),
        body: body,
      ),
    );
  }
}

/* ---------------- UI Widgets ---------------- */

class _SearchBar extends StatelessWidget {
  final HelpSupportController controller;
  final bool tablet;

  const _SearchBar({required this.controller, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tablet ? 16.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => controller.search.value = v,
              style: TextStyle(fontSize: tablet ? 16.0 : 14.0),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: tablet ? 24.0 : 20.0,),
                hintText: "Search questions (sync, guest, password...)".tr,
                hintStyle: TextStyle(fontSize: tablet ? 15.0 : 14.0),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Obx(() {
            final hasText = controller.search.value.trim().isNotEmpty;
            return hasText
                ? IconButton(
              onPressed: () => controller.search.value = "",
              icon: Icon(Icons.close, size: tablet ? 24.0 : 20.0),
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
  final bool tablet;

  const _ContactCard({required this.controller, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return _Card(
      tablet: tablet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Support".tr,
            style: TextStyle(fontSize: tablet ? 16.0 : 15.5, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: tablet ? 8.0 : 6.0),
          Text(
            "Need help quickly? Contact us using one of the options below.".tr,
            style: TextStyle(color: Colors.black54, fontSize: tablet ? 15.0 : 14.0),
          ),
          SizedBox(height: tablet ? 16.0 : 12.0),
          SizedBox(
            width: double.infinity,
            height: tablet ? 48.0 : 42.0,
            child: ElevatedButton.icon(
              onPressed: controller.openReportSheet,
              icon: Icon(Icons.bug_report_outlined, color: Colors.white, size: tablet ? 20.0 : 18.0),
              label: Text("Report a problem".tr, style: TextStyle(color: Colors.white, fontSize: tablet ? 15.0 : 14.0),),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final HelpSupportController controller;
  final bool tablet;

  const _CategoryChips({required this.controller, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedCat = controller.selectedCategory.value;

      return SizedBox(
        height: tablet ? 44.0 : 40.0,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => SizedBox(width: tablet ? 10.0 : 8.0),
          itemBuilder: (context, i) {
            final c = controller.categories[i];
            final selected = selectedCat == c;

            return ChoiceChip(
              label: Text(c.tr),
              selected: selected,
              onSelected: (_) => controller.selectedCategory.value = c,
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: tablet ? 15.0 : 14.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : Colors.grey.shade300,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _FaqHeader extends StatelessWidget {
  final bool tablet;
  const _FaqHeader({required this.tablet});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Frequently Asked Questions".tr,
      style: TextStyle(fontSize: tablet ? 16.0 : 15.5, fontWeight: FontWeight.w700),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final String tag;
  final bool tablet;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.tag,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      tablet: tablet,
      margin: EdgeInsets.only(bottom: tablet ? 14.0 : 10.0),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: tablet ? 14.0 : 10.0),
        childrenPadding: EdgeInsets.fromLTRB(
          tablet ? 20.0 : 16.0, 
          0, 
          tablet ? 20.0 : 16.0, 
          tablet ? 18.0 : 14.0
        ),
        leading: Icon(Icons.help_outline, color: Colors.black54, size: tablet ? 24.0 : 20.0),
        title: Text(
          question.tr,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: tablet ? 16.0 : 15.0),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: tablet ? 6.0 : 4.0),
          child: Text(
            tag.tr,
            style: TextStyle(fontSize: tablet ? 13.0 : 12.0, color: Colors.black54),
          ),
        ),
        children: [
          Text(
            answer.tr,
            style: TextStyle(color: Colors.black87, height: 1.35, fontSize: tablet ? 15.0 : 14.0),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  final bool tablet;

  const _EmptyState({required this.onClear, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return _Card(
      tablet: tablet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "No results found".tr,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: tablet ? 16.0 : 15.0),
          ),
          SizedBox(height: tablet ? 8.0 : 6.0),
          Text(
            "Try searching with different keywords or clear filters.".tr,
            style: TextStyle(color: Colors.black54, fontSize: tablet ? 15.0 : 14.0),
          ),
          SizedBox(height: tablet ? 16.0 : 12.0),
          SizedBox(
            width: double.infinity,
            height: tablet ? 48.0 : 42.0,
            child: OutlinedButton(
              onPressed: onClear,
              child: Text("Clear search & filters".tr, style: TextStyle(fontSize: tablet ? 15.0 : 14.0)),
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
  final bool tablet;

  const _Card({required this.child, this.margin, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: EdgeInsets.all(tablet ? 18.0 : 14.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }
}
