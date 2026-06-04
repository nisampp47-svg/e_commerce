import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../../model/product_model.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    if (provider.state == SearchState.idle) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: _buildContent(context, provider),
    );
  }

  Widget _buildContent(BuildContext context, SearchProvider provider) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildStateContent(context, provider),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, SearchProvider provider) {
    final theme = Theme.of(context);

    // If we are loading but already have results, keep showing results
    // This prevents the UI from "jumping" to a big spinner on every keystroke
    if (provider.state == SearchState.loading && provider.results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return switch (provider.state) {
      // ── Empty ────────────────────────────────────────────────────────
      SearchState.empty => Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off,
                  size: 44,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                'No results for "${provider.query}"',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),

      // ── Error ────────────────────────────────────────────────────────
      SearchState.error => Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  provider.errorMessage,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        ),

      // ── Results (Success OR Loading with existing results) ────────────
      SearchState.success || SearchState.loading => ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: provider.results.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 72,
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
          itemBuilder: (context, index) {
            final product = provider.results[index];
            return _ProductResultTile(
              product: product,
              query: provider.query,
            );
          },
        ),

      // Catch-all
      _ => const SizedBox.shrink(),
    };
  }
}

// ─── Individual result tile ─────────────────────────────────────────────────
class _ProductResultTile extends StatelessWidget {
  final ProductModel product;
  final String query;

  const _ProductResultTile({required this.product, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/${product.image}',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          // Graceful fallback if asset isn't found
          errorBuilder: (_, __, ___) => Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.chair_alt,
                color: theme.colorScheme.primary, size: 24),
          ),
        ),
      ),
      title: _HighlightedText(
        text: product.name,
        query: query,
        style: theme.textTheme.bodyMedium!
            .copyWith(fontWeight: FontWeight.w600),
        highlightColor: theme.colorScheme.primary,
      ),
      subtitle: Row(
        children: [
          Icon(Icons.star_rounded,
              size: 14, color: Colors.amber.shade600),
          const SizedBox(width: 3),
          Text(
            product.rating.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer
                  .withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              product.categoryId,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
      trailing: Text(
        '\$${product.price.toStringAsFixed(2)}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      onTap: () {
        context.pushNamed(
          'product_detail',
          pathParameters: {'id': product.id},
          extra: product,
        );
      },
    );
  }
}

// ─── Highlighted match text ─────────────────────────────────────────────────
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return Text(text, style: style);

    final lower = text.toLowerCase();
    final start = lower.indexOf(trimmedQuery.toLowerCase());
    if (start == -1) return Text(text, style: style);

    final end = start + trimmedQuery.length;

    return Text.rich(TextSpan(children: [
      if (start > 0)
        TextSpan(text: text.substring(0, start), style: style),
      TextSpan(
        text: text.substring(start, end),
        style: style.copyWith(
          color: highlightColor,
          backgroundColor: highlightColor.withValues(alpha: 0.12),
        ),
      ),
      if (end < text.length)
        TextSpan(text: text.substring(end), style: style),
    ]));
  }
}