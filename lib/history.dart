import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'main.dart';
import 'service.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({
    Key key,
    this.text,
    this.history,
  }) : super(key: key);

  final String text;

  final History history;

  @override
  Widget build(BuildContext context) {
    return _buildFocusNode(context);
  }

  Widget _buildFocusNode(BuildContext context) {
    return ChangeNotifierProvider<FocusNode>(
      builder: (BuildContext context) => FocusNode(),
      child: Consumer<FocusNode>(
        builder: (BuildContext context, FocusNode focusNode, Widget child) {
          return _buildTextNotifier(context, focusNode);
        },
      ),
    );
  }

  Widget _buildTextNotifier(BuildContext context, FocusNode focusNode) {
    return ChangeNotifierProvider<ValueNotifier<String>>(
      builder: (BuildContext context) => ValueNotifier<String>(text),
      child: Consumer<ValueNotifier<String>>(
        builder: (BuildContext context, ValueNotifier<String> textNotifier, Widget child) {
          return _buildScaffold(
            context,
            focusNode: focusNode,
            textNotifier: textNotifier,
          );
        },
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    FocusNode focusNode,
    ValueNotifier<String> textNotifier,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.white,
          ),
          child: _buildTextField(
            context,
            focusNode: focusNode,
            textNotifier: textNotifier,
          ),
        ),
      ),
      body: _HistoryListView(
        focusNode: focusNode,
        textNotifier: textNotifier,
        entries: history.entries,
        onSelected: (String value) => Navigator.of(context)?.maybePop(value),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    FocusNode focusNode,
    ValueNotifier<String> textNotifier,
    TextEditingController controller,
  }) {
    return ChangeNotifierProvider<TextEditingController>(
      builder: (BuildContext context) => TextEditingController(text: text),
      child: Consumer<TextEditingController>(
        builder: (BuildContext context, TextEditingController controller, Widget child) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: "example.com",
              hintStyle: TextStyle(
                fontSize: kFontSize,
              ),
            ),
            style: const TextStyle(
              fontSize: kFontSize,
            ),
            keyboardType: TextInputType.url,
            onChanged: (String value) => textNotifier.value = value,
            onSubmitted: (String value) => textNotifier.value = value,
            autofocus: false,
            autocorrect: false,
            cursorColor: Colors.white,
          );
        },
      ),
    );
  }
}

typedef _ValueSelected<T> = void Function(T value);

class _HistoryListView extends StatefulWidget {
  _HistoryListView({
    Key key,
    @required this.textNotifier,
    @required this.entries,
    @required this.onSelected,
    @required this.focusNode,
  }) : super(key: key);

  final ValueNotifier<String> textNotifier;

  final Iterable<String> entries;

  final _ValueSelected<String> onSelected;

  final FocusNode focusNode;

  @override
  _HistoryListViewState createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<_HistoryListView> {
  ScrollController _scrollController;

  @override
  void didChangeDependencies() {
    _scrollController?.removeListener(_onScroll);
    _scrollController = PrimaryScrollController.of(context);
    _scrollController?.addListener(_onScroll);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.textNotifier,
      builder: (BuildContext context, String value, Widget child) {
        Iterable<String> targets;
        if (value == null || value.isEmpty) {
          targets = widget.entries;
        } else {
          targets = widget.entries.where((String entry) {
            return entry.contains(value);
          });
        }
        return ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
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
          style: const TextStyle(
            fontSize: kFontSize,
          ),
        ),
      ),
    );
  }

  void _onScroll() {
    if (mounted) {
      widget.focusNode?.unfocus();
    }
  }
}
