import 'package:emoapp/view_model/mindmap_view_model.dart';
import 'package:emoapp/widgets/mindmap/edit_idea_dialog.dart';
import 'package:emoapp/widgets/mindmap/idea_list_view.dart';
import 'package:emoapp/widgets/mindmap/mindmap_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Main screen for the collaborative mindmap feature
class MindmapScreen extends StatefulWidget {
  const MindmapScreen({
    Key? key,
    this.currentUserUuid,
  }) : super(key: key);

  final String? currentUserUuid;

  @override
  State<MindmapScreen> createState() => _MindmapScreenState();
}

class _MindmapScreenState extends State<MindmapScreen> {
  bool _showListView = false;
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();
    // Load ideas when screen initializes
    Future.microtask(() {
      context.read<MindmapViewModel>().loadIdeas(
            ownerUuid: widget.currentUserUuid,
          );
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MindmapViewModel>(
      builder: (context, viewModel, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Collaborative Mindmap'),
          elevation: 0,
          actions: [
            // Toggle view button
            IconButton(
              icon: Icon(
                _showListView ? Icons.map : Icons.list,
              ),
              tooltip: _showListView ? 'Show Mindmap' : 'Show List',
              onPressed: () {
                setState(() {
                  _showListView = !_showListView;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: !_showListView
            ? FloatingActionButton.extended(
                onPressed: () {
                  // Show dialog to create new idea at center
                  _showCreateIdeaDialog(context, viewModel,
                      quadrantCenter: viewModel.lastQuadrantCenter);
                },
                icon: const Icon(Icons.add),
                label: const Text('New Idea'),
              )
            : null,
        body: _showListView
            ? IdeaListView(
                currentUserUuid: widget.currentUserUuid,
              )
            : Stack(
                children: [
                  // Mindmap view
                  MindmapView(
                    ownerUuid: widget.currentUserUuid ?? '',
                    onCreateIdea: (x, y, quadrantCenter) async {
                      _showCreateIdeaDialog(context, viewModel,
                          x: x, y: y, quadrantCenter: quadrantCenter);
                    },
                  ),
                  // Edit dialog if in editing mode
                  if (viewModel.isEditingIdea && viewModel.selectedIdea != null)
                    GestureDetector(
                      onTap: () {
                        viewModel.stopEditing();
                        viewModel.deselectIdea();
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {},
                            child: RepaintBoundary(
                              child: EditIdeaDialog(
                                key: ValueKey(viewModel.selectedIdea!.id),
                                idea: viewModel.selectedIdea!,
                                currentUserUuid: widget.currentUserUuid,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _showCreateIdeaDialog(
    BuildContext context,
    MindmapViewModel viewModel, {
    double? x,
    double? y,
    Offset? quadrantCenter,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header with buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Create New Idea',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final idea = await viewModel.createIdea(
                        title: titleController.text.isEmpty
                            ? 'Untitled Idea'
                            : titleController.text,
                        content: contentController.text,
                        positionX: x ?? 0,
                        positionY: y ?? 0,
                        ownerUuid: widget.currentUserUuid ?? '',
                        currentQuadrantCenter: quadrantCenter,
                      );

                      // Clear controllers for next use
                      titleController.clear();
                      contentController.clear();

                      Navigator.pop(context);

                      // Show edit dialog for the new idea
                      // if (idea != null && mounted) {
                      //   await Future.delayed(const Duration(milliseconds: 300));
                      //   viewModel.selectIdea(idea);
                      //   viewModel.startEditing();
                      // }
                    },
                    child: const Text('Create'),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Idea title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        hintText: 'Idea description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
