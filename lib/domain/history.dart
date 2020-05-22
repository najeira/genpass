import 'dart:async';
import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';

const String _keyHistoryEntries = "historyEntries";

class History {
  final Set<String> entries = LinkedHashSet<String>();

  History.list(List<String> value) {
    if (value != null && value.isNotEmpty) {
      entries.addAll(value);
    }
  }

  void add(String entry) {
    entries.remove(entry);
    entries.add(entry);

    final int overflow = (entries.length - 100);
    for (int i = 0; i < overflow; i++) {
      entries.remove(entries.first);
    }
  }

  void remove(String entry) {
    entries.remove(entry);
  }

  static Future<History> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> value = prefs.getStringList(_keyHistoryEntries);
    return History.list(value);
  }

  Future<void> save() async {
    final List<String> value = entries.toList();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyHistoryEntries, value);
  }
}
