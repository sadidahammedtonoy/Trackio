import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/Controller.dart';

class backgroundSelection extends StatelessWidget {
  backgroundSelection({super.key});
  final controller = Get.find<backgroundController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Change App Background".tr,
            style: const TextStyle(fontSize: 16),
          ),
          centerTitle: false,
          titleSpacing: -10,
          bottom: TabBar(
            indicatorColor: Colors.cyan,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            dividerHeight: 0,
            tabs: [
              Tab(text: "Images Background".tr),
              Tab(text: "Plain Background".tr),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(
              child: ImageCarouselSlider()
            ),

            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: AdvancedColorPicker(),
              )
            ),
          ],
        ),
      ),
    );
  }
}


class AdvancedColorPicker extends StatefulWidget {
  const AdvancedColorPicker({super.key});

  @override
  State<AdvancedColorPicker> createState() => _AdvancedColorPickerState();
}

class _AdvancedColorPickerState extends State<AdvancedColorPicker> {
  final PageController _pageController =
  PageController(viewportFraction: 0.75);

  bool showGrid = false;
  int selectedIndex = 0;

  // ✅ 50+ Colors (Primary First)
  final List<Color> colors = [
    // 🔴 Primary RGB
    Colors.red,
    Colors.white,
    Colors.black,
    Colors.blue,
    Colors.green,


    // 🟡 Traditional Primary
    Colors.yellow,

    // 🟠 Secondary
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,

    // Extended palette
    Color(0xFFF44336), Color(0xFFE91E63), Color(0xFF9C27B0),
    Color(0xFF673AB7), Color(0xFF3F51B5), Color(0xFF2196F3),
    Color(0xFF03A9F4), Color(0xFF00BCD4), Color(0xFF009688),
    Color(0xFF4CAF50), Color(0xFF8BC34A), Color(0xFFCDDC39),
    Color(0xFFFFEB3B), Color(0xFFFFC107), Color(0xFFFF9800),
    Color(0xFFFF5722), Color(0xFF795548), Color(0xFF9E9E9E),
    Color(0xFF607D8B), Color(0xFFB71C1C), Color(0xFF880E4F),
    Color(0xFF4A148C), Color(0xFF311B92), Color(0xFF1A237E),
    Color(0xFF0D47A1), Color(0xFF01579B), Color(0xFF006064),
    Color(0xFF004D40), Color(0xFF1B5E20), Color(0xFF33691E),
    Color(0xFF827717), Color(0xFFF57F17), Color(0xFFFF6F00),
    Color(0xFFE65100), Color(0xFFBF360C), Color(0xFF3E2723),
    Color(0xFF212121), Color(0xFF263238),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -8) {
          setState(() => showGrid = true); // Swipe Up
        }
        if (details.delta.dy > 8) {
          setState(() => showGrid = false); // Swipe Down
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: showGrid ? _buildGridView() : _buildSliderView(),
      ),
    );
  }

  // ================= SLIDER VIEW =================

  Widget _buildSliderView() {
    return Column(
      key: const ValueKey("slider"),
      children: [
        const SizedBox(height: 30),

        // Slider of Colors
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: colors.length,
            onPageChanged: (index) {
              setState(() => selectedIndex = index);
            },
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: BorderRadius.circular(25),
                  border: selectedIndex == index
                      ? Border.all(color: Colors.black, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "#${colors[index].value.toRadixString(16).substring(2).toUpperCase()}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 25),

        // Button to save selection
        ElevatedButton(
          onPressed: () async {
            final selectedColor = colors[selectedIndex];
            final colorCode = "#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}";
            Get.find<backgroundController>().saveUserBackground(isColor: true, source: colorCode);
            Get.back();
          },
          child: Text(
            "Use as Background".tr,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),

        const SizedBox(height: 15),
        Text(
          "Swipe Up to See All Colors".tr,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
  // ================= GRID VIEW =================

  Widget _buildGridView() {
    return Column(
      key: const ValueKey("grid"),
      children: [
        const SizedBox(height: 25),
        Text(
          "Select a Color".tr,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: colors.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              bool isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                    showGrid = false; // ✅ Back to slider
                  });

                  if (_pageController.hasClients) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(18),
                    border: isSelected
                        ? Border.all(
                        color: Colors.black, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.4),
                        blurRadius: 10,
                      )
                    ]
                        : [],
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            "Swipe Down to Return".tr,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}



class ImageCarouselSlider extends StatefulWidget {
  const ImageCarouselSlider({super.key});

  @override
  State<ImageCarouselSlider> createState() => _ImageCarouselSliderState();
}

class _ImageCarouselSliderState extends State<ImageCarouselSlider> {
  final PageController _pageController =
  PageController(viewportFraction: 0.65);

  double currentPage = 0;
  int selectedIndex = 0;

  // ✅ Demo Image List (Change Later)
  final List<String> images = [
    "assets/newBackground.jpeg",
    "assets/Cream and Beige Illustrative Background Portrait Document A4.png",
    "assets/background.jpeg",
    "assets/White Golden Floral Frame Background Facebook Story.jpg",
    "assets/Pink Yellow Aesthetic Watercolor Background Document A4.jpg",
    "assets/Mint Green Minimalist Watercolor Leaves Background Instagram Story.jpg",
    "assets/Green and Purple Watercolor Background Document A4.jpg",
    "assets/Brown Floral Watercolor Minimalist Notes Background A4 Document.jpg",
    "assets/Blue Watercolor Background Document.jpg",
    "assets/Blue and White Simple Watercolor Background Instagram Story.jpg",
    "assets/Blue Cute Simple Background Instagram Story.jpg",
    "assets/Green Aesthetic Poster Portrait.jpg",
    "assets/Green Modern Welcome Spring (Instagram Story).jpg"
  ];

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page ?? 0;
        selectedIndex = currentPage.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        /// 🔥 Carousel
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              double difference = (currentPage - index).abs();
              double scale = (1 - (difference * 0.2)).clamp(0.75, 1.0);

              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  transform: Matrix4.identity()..scale(scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 30),

        /// 🔥 Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Get.find<backgroundController>().saveUserBackground(isColor: false, source: images[selectedIndex]);
                Get.back();
              },
              child: Text(
                "Use as Background".tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}