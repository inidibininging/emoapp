import 'package:flutter_test/flutter_test.dart';
import 'package:emoapp/model/journal_entry_extended.dart';

void main() {
  test('JournalEntryExtended toJson/fromJson roundtrip', () {
    final entry = JournalEntryExtended(
      id: 'id-1',
      text: 'hello',
      timeStamp: DateTime.parse('2023-01-01T12:00:00.000Z'),
      emotionalLevel: 5,
      type: 1,
      discussionId: 'd1',
      topicId: 't1',
      calendarEntryId: 'c1',
      title: 'title',
      tags: ['a', 'b'],
      emotionIds: ['e1'],
    );

    final json = entry.toJson();
    final parsed = JournalEntryExtended.fromJson(json);

    expect(parsed.id, entry.id);
    expect(parsed.text, entry.text);
    expect(parsed.title, entry.title);
    expect(parsed.tags, entry.tags);
    expect(parsed.emotionIds, entry.emotionIds);
    expect(parsed.timeStamp.toUtc(), entry.timeStamp.toUtc());
    expect(parsed.emotionalLevel, entry.emotionalLevel);
    expect(parsed.type, entry.type);
    expect(parsed.calendarEntryId, entry.calendarEntryId);
    expect(parsed.discussionId, entry.discussionId);
    expect(parsed.topicId, entry.topicId);
  });
}
