import 'dart:async';
import 'package:flutter/material.dart';
import '../../model/product_model.dart';
import '../data/repositories/product_data.dart';

enum SearchState { idle, loading, success, empty, error }

class SearchProvider extends ChangeNotifier {
  // ─── State ────────────────────────────────────────────────────────────────
  SearchState _state = SearchState.idle;
  List<ProductModel> _results = [];
  String _query = '';
  String _errorMessage = '';

  Timer? _debounceTimer;

  // ─── Getters ──────────────────────────────────────────────────────────────
  SearchState get state => _state;
  List<ProductModel> get results => List.unmodifiable(_results);
  String get query => _query;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == SearchState.loading;

  // ─── Public: called from TextField.onChanged ──────────────────────────────
  void onSearchChanged(String value) {
    if (_query == value) return; // Skip if no real change

    final oldTrimmed = _query.trim();
    _query = value;
    final newTrimmed = _query.trim();

    _debounceTimer?.cancel();

    if (newTrimmed.isEmpty) {
      _results = [];
      _updateState(SearchState.idle);
      return;
    }

    // Only trigger loading state and timer if the actual search term changed
    if (oldTrimmed != newTrimmed) {
      _updateState(SearchState.loading);
      _debounceTimer = Timer(const Duration(milliseconds: 400), _runSearch);
    } else {
      // If only spaces changed, just notify listeners (for UI like the 'X' button)
      notifyListeners();
    }
  }

  // ─── Internal: local filter (no async needed for in-memory data) ──────────
  void _runSearch() {
    try {
      final q = _query.trim().toLowerCase();

      if (q.isEmpty) {
        _results = [];
        _updateState(SearchState.idle);
        return;
      }

      final matched = products.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.categoryId.toLowerCase().contains(q);
      }).toList();

      _results = matched;
      _updateState(matched.isEmpty ? SearchState.empty : SearchState.success);
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _updateState(SearchState.error);
    }
  }

  // ─── Clear ─────────────────────────────────────────────────────────────────
  void clearSearch() {
    _debounceTimer?.cancel();
    _query = '';
    _results = [];
    _updateState(SearchState.idle);
  }

  void _updateState(SearchState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}