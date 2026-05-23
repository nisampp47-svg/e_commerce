import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final IconData? icon;

  const MySearchBar({super.key,required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        children: [
          /// 🔍 Search Field
          Expanded(
            child: Center(
              child: Container(
                alignment: Alignment.center,
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha(180),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const TextField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: Colors.deepPurple,
                    ),
                    hintText: "Search furniture, brands...",
                    border: InputBorder.none,
                    isCollapsed: true
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          /// 🔔 Notification Button
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child:  Icon(
              icon,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}
