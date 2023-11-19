import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/providers.dart';

final _inputTextProvider = StateProvider<String>((ref) {
  return "";
});

final _filteredHistoryProvider = Provider.autoDispose<Iterable<String>>((ref) {
  final history = ref.watch(historyProvider);
  final text = ref.watch(_inputTextProvider);
  return history.when(
    data: (entries) {
      if (text.isEmpty) {
        return entries;
      }
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
    return Navigator.of(context).push<String>(
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
      body: _HistoryListView(
        onSelected: (String value) {
          Navigator.maybeOf(context)?.maybePop(value);
        },
      ),
    );
  }
}

class _SearchTextField extends ConsumerWidget {
  const _SearchTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domainText = ref.watch(domainInputTextProvider);
    return TextFormField(
      initialValue: domainText,
      decoration: const InputDecoration(
        hintText: "example.com",
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
        .read(_inputTextProvider.notifier)
        .state = value;
  }
}

class _HistoryListView extends ConsumerWidget {
  const _HistoryListView({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(_filteredHistoryProvider);
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildListTile(context, entries.elementAt(index));
      },
    );
  }

  Widget _buildListTile(BuildContext context, String value) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    return InkWell(
      key: ValueKey<String>(value),
      onTap: () {
        onSelected(value);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: Divider.createBorderSide(context),
          ),
        ),
        child: Text(
          value,
          style: textTheme.bodyMedium,
        ),
      ),
    );
  }
}
