import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genpass/app/gloabls.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyHistoryEntries = "historyEntries";

class History extends ChangeNotifier {
  History() {
    load();
  }

  final Set<String> entries = <String>{};

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void add(String entry) {
    entries.remove(entry);
    entries.add(entry);

    final overflow = entries.length - 100;
    for (var i = 0; i < overflow; i++) {
      entries.remove(entries.first);
    }

    notifyListeners();
  }

  void remove(String entry) {
    final removed = entries.remove(entry);
    if (removed) {
      notifyListeners();
    }
  }

  Future<void> load() {
    _isLoading = true;
    try {
      return _load();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getStringList(_keyHistoryEntries);
    if (value != null && value.isNotEmpty) {
      entries.addAll(value);
      notifyListeners();
    }
    log.config("histories is loaded ${entries.length}");
  }

  Future<void> save() async {
    final value = entries.toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyHistoryEntries, value);
    log.config("histories is saved ${entries.length}");
  }
}
