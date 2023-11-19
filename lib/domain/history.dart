import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genpass/app/gloabls.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyHistoryEntries = "historyEntries";

class History extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() => _load();

  Set<String>? get _entries => state.unwrapPrevious().valueOrNull; 

  Future<void> add(String entry) {
    var entries = _entries;
    if (entries != null) {
      entries.remove(entry);
      entries.add(entry);
    } else {
      entries = <String>{entry};
    }

    final overflow = entries.length - 100;
    for (var i = 0; i < overflow; i++) {
      entries.remove(entries.first);
    }

    state = AsyncValue.data(entries);
    return _save();
  }

  Future<void> remove(String entry) async {
    final entries = _entries;
    if (entries != null) {
      final removed = entries.remove(entry);
      if (removed) {
        state = AsyncValue.data(entries);
        await _save();
      }
    }
  }

  Future<Set<String>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getStringList(_keyHistoryEntries);
    log.config("histories is loaded ${value?.length}");
    return value?.toSet() ?? <String>{};
  }

  Future<void> _save() async {
    final entries = _entries;
    if (entries == null) {
      return;
    }
    final value = entries.toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyHistoryEntries, value);
    log.config("histories is saved ${entries.length}");
  }
}
