import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigation({super.key, required this.currentIndex});

  void onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        return context.go('/home/0'); // Go to HomeView
      case 1:
        return context.go('/home/1'); // Go to CategoriesView
      case 2:
        return context.go('/home/2'); // Go to FavoritesView
      default:
        return context.go('/home/0'); // Go to HomeView
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      currentIndex: currentIndex,
      onTap: (value) => onItemTapped(context, value),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_max),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.label_outline_rounded),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline_rounded),
          label: 'Favorites',
        ),
      ],
    );
  }
}
