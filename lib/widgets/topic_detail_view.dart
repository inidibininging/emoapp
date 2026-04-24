import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/model/journal_type.dart';
import 'package:emoapp/model/topic.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:emoapp/view_model/topic_detail_view_model.dart';
import 'package:emoapp/widgets/journal_card.dart';
import 'package:emoapp/widgets/journal_edit_card.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class TopicDetailView extends StatefulWidget {
  const TopicDetailView({required this.topic, Key? key}) : super(key: key);
  final Topic topic;

  @override
  State<TopicDetailView> createState() => _TopicDetailViewState();
}

class _TopicDetailViewState extends State<TopicDetailView> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _todoController = TextEditingController();
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic.title);
    _descriptionController =
        TextEditingController(text: widget.topic.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<TopicDetailViewModel>(
        create: (_) => TopicDetailViewModel(widget.topic),
        child: Consumer<TopicDetailViewModel>(
          builder: (context, viewModel, child) => Scaffold(
            appBar: AppBar(
              title: const Text('Topic Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    viewModel.title = _titleController.text;
                    viewModel.description = _descriptionController.text;
                    await viewModel.save();
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Topic?'),
                        content: const Text(
                          'This will delete the topic but not the associated journal entries.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await viewModel.delete();
                              if (mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Title',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Topic Color',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Colors.blue,
                                Colors.red,
                                Colors.green,
                                Colors.yellow,
                                Colors.purple,
                                Colors.orange,
                                Colors.pink,
                                Colors.teal,
                              ]
                                  .map((color) => GestureDetector(
                                        onTap: () {
                                          viewModel.color =
                                              '0x${color.toARGB32().toRadixString(16).toUpperCase()}';
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: color,
                                            border: Border.all(
                                              color: Color(int.parse(
                                                          viewModel.color)) ==
                                                      color
                                                  ? Colors.black
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sensitive Topic',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: viewModel.sensitiveTopic,
                            onChanged: (value) {
                              viewModel.sensitiveTopic = value;
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tags',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (viewModel.tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children:
                                  viewModel.tags.asMap().entries.map((entry) {
                                final tag = entry.value;
                                return Chip(
                                  label: Text(tag),
                                  onDeleted: () {
                                    viewModel.removeTag(tag);
                                  },
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagController,
                                  decoration: const InputDecoration(
                                    hintText: 'Add a tag...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (_tagController.text.isNotEmpty) {
                                    viewModel.addTag(_tagController.text);
                                    _tagController.clear();
                                  }
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Todos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _todoController,
                                  decoration: const InputDecoration(
                                    hintText: 'Add a todo...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (_todoController.text.isNotEmpty) {
                                    viewModel.addTodo(_todoController.text);
                                    _todoController.clear();
                                    setState(() {});
                                  }
                                },
                                child: const Icon(Icons.add),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (viewModel.todos.isNotEmpty)
                            Column(
                              children: viewModel.todos.map((todo) {
                                return CheckboxListTile(
                                  title: Text(
                                    todo.title,
                                    style: TextStyle(
                                      decoration: todo.isDone
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  value: todo.isDone,
                                  onChanged: (value) {
                                    viewModel.toggleTodo(todo.id);
                                    setState(() {});
                                  },
                                  secondary: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      viewModel.removeTodo(todo.id);
                                      setState(() {});
                                    },
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No todos yet'),
                            ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Associated Journal Entries',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final journalEntry = await GetIt.instance
                                      .get<JournalEntryExtendedService>()
                                      .createLocally(
                                    JournalType.entry.name,
                                    (
                                      'Start writing your amazing thoughts here',
                                      3
                                    ),
                                  );
                                  journalEntry.topicId = widget.topic.id;

                                  if (mounted) {
                                    await Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) => JournalEditCard(
                                          key: Key(journalEntry.id),
                                          journalEntry: journalEntry,
                                        ),
                                      ),
                                    )
                                        .then((_) {
                                      _refreshCounter++;
                                      setState(() {});
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Entry'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<JournalEntryExtended>>(
                            key: ValueKey(_refreshCounter),
                            future: viewModel.getAssociatedEntries(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final entries = snapshot.data ?? [];
                              if (entries.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                      'No journal entries linked to this topic'),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  return Dismissible(
                                    key: Key(entry.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (direction) async {
                                      await viewModel
                                          .deleteJournalEntry(entry.id);
                                      entries.removeAt(index);
                                      setState(() {});
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Journal entry deleted'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    child: JournalCard(
                                      journalEntry: entry,
                                    ),
                                  );
                                  // return Card(
                                  //   child: ListTile(
                                  //     title: Text(
                                  //       entry.title.isEmpty
                                  //           ? '(no title)'
                                  //           : entry.title,
                                  //       maxLines: 2,
                                  //       overflow: TextOverflow.ellipsis,
                                  //     ),
                                  //     subtitle: Text(
                                  //       '${DateFormat.yMd().format(entry.timeStamp)} - ${entry.text.length > 100 ? '${entry.text.substring(0, 100)}...' : entry.text}',
                                  //     ),
                                  //     onTap: () async {
                                  //       await Navigator.of(context)
                                  //           .push(
                                  //         MaterialPageRoute(
                                  //           builder: (context) =>
                                  //               JournalEditCard(
                                  //             key: Key(entry.id),
                                  //             journalEntry: entry,
                                  //           ),
                                  //         ),
                                  //       )
                                  //           .then((_) {
                                  //         setState(() {});
                                  //       });
                                  //     },
                                  //   ),
                                  // );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
