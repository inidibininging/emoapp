import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/widgets/journal_entry_stats.dart';
import 'package:chart_sparkline/chart_sparkline.dart';

void main() {
  testWidgets('JournalEntryStats builds and shows Sparkline', (tester) async {
    final entries = List<JournalEntryExtended>.generate(
      5,
      (i) => JournalEntryExtended(
        id: 'id-$i',
        text: 't$i',
        timeStamp: DateTime.now(),
        emotionalLevel: i * 2,
        type: 1,
        discussionId: 'd',
      ),
    );

    await tester.pumpWidget(MaterialApp(home: JournalEntryStats(entries: entries)));
    await tester.pumpAndSettle();

    expect(find.byType(JournalEntryStats), findsOneWidget);
    expect(find.byType(Sparkline), findsOneWidget);
  });
}
