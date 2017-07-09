import 'package:flutter/material.dart';

import 'service.dart';

class HistoryPage extends StatefulWidget {
  final String text;
  final History history;
  
  HistoryPage({this.text, this.history});
  
  @override
  State<StatefulWidget> createState() {
    return new HistoryPageState();
  }
}

class HistoryPageState extends State<HistoryPage> {
  FocusNode focusNode = new FocusNode();
  TextEditingController textEditingController;
  
  String searchText;
  
  final List<String> entries = <String>[];
  List<String> targets = <String>[];
  
  @override
  void initState() {
    super.initState();
    
    textEditingController = new TextEditingController(text: widget.text);
    
    if (widget.history != null) {
      widget.history.entries.forEach((String value){
        entries.add(value);
      });
    }
    
    onSearchTextChanged(widget.text);
  }
  
  @override
  Widget build(BuildContext context) {
    final String text = textEditingController.text;
    final bool hasText = text != null && text.isNotEmpty;
    
    final ThemeData themeData = Theme.of(context);
    final TextStyle inputStyle = themeData.textTheme.subhead;
    return new Scaffold(
      appBar: new AppBar(
        title: new Theme(
          data: themeData.copyWith(
            //accentColor: Colors.white,
            primaryColor: Colors.white70,
            hintColor: Colors.white30,
          ),
          child: new TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: new InputDecoration(
              //icon: new Icon(Icons.search),
              //hideDivider: true,
              hintText: "example.com",
              hintStyle: inputStyle.copyWith(
                color: Colors.white30,
                fontSize: 18.0,
              ),
            ),
            style: inputStyle.copyWith(
              color: focusNode.hasFocus ? Colors.white : Colors.white70,
              fontSize: 18.0,
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: onSearchTextChanged,
            //onSubmitted: (String value) {
            //  onSearchTextChanged(value);
            //},
            autofocus: !hasText,
          ),
        ),
      ),
      body: new ListView(
        children: new List.generate(targets.length, (int index) {
          return buildItem(context, targets[index]);
        }),
      ),
    );
  }
  
  Widget buildItem(BuildContext context, String value) {
    return new InkWell(
      onTap: () {
        onItemPressed(value);
      },
      child: new Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(
            color: Colors.grey[300],
          )),
        ),
        child: new Text(value, style: const TextStyle(
          fontSize: 18.0,
          //fontWeight: FontWeight.w500,
        )),
      ),
    );
  }
  
  void onItemPressed(String value) {
    Navigator.of(context)?.maybePop(value);
  }
  
  void onSearchTextChanged(String value) {
    searchText = value;
    
    if (value == null || value.isEmpty) {
      setState(() {
        targets = entries;
      });
      return;
    }
    
    var matches = entries.where((String entry) {
      if (entry.contains(value)) {
        return true;
      }
      return false;
    }).toList();
    
    if (targets.length == matches.length) {
      return;
    }
    
    setState(() {
      targets = matches;
    });
  }
}