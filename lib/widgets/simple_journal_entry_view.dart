import 'package:emoapp/model/emotion.dart';
import 'package:emoapp/model/journal_colors.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/model/journal_type.dart';
import 'package:emoapp/model/topic.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:emoapp/services/flat_file_service.dart';
import 'package:emoapp/view_model/emotion_selection_view_model.dart';
import 'package:emoapp/widgets/emotion_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// A simple, quick journal entry creation view
/// Just emotions + message, minimal UI
class SimpleJournalEntryView extends StatefulWidget {
  const SimpleJournalEntryView({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  final DateTime selectedDate;

  @override
  State<SimpleJournalEntryView> createState() => _SimpleJournalEntryViewState();
}

class _SimpleJournalEntryViewState extends State<SimpleJournalEntryView> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _selectedEmotionIds = [];
  String _selectedTopicId = '';
  List<Topic> _availableTopics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final service = GetIt.instance.get<FlatFileEntityService<Topic>>();
      final topics = await service.getAll();
      final topicsList = topics.toList();

      setState(() {
        _availableTopics = topicsList;
        // Pre-select the first topic
        if (topicsList.isNotEmpty) {
          _selectedTopicId = topicsList.first.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading topics: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _updateSelectedEmotions(List<String> emotionIds) {
    setState(() {
      _selectedEmotionIds.clear();
      _selectedEmotionIds.addAll(emotionIds);
    });
  }

  Future<void> _createEntry() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    try {
      // Create the journal entry
      final newEntry = JournalEntryExtended(
        id: const Uuid().v4(),
        text: message,
        timeStamp: widget.selectedDate,
        emotionalLevel: 3,
        type: JournalType.entry.index,
        discussionId: '',
        title: '',
        emotionIds: _selectedEmotionIds,
        topicId: _selectedTopicId,
      );

      // Save the entry
      final service = GetIt.instance.get<JournalEntryExtendedService>();
      await service.save(newEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry saved successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quick Entry')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Entry'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _createEntry,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date display
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(widget.selectedDate)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Topic selector
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Topic (Optional)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTopicId.isEmpty ? null : _selectedTopicId,
                    hint: const Text('Select a topic'),
                    items: _availableTopics.map((topic) {
                      return DropdownMenuItem<String>(
                        value: topic.id,
                        child: Text(topic.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTopicId = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // Emotion selector
            SizedBox(
              height: 200,
              child: EmotionSelector(
                onEmotionsSelected: _updateSelectedEmotions,
                initialEmotionIds: _selectedEmotionIds,
              ),
            ),

            const Divider(),

            // Message input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What\'s on your mind?',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton.icon(
                  //     onPressed: _createEntry,
                  //     icon: const Icon(Icons.check),
                  //     label: const Padding(
                  //       padding: EdgeInsets.symmetric(vertical: 12.0),
                  //       child: Text('Save Entry'),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: JournalColors.entry.value,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class to provide default emotions in simple view
class DefaultEmotions {
  static List<String> getClusters() {
    return [
      'joy',
      'sadness',
      'anger',
      'fear',
      'disgust',
      'guilt',
      'surprise',
      'love',
      'neutral',
      'pride',
      'excitement',
    ];
  }

  static List<Emotion> getEmotionsByCluster(String cluster) {
    return _getEmotions().where((e) => e.clusterGroup == cluster).toList();
  }

  static List<Emotion> _getEmotions() {
    return [
      Emotion(
        id: 'joy_happy',
        emoji: '😊',
        name: 'Happy',
        clusterGroup: 'joy',
        value: 8,
      ),
      Emotion(
        id: 'sadness_sad',
        emoji: '😢',
        name: 'Sad',
        clusterGroup: 'sadness',
        value: 8,
      ),
      Emotion(
        id: 'anger_angry',
        emoji: '😡',
        name: 'Angry',
        clusterGroup: 'anger',
        value: 8,
      ),
      Emotion(
        id: 'fear_anxious',
        emoji: '😰',
        name: 'Anxious',
        clusterGroup: 'fear',
        value: 7,
      ),
      Emotion(
        id: 'disgust_disgusted',
        emoji: '🤮',
        name: 'Disgusted',
        clusterGroup: 'disgust',
        value: 8,
      ),
      Emotion(
        id: 'guilt_guilty',
        emoji: '😔',
        name: 'Guilty',
        clusterGroup: 'guilt',
        value: 8,
      ),
      Emotion(
        id: 'surprise_surprised',
        emoji: '😲',
        name: 'Surprised',
        clusterGroup: 'surprise',
        value: 6,
      ),
      Emotion(
        id: 'love_loving',
        emoji: '😍',
        name: 'Loving',
        clusterGroup: 'love',
        value: 9,
      ),
      Emotion(
        id: 'neutral_calm',
        emoji: '😐',
        name: 'Calm',
        clusterGroup: 'neutral',
        value: 5,
      ),
      Emotion(
        id: 'pride_proud',
        emoji: '😌',
        name: 'Proud',
        clusterGroup: 'pride',
        value: 8,
      ),
      Emotion(
        id: 'excitement_excited',
        emoji: '🎉',
        name: 'Excited',
        clusterGroup: 'excitement',
        value: 8,
      ),
    ];
  }
}
