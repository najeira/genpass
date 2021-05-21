import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String _keyHistoryEntries = "historyEntries";

class History {
  History.list(List<String>? value) {
    if (value != null && value.isNotEmpty) {
      entries.addAll(value);
    }
  }

  final Set<String> entries = <String>{};

  void add(String entry) {
    entries.remove(entry);
    entries.add(entry);

    final overflow = entries.length - 100;
    for (var i = 0; i < overflow; i++) {
      entries.remove(entries.first);
    }
  }

  void remove(String entry) {
    entries.remove(entry);
  }

  static Future<History> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getStringList(_keyHistoryEntries);
    return History.list(value);
  }

  Future<void> save() async {
    final value = entries.toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyHistoryEntries, value);
  }
}
