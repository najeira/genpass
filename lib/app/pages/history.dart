import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/providers.dart';

final _filterTextProvider = StateProvider.autoDispose<String>((ref) {
  final text = ref.watch(domainInputTextProvider);
  log.fine("_filterTextProvider: ${text}");
  return text;
});

final _filteredHistoryProvider = Provider.autoDispose<Iterable<String>>((ref) {
  final history = ref.watch(historyProvider);
  final text = ref.watch(_filterTextProvider);
  return history.when(
    data: (entries) {
      if (text.isEmpty) {
        return entries;
      }
      log.fine("_filteredHistoryProvider: ${text}");
      return entries.where((String entry) {
        return entry.contains(text);
      });
    },
    error: (_, __) => <String>{},
    loading: () => <String>{},
  );
});

class HistoryPage extends StatelessWidget {
  const HistoryPage._({
    super.key,
  });

  static Future<String?> push(BuildContext context) {
    return Navigator.of(context).push<String?>(
      MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return const HistoryPage._();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _SearchTextField(),
      ),
      body: const _HistoryListView(),
    );
  }
}

class _SearchTextField extends ConsumerWidget {
  const _SearchTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domainText = ref.watch(_filterTextProvider);
    return TextFormField(
      initialValue: domainText,
      decoration: const InputDecoration(
        // icon: Icon(Icons.filter_alt_outlined),
        hintText: "example.com",
        filled: true,
        // suffixIcon: Icon(Icons.filter_alt_outlined),
      ),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.search,
      autofocus: false,
      autocorrect: false,
      enableSuggestions: true,
      onChanged: (value) => _onChanged(context, value),
      onFieldSubmitted: (value) => _onChanged(context, value),
    );
  }

  void _onChanged(BuildContext context, String value) {
    ProviderScope.containerOf(context, listen: false)
        .read(_filterTextProvider.notifier)
        .state = value;
  }
}

class _HistoryListView extends ConsumerWidget {
  const _HistoryListView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(_filteredHistoryProvider);
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) =>
          _ListTile(entries.elementAt(index)),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile(
    this.value, {
    super.key,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey<String>(value),
      onTap: () => Navigator.of(context).pop(value),
      title: Text(value),
      leading: const Icon(Icons.business),
      shape: Border(
        bottom: Divider.createBorderSide(context),
      ),
    );
  }
}
