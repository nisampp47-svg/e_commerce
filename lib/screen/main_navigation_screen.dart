import 'package:e_commerce/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_viewmodel.dart';
import 'Catelog_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key, required Null Function() onTap});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationViewmodel>(context);

    final List<Widget> screens = [
      MyHomeScreen(categories: [], products: []),
      CatalogScreen(),
       CartScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: screens[navProvider.selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.selectedIndex,
        onTap: (index) {
          navProvider.changeTab(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_mosaic_outlined),
            label: "Catalog",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
