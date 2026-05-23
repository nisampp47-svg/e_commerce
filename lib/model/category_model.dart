
import 'package:flutter/material.dart';

class CategoryModel {
  final String categoryId;
  final String categoryTitle;
  final String? image;
  final String? productCount;
  final IconData? icon;

  const CategoryModel({
    required this.categoryId,
    required this.categoryTitle,
      this.image,
      this.productCount,
    this.icon,
  });
}
