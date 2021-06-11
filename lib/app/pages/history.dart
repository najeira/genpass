import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/providers.dart';

final _textEditingProvider =
    ChangeNotifierProvider.autoDispose<TextEditingController>((ref) {
  // read domain text when initializing
  final domain = ref.read(domainTextEditingProvider);
  return TextEditingController(text: domain.text);
});

final _filteredHistoryProvider = Provider.autoDispose<Iterable<String>>((ref) {
  final history = ref.watch(historyProvider);
  final text = ref.watch(_textEditingProvider);
  if (text.text.isEmpty) {
    return history.entries;
  } else {
    return history.entries.where((String entry) {
      return entry.contains(text.text);
    });
  }
});

class HistoryPage extends StatelessWidget {
  const HistoryPage._({
    Key? key,
  }) : super(key: key);

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
        title: Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.white,
          ),
          child: const _SearchTextField(),
        ),
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final text = watch(_textEditingProvider);
    return TextField(
      controller: text,
      decoration: const InputDecoration(
        hintText: "example.com",
      ),
      keyboardType: TextInputType.url,
      autofocus: false,
      autocorrect: false,
      cursorColor: Colors.white,
    );
  }
}

class _HistoryListView extends ConsumerWidget {
  const _HistoryListView({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final entries = watch(_filteredHistoryProvider);
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
          style: textTheme.bodyText2,
        ),
      ),
    );
  }
}
