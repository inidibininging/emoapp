import 'package:emoapp/model/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class JournalTextWidget extends StatefulWidget {
  final JournalEntry journalEntry;

  const JournalTextWidget({Key? key, required this.journalEntry})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _JournalTextWidget();
}

class _JournalTextWidget extends State<JournalTextWidget> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _textEditingController,
        onChanged: (value) => widget.journalEntry.text = value,
        onSubmitted: (value) => widget.journalEntry.text = value,
      );
}
