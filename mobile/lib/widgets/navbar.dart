import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/theme/app_colors.dart';

class CustomNavigationBar extends StatefulWidget {
  final String currentPath;
  final Function(String) onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentPath,
    required this.onTap,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Define navigation paths
  static const List<String> navigationPaths = [
    AppRoutes.home,
    AppRoutes.cart,
    AppRoutes.scan,
    AppRoutes.orderHistory,
    AppRoutes.profile,
  ];

  // Define icons for each path
  static const List<String> navigationIcons = [
    'lib/icons/home.svg',
    'lib/icons/cart.svg',
    'lib/icons/scan.svg',
    'lib/icons/history.svg',
    'lib/icons/user.svg',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Register as a listener for path changes
    AppRoutes.addPathChangeListener(_onPathChanged);

    _updateSelectedIndex();
    _animationController.forward();
  }

  // Callback for path changes
  void _onPathChanged(String newPath) {
    if (mounted) {
      setState(() {
        // Update the widget's currentPath if needed
        // For login page, we still want to update even though it's not in navigationPaths
        if (widget.currentPath != newPath &&
            (navigationPaths.contains(newPath) || newPath == AppRoutes.login)) {
          _updateSelectedIndexForPath(newPath);
        }
      });
    }
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    AppRoutes.removePathChangeListener(_onPathChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected index when widget gets new props
    if (oldWidget.currentPath != widget.currentPath) {
      _updateSelectedIndex();
    }
  }

  void _updateSelectedIndex() {
    _updateSelectedIndexForPath(widget.currentPath);
  }

  void _updateSelectedIndexForPath(String path) {
    // Special case: if path is login, select the profile tab (index 4)
    int index;
    if (path == AppRoutes.login) {
      index = navigationPaths.indexOf(AppRoutes.profile);
    } else {
      index = navigationPaths.indexOf(path);
    }

    final newIndex = index >= 0 ? index : 0;

    if (_selectedIndex != newIndex) {
      _animationController.reset();
      setState(() {
        _previousIndex = _selectedIndex;
        _selectedIndex = newIndex;
      });
      _animationController.forward();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check current route from AppRoutes to ensure navbar stays in sync
    // with navigation that happens outside the navbar
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != null) {
      int index;

      // Special case: if route is login, select the profile tab
      if (currentRoute == AppRoutes.login) {
        index = navigationPaths.indexOf(AppRoutes.profile);
      } else if (navigationPaths.contains(currentRoute)) {
        index = navigationPaths.indexOf(currentRoute);
      } else {
        return; // Skip for other routes not in navigationPaths
      }

      if (_selectedIndex != index) {
        _animationController.reset();
        setState(() {
          _previousIndex = _selectedIndex;
          _selectedIndex = index;
        });
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Stack(
          children: [
            // Navigation bar
            NavigationBar(
              onDestinationSelected: (int index) {
                // Skip if already on the selected page
                if (_selectedIndex == index) {
                  return;
                }

                // Reset animation and update state for sliding effect
                _animationController.reset();
                setState(() {
                  _previousIndex = _selectedIndex;
                  _selectedIndex = index;
                });
                _animationController.forward();

                widget.onTap(navigationPaths[index]);
              },
              backgroundColor: AppColors.background,
              indicatorColor: Colors.transparent,
              height: 80,
              elevation: 0,
              selectedIndex: _selectedIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: List.generate(
                navigationPaths.length,
                (index) =>
                    index == 2
                        ? _buildScanDestination(index, _selectedIndex)
                        : _buildNavDestination(index, _selectedIndex),
              ),
            ),

            // Sliding indicator that moves between icons
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 10,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // Calculate the positions more accurately
                  double screenWidth = MediaQuery.of(context).size.width;
                  double itemWidth = screenWidth / 5; // Width per item

                  // Calculate positions for all items
                  List<double> positions = [
                    itemWidth * 0.5, // Home
                    itemWidth * 1.5, // Cart
                    itemWidth * 2.5, // Scan
                    itemWidth * 3.5, // History
                    itemWidth * 4.5, // Profile
                  ];

                  // Get starting and ending positions
                  double startX = positions[_previousIndex] - 15;
                  double endX = positions[_selectedIndex] - 15;

                  // Interpolate between positions based on animation value
                  double currentX = startX + (endX - startX) * _animation.value;

                  return Padding(
                    padding: EdgeInsets.only(
                      left: currentX,
                      right: screenWidth - currentX - 32,
                    ),
                    child: Container(
                      height: 3,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination(int index, int selectedIndex) {
    bool isSelected = index == selectedIndex;

    return NavigationDestination(
      icon: SizedBox(
        width: 44, // Fixed width for consistent positioning
        height: 44, // Fixed height
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                navigationIcons[index],
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : const Color(0xFF888888),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
      label: '', // Empty label but needed
    );
  }

  NavigationDestination _buildScanDestination(int index, int selectedIndex) {
    bool isSelected = index == selectedIndex;

    return NavigationDestination(
      icon: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(bottom: 0, top: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isSelected
                    ? [Colors.white, Colors.white]
                    : [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.elliptical(15, 15)),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? Colors.white.withAlpha(90)
                      : Colors.black54.withAlpha(80),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            navigationIcons[index],
            width: 30,
            height: 30,
            colorFilter: ColorFilter.mode(
              isSelected ? const Color(0xFF121212) : Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      label: '',
    );
  }
}
