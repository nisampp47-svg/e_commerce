import 'package:flutter/material.dart';

class NavigationViewmodel extends ChangeNotifier{

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

void changeTab(int index) {
  _selectedIndex = index;
  notifyListeners();
}
}