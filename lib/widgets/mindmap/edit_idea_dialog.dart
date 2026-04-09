import 'package:emoapp/model/idea.dart';
import 'package:emoapp/model/reference.dart';
import 'package:emoapp/view_model/mindmap_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Dialog for editing an idea with all its properties
class EditIdeaDialog extends StatefulWidget {
  const EditIdeaDialog({
    Key? key,
    required this.idea,
    this.currentUserUuid,
  }) : super(key: key);

  final Idea idea;
  final String? currentUserUuid;

  @override
  State<EditIdeaDialog> createState() => _EditIdeaDialogState();
}

class _EditIdeaDialogState extends State<EditIdeaDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.idea.title);
    _contentController = TextEditingController(text: widget.idea.content);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MindmapViewModel>(
      builder: (context, viewModel, _) => WillPopScope(
        onWillPop: () async {
          viewModel.stopEditing();
          viewModel.deselectIdea();
          return true;
        },
        child: Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
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
                      'Edit Idea',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        viewModel.stopEditing();
                        viewModel.deselectIdea();
                        // Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    if (widget.idea.canEdit(widget.currentUserUuid))
                      ElevatedButton(
                        onPressed: () async {
                          _titleController.text = _titleController.text;
                          _contentController.text = _contentController.text;
                          widget.idea.title = _titleController.text;
                          widget.idea.content = _contentController.text;
                          await viewModel.updateIdea(widget.idea);
                          viewModel.stopEditing();
                          viewModel.deselectIdea();
                          // Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        viewModel.stopEditing();
                        viewModel.deselectIdea();
                        // Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Content'),
                  Tab(text: 'References'),
                  Tab(text: 'Share'),
                  Tab(text: 'More'),
                ],
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Content tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
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
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Enter idea title',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            enabled:
                                widget.idea.canEdit(widget.currentUserUuid),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Content',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _contentController,
                            decoration: InputDecoration(
                              hintText: 'Enter idea details',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            enabled:
                                widget.idea.canEdit(widget.currentUserUuid),
                            maxLines: 6,
                          ),
                          if (widget.idea.referencedTopic.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Referenced Topic',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue[300]!,
                                      ),
                                    ),
                                    child: Text(widget.idea.referencedTopic),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // References tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IDEA REFERENCES SECTION
                          const Text(
                            'Linked Ideas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Existing idea references
                          if (widget.idea.references
                              .where(
                                  (r) => r.referenceType == ReferenceType.idea)
                              .isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Idea References:',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                ...widget.idea.references
                                    .where((r) =>
                                        r.referenceType == ReferenceType.idea)
                                    .map((ref) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.blue[300]!,
                                              ),
                                            ),
                                            child: Text(
                                              ref.text,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        if (widget.idea
                                            .canEdit(widget.currentUserUuid))
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 18),
                                            onPressed: () => setState(() {
                                              widget.idea
                                                  .removeReference(ref.id);
                                            }),
                                            tooltip: 'Remove reference',
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 16),
                              ],
                            ),
                          // Add new idea reference
                          if (widget.idea.canEdit(widget.currentUserUuid))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Add Idea Reference',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search ideas...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: const Icon(Icons.search),
                                  ),
                                  onChanged: (query) async {
                                    await viewModel.getReferenceSuggestions(
                                        query: query);
                                  },
                                ),
                                const SizedBox(height: 8),
                                // Idea suggestions
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: viewModel.suggestions.length,
                                    itemBuilder: (context, index) {
                                      final suggestion =
                                          viewModel.suggestions[index];
                                      return ListTile(
                                        title: Text(suggestion.title),
                                        subtitle: Text(
                                          suggestion.content,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          widget.idea.addReference(
                                            text: suggestion.title,
                                            ideaUuid: suggestion.id,
                                          );
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          // JOURNAL ENTRY REFERENCES SECTION
                          const Text(
                            'Linked Journal Entries',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Existing journal entry references
                          if (widget.idea.references
                              .where((r) =>
                                  r.referenceType == ReferenceType.journalEntry)
                              .isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Journal Entry References:',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                ...widget.idea.references
                                    .where((r) =>
                                        r.referenceType ==
                                        ReferenceType.journalEntry)
                                    .map((ref) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.green[300]!,
                                              ),
                                            ),
                                            child: Text(
                                              ref.text,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        if (widget.idea
                                            .canEdit(widget.currentUserUuid))
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 18),
                                            onPressed: () => setState(() {
                                              widget.idea
                                                  .removeReference(ref.id);
                                            }),
                                            tooltip: 'Remove reference',
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 16),
                              ],
                            ),
                          // Add new journal entry reference
                          if (widget.idea.canEdit(widget.currentUserUuid))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Add Journal Entry Reference',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search journal entries...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: const Icon(Icons.search),
                                  ),
                                  onChanged: (query) async {
                                    await viewModel.getJournalEntrySuggestions(
                                        query: query);
                                  },
                                ),
                                const SizedBox(height: 8),
                                // Journal entry suggestions
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: viewModel
                                        .journalEntrySuggestions.length,
                                    itemBuilder: (context, index) {
                                      final suggestion = viewModel
                                          .journalEntrySuggestions[index];
                                      final displayTitle = suggestion
                                              .title.isNotEmpty
                                          ? suggestion.title
                                          : suggestion.text
                                              .substring(
                                                  0,
                                                  suggestion.text.length > 50
                                                      ? 50
                                                      : suggestion.text.length)
                                              .replaceAll('\n', ' ');
                                      return ListTile(
                                        title: Text(displayTitle),
                                        subtitle: Text(
                                          suggestion.text,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        leading: Icon(Icons.note,
                                            color: Colors.green[600]),
                                        onTap: () {
                                          widget.idea.addJournalEntryReference(
                                            text: displayTitle,
                                            journalEntryUuid: suggestion.id,
                                          );
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    // Share tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.idea.canEdit(widget.currentUserUuid)) ...[
                            const Text(
                              'Visibility Group',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.idea.groupUuid.isEmpty
                                    ? 'No group selected'
                                    : 'Group: ${widget.idea.groupUuid}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Transfer Ownership',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter username to transfer to',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onSubmitted: (username) {
                                // TODO: Implement ownership transfer
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Transferring to $username (not yet implemented)',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: const Text(
                                'You do not have permission to edit this idea.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // More tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('ID', widget.idea.id),
                          _buildInfoRow(
                              'Owner',
                              widget.idea.ownerUuid.isEmpty
                                  ? 'Not assigned'
                                  : widget.idea.ownerUuid),
                          _buildInfoRow('Position',
                              '(${widget.idea.positionX.toStringAsFixed(1)}, ${widget.idea.positionY.toStringAsFixed(1)})'),
                          _buildInfoRow(
                            'References',
                            widget.idea.references.length.toString(),
                          ),
                          const SizedBox(height: 24),
                          if (widget.idea.canEdit(widget.currentUserUuid))
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete Idea'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Idea?'),
                                      content: const Text(
                                        'This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              viewModel.deselectIdea(),
                                          // Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            // Navigator.pop(context);
                                            await viewModel
                                                .deleteIdea(widget.idea.id);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
