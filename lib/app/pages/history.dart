import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

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
          dispose: (BuildContext context, FocusNode value) => value.dispose(),
        ),
        ListenableProvider<TextEditingController>(
          create: (BuildContext context) => TextEditingController(text: text),
          dispose: (BuildContext context, TextEditingController value) => value.dispose(),
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
    final TextEditingController controller = Provider.of<TextEditingController>(context, listen: false);
    final FocusNode focusNode = Provider.of<FocusNode>(context, listen: false);
    return TextField(
      controller: controller,
      focusNode: focusNode,
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
    final TextEditingController controller = context.watch<TextEditingController>();
    final String text = controller.text;

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
