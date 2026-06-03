import 'package:flutter/material.dart';
import 'package:e_commerce/model/category_model.dart';

const List<CategoryModel> dummyCategories = [
  CategoryModel(
    categoryId: 'sofa',
    categoryTitle: 'Sofas',
    icon: Icons.weekend,
  ),
  CategoryModel(
    categoryId: 'chair',
    categoryTitle: 'Chairs',
    icon: Icons.chair,
  ),
  CategoryModel(
    categoryId: 'table',
    categoryTitle: 'Table',
    icon: Icons.table_restaurant,
  ),
  CategoryModel(
    categoryId: 'bed',
    categoryTitle: 'Beds',
    icon: Icons.bed,
  ),
  CategoryModel(
    categoryId: 'all',
    categoryTitle: 'All',
    icon: Icons.grid_view_rounded,
  ),
];
