import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppPallete.backgroundColor,
        selectedItemColor: AppPallete.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: [
          _buildBottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.house),
            label: 'Acceuil',
            isSelected: navigationShell.currentIndex == 0,
          ),
          _buildBottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.dumbbell),
            label: 'Exercices',
            isSelected: navigationShell.currentIndex == 1,
          ),
          _buildBottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.layerGroup),
            label: 'Défis',
            isSelected: navigationShell.currentIndex == 2,
          ),
          _buildBottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.user),
            label: 'Compte',
            isSelected: navigationShell.currentIndex == 3,
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required FaIcon icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppPallete.primaryColor.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8.0),
          child: FaIcon(
            icon.icon,
            size: 18,
          )),
      label: label,
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so makes sure the last navigation state of the
    // Navigator for the branch is restored.
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
