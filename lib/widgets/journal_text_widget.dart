import 'dart:ui';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:flutter/material.dart';

class JournalTextWidget extends StatefulWidget {
  const JournalTextWidget({required this.journalEntry, Key? key})
      : super(key: key);
  final JournalEntryExtended journalEntry;

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
        selectionHeightStyle: BoxHeightStyle.max,
        onChanged: (value) => widget.journalEntry.text = value,
        onSubmitted: (value) => widget.journalEntry.text = value,
      );
}
