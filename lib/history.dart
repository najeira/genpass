import 'package:flutter/material.dart';

import 'service.dart';

class HistoryPage extends StatefulWidget {
  final String text;
  final History history;

  HistoryPage({this.text, this.history});

  @override
  State<StatefulWidget> createState() {
    return HistoryPageState();
  }
}

class HistoryPageState extends State<HistoryPage> {
  final ValueNotifier<String> _textNotifier = ValueNotifier<String>(null);
  final List<String> entries = <String>[];

  final FocusNode _focusNode = FocusNode();

  TextEditingController _textEditingController;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController(text: widget.text);
    _textNotifier.value = widget.text;

    _scrollController = ScrollController();
    _scrollController.addListener(_onScrolled);

    if (widget.history != null) {
      entries.addAll(widget.history.entries);
    }
  }

  @override
  void dispose() {
    _textNotifier?.dispose();
    _focusNode?.dispose();
    _textEditingController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Theme(
          data: themeData.copyWith(
            //accentColor: Colors.white,
            primaryColor: Colors.white70,
            hintColor: Colors.white30,
          ),
          child: _buildTextField(context),
        ),
      ),
      body: _buildListView(context),
    );
  }

  Widget _buildItem(BuildContext context, String value) {
    return InkWell(
      onTap: () {
        _onItemPressed(value);
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
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    const double fontSize = 18.0;
    final ThemeData themeData = Theme.of(context);
    final TextStyle inputStyle = themeData.textTheme.subhead;
    return TextField(
      controller: _textEditingController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: "example.com",
        hintStyle: inputStyle.copyWith(
          color: Colors.white38,
          fontSize: fontSize,
        ),
      ),
      style: inputStyle.copyWith(
        color: Colors.white,
        fontSize: fontSize,
      ),
      keyboardType: TextInputType.url,
      onChanged: (String value) => _textNotifier.value = value,
      onSubmitted: (String value) => _textNotifier.value = value,
      autofocus: false,
      autocorrect: false,
      showCursor: true,
      cursorColor: Colors.white,
    );
  }

  Widget _buildListView(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _textNotifier,
      builder: (BuildContext context, String value, Widget child) {
        List<String> targets;
        if (value == null || value.isEmpty) {
          targets = entries;
        } else {
          targets = entries.where((String entry) {
            return entry.contains(value);
          }).toList();
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: targets.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildItem(context, targets[index]);
          },
        );
      },
    );
  }

  void _onItemPressed(String value) {
    Navigator.of(context)?.maybePop(value);
  }

  void _onScrolled() {
    _focusNode?.unfocus();
  }
}
