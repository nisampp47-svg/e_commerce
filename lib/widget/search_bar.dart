import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';

class MySearchBar extends StatefulWidget {
  final IconData? icon;
  final VoidCallback? onIconTap;

  const MySearchBar({super.key, required this.icon, this.onIconTap});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize controller with current provider query
    final initialQuery = context.read<SearchProvider>().query;
    _controller = TextEditingController(text: initialQuery);
    
    // Ensure cursor is at the end
    if (initialQuery.isNotEmpty) {
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: initialQuery.length),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync controller if query changes externally (e.g. cleared from another widget)
    final providerQuery = context.watch<SearchProvider>().query;
    if (_controller.text != providerQuery) {
      _controller.text = providerQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: providerQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Optimized selections: only rebuild when these specific booleans change
    final isLoading = context.select<SearchProvider, bool>((p) => p.isLoading);
    final hasQuery = context.select<SearchProvider, bool>((p) => p.query.isNotEmpty);

    return SizedBox(
      height: 55,
      child: Row(
        children: [
          /// 🔍 Search Field
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.start,
                style: theme.textTheme.bodyLarge,
                onChanged: (value) =>
                    context.read<SearchProvider>().onSearchChanged(value),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: theme.colorScheme.primary),
                  hintText: "Search furniture, brands...",
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  suffixIcon: isLoading
                      ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                      : hasQuery
                      ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _controller.clear();
                      context.read<SearchProvider>().clearSearch();
                      FocusScope.of(context).unfocus();
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          /// 🔔 Action Button
          GestureDetector(
            onTap: widget.onIconTap,
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
