import 'package:emoapp/model/topic.dart';
import 'package:emoapp/services/flat_file_service.dart';
import 'package:emoapp/view_model/topic_list_view_model.dart';
import 'package:emoapp/widgets/topic_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TopicListView extends StatefulWidget {
  const TopicListView({Key? key}) : super(key: key);

  @override
  State<TopicListView> createState() => _TopicListViewState();
}

class _TopicListViewState extends State<TopicListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<TopicListViewModel>(
        create: (_) => TopicListViewModel(),
        child: Consumer<TopicListViewModel>(
          builder: (context, viewModel, child) => Scaffold(
            appBar: AppBar(
              title: const Text('Topics'),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search topics...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Topic>>(
                    future: _searchQuery.isEmpty
                        ? viewModel.topics(null)
                        : viewModel.searchTopics(_searchQuery),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading topics'),
                        );
                      }
                      final topicsList = snapshot.data ?? [];
                      if (topicsList.isEmpty) {
                        return const Center(
                          child: Text('No topics found'),
                        );
                      }
                      return ListView.builder(
                        itemCount: topicsList.length,
                        itemBuilder: (context, index) {
                          final topic = topicsList[index];
                          final completedTodos =
                              topic.todos.where((t) => t.isDone).length;

                          return TopicWidget(
                              key: ValueKey(topic.id),
                              topic: topic,
                              completedTodos: completedTodos,
                              onTap: () async => await Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => TopicDetailView(
                                        topic: topic,
                                      ),
                                    ),
                                  )
                                      .then((_) {
                                    viewModel.refresh();
                                  }));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreateTopicDialog(context, viewModel),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

  void _showCreateTopicDialog(
      BuildContext context, TopicListViewModel viewModel) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final tagController = TextEditingController();
    List<String> tags = [];
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetAnimationDuration: Duration.zero,
        insetAnimationCurve: Curves.linear,
        child: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            appBar: AppBar(
              title: const Text('Create New Topic'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      final topicService =
                          GetIt.instance.get<FlatFileEntityService<Topic>>();
                      final newTopic = Topic(
                        id: '',
                        title: titleController.text,
                        description: descriptionController.text,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        tags: tags,
                        color:
                            '0x${selectedColor.toARGB32().toRadixString(16).toUpperCase()}',
                      );

                      try {
                        await topicService.create(
                          newTopic,
                          (t) => t.title.isNotEmpty
                              ? (true, null)
                              : (false, Exception('Title cannot be empty')),
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          viewModel.refresh();
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error creating topic: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title field
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Topic Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Description field
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    // Color picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Topic Color'),
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
                                        setState(() {
                                          selectedColor = color;
                                        });
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: color,
                                          border: Border.all(
                                            color: selectedColor == color
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tags section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tags (Optional)'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: tagController,
                                decoration: const InputDecoration(
                                  labelText: 'Add a tag',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final tag = tagController.text.trim();
                                if (tag.isNotEmpty && !tags.contains(tag)) {
                                  setState(() {
                                    tags.add(tag);
                                    tagController.clear();
                                  });
                                }
                              },
                              child: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags
                              .map((tag) => Chip(
                                    label: Text(tag),
                                    onDeleted: () {
                                      setState(() {
                                        tags.remove(tag);
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SensitiveTopicWidget extends StatelessWidget {
  const SensitiveTopicWidget({
    super.key,
    required this.topic,
    required this.completedTodos,
    this.onTap,
    this.onLongPress,
  });

  final Topic topic;
  final int completedTodos;
  final Function()? onTap;
  final Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ListTile(
        title: Text('This topic is marked as sensitive. Tap to view details.'),
        subtitle: Text(
          '(sensitive)',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            if (!topic.sensitiveTopic && topic.todos.isNotEmpty)
              Chip(
                label: Text('(sensitive)'),
              ),
            // if (!topic.sensitiveTopic && topic.tags.isNotEmpty)
            //   Chip(
            //     label: Text('${topic.tags.length} tags'),
            //   ),
            if (topic.color.isNotEmpty)
              Chip(
                  label: SizedBox.fromSize(
                    size: Size.square(32),
                  ),
                  // quite unsure if a neutral color like grey should be used for sensitive topics, but for now let's just keep the color.
                  // might review this in the future
                  backgroundColor: Color.fromARGB(
                      int.tryParse(topic.color.substring(2, 4), radix: 16)
                              ?.toSigned(8) ??
                          0,
                      int.tryParse(topic.color.substring(4, 6), radix: 16)
                              ?.toSigned(8) ??
                          0,
                      int.tryParse(topic.color.substring(6, 8), radix: 16)
                              ?.toSigned(8) ??
                          0,
                      int.tryParse(topic.color.substring(8, 10), radix: 16)
                              ?.toSigned(8) ??
                          0)),
          ],
        ),
      ),
    );
  }
}

class TopicWidget extends StatefulWidget {
  const TopicWidget({
    super.key,
    required this.topic,
    required this.completedTodos,
    this.onTap,
    this.onLongPress,
  });

  final Topic topic;
  final int completedTodos;
  final Function()? onTap;
  final Function()? onLongPress;

  @override
  State<TopicWidget> createState() => _TopicWidgetState();
}

class _TopicWidgetState extends State<TopicWidget> {
  bool hideSensitiveContent = true;

  @override
  void initState() {
    super.initState();
    hideSensitiveContent = !widget.topic.sensitiveTopic;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(widget.topic.id),
      onTap: widget.onTap,
      onLongPress: () {
        setState(() {
          hideSensitiveContent = !hideSensitiveContent;
        });

        widget.onLongPress?.call();
      },
      title: Text(!hideSensitiveContent
          ? 'This topic is marked as sensitive. Tap to view details.'
          : widget.topic.title),
      subtitle: Text(
        !hideSensitiveContent
            ? '(sensitive)'
            : '${widget.topic.description}\nCreated: ${DateFormat.yMd().format(widget.topic.createdAt)}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Wrap(
        spacing: 8,
        children: [
          if (!hideSensitiveContent && widget.topic.todos.isNotEmpty)
            Chip(
              label: Text(
                widget.topic.sensitiveTopic
                    ? '(sensitive)'
                    : '${widget.completedTodos}/${widget.topic.todos.length} todos',
              ),
            ),
          if (!hideSensitiveContent && widget.topic.tags.isNotEmpty)
            Chip(
              label: Text('${widget.topic.tags.length} tags'),
            ),
          if (widget.topic.color.isNotEmpty)
            Chip(
                label: SizedBox.fromSize(
                  size: Size.square(32),
                ),
                // quite unsure if a neutral color like grey should be used for sensitive topics, but for now let's just keep the color.
                // might review this in the future
                backgroundColor: Color.fromARGB(
                    int.tryParse(widget.topic.color.substring(2, 4), radix: 16)
                            ?.toSigned(8) ??
                        0,
                    int.tryParse(widget.topic.color.substring(4, 6), radix: 16)
                            ?.toSigned(8) ??
                        0,
                    int.tryParse(widget.topic.color.substring(6, 8), radix: 16)
                            ?.toSigned(8) ??
                        0,
                    int.tryParse(widget.topic.color.substring(8, 10), radix: 16)
                            ?.toSigned(8) ??
                        0)),
        ],
      ),
    );
  }
}
