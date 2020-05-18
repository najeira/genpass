import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/domain/history.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({
    Key key,
    this.text,
    this.history,
  }) : super(key: key);

  final String text;

  final History history;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<FocusNode>(
          create: (BuildContext context) => FocusNode(),
        ),
        ChangeNotifierProvider<ValueNotifier<String>>(
          create: (BuildContext context) => ValueNotifier<String>(null),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) => _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.white,
          ),
          child: _buildTextField(context),
        ),
      ),
      body: _HistoryListView(
        entries: history.entries,
        onSelected: (String value) => Navigator.of(context)?.maybePop(value),
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return ListenableProvider<TextEditingController>(
      create: (BuildContext context) {
        final String value = Provider.of<ValueNotifier<String>>(context, listen: false).value;
        return TextEditingController(text: value);
      },
      child: Consumer2<TextEditingController, FocusNode>(
        builder: (
          BuildContext context,
          TextEditingController controller,
          FocusNode focusNode,
          Widget child,
        ) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: "example.com",
            ),
            keyboardType: TextInputType.url,
            onChanged: (String value) => _onTextChanged(context, value),
            onSubmitted: (String value) => _onTextChanged(context, value),
            autofocus: false,
            autocorrect: false,
            cursorColor: Colors.white,
          );
        },
      ),
    );
  }

  void _onTextChanged(BuildContext context, String value) {
    Provider.of<ValueNotifier<String>>(context, listen: false)?.value = value;
  }
}

typedef _ValueSelected<T> = void Function(T value);

class _HistoryListView extends StatefulWidget {
  const _HistoryListView({
    Key key,
    @required this.entries,
    @required this.onSelected,
  }) : super(key: key);

  final Iterable<String> entries;

  final _ValueSelected<String> onSelected;

  @override
  _HistoryListViewState createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<_HistoryListView> {
  ScrollController _scrollController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController?.removeListener(_onScroll);
    _scrollController = PrimaryScrollController.of(context);
    _scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ValueNotifier<String>>(
      builder: (
        BuildContext context,
        ValueNotifier<String> textNotifier,
        Widget child,
      ) {
        final String text = textNotifier.value;

        Iterable<String> targets;
        if (text == null || text.isEmpty) {
          targets = widget.entries;
        } else {
          targets = widget.entries.where((String entry) {
            return entry.contains(text);
          });
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: targets.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(context, targets.elementAt(index));
          },
        );
      },
    );
  }

  Widget _buildListTile(BuildContext context, String value) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    return InkWell(
      key: ValueKey<String>(value),
      onTap: () {
        widget.onSelected?.call(value);
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

  void _onScroll() {
    if (mounted) {
      Provider.of<FocusNode>(context, listen: false)?.unfocus();
    }
  }
}
