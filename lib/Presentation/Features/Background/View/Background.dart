import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sadid/App/AppColors.dart';
import '../Controller/Controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class backgroundSelection extends StatelessWidget {
  backgroundSelection({super.key});
  final controller = Get.find<backgroundController>();

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Subtle off-white modern bg
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Change App Background".tr,
            style: TextStyle(
              fontSize: tablet ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(tablet ? 70 : 60),
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: tablet ? 80 : 20,
                vertical: 10,
              ),
              height: tablet ? 50 : 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: TextStyle(
                  fontSize: tablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: "Images Background".tr),
                  Tab(text: "Plain Background".tr),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const TabBarView(
              children: [
                ImageCarouselSlider(),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: AdvancedColorPicker(),
                  ),
                ),
              ],
            ),
          ),
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
  final PageController _pageController = PageController(viewportFraction: 0.75);

  bool showGrid = false;
  int selectedIndex = 0;

  final List<Color> colors = [
    Colors.red, Colors.white, Colors.black, Colors.blue, Colors.green,
    Colors.yellow, Colors.orange, Colors.purple, Colors.teal, Colors.cyan,
    Colors.indigo, Colors.lime, Color(0xFFF44336), Color(0xFFE91E63),
    Color(0xFF9C27B0), Color(0xFF673AB7), Color(0xFF3F51B5), Color(0xFF2196F3),
    Color(0xFF03A9F4), Color(0xFF00BCD4), Color(0xFF009688), Color(0xFF4CAF50),
    Color(0xFF8BC34A), Color(0xFFCDDC39), Color(0xFFFFEB3B), Color(0xFFFFC107),
    Color(0xFFFF9800), Color(0xFFFF5722), Color(0xFF795548), Color(0xFF9E9E9E),
    Color(0xFF607D8B), Color(0xFFB71C1C), Color(0xFF880E4F), Color(0xFF4A148C),
    Color(0xFF311B92), Color(0xFF1A237E), Color(0xFF0D47A1), Color(0xFF01579B),
    Color(0xFF006064), Color(0xFF004D40), Color(0xFF1B5E20), Color(0xFF33691E),
    Color(0xFF827717), Color(0xFFF57F17), Color(0xFFFF6F00), Color(0xFFE65100),
    Color(0xFFBF360C), Color(0xFF3E2723), Color(0xFF212121), Color(0xFF263238),
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
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: showGrid ? _buildGridView() : _buildSliderView(context),
      ),
    );
  }

  Widget _buildSliderView(BuildContext context) {
    final tablet = _isTablet(context);
    return Column(
      key: const ValueKey("slider"),
      children: [
        SizedBox(height: tablet ? 50 : 30),
        SizedBox(
          height: tablet ? 400 : 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: colors.length,
            onPageChanged: (index) {
              setState(() => selectedIndex = index);
            },
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(
                  horizontal: tablet ? 30 : 15,
                  vertical: isSelected ? 10 : 30,
                ),
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: BorderRadius.circular(35),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: colors[index].withOpacity(0.4),
                      blurRadius: isSelected ? 20 : 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "#${colors[index].value.toRadixString(16).substring(2).toUpperCase()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Spacer(),
        _buildUseButton(
          label: "Use as Background".tr,
          onPressed: () {
            final selectedColor = colors[selectedIndex];
            final colorCode = "#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}";
            Get.find<backgroundController>().saveUserBackground(isColor: true, source: colorCode);
            Get.back();
          },
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            Text(
              "Swipe Up to See All Colors".tr,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade400),
          ],
        ),
        SizedBox(height: tablet ? 40 : 20),
      ],
    );
  }

  Widget _buildGridView() {
    final tablet = _isTablet(context);
    return Column(
      key: const ValueKey("grid"),
      children: [
        const SizedBox(height: 20),
        Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
        const SizedBox(height: 4),
        Text(
          "Swipe Down to Return".tr,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: tablet ? 40 : 20, vertical: 10),
            itemCount: colors.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: tablet ? 6 : 4,
              mainAxisSpacing: tablet ? 20 : 16,
              crossAxisSpacing: tablet ? 20 : 16,
            ),
            itemBuilder: (context, index) {
              bool isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                    showGrid = false; 
                  });
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(index);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 4)
                        : Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: colors[index].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: isSelected 
                      ? const Icon(Icons.check, color: Colors.white) 
                      : null,
                ),
              );
            },
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
  PageController? _pageController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final tablet = _isTablet(context);
      _pageController = PageController(viewportFraction: tablet ? 0.85 : 0.85);
      _pageController!.addListener(() {
        if (mounted) {
          setState(() {
            currentPage = _pageController!.page ?? 0;
            selectedIndex = currentPage.round();
          });
        }
      });
      _initialized = true;
    }
  }

  double currentPage = 0;
  int selectedIndex = 0;

  final List<String> images = [
    "assets/12bdb075678dee4c0ab2c5d092552294.jpg",
    "assets/49d6567948370c7451a6d4c15ac8c376.jpg",
    "assets/5cccc0b0228dc895465d0b1440a42ddb.jpg",
    "assets/cbfb01f0c5de123998fc236ae6e55751.jpg",
    "assets/e62b8bdea5ae49802f3ac19a109a6410.jpg",
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
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);
    return Column(
      children: [
        SizedBox(height: tablet ? 30 : 20),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              double difference = (currentPage - index).abs();
              double scale = (1 - (difference * 0.15)).clamp(0.8, 1.0);
              bool isSelected = selectedIndex == index;

              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(horizontal: tablet ? 15 : 10),
                  transform: Matrix4.identity()..scale(scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 15),
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          images[index],
                          fit: BoxFit.cover,
                        ),
                        // Dashboard Skeleton Overlay
                        _buildDashboardSkeleton(tablet),
                        if (!isSelected)
                          Container(color: Colors.white.withValues(alpha: 0.4)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        _buildUseButton(
          label: "Use as Background".tr,
          onPressed: () {
            Get.find<backgroundController>().saveUserBackground(
              isColor: false, 
              source: images[selectedIndex]
            );
            Get.back();
          },
        ),
        SizedBox(height: tablet ? 60 : 40),
      ],
    );
  }

  Widget _buildDashboardSkeleton(bool tablet) {
    return Padding(
      padding: EdgeInsets.all(tablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock App Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: tablet ? 50 : 40, height: tablet ? 50 : 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle)),
              Container(width: tablet ? 150 : 100, height: tablet ? 24 : 20, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10))),
              Container(width: tablet ? 50 : 40, height: tablet ? 50 : 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle)),
            ],
          ),
          SizedBox(height: tablet ? 40 : 30),
          // Mock Glass Card
          Container(
            width: double.infinity,
            height: tablet ? 180 : 140,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
            ),
            padding: EdgeInsets.all(tablet ? 20 : 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 80, height: 15, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 10),
                Container(width: 150, height: 30, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(10))),
              ],
            ),
          ),
          SizedBox(height: tablet ? 30 : 20),
          // Mock List Items
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Container(
                  width: double.infinity,
                  height: tablet ? 80 : 65,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), shape: BoxShape.circle)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6))),
                            const SizedBox(height: 8),
                            Container(width: 60, height: 10, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(5))),
                          ],
                        ),
                      ),
                      Container(width: 50, height: 12, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6))),
                      const SizedBox(width: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildUseButton({required String label, required VoidCallback onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),
  );
}